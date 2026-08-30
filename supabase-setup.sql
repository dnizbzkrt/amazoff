-- AMAZOFF - Supabase schema
-- Paste this file into Supabase Dashboard > SQL Editor and click "Run".

-- 1) User profile (wallet balance is stored here)
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text,
  wallet_balance numeric not null default 1000,
  created_at timestamp with time zone default now()
);

alter table public.profiles enable row level security;

create policy "Kullanıcı kendi profilini görebilir"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Kullanıcı kendi profilini güncelleyebilir"
  on public.profiles for update
  using (auth.uid() = id);

-- Automatically create a profile when a new user signs up (with 1000 TL balance)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, wallet_balance)
  values (new.id, new.email, 1000);
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 2) Orders
create table if not exists public.orders (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  order_number text not null,
  total_amount numeric not null,
  created_at timestamp with time zone default now()
);

alter table public.orders enable row level security;

create policy "Kullanıcı kendi siparişlerini görebilir"
  on public.orders for select
  using (auth.uid() = user_id);

create policy "Kullanıcı kendi siparişini oluşturabilir"
  on public.orders for insert
  with check (auth.uid() = user_id);

-- 3) Order items
create table if not exists public.order_items (
  id uuid default gen_random_uuid() primary key,
  order_id uuid references public.orders on delete cascade not null,
  product_id integer not null,
  product_name text not null,
  quantity integer not null,
  price numeric not null
);

alter table public.order_items enable row level security;

create policy "Kullanıcı kendi sipariş kalemlerini görebilir"
  on public.order_items for select
  using (
    exists (
      select 1 from public.orders
      where orders.id = order_items.order_id
      and orders.user_id = auth.uid()
    )
  );

create policy "Kullanıcı kendi sipariş kalemini ekleyebilir"
  on public.order_items for insert
  with check (
    exists (
      select 1 from public.orders
      where orders.id = order_items.order_id
      and orders.user_id = auth.uid()
    )
  );

-- Note: Products are not stored in the database in this MVP — they live
-- statically in lib/products.ts (matching the doc's "Phase 3 - start with
-- JSON" recommendation). If you later want to move products into Supabase
-- too, you can add a separate "products" table.

-- =========================================================================
-- UPDATE — "My Orders" + public "All Orders" feed with name privacy toggle
-- If you already ran the script above in an earlier setup, you only need
-- to run the block below (it's safe to run on its own).
-- =========================================================================

-- Each user can set a display name and choose whether it's shown publicly.
-- If is_public is false (the default), the feed shows "Anonim Kullanıcı"
-- instead of their name.
alter table public.profiles
  add column if not exists display_name text,
  add column if not exists is_public boolean not null default false;

-- Public order feed: returns every order with either the buyer's display
-- name (if they opted in) or "Anonim Kullanıcı". This function is
-- SECURITY DEFINER so it can read across all users' orders/profiles
-- without loosening the table-level RLS policies above — it only ever
-- returns the safe, already-privacy-filtered columns below (never wallet
-- balance, email, or user id).
create or replace function public.get_order_feed()
returns table (
  order_id uuid,
  order_number text,
  total_amount numeric,
  created_at timestamptz,
  buyer_name text
)
language sql
security definer
set search_path = public
as $$
  select
    o.id,
    o.order_number,
    o.total_amount,
    o.created_at,
    case
      when p.is_public and coalesce(p.display_name, '') <> '' then p.display_name
      else 'Anonim Kullanıcı'
    end as buyer_name
  from public.orders o
  join public.profiles p on p.id = o.user_id
  order by o.created_at desc;
$$;

grant execute on function public.get_order_feed() to authenticated;

-- Returns the line items for a single order (used by both "My Orders" and
-- the public feed detail view). Also SECURITY DEFINER for the same reason.
create or replace function public.get_order_feed_items(p_order_id uuid)
returns table (
  product_name text,
  quantity integer,
  price numeric
)
language sql
security definer
set search_path = public
as $$
  select product_name, quantity, price
  from public.order_items
  where order_id = p_order_id;
$$;

grant execute on function public.get_order_feed_items(uuid) to authenticated;

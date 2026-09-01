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

drop policy if exists "Kullanıcı kendi profilini görebilir" on public.profiles;
create policy "Kullanıcı kendi profilini görebilir"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "Kullanıcı kendi profilini güncelleyebilir" on public.profiles;
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

drop policy if exists "Kullanıcı kendi siparişlerini görebilir" on public.orders;
create policy "Kullanıcı kendi siparişlerini görebilir"
  on public.orders for select
  using (auth.uid() = user_id);

drop policy if exists "Kullanıcı kendi siparişini oluşturabilir" on public.orders;
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

drop policy if exists "Kullanıcı kendi sipariş kalemlerini görebilir" on public.order_items;
create policy "Kullanıcı kendi sipariş kalemlerini görebilir"
  on public.order_items for select
  using (
    exists (
      select 1 from public.orders
      where orders.id = order_items.order_id
      and orders.user_id = auth.uid()
    )
  );

drop policy if exists "Kullanıcı kendi sipariş kalemini ekleyebilir" on public.order_items;
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

-- =========================================================================
-- UPDATE 2 — Shared shopping cart (moved from browser localStorage to
-- Supabase so the same cart follows a user across devices, and so friends
-- using the site each get their own real, database-backed cart).
-- Safe to run again — uses IF NOT EXISTS / OR REPLACE everywhere.
-- =========================================================================

create table if not exists public.cart_items (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  product_id integer not null,
  quantity integer not null default 1,
  updated_at timestamptz not null default now(),
  unique (user_id, product_id)
);

alter table public.cart_items enable row level security;

drop policy if exists "Kullanıcı kendi sepetini görebilir" on public.cart_items;
create policy "Kullanıcı kendi sepetini görebilir"
  on public.cart_items for select
  using (auth.uid() = user_id);

drop policy if exists "Kullanıcı kendi sepetine ürün ekleyebilir" on public.cart_items;
create policy "Kullanıcı kendi sepetine ürün ekleyebilir"
  on public.cart_items for insert
  with check (auth.uid() = user_id);

drop policy if exists "Kullanıcı kendi sepetini güncelleyebilir" on public.cart_items;
create policy "Kullanıcı kendi sepetini güncelleyebilir"
  on public.cart_items for update
  using (auth.uid() = user_id);

drop policy if exists "Kullanıcı kendi sepetinden ürün silebilir" on public.cart_items;
create policy "Kullanıcı kendi sepetinden ürün silebilir"
  on public.cart_items for delete
  using (auth.uid() = user_id);

-- =========================================================================
-- UPDATE 3 — Starting wallet balance raised from 1.000 TL to 10.000 TL,
-- and two new "leaderboard" style aggregate functions for the shareable
-- stats page (En Çok Harcayanlar / Popüler Ürünler). Safe to run again.
-- =========================================================================

alter table public.profiles alter column wallet_balance set default 10000;

-- Re-create the signup trigger function with the new starting balance.
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, wallet_balance)
  values (new.id, new.email, 10000);
  return new;
end;
$$ language plpgsql security definer;

-- Leaderboard: how much each user has spent in total, safe fields only
-- (same anonymity rule as the order feed: shows display_name only if the
-- user opted in via Ayarlar, otherwise "Anonim Kullanıcı").
create or replace function public.get_leaderboard()
returns table (
  buyer_name text,
  total_spent numeric,
  order_count bigint
)
language sql
security definer
set search_path = public
as $$
  select
    case
      when p.is_public and coalesce(p.display_name, '') <> '' then p.display_name
      else 'Anonim Kullanıcı'
    end as buyer_name,
    sum(o.total_amount) as total_spent,
    count(o.id) as order_count
  from public.orders o
  join public.profiles p on p.id = o.user_id
  group by o.user_id, p.is_public, p.display_name
  order by total_spent desc
  limit 20;
$$;

grant execute on function public.get_leaderboard() to authenticated;

-- Most-purchased products across all users (product data itself lives in
-- products.js, this just returns product_id + total quantity sold so the
-- frontend can look up the name/image/price from PRODUCTS).
create or replace function public.get_popular_products()
returns table (
  product_id integer,
  product_name text,
  total_quantity bigint
)
language sql
security definer
set search_path = public
as $$
  select product_id, product_name, sum(quantity) as total_quantity
  from public.order_items
  group by product_id, product_name
  order by total_quantity desc
  limit 12;
$$;

grant execute on function public.get_popular_products() to authenticated;

-- =========================================================================
-- UPDATE 4 — Language preference (TR/EN toggle). Stored in Supabase, not
-- localStorage, so it's consistent with the rest of the site's data model.
-- Safe to run again.
-- =========================================================================

alter table public.profiles
  add column if not exists language text not null default 'tr';

-- =========================================================================
-- UPDATE 5 — Security hardening + moving the product catalog into the
-- database. Safe to run again.
--
-- What changes and why:
--   1. Products now live in a real `products` table instead of a static
--      JS file, so prices/stock can't be edited by anyone in the browser.
--   2. Checkout is now computed entirely server-side: the frontend only
--      ever sends {product_id, quantity} — the function below looks up
--      the real price from the database and ignores anything the client
--      might claim the price to be.
--   3. Stock is decremented atomically inside the same function, using
--      row locks, so two people buying the last unit at the same time
--      can't both succeed (one of them will correctly get "insufficient
--      stock").
--   4. Wallet balance can no longer be updated directly by a logged-in
--      user from the browser — only this SECURITY DEFINER function (and
--      the signup trigger) can change it. Direct inserts into `orders` /
--      `order_items` from the client are removed for the same reason —
--      all order creation now goes through create_order().
-- =========================================================================

-- ---- 5a. Products table ----------------------------------------------

create table if not exists public.products (
  id integer primary key,
  name text not null,
  name_en text,
  description text,
  description_en text,
  category text not null,
  category_en text,
  price numeric not null check (price >= 0),
  stock integer not null default 0 check (stock >= 0),
  image text
);

alter table public.products enable row level security;

drop policy if exists "Ürünleri herkes görebilir" on public.products;
create policy "Ürünleri herkes görebilir"
  on public.products for select
  using (true);

-- No insert/update/delete policy is defined on purpose: with RLS enabled
-- and no such policy, regular users (the "authenticated" role, which is
-- all the anon/publishable key can ever act as) cannot modify products at
-- all — only from the Supabase SQL Editor / Table Editor as the project
-- owner.

-- ---- 5b. Security hardening on profiles/orders/order_items ------------

-- Users may no longer UPDATE their profile row directly (this used to let
-- anyone set their own wallet_balance to anything they wanted from the
-- browser console). Only a few harmless columns remain client-editable;
-- wallet_balance and email can only change via SECURITY DEFINER functions.
revoke update on public.profiles from authenticated;
grant update (display_name, is_public, language) on public.profiles to authenticated;

-- Orders/order_items can no longer be inserted directly from the client
-- (that used to let anyone insert an order with a made-up total_amount).
-- All order creation now goes through create_order() below, which is
-- SECURITY DEFINER and bypasses RLS safely because it computes and
-- validates everything itself.
drop policy if exists "Kullanıcı kendi siparişini oluşturabilir" on public.orders;
drop policy if exists "Kullanıcı kendi sipariş kalemini ekleyebilir" on public.order_items;

-- ---- 5c. Server-side checkout ------------------------------------------

create or replace function public.create_order(p_items jsonb)
returns table (
  order_id uuid,
  order_number text,
  total_amount numeric,
  new_balance numeric
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_total numeric := 0;
  v_balance numeric;
  v_order_id uuid;
  v_order_number text;
  v_item jsonb;
  v_product_id integer;
  v_qty integer;
  v_price numeric;
  v_name text;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'Cart is empty';
  end if;

  v_order_number := 'ORDER-' || floor(1000 + random() * 9000)::int;

  -- Pass 1: lock the product rows and compute the real total from the
  -- database's own prices — the client's opinion of the price is never
  -- consulted.
  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_product_id := (v_item->>'product_id')::integer;
    v_qty := (v_item->>'quantity')::integer;

    if v_qty is null or v_qty <= 0 then
      raise exception 'Invalid quantity for product %', v_product_id;
    end if;

    select price into v_price from public.products where id = v_product_id for update;
    if not found then
      raise exception 'Product % not found', v_product_id;
    end if;

    v_total := v_total + (v_price * v_qty);
  end loop;

  -- Lock the buyer's wallet row and check funds.
  select wallet_balance into v_balance from public.profiles where id = v_user_id for update;
  if v_balance is null or v_balance < v_total then
    raise exception 'Insufficient balance';
  end if;

  insert into public.orders (user_id, order_number, total_amount)
  values (v_user_id, v_order_number, v_total)
  returning id into v_order_id;

  -- Pass 2: atomically decrement stock (fails per-item if not enough is
  -- left — this is what prevents stock from ever going negative even if
  -- two people check out the last unit at the same moment) and record the
  -- line items.
  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_product_id := (v_item->>'product_id')::integer;
    v_qty := (v_item->>'quantity')::integer;

    update public.products
      set stock = stock - v_qty
      where id = v_product_id and stock >= v_qty
      returning name, price into v_name, v_price;

    if not found then
      raise exception 'Insufficient stock for product %', v_product_id;
    end if;

    insert into public.order_items (order_id, product_id, product_name, quantity, price)
    values (v_order_id, v_product_id, v_name, v_qty, v_price);
  end loop;

  update public.profiles set wallet_balance = wallet_balance - v_total where id = v_user_id;

  delete from public.cart_items where user_id = v_user_id;

  return query select v_order_id, v_order_number, v_total, (v_balance - v_total);
end;
$$;

grant execute on function public.create_order(jsonb) to authenticated;

-- =========================================================================
-- UPDATE 6 — Seed the products table with the 100 demo products (14
-- categories, TR + EN name/description, category-relevant stock photos).
-- Safe to run again: uses "on conflict (id) do update", and deliberately
-- does NOT overwrite `stock` on conflict, so re-running this after real
-- demo purchases have happened won't reset anyone's stock back to full.
-- =========================================================================

insert into public.products (id, name, name_en, description, description_en, category, category_en, price, stock, image) values
  (1, 'Yazlık Midi Elbise', 'Summer Midi Dress', 'Dolapta 3 tane var ama bu farklı diyorsun.', 'You own 3 already but swear this one''s different.', 'Kadın Giyim', 'Women''s Clothing', 459, 11, 'https://loremflickr.com/600/600/women,fashion?lock=1'),
  (2, 'Yüksek Bel Kot Pantolon', 'High-Waist Jeans', 'Instagram''da gördüğün pozu asla veremeyeceksin ama dene.', 'You''ll never nail that Instagram pose, but go ahead and try.', 'Kadın Giyim', 'Women''s Clothing', 549, 12, 'https://loremflickr.com/600/600/women,fashion?lock=2'),
  (3, 'Örme Triko Kazak', 'Knit Sweater', 'Kışın 2 kere giyip ''kalıcı parça'' diyeceğin ürün.', 'The ''timeless piece'' you''ll wear twice all winter.', 'Kadın Giyim', 'Women''s Clothing', 389, 13, 'https://loremflickr.com/600/600/women,fashion?lock=3'),
  (4, 'Blazer Ceket', 'Blazer Jacket', 'Toplantıda ciddi görünmeni sağlar, toplantı hâlâ gereksizdir.', 'Makes you look serious in meetings the meeting itself still didn''t need.', 'Kadın Giyim', 'Women''s Clothing', 699, 14, 'https://loremflickr.com/600/600/women,fashion?lock=4'),
  (5, 'Saten Gömlek', 'Satin Blouse', 'Ütü istemez demiyoruz, sadece hayal kuruyoruz.', 'We''re not saying it''s iron-free, we''re just dreaming.', 'Kadın Giyim', 'Women''s Clothing', 329, 15, 'https://loremflickr.com/600/600/women,fashion?lock=5'),
  (6, 'Pileli Uzun Etek', 'Pleated Maxi Skirt', 'Rüzgarda uçuşurken çekilen 1 fotoğraf için yeterli.', 'Good for exactly one windswept photo.', 'Kadın Giyim', 'Women''s Clothing', 419, 16, 'https://loremflickr.com/600/600/women,fashion?lock=6'),
  (7, 'Crop Tişört', 'Crop Top', 'Göbek deme, ''midriff reveal'' de.', 'Don''t call it a belly show, call it a ''midriff reveal''.', 'Kadın Giyim', 'Women''s Clothing', 199, 17, 'https://loremflickr.com/600/600/women,fashion?lock=7'),
  (8, 'Triko Hırka', 'Knit Cardigan', 'Ofiste hem soğuk hem sıcak olduğunda tek çözüm.', 'The only fix when the office is somehow both too cold and too hot.', 'Kadın Giyim', 'Women''s Clothing', 349, 18, 'https://loremflickr.com/600/600/women,fashion?lock=8'),
  (9, 'Slim Fit Gömlek', 'Slim Fit Shirt', 'Aynı gömlekten 4 renk aldın, hepsi dolapta duruyor.', 'You bought it in 4 colors, all four still hang untouched.', 'Erkek Giyim', 'Men''s Clothing', 379, 19, 'https://loremflickr.com/600/600/men,fashion?lock=9'),
  (10, 'Kargo Pantolon', 'Cargo Pants', 'O kadar cep var ki hiçbirini kullanmıyorsun.', 'So many pockets, you use exactly none of them.', 'Erkek Giyim', 'Men''s Clothing', 459, 20, 'https://loremflickr.com/600/600/men,fashion?lock=10'),
  (11, 'Basic Tişört 3''lü Paket', 'Basic T-Shirt 3-Pack', 'Beyaz tişört her zaman lazım, üçü birden değil ama neyse.', 'You always need a white tee, just not three at once.', 'Erkek Giyim', 'Men''s Clothing', 299, 21, 'https://loremflickr.com/600/600/men,fashion?lock=11'),
  (12, 'Deri Ceket', 'Leather Jacket', 'Motosikletin yok ama ceket duruyor.', 'You don''t own a motorcycle, but the jacket''s ready.', 'Erkek Giyim', 'Men''s Clothing', 1299, 22, 'https://loremflickr.com/600/600/men,fashion?lock=12'),
  (13, 'Slim Fit Kot Pantolon', 'Slim Fit Jeans', 'Instagram algoritması yüzünden aldın, kabul et.', 'Admit it, the algorithm made you buy these.', 'Erkek Giyim', 'Men''s Clothing', 519, 23, 'https://loremflickr.com/600/600/men,fashion?lock=13'),
  (14, 'Sweatshirt Oversize', 'Oversized Sweatshirt', 'Rahat diye aldın, artık tek giydiğin bu.', 'Bought for comfort, now it''s the only thing you wear.', 'Erkek Giyim', 'Men''s Clothing', 429, 24, 'https://loremflickr.com/600/600/men,fashion?lock=14'),
  (15, 'Klasik Blazer', 'Classic Blazer', 'Düğün davetiyesi geldiğinde işine yarayacak, belki.', 'Will come in handy for a wedding invite, maybe.', 'Erkek Giyim', 'Men''s Clothing', 799, 10, 'https://loremflickr.com/600/600/men,fashion?lock=15'),
  (16, 'Chino Pantolon', 'Chino Pants', 'Ne spor ne resmi, tam ortada bir kararsızlık.', 'Not sporty, not formal — indecision made fabric.', 'Erkek Giyim', 'Men''s Clothing', 449, 11, 'https://loremflickr.com/600/600/men,fashion?lock=16'),
  (17, 'Beyaz Spor Ayakkabı', 'White Sneakers', 'Bir hafta beyaz kalır, sonra hayat başlar.', 'Stay white for a week, then life happens.', 'Ayakkabı', 'Shoes', 899, 12, 'https://loremflickr.com/600/600/shoes?lock=17'),
  (18, 'Topuklu Ayakkabı', 'Heels', 'Kutudan çıkıp 2 saat giyilip tekrar kutuya girer.', 'Out of the box for two hours, back in the box forever.', 'Ayakkabı', 'Shoes', 649, 13, 'https://loremflickr.com/600/600/shoes?lock=18'),
  (19, 'Klasik Deri Ayakkabı', 'Classic Leather Shoes', 'Yılda bir düğünde giyilir, geri kalanı dolapta bekler.', 'Worn to one wedding a year, waits in the closet otherwise.', 'Ayakkabı', 'Shoes', 999, 14, 'https://loremflickr.com/600/600/shoes?lock=19'),
  (20, 'Sneaker Bot', 'Sneaker Boots', 'Hem bot hem spor, kimliğini bulamamış bir ürün.', 'Half boot, half sneaker, having an identity crisis.', 'Ayakkabı', 'Shoes', 1099, 15, 'https://loremflickr.com/600/600/shoes?lock=20'),
  (21, 'Sandalet', 'Sandals', 'Yazın 3 ay, kışın hiç giyilmez ama alınır.', 'Worn 3 summer months, bought regardless of the other nine.', 'Ayakkabı', 'Shoes', 379, 16, 'https://loremflickr.com/600/600/shoes?lock=21'),
  (22, 'Koşu Ayakkabısı', 'Running Shoes', 'Koşmuyorsun ama ''koşabilirim'' rahatlığı var ya.', 'You don''t run, but ''I technically could'' is a nice feeling.', 'Ayakkabı', 'Shoes', 1199, 17, 'https://loremflickr.com/600/600/shoes?lock=22'),
  (23, 'Terlik Set', 'Slipper Set', 'Evde bile stil sahibi olmak istiyorsan.', 'For when even indoors needs to be stylish.', 'Ayakkabı', 'Shoes', 149, 18, 'https://loremflickr.com/600/600/shoes?lock=23'),
  (24, 'Deri Sırt Çantası', 'Leather Backpack', 'Laptop taşımak için aldın, süt almak için kullanıyorsun.', 'Bought for your laptop, used for grocery runs.', 'Çanta & Aksesuar', 'Bags & Accessories', 799, 19, 'https://loremflickr.com/600/600/bag,accessory?lock=24'),
  (25, 'Kadın El Çantası', 'Women''s Handbag', 'İçine ne koyduğunu asla hatırlamıyorsun.', 'You never remember what''s actually inside.', 'Çanta & Aksesuar', 'Bags & Accessories', 649, 20, 'https://loremflickr.com/600/600/bag,accessory?lock=25'),
  (26, 'Güneş Gözlüğü', 'Sunglasses', 'Güneş yokken de takıyorsun, kabul et bu bir imaj meselesi.', 'Worn even without sun, admit it''s purely aesthetic.', 'Çanta & Aksesuar', 'Bags & Accessories', 349, 21, 'https://loremflickr.com/600/600/bag,accessory?lock=26'),
  (27, 'Kemer', 'Belt', 'Pantolon düşmüyor ama kemer duruyor, denge böyle.', 'Pants don''t need it, belt stays anyway — balance.', 'Çanta & Aksesuar', 'Bags & Accessories', 199, 22, 'https://loremflickr.com/600/600/bag,accessory?lock=27'),
  (28, 'Bel Çantası 2000''ler Esintili', 'Y2K Belt Bag', 'Nostalji mi moda mı karar veremedik, ikisi de olsun.', 'Nostalgia or fashion? Let''s just say both.', 'Çanta & Aksesuar', 'Bags & Accessories', 259, 23, 'https://loremflickr.com/600/600/bag,accessory?lock=28'),
  (29, 'Cüzdan', 'Wallet', 'Nakit taşımıyorsun ama cüzdan lazım, mantık böyle işliyor.', 'You carry no cash, yet somehow still need a wallet.', 'Çanta & Aksesuar', 'Bags & Accessories', 289, 24, 'https://loremflickr.com/600/600/bag,accessory?lock=29'),
  (30, 'Şapka', 'Hat', 'Kötü saç günü kurtarıcısı, her gün kötü saç günü gibi kullanılıyor.', 'Saves bad hair days — worn as if every day is one.', 'Çanta & Aksesuar', 'Bags & Accessories', 179, 10, 'https://loremflickr.com/600/600/bag,accessory?lock=30'),
  (31, 'Nemlendirici Yüz Kremi', 'Moisturizing Face Cream', 'Cilt bakımı rutini 1. adım, rutin hiç bitmiyor.', 'Step 1 of a skincare routine that never actually ends.', 'Kozmetik & Kişisel Bakım', 'Cosmetics & Personal Care', 179, 11, 'https://loremflickr.com/600/600/cosmetics,beauty?lock=31'),
  (32, 'Dudak Parlatıcısı', 'Lip Gloss', 'Bir tane yeter derken 6. tanesini alıyorsun.', 'You said one was enough, this is number six.', 'Kozmetik & Kişisel Bakım', 'Cosmetics & Personal Care', 129, 12, 'https://loremflickr.com/600/600/cosmetics,beauty?lock=32'),
  (33, 'Mat Ruj - Kiremit', 'Matte Lipstick - Terracotta', 'Video call''da güzel görünmek için yeterli sebep.', 'Reason enough to look good on a video call.', 'Kozmetik & Kişisel Bakım', 'Cosmetics & Personal Care', 149, 13, 'https://loremflickr.com/600/600/cosmetics,beauty?lock=33'),
  (34, 'Parfüm 50ml', 'Perfume 50ml', 'Koku hafızası güçlüdür derler, cüzdan hafızası daha güçlü olsun.', 'Scent memory is strong, wallet memory should be stronger.', 'Kozmetik & Kişisel Bakım', 'Cosmetics & Personal Care', 899, 14, 'https://loremflickr.com/600/600/cosmetics,beauty?lock=34'),
  (35, 'Cilt Bakım Seti', 'Skincare Set', '5 adımlı rutin, gerçekte 2 adımda pes ediyorsun.', '5-step routine, real life gives up at step 2.', 'Kozmetik & Kişisel Bakım', 'Cosmetics & Personal Care', 549, 15, 'https://loremflickr.com/600/600/cosmetics,beauty?lock=35'),
  (36, 'Saç Bakım Yağı', 'Hair Care Oil', 'Saçların ipeksi olacak, en azından reklamda öyle.', 'Silky hair guaranteed, at least in the ad.', 'Kozmetik & Kişisel Bakım', 'Cosmetics & Personal Care', 199, 16, 'https://loremflickr.com/600/600/cosmetics,beauty?lock=36'),
  (37, 'Güneş Kremi SPF50', 'Sunscreen SPF50', 'Bir kere sürüp şişeyi bir yıl saklayan tipsen bu tam sana göre.', 'For the type who applies once and keeps the bottle a year.', 'Kozmetik & Kişisel Bakım', 'Cosmetics & Personal Care', 249, 17, 'https://loremflickr.com/600/600/cosmetics,beauty?lock=37'),
  (38, 'Makyaj Fırça Seti', 'Makeup Brush Set', 'Kaç tanesini kullanıyorsun? İkisi. Kaç tane aldın? On iki.', 'How many do you use? Two. How many did you buy? Twelve.', 'Kozmetik & Kişisel Bakım', 'Cosmetics & Personal Care', 379, 18, 'https://loremflickr.com/600/600/cosmetics,beauty?lock=38'),
  (39, 'Kablosuz Kulaklık', 'Wireless Earbuds', 'Sessizliği satın alıyorsun, aslında.', 'You''re basically buying silence.', 'Elektronik', 'Electronics', 1299, 19, 'https://loremflickr.com/600/600/electronics,gadget?lock=39'),
  (40, 'Akıllı Bileklik', 'Smart Band', '10.000 adım hedefine hiç ulaşmadın ama takip ediyorsun.', 'Never hit 10,000 steps, but tracking it anyway.', 'Elektronik', 'Electronics', 899, 20, 'https://loremflickr.com/600/600/electronics,gadget?lock=40'),
  (41, 'Taşınabilir Şarj Cihazı', 'Portable Power Bank', 'Çantada duruyor, tam lazım olduğunda şarjı bitik çıkıyor.', 'Sits in your bag, dead exactly when you need it.', 'Elektronik', 'Electronics', 349, 21, 'https://loremflickr.com/600/600/electronics,gadget?lock=41'),
  (42, 'Bluetooth Hoparlör', 'Bluetooth Speaker', 'Duşta konser veriyorsun, komşular minnettar değil.', 'Shower concerts nightly, neighbors not impressed.', 'Elektronik', 'Electronics', 749, 22, 'https://loremflickr.com/600/600/electronics,gadget?lock=42'),
  (43, 'Mekanik Klavye', 'Mechanical Keyboard', 'Klik sesi mesai arkadaşlarının en sevdiği şey, tabii ki değil.', 'Your coworkers definitely don''t love the clicking.', 'Elektronik', 'Electronics', 1599, 23, 'https://loremflickr.com/600/600/electronics,gadget?lock=43'),
  (44, 'Kablosuz Mouse', 'Wireless Mouse', 'Kablosuz özgürlük, pil bitene kadar.', 'Freedom from cables, until the battery dies.', 'Elektronik', 'Electronics', 399, 24, 'https://loremflickr.com/600/600/electronics,gadget?lock=44'),
  (45, 'Telefon Kılıfı', 'Phone Case', 'Telefonu düşürmene neden olan asıl şey bu kılıfın kalınlığı.', 'This case''s bulk is exactly why you keep dropping the phone.', 'Elektronik', 'Electronics', 129, 10, 'https://loremflickr.com/600/600/electronics,gadget?lock=45'),
  (46, 'USB-C Çoklu Adaptör', 'USB-C Multi Adapter', 'Kaç tane girişe ihtiyacın var ki, hepsine.', 'How many ports do you need? All of them, obviously.', 'Elektronik', 'Electronics', 449, 11, 'https://loremflickr.com/600/600/electronics,gadget?lock=46'),
  (47, 'Aromaterapi Mum Seti', 'Aromatherapy Candle Set', 'Ev spa''ya dönüşüyor, 20 dakikalığına.', 'Turns your home into a spa, for 20 minutes.', 'Ev & Yaşam', 'Home & Living', 279, 12, 'https://loremflickr.com/600/600/home,interior?lock=47'),
  (48, 'Dekoratif Yastık Kılıfı', 'Decorative Pillow Cover', 'Kanepede oturmayı yasaklayan estetik obje.', 'The aesthetic object that bans actually sitting on the couch.', 'Ev & Yaşam', 'Home & Living', 199, 13, 'https://loremflickr.com/600/600/home,interior?lock=48'),
  (49, 'Mutfak Bıçak Seti', 'Kitchen Knife Set', 'Şef gibi doğruyorsun, şef gibi değil.', 'You chop like a chef. You do not chop like a chef.', 'Ev & Yaşam', 'Home & Living', 599, 14, 'https://loremflickr.com/600/600/home,interior?lock=49'),
  (50, 'Battaniye Peluş', 'Plush Blanket', 'Kışın tek arkadaşın, yazın dolapta unutulan.', 'Your only friend in winter, forgotten in a drawer come summer.', 'Ev & Yaşam', 'Home & Living', 349, 15, 'https://loremflickr.com/600/600/home,interior?lock=50'),
  (51, 'Duvar Saati Minimalist', 'Minimalist Wall Clock', 'Telefon varken saate bakan tek insansın.', 'The only person still checking a clock when phones exist.', 'Ev & Yaşam', 'Home & Living', 429, 16, 'https://loremflickr.com/600/600/home,interior?lock=51'),
  (52, 'Bitki Saksısı Seti', 'Plant Pot Set', '3 bitki aldın, 2''si hayatta, biri ''dinleniyor''.', 'Bought 3 plants, 2 survived, one is ''resting''.', 'Ev & Yaşam', 'Home & Living', 259, 17, 'https://loremflickr.com/600/600/home,interior?lock=52'),
  (53, 'Difüzör Set', 'Diffuser Set', 'Ev kokusu senin kişiliğin oldu artık.', 'Your home scent has basically become your personality.', 'Ev & Yaşam', 'Home & Living', 329, 18, 'https://loremflickr.com/600/600/home,interior?lock=53'),
  (54, 'Organizasyon Kutusu Seti', 'Storage Box Set', 'Düzenli görünmek, düzenli olmaktan daha kolay.', 'Looking organized is easier than being organized.', 'Ev & Yaşam', 'Home & Living', 379, 19, 'https://loremflickr.com/600/600/home,interior?lock=54'),
  (55, 'Yoga Matı', 'Yoga Mat', 'Bir kere yoga yaptın, mat artık dekor oldu.', 'Did yoga once, the mat is now home decor.', 'Spor & Outdoor', 'Sports & Outdoor', 349, 20, 'https://loremflickr.com/600/600/sports,fitness?lock=55'),
  (56, 'Fitness Eldiveni', 'Fitness Gloves', 'Spor salonuna gitmiyorsun ama eldiven hazır.', 'You don''t go to the gym, but the gloves are ready.', 'Spor & Outdoor', 'Sports & Outdoor', 149, 21, 'https://loremflickr.com/600/600/sports,fitness?lock=56'),
  (57, 'Kamp Çadırı 2 Kişilik', '2-Person Camping Tent', 'Bir kez kamp yaptın, çadır balkonda kaldı.', 'Camped once, tent''s been on the balcony since.', 'Spor & Outdoor', 'Sports & Outdoor', 1899, 22, 'https://loremflickr.com/600/600/sports,fitness?lock=57'),
  (58, 'Termos 1L', 'Thermos 1L', 'Suyu sıcak tutuyor, motivasyonunu tutmuyor.', 'Keeps water hot, doesn''t keep your motivation warm.', 'Spor & Outdoor', 'Sports & Outdoor', 249, 23, 'https://loremflickr.com/600/600/sports,fitness?lock=58'),
  (59, 'Spor Çantası', 'Gym Bag', 'Spor kıyafetleri içinde 3 ay değişmeden duruyor.', 'Same gym clothes inside, unchanged for 3 months.', 'Spor & Outdoor', 'Sports & Outdoor', 299, 24, 'https://loremflickr.com/600/600/sports,fitness?lock=59'),
  (60, 'Bisiklet Kilidi', 'Bike Lock', 'Bisiklet çalınmasın diye aldın, bisiklete binmiyorsun ki.', 'Bought to prevent theft of a bike you never ride.', 'Spor & Outdoor', 'Sports & Outdoor', 199, 10, 'https://loremflickr.com/600/600/sports,fitness?lock=60'),
  (61, 'Direnç Bandı Seti', 'Resistance Band Set', 'Evde spor yapacaktın, bant hâlâ ambalajında.', 'Home workouts were the plan, still in the packaging.', 'Spor & Outdoor', 'Sports & Outdoor', 179, 11, 'https://loremflickr.com/600/600/sports,fitness?lock=61'),
  (62, 'Bebek Battaniyesi', 'Baby Blanket', 'Bebekten çok sen üşüyorsun galiba.', 'Pretty sure you''re the cold one, not the baby.', 'Anne & Bebek', 'Mom & Baby', 299, 12, 'https://loremflickr.com/600/600/baby,infant?lock=62'),
  (63, 'Emzik Seti', 'Pacifier Set', 'Bebeğin en sevdiği aksesuar, senin en çok aradığın eşya.', 'Baby''s favorite accessory, your most-searched-for item.', 'Anne & Bebek', 'Mom & Baby', 129, 13, 'https://loremflickr.com/600/600/baby,infant?lock=63'),
  (64, 'Bebek Bakım Seti', 'Baby Care Set', 'Kutuyu açtın, hepsini kullanmadın, olsun.', 'Opened the box, didn''t use everything, that''s fine.', 'Anne & Bebek', 'Mom & Baby', 449, 14, 'https://loremflickr.com/600/600/baby,infant?lock=64'),
  (65, 'Mama Sandalyesi', 'High Chair', 'Bebek 10 dakika oturuyor, sandalye ömür boyu duruyor.', 'Baby sits for 10 minutes, chair stays for a lifetime.', 'Anne & Bebek', 'Mom & Baby', 1599, 15, 'https://loremflickr.com/600/600/baby,infant?lock=65'),
  (66, 'Bebek Oyun Halısı', 'Baby Play Mat', 'Bebekten çok sen yatıyorsun üzerinde.', 'You lie on it more than the baby does.', 'Anne & Bebek', 'Mom & Baby', 549, 16, 'https://loremflickr.com/600/600/baby,infant?lock=66'),
  (67, 'Biberon Seti', 'Baby Bottle Set', 'Kaç biberon lazım? Bilmiyoruz, hepsini alalım.', 'How many bottles are needed? Unclear, buy them all.', 'Anne & Bebek', 'Mom & Baby', 249, 17, 'https://loremflickr.com/600/600/baby,infant?lock=67'),
  (68, 'Bebek Taşıma Çantası', 'Baby Diaper Bag', 'İçinde bebek eşyası mı taşınıyor yoksa senin tüm hayatın mı belli değil.', 'Unclear if it holds baby gear or your entire life.', 'Anne & Bebek', 'Mom & Baby', 399, 18, 'https://loremflickr.com/600/600/baby,infant?lock=68'),
  (69, 'Kedi Tırmalama Tahtası', 'Cat Scratching Post', 'Koltuğu tırmalamasın diye aldın, koltuğu hâlâ tırmalıyor.', 'Bought to save the couch, the couch is still not saved.', 'Pet Shop', 'Pet Shop', 399, 19, 'https://loremflickr.com/600/600/pet,animal?lock=69'),
  (70, 'Köpek Maması 3kg', 'Dog Food 3kg', 'Dört ayaklı aile üyesi senden iyi besleniyor.', 'The four-legged family member eats better than you do.', 'Pet Shop', 'Pet Shop', 349, 20, 'https://loremflickr.com/600/600/pet,animal?lock=70'),
  (71, 'Evcil Hayvan Taşıma Çantası', 'Pet Carrier Bag', 'Veterinere giderken kullanılan tek eşya.', 'The one item that only ever leaves the house for the vet.', 'Pet Shop', 'Pet Shop', 449, 21, 'https://loremflickr.com/600/600/pet,animal?lock=71'),
  (72, 'Kedi Kumu 10L', 'Cat Litter 10L', 'Koku yok diyor reklam, koku her zaman var.', 'The ad says odorless, the odor always disagrees.', 'Pet Shop', 'Pet Shop', 199, 22, 'https://loremflickr.com/600/600/pet,animal?lock=72'),
  (73, 'Köpek Tasması', 'Dog Leash', 'Şık görünüyor, köpeğin umurunda değil.', 'Looks stylish, the dog couldn''t care less.', 'Pet Shop', 'Pet Shop', 179, 23, 'https://loremflickr.com/600/600/pet,animal?lock=73'),
  (74, 'Kedi Oyuncak Seti', 'Cat Toy Set', 'Oyuncaklar dururken kutunun kendisiyle oynuyor.', 'Toys sit unused, the box itself is the real winner.', 'Pet Shop', 'Pet Shop', 149, 24, 'https://loremflickr.com/600/600/pet,animal?lock=74'),
  (75, 'A5 Defter Set', 'A5 Notebook Set', 'Günlük tutacaktın, 3 sayfa yazıp bıraktın.', 'Was going to journal daily, stopped after 3 pages.', 'Kırtasiye & Ofis', 'Stationery & Office', 149, 10, 'https://loremflickr.com/600/600/stationery,office?lock=75'),
  (76, 'Gel Kalem 12''li Set', 'Gel Pen 12-Pack', '12 renk aldın, sadece siyahı kullanıyorsun.', 'Bought 12 colors, only ever use black.', 'Kırtasiye & Ofis', 'Stationery & Office', 89, 11, 'https://loremflickr.com/600/600/stationery,office?lock=76'),
  (77, 'Masaüstü Organizer', 'Desk Organizer', 'Düzenli masa, düzensiz hayat.', 'Tidy desk, chaotic life.', 'Kırtasiye & Ofis', 'Stationery & Office', 229, 12, 'https://loremflickr.com/600/600/stationery,office?lock=77'),
  (78, 'Planlayıcı Ajanda', 'Planner', 'Ocak ayı dolu, şubat boş kaldı.', 'January''s full, February''s suspiciously empty.', 'Kırtasiye & Ofis', 'Stationery & Office', 199, 13, 'https://loremflickr.com/600/600/stationery,office?lock=78'),
  (79, 'Sticky Not Seti', 'Sticky Note Set', 'Ofis masan artık sanat enstalasyonu gibi.', 'Your desk is basically an art installation now.', 'Kırtasiye & Ofis', 'Stationery & Office', 79, 14, 'https://loremflickr.com/600/600/stationery,office?lock=79'),
  (80, 'Mekanik Kurşun Kalem Seti', 'Mechanical Pencil Set', 'Yazı yazmıyorsun ama estetik duruyor.', 'You don''t write, but it looks great sitting there.', 'Kırtasiye & Ofis', 'Stationery & Office', 129, 15, 'https://loremflickr.com/600/600/stationery,office?lock=80'),
  (81, 'Araç İç Temizlik Seti', 'Car Interior Cleaning Kit', 'Bir kez kullandın, araç yine toz içinde.', 'Used it once, dust returned immediately.', 'Otomotiv', 'Automotive', 349, 16, 'https://loremflickr.com/600/600/car,automotive?lock=81'),
  (82, 'Telefon Tutucu Araç İçi', 'Car Phone Mount', 'GPS için aldın, sadece müzik için kullanıyorsun.', 'Bought for GPS, used only for music.', 'Otomotiv', 'Automotive', 179, 17, 'https://loremflickr.com/600/600/car,automotive?lock=82'),
  (83, 'Oto Koku Seti', 'Car Air Freshener Set', 'Araba artık spa gibi kokuyor, yol hâlâ trafik.', 'Car smells like a spa now, the road is still traffic.', 'Otomotiv', 'Automotive', 99, 18, 'https://loremflickr.com/600/600/car,automotive?lock=83'),
  (84, 'Araç Şarj Adaptörü', 'Car Charger', 'İki USB girişi, hep tek telefonun var.', 'Two USB ports, you only ever have one phone.', 'Otomotiv', 'Automotive', 149, 19, 'https://loremflickr.com/600/600/car,automotive?lock=84'),
  (85, 'Direksiyon Kılıfı', 'Steering Wheel Cover', 'Elin terli olduğunda tek faydası oluyor.', 'Only useful when your hands are sweaty.', 'Otomotiv', 'Automotive', 229, 20, 'https://loremflickr.com/600/600/car,automotive?lock=85'),
  (86, 'Bagaj Organizer', 'Trunk Organizer', 'Bagaj düzenli, arka koltuk hâlâ dağınık.', 'Trunk''s tidy, back seat''s still a disaster.', 'Otomotiv', 'Automotive', 279, 21, 'https://loremflickr.com/600/600/car,automotive?lock=86'),
  (87, '1000 Parça Puzzle', '1000-Piece Puzzle', 'Kutudan çıkarıp yarısında bıraktığın klasik.', 'The classic ''half-finished, back in the box'' story.', 'Hobi & Oyuncak', 'Hobby & Toys', 249, 22, 'https://loremflickr.com/600/600/toy,hobby?lock=87'),
  (88, 'Model Uçak Seti', 'Model Airplane Kit', 'Yapacaktın, kutu hâlâ raftan inmedi.', 'The plan was to build it, the box hasn''t moved.', 'Hobi & Oyuncak', 'Hobby & Toys', 399, 23, 'https://loremflickr.com/600/600/toy,hobby?lock=88'),
  (89, 'Uzaktan Kumandalı Araba', 'RC Car', 'Yetişkin aldı, ''çocuğa'' diye açıklıyor.', 'An adult bought it, calls it ''for the kid''.', 'Hobi & Oyuncak', 'Hobby & Toys', 599, 24, 'https://loremflickr.com/600/600/toy,hobby?lock=89'),
  (90, 'Boyama Seti Yetişkin', 'Adult Coloring Set', 'Stres atmak için aldın, stresle boyuyorsun.', 'Bought to relieve stress, colored while stressed.', 'Hobi & Oyuncak', 'Hobby & Toys', 179, 10, 'https://loremflickr.com/600/600/toy,hobby?lock=90'),
  (91, 'Satranç Takımı', 'Chess Set', 'Kurallarını hâlâ tam bilmiyorsun ama şık duruyor.', 'You still don''t fully know the rules, but it looks great.', 'Hobi & Oyuncak', 'Hobby & Toys', 349, 11, 'https://loremflickr.com/600/600/toy,hobby?lock=91'),
  (92, 'Lego Uyumlu Yapı Seti', 'Building Block Set', 'Kutudan hiç çıkmadı ama ''ileride'' lazım olacak.', 'Never left the box, but ''someday'' it''ll be useful.', 'Hobi & Oyuncak', 'Hobby & Toys', 449, 12, 'https://loremflickr.com/600/600/toy,hobby?lock=92'),
  (93, 'Organik Bal 850g', 'Organic Honey 850g', 'Organik yazınca fiyat 3 katına çıkıyor, alıyorsun yine de.', 'The word ''organic'' triples the price, you buy it anyway.', 'Süpermarket', 'Supermarket', 289, 13, 'https://loremflickr.com/600/600/grocery,food?lock=93'),
  (94, 'Kahve Çekirdeği 1kg', 'Coffee Beans 1kg', 'Barista gibi demliyorsun, tadı yine de nescafe gibi.', 'Brewed like a barista, still somehow tastes like instant.', 'Süpermarket', 'Supermarket', 349, 14, 'https://loremflickr.com/600/600/grocery,food?lock=94'),
  (95, 'Bitki Çayı Seti', 'Herbal Tea Set', 'Sağlıklı yaşam bu çaylarla başlıyor, sözde.', 'Healthy living starts with these teas, allegedly.', 'Süpermarket', 'Supermarket', 149, 15, 'https://loremflickr.com/600/600/grocery,food?lock=95'),
  (96, 'Kuruyemiş Karışık 500g', 'Mixed Nuts 500g', 'Sağlıklı atıştırmalık, poşeti bitirene kadar sağlıklı kalıyor.', 'A healthy snack, until the whole bag is gone.', 'Süpermarket', 'Supermarket', 199, 16, 'https://loremflickr.com/600/600/grocery,food?lock=96'),
  (97, 'Zeytinyağı 1L', 'Olive Oil 1L', 'Soğuk sıkım yazınca elin cebe gidiyor.', '''Cold-pressed'' on the label, your wallet feels it.', 'Süpermarket', 'Supermarket', 259, 17, 'https://loremflickr.com/600/600/grocery,food?lock=97'),
  (98, 'Bal Kavanozu Hediyelik Set', 'Honey Jar Gift Set', 'Hediye almak bahane, kendine aldığını biliyoruz.', '''For a gift'' is the excuse, we know it''s for you.', 'Süpermarket', 'Supermarket', 329, 18, 'https://loremflickr.com/600/600/grocery,food?lock=98'),
  (99, 'Makarna Çeşitleri Seti', 'Pasta Variety Set', 'İtalyan mutfağına 1 adım, İtalya''ya 0 adım.', 'One step closer to Italian cuisine, zero steps closer to Italy.', 'Süpermarket', 'Supermarket', 179, 19, 'https://loremflickr.com/600/600/grocery,food?lock=99'),
  (100, 'Baharat Seti 12''li', 'Spice Set 12-Pack', 'Hepsini kullanmıyorsun ama raf çok güzel duruyor.', 'You don''t use them all, but the shelf looks amazing.', 'Süpermarket', 'Supermarket', 249, 20, 'https://loremflickr.com/600/600/grocery,food?lock=100')
on conflict (id) do update set
  name = excluded.name,
  name_en = excluded.name_en,
  description = excluded.description,
  description_en = excluded.description_en,
  category = excluded.category,
  category_en = excluded.category_en,
  price = excluded.price,
  image = excluded.image;
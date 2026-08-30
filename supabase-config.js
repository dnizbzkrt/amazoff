// Supabase project credentials.
// Get these from: Supabase Dashboard > Project Settings > API
const SUPABASE_URL = "https://YOUR_PROJECT_REF.supabase.co";
const SUPABASE_ANON_KEY = "YOUR_ANON_PUBLIC_KEY";

const supabaseClient = window.supabase.createClient(
  SUPABASE_URL,
  SUPABASE_ANON_KEY
);

// If the user is already logged in, send them straight to the store.
// Used on index.html (login) and register.html.
async function redirectIfLoggedIn() {
  const { data } = await supabaseClient.auth.getSession();
  if (data.session) {
    window.location.href = "home.html";
  }
}

// If the user is NOT logged in, send them back to the login page.
// Used on every protected page (home, product, cart, success).
async function requireAuth() {
  const { data } = await supabaseClient.auth.getSession();
  if (!data.session) {
    window.location.href = "index.html";
    return null;
  }
  return data.session.user;
}

async function logout() {
  await supabaseClient.auth.signOut();
  window.location.href = "index.html";
}

// Fetch the current user's wallet balance from the profiles table.
async function getWalletBalance(userId) {
  const { data, error } = await supabaseClient
    .from("profiles")
    .select("wallet_balance")
    .eq("id", userId)
    .single();
  if (error) {
    console.error("Wallet fetch error:", error);
    return 0;
  }
  return Number(data.wallet_balance);
}

// Render "Wallet: 1.000 TL" into any element with id="walletDisplay".
async function renderWalletBalance(userId) {
  const el = document.getElementById("walletDisplay");
  if (!el) return;
  const balance = await getWalletBalance(userId);
  el.textContent = `Cüzdan: ${formatTL(balance)}`;
  return balance;
}

function formatTL(amount) {
  return `${Number(amount).toLocaleString("tr-TR")} TL`;
}

// Supabase project credentials.
const SUPABASE_URL = "https://lwynkkwvifxqibwbxrln.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_-mZzGmbCRZTi8p45_FcqHw_Q_GqmX-6";

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

// Render "Wallet: 10.000 TL" into any element with id="walletDisplay".
async function renderWalletBalance(userId) {
  const el = document.getElementById("walletDisplay");
  if (!el) return;
  const balance = await getWalletBalance(userId);
  const label = typeof tt === "function" ? tt("Cüzdan", "Wallet") : "Cüzdan";
  el.textContent = `${label}: ${formatTL(balance)}`;
  return balance;
}

function formatTL(amount) {
  return `${Number(amount).toLocaleString("tr-TR")} TL`;
}

// Language preference — stored in Supabase (profiles.language), never in
// the browser, so it stays consistent with the rest of the site's data
// model and works the same for every friend using the site.
async function getLanguage(userId) {
  const { data, error } = await supabaseClient
    .from("profiles")
    .select("language")
    .eq("id", userId)
    .single();
  if (error || !data) return "tr";
  return data.language || "tr";
}

async function setLanguage(userId, lang) {
  await supabaseClient.from("profiles").update({ language: lang }).eq("id", userId);
}

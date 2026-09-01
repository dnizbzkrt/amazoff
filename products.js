// Product catalog — lives in Supabase (table: products), NOT in this file.
// Prices, stock and descriptions can only be changed from the Supabase
// dashboard; nobody can edit them from the browser. This file just fetches
// the catalog once per page load and exposes the same PRODUCTS / CATEGORIES
// / getProductById(...) helpers the rest of the site already uses, so no
// other page needs to know where the data actually comes from.

let PRODUCTS = [];
let CATEGORIES = []; // [{ name: "Kozmetik & Kişisel Bakım", name_en: "Cosmetics & Personal Care" }, ...]

async function loadProducts() {
  if (PRODUCTS.length > 0) return; // already loaded this page

  const { data, error } = await supabaseClient
    .from("products")
    .select("id, name, name_en, description, description_en, category, category_en, price, stock, image")
    .order("id", { ascending: true });

  if (error) {
    console.error("Products fetch error:", error);
    PRODUCTS = [];
    CATEGORIES = [];
    return;
  }

  PRODUCTS = data || [];

  CATEGORIES = [];
  const seen = new Set();
  for (const p of PRODUCTS) {
    if (!seen.has(p.category)) {
      seen.add(p.category);
      CATEGORIES.push({ name: p.category, name_en: p.category_en || p.category });
    }
  }
}

function getProductById(id) {
  return PRODUCTS.find((p) => p.id === Number(id));
}

function getProductsByCategory(category) {
  return PRODUCTS.filter((p) => p.category === category);
}

function searchProducts(query) {
  const q = query.trim().toLocaleLowerCase("tr-TR");
  if (!q) return PRODUCTS;
  return PRODUCTS.filter(
    (p) =>
      p.name.toLocaleLowerCase("tr-TR").includes(q) ||
      (p.name_en || "").toLowerCase().includes(q.toLowerCase()) ||
      p.category.toLocaleLowerCase("tr-TR").includes(q) ||
      (p.description || "").toLocaleLowerCase("tr-TR").includes(q)
  );
}

// Bilingual display helpers — pick TR or EN depending on the active
// language (tt() comes from i18n.js).
function productName(p) {
  return typeof tt === "function" ? tt(p.name, p.name_en || p.name) : p.name;
}
function productDescription(p) {
  return typeof tt === "function" ? tt(p.description, p.description_en || p.description) : p.description;
}
function productCategory(p) {
  return typeof tt === "function" ? tt(p.category, p.category_en || p.category) : p.category;
}

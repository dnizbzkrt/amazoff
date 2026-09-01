// Shared header behaviors used on every page: the "Tüm Kategoriler" mega
// menu and the search bar. Requires products.js (for CATEGORIES) to be
// loaded first.

function renderCategoryMenu() {
  const panel = document.getElementById("categoryMenuPanel");
  if (!panel) return;
  panel.innerHTML = CATEGORIES.map(
    (c) => `<a href="home.html?category=${encodeURIComponent(c.name)}">${tt(c.name, c.name_en)}</a>`
  ).join("");
}

function toggleCategoryMenu(e) {
  e.stopPropagation();
  const panel = document.getElementById("categoryMenuPanel");
  if (!panel) return;
  panel.classList.toggle("open");
}

document.addEventListener("click", () => {
  const panel = document.getElementById("categoryMenuPanel");
  if (panel) panel.classList.remove("open");
});

function handleSearch(e) {
  e.preventDefault();
  const input = document.getElementById("searchInput");
  const q = input ? input.value.trim() : "";
  window.location.href = q
    ? `home.html?search=${encodeURIComponent(q)}`
    : "home.html";
  return false;
}

// Prefill the search box if the current page URL already has ?search=
function prefillSearchBox() {
  const input = document.getElementById("searchInput");
  if (!input) return;
  const params = new URLSearchParams(window.location.search);
  const q = params.get("search");
  if (q) input.value = q;
}

// Runs the common header setup shared by every logged-in page.
async function initHeader(userId) {
  renderCategoryMenu();
  prefillSearchBox();
  renderWalletBalance(userId);
  updateCartBadge();
}

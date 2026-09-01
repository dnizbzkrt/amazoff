// Lightweight TR/EN language switch. No localStorage — the preference is
// stored in Supabase (profiles.language) so it's consistent with the rest
// of the site's data model and works the same for every friend using the
// site on their own account.
//
// Usage in dynamic (JS-rendered) content:  tt("Sepete Ekle", "Add to Cart")
// Usage in static HTML: <h1 data-i18n-en="About Us">Hakkımızda</h1>
//   then call applyStaticTranslations() once the language is known.

let currentLang = "tr";

// Returns the Turkish or English string depending on the active language.
function tt(tr, en) {
  return currentLang === "en" ? en : tr;
}

// Swap textContent (and placeholders) for any element carrying a
// data-i18n-en / data-i18n-en-placeholder attribute. Works in both
// directions (remembers the original Turkish text on first run).
function applyStaticTranslations() {
  document.querySelectorAll("[data-i18n-en]").forEach((el) => {
    if (!el.hasAttribute("data-i18n-tr")) {
      el.setAttribute("data-i18n-tr", el.textContent);
    }
    el.textContent =
      currentLang === "en"
        ? el.getAttribute("data-i18n-en")
        : el.getAttribute("data-i18n-tr");
  });
  document.querySelectorAll("[data-i18n-en-placeholder]").forEach((el) => {
    if (!el.hasAttribute("data-i18n-tr-placeholder")) {
      el.setAttribute("data-i18n-tr-placeholder", el.getAttribute("placeholder") || "");
    }
    el.setAttribute(
      "placeholder",
      currentLang === "en"
        ? el.getAttribute("data-i18n-en-placeholder")
        : el.getAttribute("data-i18n-tr-placeholder")
    );
  });
  document.documentElement.setAttribute("lang", currentLang);
}

// Fetches the user's saved language, renders the TR/EN pill into
// <div id="langSwitch">, and applies static translations. Call this once
// per page, right after requireAuth().
async function initLangSwitch(userId) {
  currentLang = await getLanguage(userId);
  renderLangSwitchUI(userId);
  applyStaticTranslations();
}

function renderLangSwitchUI(userId) {
  const el = document.getElementById("langSwitch");
  if (!el) return;
  el.innerHTML = `
    <button class="${currentLang === "tr" ? "active" : ""}" data-lang="tr">TR</button>
    <button class="${currentLang === "en" ? "active" : ""}" data-lang="en">EN</button>
  `;
  el.querySelectorAll("button").forEach((btn) => {
    btn.addEventListener("click", async () => {
      const lang = btn.getAttribute("data-lang");
      if (lang === currentLang) return;
      await setLanguage(userId, lang);
      window.location.reload();
    });
  });
}

// Same as above, but for pages with no logged-in user yet (login/register):
// toggles the in-memory language only, no Supabase write, no reload needed
// since applyStaticTranslations() re-renders the visible text immediately.
function renderLangSwitchLocal() {
  const el = document.getElementById("langSwitch");
  if (!el) return;
  el.innerHTML = `
    <button class="${currentLang === "tr" ? "active" : ""}" data-lang="tr">TR</button>
    <button class="${currentLang === "en" ? "active" : ""}" data-lang="en">EN</button>
  `;
  el.querySelectorAll("button").forEach((btn) => {
    btn.addEventListener("click", () => {
      currentLang = btn.getAttribute("data-lang");
      renderLangSwitchLocal();
      applyStaticTranslations();
    });
  });
}

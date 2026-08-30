// Shopping cart, stored in the browser's localStorage.
// Each item: { productId: number, quantity: number }
const CART_STORAGE_KEY = "amazoff_cart";

function getCart() {
  try {
    const raw = window.localStorage.getItem(CART_STORAGE_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function saveCart(cart) {
  window.localStorage.setItem(CART_STORAGE_KEY, JSON.stringify(cart));
}

function addToCart(productId, quantity = 1) {
  const product = getProductById(productId);
  const maxStock = product ? product.stock : 99;
  const cart = getCart();
  const existing = cart.find((i) => i.productId === productId);
  if (existing) {
    existing.quantity = Math.min(existing.quantity + quantity, maxStock);
  } else {
    cart.push({ productId, quantity: Math.min(quantity, maxStock) });
  }
  saveCart(cart);
  updateCartBadge();
}

function removeFromCart(productId) {
  const cart = getCart().filter((i) => i.productId !== productId);
  saveCart(cart);
  updateCartBadge();
}

function setCartQuantity(productId, quantity) {
  if (quantity <= 0) {
    removeFromCart(productId);
    return;
  }
  const cart = getCart();
  const item = cart.find((i) => i.productId === productId);
  if (item) {
    item.quantity = quantity;
    saveCart(cart);
    updateCartBadge();
  }
}

function clearCart() {
  saveCart([]);
  updateCartBadge();
}

function getCartTotal() {
  return getCart().reduce((sum, item) => {
    const product = getProductById(item.productId);
    return sum + (product ? product.price * item.quantity : 0);
  }, 0);
}

function getCartItemCount() {
  return getCart().reduce((sum, item) => sum + item.quantity, 0);
}

// Updates any element with id="cartBadge" (shown in the header on every page).
function updateCartBadge() {
  const badge = document.getElementById("cartBadge");
  if (!badge) return;
  const count = getCartItemCount();
  badge.textContent = count;
  badge.style.display = count > 0 ? "inline-flex" : "none";
}

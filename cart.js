// Shopping cart — backed entirely by Supabase (table: cart_items).
// Nothing is stored in the browser (no localStorage/sessionStorage), so the
// same cart follows a user across devices, and every friend using the site
// gets their own real, database-backed cart.
//
// All functions are async. Pages call them with `await` (or fire-and-forget
// in onclick handlers, since each function updates the on-screen badge
// itself once it finishes).

async function getCart() {
  const { data: { user } } = await supabaseClient.auth.getUser();
  if (!user) return [];

  const { data, error } = await supabaseClient
    .from("cart_items")
    .select("product_id, quantity")
    .eq("user_id", user.id);

  if (error) {
    console.error("Cart fetch error:", error);
    return [];
  }
  return (data || []).map((row) => ({ productId: row.product_id, quantity: row.quantity }));
}

async function addToCart(productId, quantity = 1) {
  const { data: { user } } = await supabaseClient.auth.getUser();
  if (!user) return;

  const product = getProductById(productId);
  const maxStock = product ? product.stock : 99;

  const { data: existing } = await supabaseClient
    .from("cart_items")
    .select("quantity")
    .eq("user_id", user.id)
    .eq("product_id", productId)
    .maybeSingle();

  if (existing) {
    const newQty = Math.min(existing.quantity + quantity, maxStock);
    await supabaseClient
      .from("cart_items")
      .update({ quantity: newQty, updated_at: new Date().toISOString() })
      .eq("user_id", user.id)
      .eq("product_id", productId);
  } else {
    await supabaseClient.from("cart_items").insert({
      user_id: user.id,
      product_id: productId,
      quantity: Math.min(quantity, maxStock),
    });
  }

  await updateCartBadge();
}

async function removeFromCart(productId) {
  const { data: { user } } = await supabaseClient.auth.getUser();
  if (!user) return;

  await supabaseClient
    .from("cart_items")
    .delete()
    .eq("user_id", user.id)
    .eq("product_id", productId);

  await updateCartBadge();
}

async function setCartQuantity(productId, quantity) {
  if (quantity <= 0) {
    await removeFromCart(productId);
    return;
  }
  const { data: { user } } = await supabaseClient.auth.getUser();
  if (!user) return;

  await supabaseClient
    .from("cart_items")
    .update({ quantity, updated_at: new Date().toISOString() })
    .eq("user_id", user.id)
    .eq("product_id", productId);

  await updateCartBadge();
}

async function clearCart() {
  const { data: { user } } = await supabaseClient.auth.getUser();
  if (!user) return;

  await supabaseClient.from("cart_items").delete().eq("user_id", user.id);
  await updateCartBadge();
}

async function getCartTotal() {
  const cart = await getCart();
  return cart.reduce((sum, item) => {
    const product = getProductById(item.productId);
    return sum + (product ? product.price * item.quantity : 0);
  }, 0);
}

async function getCartItemCount() {
  const cart = await getCart();
  return cart.reduce((sum, item) => sum + item.quantity, 0);
}

// Updates any element with id="cartBadge" (shown in the header on every page).
async function updateCartBadge() {
  const badge = document.getElementById("cartBadge");
  if (!badge) return;
  const count = await getCartItemCount();
  badge.textContent = count;
  badge.style.display = count > 0 ? "inline-flex" : "none";
}

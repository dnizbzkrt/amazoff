// Demo products — using stock photos (picsum.photos).
// When you have real product photos, replace the "image" values below with
// your own images placed in the /products folder (e.g. "products/cream.jpg").
const PRODUCTS = [
  {
    id: 1,
    name: "Nemlendirici Yüz Kremi",
    description:
      "Cilde yoğun nem sağlayan, hyalüronik asit içeren günlük bakım kremi. Tüm cilt tiplerine uygundur.",
    category: "Kozmetik",
    price: 179,
    image: "https://picsum.photos/seed/amazoff-cream/600/600",
    stock: 10,
  },
  {
    id: 2,
    name: "Dudak Parlatıcısı",
    description:
      "Şeffaf ve hafif pembe tonlarda, dudaklara doğal bir parlaklık kazandıran uzun etkili dudak parlatıcısı.",
    category: "Kozmetik",
    price: 129,
    image: "https://picsum.photos/seed/amazoff-lipgloss/600/600",
    stock: 10,
  },
  {
    id: 3,
    name: "Mat Ruj - Kiremit",
    description:
      "Kalıcı mat bitişli, kuru hissettirmeyen formülü ile gün boyu canlı renk sunan ruj.",
    category: "Kozmetik",
    price: 149,
    image: "https://picsum.photos/seed/amazoff-lipstick/600/600",
    stock: 10,
  },
  {
    id: 4,
    name: "Yazlık Midi Elbise",
    description:
      "Hafif ve nefes alan kumaştan üretilmiş, günlük kullanıma uygun çiçek desenli midi elbise.",
    category: "Kadın Giyim",
    price: 459,
    image: "https://picsum.photos/seed/amazoff-dress/600/600",
    stock: 10,
  },
  {
    id: 5,
    name: "Yüksek Bel Kot Pantolon",
    description:
      "Rahat kesim, esnek kumaş yapısıyla her kombine uyum sağlayan yüksek bel kot pantolon.",
    category: "Kadın Giyim",
    price: 549,
    image: "https://picsum.photos/seed/amazoff-jeans/600/600",
    stock: 10,
  },
];

function getProductById(id) {
  return PRODUCTS.find((p) => p.id === Number(id));
}

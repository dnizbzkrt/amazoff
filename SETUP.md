# amazoff — Kurulum Rehberi

Düz HTML/CSS/JS ile yazılmış, framework ve build adımı olmayan bir proje.
GitHub Pages'te doğrudan yayınlanabilir.

---

## 1) Supabase — key'ler zaten gömülü ✅

`supabase-config.js` dosyasında Supabase proje bilgileriniz zaten tanımlı.

**Zorunlu tek adım:** `supabase-setup.sql` dosyasının **tüm içeriğini**
Supabase Dashboard → SQL Editor'da çalıştırın (baştan sona, tek seferde).
Dosya tamamen **idempotent**tir — yani daha önce bir kısmını çalıştırmış
olsanız bile, dosyanın tamamını tekrar çalıştırmak güvenlidir ve hata
vermez. Var olan hiçbir veriyi silmez veya bozmaz.

Bu çalıştırma şunları oluşturur/günceller:
- `profiles`, `orders`, `order_items`, `cart_items` tabloları
- Row Level Security (RLS) politikaları (herkes sadece kendi verisini
  değiştirebilir; sepet dahil — böylece her arkadaşınız kendi gerçek
  sepetine sahip olur, hiçbir şey tarayıcıda/localStorage'da tutulmaz)
- Yeni kullanıcıya otomatik **10.000 TL** demo bakiye veren tetikleyici
- `get_order_feed`, `get_order_feed_items` — Siparişlerim / Tüm Siparişler
  sayfaları için
- `get_leaderboard`, `get_popular_products` — İstatistikler sayfası için
  (en çok harcayanlar, en popüler ürünler)

**Authentication > Providers** sayfasında **Email** sağlayıcısının açık
olduğundan emin olun. Test için e-posta doğrulamasını atlamak isterseniz
**Authentication > Settings** içinde "Confirm email" seçeneğini
kapatabilirsiniz.

---

## 2) GitHub'a yükleme

```bash
git init
git add .
git commit -m "amazoff marketplace update"
git branch -M main
git remote add origin https://github.com/<kullanici-adiniz>/amazoff.git
git push -u origin main
```

## 3) GitHub Pages olarak yayınlama

Repo → **Settings → Pages** → **Source**: "Deploy from a branch" →
**Branch**: `main`, klasör: `/ (root)` → **Save**.

Birkaç dakika içinde `https://<kullanici-adiniz>.github.io/amazoff/`
adresinde yayında olur.

---

## Dosya yapısı

```
index.html          → Giriş (login)
register.html        → Kayıt ol (10.000 TL demo bakiye ile başlar)
home.html            → Marketplace ana sayfa: arama, kategori menüsü,
                        istatistik kartları, popüler ürünler, "bunu
                        gerçekten alır mıydın?" widget'ı, 100 ürünlük ızgara
product.html          → Ürün detayı (?id=1..100)
cart.html            → Sepet (artık tamamen Supabase — cart_items tablosu)
success.html          → Başarılı sipariş ekranı
orders.html           → Siparişlerim + bugün/toplam harcama istatistiği
feed.html            → Tüm Siparişler (herkese açık akış, isim/anonim)
istatistikler.html    → Liderlik tablosu (en çok harcayanlar) + popüler ürünler
settings.html         → Görünen ad + "adım herkese görünsün" ayarı
blog.html / blog-post.html → Blog listesi ve detay sayfası (5 yazı)
blog-data.js          → Blog içerikleri
about.html            → Hakkımızda
privacy.html          → Gizlilik Politikası
contact.html          → İletişim
terms.html            → Kullanım Koşulları
style.css            → Tüm site stilleri (editoryal, koyu/krem tema)
supabase-config.js    → Supabase bağlantısı + oturum yardımcıları
products.js           → 100 ürün, 14 kategori + arama/filtre fonksiyonları
site-ui.js            → Kategori menüsü + arama çubuğu (ortak header mantığı)
cart.js              → Sepet mantığı — TAMAMEN Supabase, localStorage YOK
supabase-setup.sql    → Veritabanı şeması (idempotent, tek dosyada tam kurulum)
```

## Önemli notlar

- **localStorage kullanılmıyor.** Sepet dahil hiçbir veri tarayıcıda
  tutulmuyor; her şey Supabase'de. Bu sayede arkadaşlarınız siteyi kendi
  hesaplarıyla kullandığında kendi gerçek sepetlerine, bakiyelerine ve
  sipariş geçmişlerine sahip olur, veriler ortak veritabanında toplanır.
- **10.000 TL bakiye** sadece **yeni kayıt olan** kullanıcılara otomatik
  verilir. Daha önce 1.000 TL ile kayıt olmuş test hesaplarınız varsa,
  bakiyelerini elle güncellemek isterseniz Supabase → Table Editor →
  `profiles` tablosundan ilgili satırı düzenleyebilirsiniz.
- Ürün kataloğu (`products.js`) statik bir JS dosyasıdır, veritabanında
  değildir — bu "local storage" değildir, sadece sitenin kendi statik
  içeriğidir (tıpkı style.css gibi), kullanıcıya özel bir veri saklamaz.

## Sonraki adımlar (fikir)

- Cüzdana demo para yükleme / günlük bonus
- Favoriler (Supabase'de `favorites` tablosu ile)
- Ürün puanlama / yorum sistemi
- Admin paneli

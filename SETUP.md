# amazoff — Kurulum Rehberi

Bu proje düz HTML/CSS/JS ile yazılmıştır (framework yok, build adımı yok).
`naciye` projesindeki gibi doğrudan GitHub Pages'te yayınlanabilir.

---

## 1) Ücretsiz Supabase veritabanı kurulumu

1. https://supabase.com → **Start your project** → GitHub hesabınızla ücretsiz kayıt olun.
2. **New Project**:
   - Project name: `amazoff`
   - Database password: güçlü bir şifre belirleyin (bir yere not edin)
   - Region: `Frankfurt (eu-central-1)`
3. Proje açılınca sol menüden **SQL Editor** → **New query** → bu depodaki
   `supabase-setup.sql` dosyasının tüm içeriğini yapıştırıp **Run** deyin.
   Bu işlem şunları oluşturur:
   - `profiles` tablosu (cüzdan bakiyesi burada tutulur)
   - `orders` ve `order_items` tabloları
   - Yeni kullanıcı kayıt olduğunda otomatik olarak **1.000 TL** bakiye
     tanımlayan tetikleyici (trigger)
   - Row Level Security (RLS) politikaları
4. Sol menüden **Project Settings > API** sayfasına gidin, şu iki değeri
   kopyalayın:
   - **Project URL**
   - **anon public** key
5. **Authentication > Providers** sayfasında **Email** sağlayıcısının açık
   olduğundan emin olun (varsayılan olarak açıktır). Test sırasında
   e-posta doğrulamasını atlamak isterseniz **Authentication > Settings**
   içinde "Confirm email" seçeneğini kapatabilirsiniz.
6. Bu iki değeri `supabase-config.js` dosyasının en üstüne yapıştırın:

```js
const SUPABASE_URL = "https://xxxxxxxxxxxx.supabase.co";
const SUPABASE_ANON_KEY = "eyJxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
```

> Not: Bu anahtar "anon public" anahtardır, gizli değildir — tarayıcı
> tarafında kullanılmak üzere tasarlanmıştır. Güvenlik, veritabanı
> tarafındaki RLS politikaları ile sağlanır (yukarıdaki SQL dosyasında
> zaten tanımlı).

---

## 2) GitHub'a yükleme

`dnizbzkrt/naciye` reponuza benzer şekilde, kendi hesabınızda yeni bir
depo oluşturup bu klasördeki tüm dosyaları oraya push edin:

```bash
git init
git add .
git commit -m "amazoff MVP"
git branch -M main
git remote add origin https://github.com/<kullanici-adiniz>/amazoff.git
git push -u origin main
```

---

## 3) GitHub Pages olarak yayınlama

1. GitHub'da reponuzun sayfasına gidin → **Settings** → sol menüden **Pages**.
2. **Build and deployment** altında **Source** olarak **Deploy from a branch**
   seçin.
3. **Branch** kısmında `main` ve klasör olarak `/ (root)` seçip **Save**
   deyin.
4. Birkaç dakika içinde siteniz şu adreste yayında olur:

   `https://<kullanici-adiniz>.github.io/amazoff/`

5. Siteye girip **Kayıt Ol** ile yeni bir hesap oluşturun — otomatik olarak
   1.000 TL bakiye ile başlayacaksınız. Ürün ekleyip sepete atıp "Satın Al"
   dediğinizde işlem Supabase veritabanınıza kaydedilir; Supabase
   Dashboard'da **Table Editor > orders / order_items / profiles**
   kısımlarından verileri canlı görebilirsiniz.

---

## Dosya yapısı

```
index.html          → Giriş (login) — site giriş noktası
register.html        → Kayıt ol
home.html            → Mağaza (ürün listeleme, kategori filtresi)
product.html          → Ürün detayı (?id=1)
cart.html            → Sepet + satın alma
success.html          → Başarılı sipariş ekranı
style.css            → Tüm site stilleri
supabase-config.js    → Supabase bağlantısı + oturum yardımcı fonksiyonları
products.js           → 5 demo ürün (stok fotoğraflarla)
cart.js              → Sepet mantığı (localStorage)
supabase-setup.sql    → Veritabanı şeması (SQL Editor'a yapıştırılacak)
```

## Demo ürünler

Ürün görselleri şu an stok fotoğraf servisinden (picsum.photos) geliyor.
Gerçek ürün fotoğraflarınız olduğunda `products.js` içindeki `image`
alanlarını kendi görsellerinizle değiştirebilirsiniz (örneğin bu klasöre
`products/urun1.jpg` şeklinde ekleyip yolu `products/urun1.jpg` yapabilirsiniz).

## Sonraki adımlar

- Sipariş geçmişi sayfası (`orders` / `order_items` tabloları zaten hazır)
- Cüzdana demo para yükleme
- Admin paneli (ürün ekleme/çıkarma, stok yönetimi)
- Arama ve filtreleme

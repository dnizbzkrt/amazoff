# amazoff — Kurulum Rehberi

Bu proje düz HTML/CSS/JS ile yazılmıştır (framework yok, build adımı yok).
`naciye` projesindeki gibi doğrudan GitHub Pages'te yayınlanabilir.

---

## 1) Supabase veritabanı — key'ler zaten gömülü ✅

`supabase-config.js` dosyasında Supabase proje bilgileriniz zaten
tanımlı, ekstra bir şey yapmanıza gerek yok.

**Ama tek bir zorunlu adım var:** Supabase projenizde tablolar henüz
oluşturulmadıysa (ör. "Could not find the table 'public.orders'" gibi
bir hata görüyorsanız) şeması hiç çalıştırılmamış demektir. Şunu yapın:

1. https://supabase.com/dashboard → projeniz (`lwynkkwvifxqibwbxrln`) → sol
   menüden **SQL Editor**
2. **New query** → bu depodaki `supabase-setup.sql` dosyasının **tüm
   içeriğini** (en baştan en sona, "UPDATE" bölümü dahil) kopyalayıp
   yapıştırın
3. **Run** butonuna basın

Bu tek çalıştırma şunların hepsini oluşturur: `profiles`, `orders`,
`order_items` tabloları, RLS güvenlik kuralları, yeni kullanıcıya otomatik
1.000 TL veren tetikleyici, ve "Tüm Siparişler" sayfasının kullandığı
`get_order_feed` / `get_order_feed_items` fonksiyonları.

> Not: Daha önce sadece "UPDATE" bölümünü çalıştırıp asıl tabloları hiç
> oluşturmadıysanız (bu, "table not found" hatalarının sebebi), dosyanın
> tamamını baştan sona bir kere daha çalıştırmanız yeterli — `create table
> if not exists` kullanıldığı için zaten var olan hiçbir şeyi bozmaz.

**Authentication > Providers** sayfasında **Email** sağlayıcısının açık
olduğundan emin olun (varsayılan olarak açıktır). Test sırasında
e-posta doğrulamasını atlamak isterseniz **Authentication > Settings**
içinde "Confirm email" seçeneğini kapatabilirsiniz.

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
orders.html           → Siparişlerim (kendi sipariş geçmişiniz)
feed.html            → Tüm Siparişler (herkesin siparişleri, isim/anonim tercihli)
settings.html         → Görünen ad + "adım herkese görünsün" ayarı
style.css            → Tüm site stilleri
supabase-config.js    → Supabase bağlantısı + oturum yardımcı fonksiyonları
products.js           → 5 demo ürün (stok fotoğraflarla)
cart.js              → Sepet mantığı (localStorage)
supabase-setup.sql    → Veritabanı şeması (SQL Editor'a yapıştırılacak)
```

## Siparişlerim / Tüm Siparişler nasıl çalışır?

- **Siparişlerim** (`orders.html`): sadece kendi siparişlerinizi, Supabase'deki
  RLS (Row Level Security) kuralları sayesinde otomatik olarak görürsünüz.
- **Tüm Siparişler** (`feed.html`): herkesin siparişlerini gösteren ortak bir
  akış. Burada kimin ne aldığı görünür ama **isim gizliliği kullanıcı
  tercihine bağlıdır**:
  - `settings.html` sayfasından bir "Görünen Ad" girip "Siparişlerimde adım
    görünsün" anahtarını açarsanız, adınız akışta görünür.
  - Anahtar kapalıysa (varsayılan), siparişleriniz akışta **"Anonim
    Kullanıcı"** olarak görünür — kimliğiniz gizli kalır.
  - Bu mantık veritabanı tarafında bir Postgres fonksiyonu
    (`get_order_feed`) ile çalışır; wallet bakiyesi, e-posta gibi hassas
    bilgiler bu akışta **hiçbir zaman** paylaşılmaz, sadece sipariş no,
    tutar, tarih ve (varsa) görünen ad döner.

> Önemli: Bu özelliğin çalışması için `supabase-setup.sql` dosyasının
> içindeki **"UPDATE"** başlıklı son bölümü de SQL Editor'da çalıştırmanız
> gerekir (daha önce ilk kurulumu yaptıysanız sadece bu son bölümü
> çalıştırmanız yeterli).

## Demo ürünler

Ürün görselleri şu an stok fotoğraf servisinden (picsum.photos) geliyor.
Gerçek ürün fotoğraflarınız olduğunda `products.js` içindeki `image`
alanlarını kendi görsellerinizle değiştirebilirsiniz (örneğin bu klasöre
`products/urun1.jpg` şeklinde ekleyip yolu `products/urun1.jpg` yapabilirsiniz).

## Sonraki adımlar

- Cüzdana demo para yükleme
- Admin paneli (ürün ekleme/çıkarma, stok yönetimi)
- Arama ve filtreleme

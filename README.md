# amazoff

*everything you don't actually need.*

Kozmetik ve Kadın Giyim kategorilerinde 5 ürünlük mini e-ticaret MVP'si.
Gerçek ödeme yoktur — kullanıcı kayıt olduğunda **1.000 TL** demo cüzdan
bakiyesi alır ve alışverişini bu bakiye ile simüle eder.

**Stack:** Düz HTML + CSS + JavaScript (framework/build yok) + Supabase
(Auth + Database, ücretsiz plan) — doğrudan **GitHub Pages** üzerinde
yayınlanabilir.

Kurulum adımları (Supabase + GitHub + GitHub Pages) için **[SETUP.md](SETUP.md)**
dosyasına bakın.

## Hızlı özet

1. Supabase Dashboard → SQL Editor'da `supabase-setup.sql` dosyasının tüm
   içeriğini çalıştırın (key'ler `supabase-config.js`'e zaten gömülü).
2. Bu klasörü GitHub reponuza push edin.
3. Repo **Settings > Pages** kısmından `main` branch / root klasörü seçip
   yayınlayın.

Site açıldığında: Kayıt Ol → 1.000 TL bakiye → ürünleri gez → sepete ekle →
Satın Al → sipariş Supabase'e kaydedilir, bakiye güncellenir.

**Siparişlerim** sayfasından kendi geçmişinizi, **Tüm Siparişler**
sayfasından ise herkesin siparişlerini görebilirsiniz — isminizin bu akışta
görünüp görünmeyeceğini **Ayarlar** sayfasından siz belirlersiniz (varsayılan:
anonim).

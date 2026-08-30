# amazoff

Kozmetik ve Kadın Giyim kategorilerinde 5 ürünlük mini e-ticaret MVP'si.
Gerçek ödeme yoktur — kullanıcı kayıt olduğunda **1.000 TL** demo cüzdan
bakiyesi alır ve alışverişini bu bakiye ile simüle eder.

**Stack:** Düz HTML + CSS + JavaScript (framework/build yok) + Supabase
(Auth + Database, ücretsiz plan) — doğrudan **GitHub Pages** üzerinde
yayınlanabilir.

Kurulum adımları (Supabase + GitHub + GitHub Pages) için **[SETUP.md](SETUP.md)**
dosyasına bakın.

## Hızlı özet

1. `supabase-setup.sql` dosyasını Supabase SQL Editor'da çalıştırın.
2. Supabase URL ve anon key'inizi `supabase-config.js` içine yapıştırın.
3. Bu klasörü GitHub reponuza push edin.
4. Repo **Settings > Pages** kısmından `main` branch / root klasörü seçip
   yayınlayın.

Site açıldığında: Kayıt Ol → 1.000 TL bakiye → ürünleri gez → sepete ekle →
Satın Al → sipariş Supabase'e kaydedilir, bakiye güncellenir.

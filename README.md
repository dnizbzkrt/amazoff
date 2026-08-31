# amazoff

*everything you don't actually need.*

100 ürün, 14 kategori: bir marketplace deneyimi simülasyonu. Gerçek
ödeme yoktur — kullanıcı kayıt olduğunda **10.000 TL** demo cüzdan
bakiyesi alır ve alışverişini bu bakiye ile simüle eder.

**Stack:** Düz HTML + CSS + JavaScript (framework/build yok) + Supabase
(Auth + Database, ücretsiz plan) — **GitHub Pages** üzerinde yayınlanır.
Hiçbir veri tarayıcıda (localStorage) tutulmaz; sepet dahil her şey
Supabase'de toplanır, böylece arkadaşlarınız da kendi hesaplarıyla
kullanabilir.

Kurulum için **[SETUP.md](SETUP.md)** dosyasına bakın.

## Öne çıkanlar

- 🛍️ 100 ürün, 14 kategori, arama + kategori filtresi
- 💸 10.000 TL demo cüzdan, sepet ve satın alma tamamen Supabase'de
- 📦 Siparişlerim / Tüm Siparişler (isim gizliliği kullanıcı tercihine bağlı)
- 🏆 İstatistikler: en çok harcayanlar liderlik tablosu + en popüler ürünler
- 🎲 "Bunu gerçekten alır mıydın?" rastgele ürün widget'ı
- 📝 Blog: gereksiz alışveriş üzerine 5 orijinal yazı
- 📄 Hakkımızda / Gizlilik / İletişim / Kullanım Koşulları sayfaları

## Hızlı özet

1. Supabase Dashboard → SQL Editor'da `supabase-setup.sql` dosyasının tüm
   içeriğini çalıştırın (key'ler `supabase-config.js`'e zaten gömülü).
2. Bu klasörü GitHub reponuza push edin.
3. Repo **Settings > Pages** kısmından `main` branch / root klasörü seçip
   yayınlayın.

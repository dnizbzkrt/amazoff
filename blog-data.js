// Blog content for amazoff — 5 original, lightly humorous demo articles
// about impulse shopping / "things you don't actually need". No framework,
// just a plain JS array read by blog.html and blog-post.html.

const BLOG_POSTS = [
  {
    slug: "gereksiz-alisveris-aliskanliklari",
    tag: "Alışveriş Psikolojisi",
    title: "İnternette En Gereksiz Alışveriş Alışkanlıkları",
    excerpt:
      "Sepete atıp unutmak, indirim süresi bitmeden panik satın almak ve 'belki bir gün lazım olur' diye düşünmek — hepimiz bu kulüpteyiz.",
    body: [
      "Herkesin bir 'gece 2 alışverişçisi' evresi vardır. Uyku tutmaz, telefon elimize geçer ve birdenbire ihtiyacımız olmayan bir ürün sepette belirir. Ertesi gün kargo takip numarasını görünce 'bunu ne zaman aldım' diye düşünürüz. Bu, amazoff'un varoluş sebebidir aslında: bu dürtüyü gerçek parayla değil, demo cüzdanla yaşamak.",
      "İkinci klasik alışkanlık, 'indirim bitmeden alayım' paniğidir. Ürünün gerçekten işine yarayıp yaramayacağı ikinci planda kalır, önemli olan o kırmızı sayacın sıfıra inmesidir. Sayaç sıfırlanınca da ürün zaten dolapta bir köşeye kalkar.",
      "Üçüncüsü ise 'belki bir gün lazım olur' mantığıdır. Bu mantık sayesinde evlerimiz, hiç kullanılmayan ama 'lazım olabilecek' eşyalarla dolar. amazoff'ta bu dürtüyü doyurmak, gerçek dolabınızı işgal etmeden mümkün.",
    ],
  },
  {
    slug: "sepete-atip-almaman-gerekenler",
    tag: "Rehber",
    title: "Sepete Atıp Asla Almaman Gereken Şeyler",
    excerpt:
      "Bazı ürünler sepette çok daha mantıklı görünür. Gerçek hayatta karşılaştığında ise 'bu neden burada' dersin.",
    body: [
      "Sepete atmak ile satın almak arasında büyük bir felsefi fark vardır. Sepete atmak bir hayaldir, ücretsizdir, sorumluluk gerektirmez. Satın almak ise o hayali gerçeğe, yani dolabınıza taşır.",
      "Klasik örnek: 'bir gün lazım olur' diye alınan üçüncü şarj kablosu. Ya da 'indirimde' diye alınan, hiçbir zaman giyilmeyecek renkte bir kazak. Ya da sadece kutusu güzel diye alınan bir dekor objesi.",
      "amazoff'un güzelliği tam burada devreye giriyor: sepete attığınız her şeyi gerçekten 'satın alabilirsiniz', çünkü zaten hiçbir şey gerçek değil. Demo cüzdanınız, gerçek pişmanlığınızdan sizi koruyor.",
    ],
  },
  {
    slug: "durtusel-harcama",
    tag: "Farkındalık",
    title: "Online Alışverişte Dürtüsel Harcama",
    excerpt:
      "Neden bir tık uzağımızdaki her şeyi almak isteriz? Cevap sandığımızdan daha basit: çünkü çok kolay.",
    body: [
      "Fiziksel bir mağazada bir ürünü almak için en azından kalkıp gitmemiz, elimize almamız, kasaya kadar taşımamız gerekir. Bu küçük sürtünme bile bazen bizi vazgeçirir. Online alışverişte ise tek gereken bir tık.",
      "Bu kolaylık, dürtüsel harcamanın en büyük destekçisidir. 'Sepete Ekle' ve 'Satın Al' butonları arasındaki mesafe genellikle birkaç santimetredir, birkaç saniyedir.",
      "amazoff, bu dürtüyü ortadan kaldırmıyor — tam tersine kucaklıyor. Çünkü burada satın aldığınız her şey demo cüzdanınızdan çıkıyor, gerçek bankanızdan değil. Dürtüsel harcama yapma isteğinizi zararsız bir şekilde tatmin edebilirsiniz.",
    ],
  },
  {
    slug: "10000-tl-ile-ne-alinir",
    tag: "Deneme",
    title: "10.000 TL ile Ne Kadar Gereksiz Şey Alınabilir?",
    excerpt:
      "amazoff'ta her yeni kullanıcıya verilen 10.000 TL demo bakiyeyle gerçekten kaç 'gereksiz' ürün satın alınabiliyor, hesapladık.",
    body: [
      "amazoff'a kayıt olduğunuzda cüzdanınıza otomatik olarak 10.000 TL demo bakiye tanımlanıyor. Peki bu parayla gerçekten neler 'satın alınabilir'?",
      "Ortalama bir ürün fiyatımız 350-400 TL civarında. Yani teorik olarak 10.000 TL ile yaklaşık 25-28 farklı ürünü sepete ekleyip Satın Al diyebilirsiniz — kozmetikten elektroniğe, kırtasiyeden otomotive kadar 14 farklı kategoriden istediğiniz kadar.",
      "Gerçek hayatta bu kadar çeşitli bir alışveriş yapmak hem zaman hem bütçe gerektirir. amazoff'ta ise tek yapmanız gereken birkaç dakika ayırmak. Deneyin, bakiyenizin ne kadar sürede eriyeceğine siz karar verin.",
    ],
  },
  {
    slug: "gercekten-ihtiyacin-var-mi",
    tag: "Soru",
    title: "Gerçekten İhtiyacın Var mı?",
    excerpt:
      "Sepete bir şey eklemeden önce sorman gereken tek soru bu. Cevap genelde hayır, ama sorun değil.",
    body: [
      "'Gerçekten ihtiyacın var mı?' sorusu, aslında çoğu alışverişte cevabını zaten bildiğimiz bir sorudur. Ve genelde cevap hayırdır. Ama bu, o ürünü almaktan bizi alıkoymaz — çünkü alışveriş her zaman ihtiyaçla değil, bazen sadece istekle ilgilidir.",
      "amazoff'un sloganı tam olarak bunu kutluyor: 'everything you don't actually need.' Yani gerçekten ihtiyacınız olmayan her şey. Burada kimse sizden mantıklı bir gerekçe istemiyor.",
      "Sonuçta bu bir demo cüzdan, gerçek bir fatura değil. Yani bu sefer, sorunun cevabı ne olursa olsun, sepete ekleyebilirsiniz.",
    ],
  },
];

function getBlogPostBySlug(slug) {
  return BLOG_POSTS.find((p) => p.slug === slug);
}

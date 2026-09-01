// Blog content for amazoff — 5 original, lightly humorous demo articles
// about impulse shopping / "things you don't actually need". No framework,
// just a plain JS array read by blog.html and blog-post.html. Bilingual:
// each post has a TR field and an _en counterpart.

const BLOG_POSTS = [
  {
    slug: "gereksiz-alisveris-aliskanliklari",
    tag: "Alışveriş Psikolojisi",
    tag_en: "Shopping Psychology",
    title: "İnternette En Gereksiz Alışveriş Alışkanlıkları",
    title_en: "The Most Unnecessary Online Shopping Habits",
    excerpt:
      "Sepete atıp unutmak, indirim süresi bitmeden panik satın almak ve 'belki bir gün lazım olur' diye düşünmek — hepimiz bu kulüpteyiz.",
    excerpt_en:
      "Adding to cart and forgetting, panic-buying before a discount timer runs out, thinking 'maybe I'll need it someday' — we're all in this club.",
    body: [
      "Herkesin bir 'gece 2 alışverişçisi' evresi vardır. Uyku tutmaz, telefon elimize geçer ve birdenbire ihtiyacımız olmayan bir ürün sepette belirir. Ertesi gün kargo takip numarasını görünce 'bunu ne zaman aldım' diye düşünürüz. Bu, amazoff'un varoluş sebebidir aslında: bu dürtüyü gerçek parayla değil, demo cüzdanla yaşamak.",
      "İkinci klasik alışkanlık, 'indirim bitmeden alayım' paniğidir. Ürünün gerçekten işine yarayıp yaramayacağı ikinci planda kalır, önemli olan o kırmızı sayacın sıfıra inmesidir. Sayaç sıfırlanınca da ürün zaten dolapta bir köşeye kalkar.",
      "Üçüncüsü ise 'belki bir gün lazım olur' mantığıdır. Bu mantık sayesinde evlerimiz, hiç kullanılmayan ama 'lazım olabilecek' eşyalarla dolar. amazoff'ta bu dürtüyü doyurmak, gerçek dolabınızı işgal etmeden mümkün.",
    ],
    body_en: [
      "Everyone has a '2am shopper' phase. Sleep won't come, the phone is in your hand, and suddenly an item you don't need is in the cart. The next day, seeing the tracking number, you think 'when did I even buy this?' This is basically why amazoff exists: to live out that impulse with a demo wallet instead of real money.",
      "The second classic habit is 'let me buy it before the discount ends' panic. Whether the product is actually useful becomes secondary — what matters is that red countdown hitting zero. Once it does, the item quietly retires to a corner of the closet.",
      "Third is the 'maybe I'll need it someday' logic. This is exactly how our homes fill up with things we never use but might 'need eventually'. On amazoff you can feed that urge without it ever taking up real closet space.",
    ],
  },
  {
    slug: "sepete-atip-almaman-gerekenler",
    tag: "Rehber",
    tag_en: "Guide",
    title: "Sepete Atıp Asla Almaman Gereken Şeyler",
    title_en: "Things You Should Add to Cart and Never Actually Buy",
    excerpt:
      "Bazı ürünler sepette çok daha mantıklı görünür. Gerçek hayatta karşılaştığında ise 'bu neden burada' dersin.",
    excerpt_en:
      "Some products make a lot more sense sitting in a cart. Once they show up in real life, you ask yourself 'why is this here'.",
    body: [
      "Sepete atmak ile satın almak arasında büyük bir felsefi fark vardır. Sepete atmak bir hayaldir, ücretsizdir, sorumluluk gerektirmez. Satın almak ise o hayali gerçeğe, yani dolabınıza taşır.",
      "Klasik örnek: 'bir gün lazım olur' diye alınan üçüncü şarj kablosu. Ya da 'indirimde' diye alınan, hiçbir zaman giyilmeyecek renkte bir kazak. Ya da sadece kutusu güzel diye alınan bir dekor objesi.",
      "amazoff'un güzelliği tam burada devreye giriyor: sepete attığınız her şeyi gerçekten 'satın alabilirsiniz', çünkü zaten hiçbir şey gerçek değil. Demo cüzdanınız, gerçek pişmanlığınızdan sizi koruyor.",
    ],
    body_en: [
      "There's a big philosophical gap between adding to cart and actually buying. Adding to cart is a daydream — free, consequence-free. Buying drags that daydream into reality, i.e. your closet.",
      "The classic example: a third charging cable bought 'just in case'. Or a sweater in a color you'll never wear, bought because it was on sale. Or a decor object bought purely because the box looked nice.",
      "This is exactly where amazoff shines: you can genuinely 'buy' everything you throw in the cart, because none of it was ever real to begin with. Your demo wallet protects you from real regret.",
    ],
  },
  {
    slug: "durtusel-harcama",
    tag: "Farkındalık",
    tag_en: "Awareness",
    title: "Online Alışverişte Dürtüsel Harcama",
    title_en: "Impulse Spending in Online Shopping",
    excerpt:
      "Neden bir tık uzağımızdaki her şeyi almak isteriz? Cevap sandığımızdan daha basit: çünkü çok kolay.",
    excerpt_en:
      "Why do we want to buy everything that's just one click away? The answer is simpler than you'd think: because it's easy.",
    body: [
      "Fiziksel bir mağazada bir ürünü almak için en azından kalkıp gitmemiz, elimize almamız, kasaya kadar taşımamız gerekir. Bu küçük sürtünme bile bazen bizi vazgeçirir. Online alışverişte ise tek gereken bir tık.",
      "Bu kolaylık, dürtüsel harcamanın en büyük destekçisidir. 'Sepete Ekle' ve 'Satın Al' butonları arasındaki mesafe genellikle birkaç santimetredir, birkaç saniyedir.",
      "amazoff, bu dürtüyü ortadan kaldırmıyor — tam tersine kucaklıyor. Çünkü burada satın aldığınız her şey demo cüzdanınızdan çıkıyor, gerçek bankanızdan değil. Dürtüsel harcama yapma isteğinizi zararsız bir şekilde tatmin edebilirsiniz.",
    ],
    body_en: [
      "Buying something in a physical store requires, at minimum, getting up, walking there, picking it up, and carrying it to the register. That tiny bit of friction is sometimes enough to change our minds. Online, all it takes is one click.",
      "That ease is the biggest enabler of impulse spending. The distance between 'Add to Cart' and 'Check Out' is usually a few centimeters and a few seconds.",
      "amazoff doesn't fight that impulse — it embraces it. Everything you buy here comes out of your demo wallet, not your real bank account. You get to satisfy the urge to spend impulsively, harmlessly.",
    ],
  },
  {
    slug: "10000-tl-ile-ne-alinir",
    tag: "Deneme",
    tag_en: "Experiment",
    title: "10.000 TL ile Ne Kadar Gereksiz Şey Alınabilir?",
    title_en: "How Much Unnecessary Stuff Can You Buy With 10,000 TL?",
    excerpt:
      "amazoff'ta her yeni kullanıcıya verilen 10.000 TL demo bakiyeyle gerçekten kaç 'gereksiz' ürün satın alınabiliyor, hesapladık.",
    excerpt_en:
      "We did the math on how many 'unnecessary' products you can actually buy with the 10,000 TL demo balance every new amazoff user gets.",
    body: [
      "amazoff'a kayıt olduğunuzda cüzdanınıza otomatik olarak 10.000 TL demo bakiye tanımlanıyor. Peki bu parayla gerçekten neler 'satın alınabilir'?",
      "Ortalama bir ürün fiyatımız 350-400 TL civarında. Yani teorik olarak 10.000 TL ile yaklaşık 25-28 farklı ürünü sepete ekleyip Satın Al diyebilirsiniz — kozmetikten elektroniğe, kırtasiyeden otomotive kadar 14 farklı kategoriden istediğiniz kadar.",
      "Gerçek hayatta bu kadar çeşitli bir alışveriş yapmak hem zaman hem bütçe gerektirir. amazoff'ta ise tek yapmanız gereken birkaç dakika ayırmak. Deneyin, bakiyenizin ne kadar sürede eriyeceğine siz karar verin.",
    ],
    body_en: [
      "When you sign up for amazoff, your wallet is automatically loaded with 10,000 TL in demo balance. So what can you actually 'buy' with that?",
      "Our average product price sits around 350-400 TL. That means, in theory, 10,000 TL gets you roughly 25-28 different products across all 14 categories, from cosmetics to electronics to stationery to automotive.",
      "Doing that much varied shopping in real life takes both time and budget. On amazoff, all it takes is a few minutes. Give it a try and decide for yourself how fast your balance disappears.",
    ],
  },
  {
    slug: "gercekten-ihtiyacin-var-mi",
    tag: "Soru",
    tag_en: "Question",
    title: "Gerçekten İhtiyacın Var mı?",
    title_en: "Do You Actually Need This?",
    excerpt:
      "Sepete bir şey eklemeden önce sorman gereken tek soru bu. Cevap genelde hayır, ama sorun değil.",
    excerpt_en:
      "The only question worth asking before adding something to your cart. The answer is usually no, and that's fine.",
    body: [
      "'Gerçekten ihtiyacın var mı?' sorusu, aslında çoğu alışverişte cevabını zaten bildiğimiz bir sorudur. Ve genelde cevap hayırdır. Ama bu, o ürünü almaktan bizi alıkoymaz — çünkü alışveriş her zaman ihtiyaçla değil, bazen sadece istekle ilgilidir.",
      "amazoff'un sloganı tam olarak bunu kutluyor: 'everything you don't actually need.' Yani gerçekten ihtiyacınız olmayan her şey. Burada kimse sizden mantıklı bir gerekçe istemiyor.",
      "Sonuçta bu bir demo cüzdan, gerçek bir fatura değil. Yani bu sefer, sorunun cevabı ne olursa olsun, sepete ekleyebilirsiniz.",
    ],
    body_en: [
      "'Do you actually need this?' is a question we usually already know the answer to before we even ask it. And the answer is usually no. But that rarely stops us — because shopping isn't always about need, sometimes it's just about want.",
      "amazoff's slogan celebrates exactly that: 'everything you don't actually need.' Nobody here is asking you for a rational justification.",
      "At the end of the day, it's a demo wallet, not a real bill. So this time, whatever the answer to the question is, go ahead and add it to the cart.",
    ],
  },
];

function getBlogPostBySlug(slug) {
  return BLOG_POSTS.find((p) => p.slug === slug);
}

function blogTag(post) {
  return typeof tt === "function" ? tt(post.tag, post.tag_en) : post.tag;
}
function blogTitle(post) {
  return typeof tt === "function" ? tt(post.title, post.title_en) : post.title;
}
function blogExcerpt(post) {
  return typeof tt === "function" ? tt(post.excerpt, post.excerpt_en) : post.excerpt;
}
function blogBody(post) {
  return typeof currentLang !== "undefined" && currentLang === "en" ? post.body_en : post.body;
}

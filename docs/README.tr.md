# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

NAS sayfasını açık tutmadan indirilenleri UGOS Pro altındaki UGREEN NAS'ın **İndirilenler** uygulamasına göndermek için bir macOS uygulaması ve Safari uzantısı.

Kaynaklar ve DMG sürümü: **0.6.1**. UGREEN veya Apple'a bağlı olmayan bağımsız topluluk projesi.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

Uygulama ve uzantı arayüzü 34 dilde mevcuttur.

## Özellikler

- Safari'de yetkili sitelerdeki `.torrent` ve `magnet:` bağlantıların ele geçirilmesi.
- Eylem **Doğrudan erişilebilen bir bağlantıya, resme, videoya veya ses öğesine sağ tıklayarak **NAS'a indirin**.
- Uzantı menüsünden manuel olarak bir URL gönderme.
- MacOS Keychain'de hesap ve oturum; İki faktörlü kimlik doğrulama ve cihaz güveni desteği.
- UGREEN çevrimiçi hizmetini veya manuel HTTPS adresini kullanarak isteğe bağlı NAS araması.
- İndirmelerin, ilerlemenin ve hızın listesi; isteğe bağlı tamamlama, kapatma ve hata bildirimleri.
- Dosya açık bir şekilde tanımlandığında indirme sonrasında ad düzeltmesi ile HTTP dosya adlarının ve türlerinin tanımlanması.
- Yerel açık ve koyu simgeler ve sistem temasına uyarlanmış Safari logoları.

## Uyumluluk

Proje **macOS 27 veya üzeri** için yapılandırılmıştır ve Apple Silicon için **Xcode 27.1** ile derlenmiştir. NAS testi **DXP2800**, **UGOS Pro 1.20.0.0142** ve **İndirilenler 1.19.1.0004** ile gerçekleştirilmiştir. Diğer sürümler garanti edilmez: Entegrasyon, istikrarlı bir UGREEN kamu sözleşmesi olmadan, gözlemlenen API'lere dayalıdır.

## DMG'den yükleyin

[Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.1) için UGREEN NAS İndir 0.6.1'ı indirin.

1. DMG'yi açın, **UGREEN NAS İndirme**'yi **Uygulamalar**'a sürükleyin ve ardından uygulamayı açın.
2. **Safari → Ayarlar → Gelişmiş**'de web geliştiricilerine yönelik özellikleri etkinleştirin. **Geliştirici**'de **İmzasız uzantılara izin ver**'i etkinleştirin, ardından **Uzantılar**'da **UGREEN NAS İndirme**'yi etkinleştirin.
3. Uzantı ayarlarında NAS'ı yapılandırın.

Bu genel paket yerel olarak imzalanmıştır (geçici) ve noter tasdikli değildir. macOS ilk açılışını engelleyebilir. Safari, tarayıcıdan çıktıktan sonra imzasız uzantıların yeniden etkinleştirilmesini isteyebilir.

## Kaynaktan derle

1. Bu depoyu klonlayın ve `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`'yi açın.
2. **İmzalama ve Yetenekler** bölümünde iki hedef için kendi Apple ekibinizi seçin: uygulama ve uzantısı. Depoya hiçbir kişisel ekip girilmez.
3. **UGREEN NAS İndirme** şemasını seçin, **MyMac** hedefini seçin, ardından Xcode ile derleyin ve başlatın.
4. **Safari → Ayarlar → Uzantılar** bölümünde uzantıyı etkinleştirin, ardından istediğiniz siteleri yetkilendirin.
5. Uzantı ayarlarını açın ve NAS'ınızı aşağıda açıklandığı şekilde yapılandırın.

Örnek paket kimlikleri `com.example.UGREENNASDownload` ve `com.example.UGREENNASDownload.Extension`'dir. Bunları imzanız için özelleştirmeniz gerekiyorsa, Xcode proje tanımlayıcılarını **ve** `Extension/background.js` ve `ViewController.swift`'deki karşılık gelen sabitleri değiştirin: değerler tutarlı kalmalıdır.

Bu genel sürüm, kişisel gelişim uygulamasından ayrı olarak tanımlayıcılar ve bir Anahtarlık alanı kullanır. Kendi NAS yapılandırmasını gerektirir. Geliştirici imzası noter tasdikli bir dağıtım teşkil etmez ve aktivasyon, imzanıza uygun Safari geliştirici ayarlarını gerektirebilir.

Bir derlemeyi imzasız olarak kontrol etmek için havuzun kökünden:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Bu kontrol imzasız bir başvuru oluşturur; Safari'de kullanılabilecek bir geliştirme kurulumu için Apple ekibinizi kullanın. Depo ağacını koruyun: `Extension` ve `Design`'ye yapılan Xcode referansları görecelidir.

## NAS'ı yapılandırma

1. NAS'ın HTTPS adresini bağlantı noktası, tanımlayıcınız ve NAS üzerindeki mutlak hedef yolu ile birlikte girin. Kişisel alanlar varsayılan olarak boştur.
2. **SIN sertifikasını kontrol et**'i tıklayın. Sertifikayı onaylamadan önce SHA-256 parmak izini güvenilir bir kaynakla karşılaştırın.
3. Şifreyi ve gerekirse çift kimlik doğrulama kodunu girin. Cihaza güvenmek isteğe bağlıdır; bu olmadan oturumun süresi dolduğunda yeni bir kod gerekebilir.
4. **Bağlantıyı kaydet ve test et**'i tıklayın. MacOS talep ettiğinde yerel ağ erişimine izin verin.
5. İstenirse torrentlerin ve mıknatısların otomatik olarak durdurulmasını etkinleştirin. Sağ tıklama ve manuel gönderme bu anahtardan bağımsız kalır.

Adres, hesap ve klasör yine de ayarlardan değiştirilebilir. **Bu hesabı unut**, hesabı ve mevcut Safari profiline ait Anahtar Zinciri oturumunu siler.

## Güvenlik ve Çalıştırma

Web sayfaları hesabı yapılandıramaz veya bir sertifikaya güvenemez. Uzantı, Swift modülüyle yerel mesajlaşma yoluyla iletişim kurar. NAS istekleri, geçici depolama ve sayfa komut dosyası oluşturma devre dışı bırakılmış, yalıtılmış bir WebKit motorundan geçer; sertifikanın onaylanan parmak iziyle eşleşmesi gerekir. NAS yönlendirmeleri reddedilir. Parola, NAS tarafından HTTPS üzerinden sağlanan RSA anahtarıyla şifrelenir.

Parola, belirteç ve oturum açma bilgileri web depolama alanında veya bu depoda değil, Anahtarlık'ta saklanır. Geçici kod kullanımdan sonra silinir. Çerezler ve Safari site tanımlayıcıları hiçbir zaman NAS'a iletilmez. Aynı sitedeki bazı torrentler için küçük dosya, Safari oturumuyla bellekten alınır, ardından yerel yedekleme veya SMB olmadan NAS'a iletilir; boyutu 512 KiB ile sınırlıdır.

Otomatik arama gönüllü olarak `api.ugnas.com` sorgusunu sorgular: bu hizmet bağlantının genel IP adresini görür ancak bir parola veya NAS belirteci almaz. Manuel giriş bu hizmete bağlı değildir.

Belirsiz bir yanıt veya son teslim tarihi geçtikten sonra yeni ekleme yapılmaya çalışılmaz. Yeniden bağlanmaya ve yeni bir denemeye yalnızca kimlik doğrulamanın açıkça reddedilmesinden sonra izin verilir. **NAS tarafından kabul edilen bir görev, indirme işleminin tamamlandığının kanıtı değildir.**

## Sınırlar

- Safari, indirilenlerin tümünü evrensel olarak değiştirmenize izin vermez. Otomatik müdahale, tanınan torrent bağlantılarını ve mekanizmalarını kapsar; sağ tıklama ve manuel giriş bu işlemi tamamlar.
- Bir HTTP bağlantısına doğrudan NAS tarafından erişilebilmelidir. Site oturumu korumalı içerikler, süresi dolmuş URL'ler, korumalı videolar ve `blob:` veya `data:`'de oluşturulan sıradan dosyalar, genel bağlantılara dönüştürülmez.
- Menü takibi her yanıttan sonra yaklaşık 3,5 saniye bekler; bildirimler ve ad düzeltmeleri yaklaşık her 30 saniyede bir kontrol edilir. Safari'nin kapalı olması, askıya alınması veya uyku halindeki bir Mac bu işlemleri geciktirebilir.
- Bilinmeyen formatlar icat edilmiş bir uzantı almaz. Yeniden adlandırma, indirme işlemi tamamlandıktan sonra gerçekleşir; gerçek dosya sabitlenirken İndirme geçmişi orijinal adını koruyabilir.
- Düzeltmeler, zorunlu değiştirme olmaksızın, en fazla 100 bekleyen işlem ve yedi günlük bir saklama süresiyle, açıkça tanımlanan yeni HTTP görevleriyle sınırlı kalır. Listeler kategori başına 10.000 görevle sınırlıdır.
- Genel macOS simge ayarı öncelikli olmaya devam ediyor: **Koyu → Otomatik** temayı takip etmenize olanak tanır. Safari uzantıları listesindeki statik simge, anlaşılır sürümünde kalır; menü ve seçenekler logoları temayı takip ediyor.

## Geliştirme ve test

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

JavaScript testi Node.js gerektirir; Yerel test; macOS, Xcode araçları, Python 3 ve OpenSSL gerektirir. 18443 numaralı bağlantı noktasında geçici bir yerel HTTPS sunucusu başlatırlar ve herhangi bir gerçek NAS hesabı kullanmazlar. 0.5.1 denetimi 45 JavaScript testini ve 121 yerel kontrolü içeriyordu. Bkz. [rapor](../AUDIT-0.5.1.md).

- `Extension/`: menü, ayarlar, Safari komut dosyaları ve simgeler.
- `Xcode/`: AppKit uygulaması, Swift modülü, kimlik doğrulama ve NAS aktarımı.
- `Design/Adaptive/UGREENIcon.icon/`: Açık ve koyu görünümlere sahip yerel simge.
- `Design/generate-icons.swift`: PNG'lerin oluşturulması ve pencerenin uyarlanabilir logosu.
- `Tests/`: güvenlik testleri, veri doğrulama ve davranış.

## Referanslar

- [ugnas-api topluluk istemcisi](https://github.com/Fracizz/ugnas-api): protokol referansı, bir NAS sayfasından yüklenen üçüncü taraf kodu olmadan.
- [UGREEN topluluk entegrasyonu](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): çift kimlik doğrulama referansı.
- [Apple Safari Web Uzantıları belgeleri](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Bir sorunu bildirmek için herhangi bir şifre, geçici kod, belirteç, imzalı URL, özel torrent veya Anahtarlık dışa aktarımı eklemeyin. Örneklerde hayali veriler kullanın.

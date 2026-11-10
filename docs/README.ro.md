# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

O aplicație macOS și o extensie Safari pentru a trimite descărcări către aplicația **Descărcări** a unui UGREEN NAS sub UGOS Pro, fără a menține deschisă pagina NAS.

Surse și versiunea DMG: **0.6.0**. Proiect comunitar independent, neafiliat cu UGREEN sau Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

Aplicația și interfața extensiei sunt disponibile în 34 de limbi.

## Caracteristici

- Interceptarea linkurilor `.torrent` și `magnet:` de pe site-uri autorizate în Safari.
- Acțiune **Descărcați pe NAS** făcând clic dreapta pe un link accesibil direct, pe un element de imagine, video sau audio.
- Trimiterea manuală a unei adrese URL din meniul extensiei.
- Cont și sesiune în macOS Keychain; Suport pentru autentificare cu doi factori și încredere în dispozitiv.
- Căutare NAS opțională folosind serviciul online UGREEN sau adresa HTTPS manuală.
- Lista de descărcări, progres și viteză; notificări opționale de finalizare, oprire și erori.
- Identificarea numelor și tipurilor de fișiere HTTP, cu corecția numelui după descărcare, atunci când fișierul este identificat fără ambiguitate.
- Pictograme native luminoase și întunecate și sigle Safari adaptate temei sistemului.

## Compatibilitate

Proiectul este configurat pentru **macOS 27 sau o versiune ulterioară** și a fost compilat cu **Xcode 27.1**, pentru Apple Silicon. Testarea NAS a fost efectuată cu un **DXP2800**, **UGOS Pro 1.20.0.0142** și **Descărcări 1.19.1.0004**. Alte versiuni nu sunt garantate: integrarea se bazează pe API-uri observate, fără un contract public stabil UGREEN.

## Instalați din DMG

[Descărcați UGREEN NAS Download 0.6.0 pentru Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.0).

1. Deschideți DMG, trageți **UGREEN NAS Download** în **Aplicații**, apoi deschideți aplicația.
2. În **Safari → Setări → Avansat**, activați funcțiile pentru dezvoltatorii web. În **Developer**, activați **Permite extensii nesemnate**, apoi activați **UGREEN NAS Download** în **Extensions**.
3. Configurați NAS în setările extensiei.

Acest pachet public este semnat local (ad-hoc) și nu este legalizat. macOS poate bloca deschiderea sa inițială. Safari poate cere reactivarea extensiilor nesemnate după părăsirea browserului.

## Compilați de la sursă

1. Clonează acest depozit și deschide `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. În **Semnare și capabilități**, alegeți propria echipă Apple pentru cele două ținte: aplicația și extensia acesteia. Nicio echipă personală nu este introdusă în depozit.
3. Alegeți schema **UGREEN NAS Download**, destinația **My Mac**, apoi compilați și lansați cu Xcode.
4. Activați extensia în **Safari → Setări → Extensii**, apoi autorizați site-urile dorite.
5. Deschideți setările extensiei și configurați NAS-ul așa cum este descris mai jos.

Exemplele de ID-uri de pachet sunt `com.example.UGREENNASDownload` și `com.example.UGREENNASDownload.Extension`. Dacă trebuie să le personalizați pentru semnătura dvs., modificați identificatorii proiectului Xcode **și** constantele corespunzătoare în `Extension/background.js` și `ViewController.swift`: valorile ar trebui să rămână consistente.

Această ediție publică folosește identificatori și un spațiu Keychain separat de aplicația de dezvoltare personală. Necesită propria configurație NAS. Semnătura dezvoltatorului nu constituie o distribuție legalizată și activarea poate necesita setări de dezvoltator Safari adecvate semnăturii dvs.

Pentru a verifica o compilație fără semnătură, din rădăcina depozitului:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Această verificare produce o cerere nesemnată; Folosiți-vă echipa Apple pentru o instalare de dezvoltare care poate fi utilizată în Safari. Păstrați arborele de depozit: referințele Xcode la `Extension` și `Design` sunt relative.

## Configurați NAS

1. Introduceți adresa HTTPS a NAS-ului cu portul său, identificatorul dvs. și calea de destinație absolută pe NAS. Câmpurile personale sunt goale în mod implicit.
2. Faceți clic pe **Verificați certificatul SIN**. Comparați amprenta SHA-256 cu o sursă de încredere înainte de a confirma certificatul.
3. Introduceți parola și, dacă este necesar, un cod dublu de autentificare. Încrederea în dispozitiv este opțională; fără acesta, poate fi necesar un nou cod la expirarea sesiunii.
4. Faceți clic pe **Salvați și testați conexiunea**. Permiteți accesul la rețeaua locală atunci când macOS îl solicită.
5. Activați interceptarea automată a torenților și magneților, dacă doriți. Clic-dreapta și trimiterea manuală rămân independente de acest comutator.

Adresa, contul și folderul pot fi modificate în continuare în setări. **Uitați acest cont** șterge contul și sesiunea de breloc pentru profilul Safari curent.

## Siguranță și funcționare

Paginile web nu pot configura contul sau nu pot avea încredere într-un certificat. Extensia comunică cu modulul său Swift prin mesagerie nativă. Solicitările NAS trec printr-un motor WebKit izolat cu stocarea efemeră și scriptarea paginii dezactivată; certificatul trebuie să se potrivească cu amprenta digitală aprobată. Redirecționările NAS sunt refuzate. Parola este criptată cu cheia RSA furnizată de NAS, prin HTTPS.

Parola, simbolul și informațiile de conectare sunt stocate în Keychain, nu în stocarea web sau în acest depozit. Codul temporar este șters după utilizare. Cookie-urile și identificatorii site-ului Safari nu sunt niciodată transmise către NAS. Pentru unele torrente de pe același site, fișierul mic este preluat din memorie cu sesiunea Safari, apoi transmis pe NAS fără backup local sau SMB; dimensiunea sa este limitată la 512 KiB.

Căutarea automată interogează voluntar `api.ugnas.com`: acest serviciu vede adresa IP publică a conexiunii, dar nu primește o parolă sau un token NAS. Introducerea manuală nu depinde de acest serviciu.

Nu se încearcă adăugări noi după un răspuns ambiguu sau după expirarea unui termen limită. O reconectare și o nouă încercare sunt permise numai după un refuz explicit de autentificare. **O sarcină acceptată de NAS nu este o dovadă că descărcarea este completă.**

## Limite

- Safari nu vă permite să înlocuiți universal toate descărcările sale. Interceptarea automată acoperă link-uri și mecanisme de torrent recunoscute; clic dreapta și introducerea manuală completează această operațiune.
- O legătură HTTP trebuie să fie accesibilă direct de către NAS. Conținutul protejat de sesiunea site-ului, adresele URL expirate, videoclipurile protejate și fișierele obișnuite generate în `blob:` sau `data:` nu sunt convertite în link-uri publice.
- Urmărirea meniului așteaptă aproximativ 3,5 secunde după fiecare răspuns; notificările și corecțiile de nume sunt verificate aproximativ la fiecare 30 de secunde. Safari închis, suspendat sau un Mac adormit poate întârzia aceste operațiuni.
- Formatele necunoscute nu primesc o extensie inventată. Redenumirea are loc după ce descărcarea este finalizată; fișierul real este reparat, în timp ce istoricul descărcărilor își poate păstra numele original.
- Remedierile rămân limitate la sarcini HTTP noi identificate fără ambiguitate, fără înlocuire forțată, cu maximum 100 de operațiuni în așteptare și o păstrare de șapte zile. Listele sunt limitate la 10.000 de sarcini per categorie.
- Setarea globală a pictogramei macOS rămâne prioritară: **Întunecat → Automat** vă permite să urmăriți tema. Pictograma statică din lista de extensii Safari rămâne în versiunea sa clară; siglele meniului și ale opțiunilor urmează tema.

## Dezvoltare și testare

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

Testarea JavaScript necesită Node.js; Testarea nativă necesită macOS, instrumente Xcode, Python 3 și OpenSSL. Ei pornesc un server HTTPS local temporar pe portul 18443 și nu folosesc niciun cont NAS real. Auditul 0.5.1 a inclus 45 de teste JavaScript și 121 de controale native. Vezi [raport](../AUDIT-0.5.1.md).

- `Extension/`: meniu, setări, scripturi Safari și pictograme.
- `Xcode/`: aplicație AppKit, modul Swift, autentificare și transport NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Pictogramă nativă cu apariții luminoase și întunecate.
- `Design/generate-icons.swift`: generarea PNG-urilor și logo-ul adaptiv al ferestrei.
- `Tests/`: teste de securitate, validare a datelor și comportament.

## Referințe

- [client comunitar ugnas-api](https://github.com/Fracizz/ugnas-api): referință de protocol, fără cod terță parte încărcat de pe o pagină NAS.
- [Integrarea comunității UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): referință pentru autentificarea dublă.
- [Documentația Apple Safari Web Extensions](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Pentru a raporta o problemă, nu atașați parole, coduri temporare, jetoane, adrese URL semnate, torrente private sau exporturi de chei. Folosiți date fictive în exemple.

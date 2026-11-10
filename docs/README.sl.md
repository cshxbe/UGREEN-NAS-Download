# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

Aplikacija macOS in razširitev Safari za pošiljanje prenosov v aplikacijo **Prenosi** za NAS UGREEN pod UGOS Pro, ne da bi stran NAS ostala odprta.

Viri in različica DMG: **0.6.0**. Neodvisen projekt skupnosti, ki ni povezan z UGREEN ali Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

Vmesnik aplikacije in razširitve je na voljo v 34 jezikih.

## Lastnosti

- Prestrezanje povezav `.torrent` in `magnet:` na straneh, odobrenih v Safari.
- Dejanje **Prenesi na NAS** z desnim klikom na neposredno dostopno povezavo, sliko, video ali zvočni element.
- Ročno pošiljanje URL iz razširitvenega menija.
- Račun in seja v Keychainu macOS; Podpora za dvostopenjsko avtentikacijo in zaupanje naprave.
- Izbirno poiščite NAS s spletno storitvijo UGREEN ali naslovite HTTPS ročno.
- Seznam prenosov, napredek in hitrost; neobvezno dokončanje, zaustavitev in obvestila o napakah.
- Identifikacija imen in tipov datotek HTTP, s popravkom imena po prenosu, ko je datoteka nedvoumno identificirana.
- Izvorne svetle in temne ikone ter logotipi Safari, prilagojeni sistemski temi.

## Združljivost

Projekt je konfiguriran za **macOS 27 ali novejšo** in je bil preveden z **Xcode 27.1** za Apple Silicon. Preizkusi NAS so bili izvedeni z **DXP2800**, **UGOS Pro 1.20.0.0142** in **Prenosi 1.19.1.0004**. Druge različice niso zajamčene: integracija temelji na opazovanih API-jih brez stabilne javne pogodbe UGREEN.

## Namestite iz DMG

[Prenos UGREEN NAS Download 0.6.0 za Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.0).

1. Odprite DMG, povlecite **UGREEN NAS Download** v **Aplikacije** in nato odprite aplikacijo.
2. V **Safari → Nastavitve → Napredno** omogočite funkcije za spletne razvijalce. V **Razvijalec** omogočite **Dovoli nepodpisane razširitve**, nato omogočite **UGREEN NAS Download** v **Razširitve**.
3. V nastavitvah razširitve konfigurirajte NAS.

Ta javni paket je podpisan lokalno (ad hoc) in ni overjen pri notarju. macOS lahko blokira njegovo začetno odpiranje. Safari lahko po izhodu iz brskalnika zahteva ponovno omogočitev dovoljenja za nepodpisane razširitve.

## Prevedi iz vira

1. Klonirajte to skladišče in odprite `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. V **Podpisovanju in zmožnostih** izberite lastno Apple ekipo za dva cilja: aplikacijo in njeno razširitev. V repozitorij ni vpisana osebna ekipa.
3. Izberite shemo **UGREEN NAS Download**, cilj **My Mac**, nato prevedite in zaženite z Xcode.
4. Aktivirajte razširitev v **Safari → Nastavitve → Razširitve**, nato avtorizirajte želena mesta.
5. Odprite nastavitve razširitve in konfigurirajte svoj NAS, kot je opisano spodaj.

Primera ID-jev svežnja sta `com.example.UGREENNASDownload` in `com.example.UGREENNASDownload.Extension`. Če jih morate prilagoditi za svoj podpis, spremenite identifikatorje projekta Xcode **in** ustrezne konstante v `Extension/background.js` in `ViewController.swift`: vrednosti morajo ostati dosledne.

Ta javna izdaja uporablja identifikatorje in prostor Keychain, ločen od aplikacije za osebni razvoj. Zahteva lastno konfiguracijo NAS. Razvojni podpis ne predstavlja notarsko overjene distribucije in aktivacija lahko zahteva razvojne nastavitve Safari, ki ustrezajo vašemu podpisu.

Če želite preveriti kompilacijo brez podpisa, iz korena repozitorija:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

To preverjanje ustvari nepodpisano aplikacijo; uporabite svojo ekipo Apple za razvojno namestitev, uporabno v Safari. Ohranite drevo repozitorija: sklicevanja Xcode na `Extension` in `Design` so relativna.

## Konfiguriraj NAS

1. Vnesite naslov HTTPS od NAS z njegovimi vrati, identifikatorjem in absolutno ciljno potjo na NAS. Osebna polja so privzeto prazna.
2. Kliknite **Preveri potrdilo NAS**. Primerjajte prstni odtis SHA-256 z zaupanja vrednim virom, preden potrdite potrdilo.
3. Vnesite geslo in po potrebi dvojno kodo za preverjanje pristnosti. Zaupanje napravi ni obvezno; brez nje bo morda potrebna nova koda, ko se seja izteče.
4. Kliknite **Shrani in preizkusi povezavo**. Dovoli dostop do lokalnega omrežja, ko macOS to zahteva.
5. Po želji omogočite samodejno prestrezanje torrentov in magnetov. Desni klik in ročno pošiljanje ostajata neodvisna od tega stikala.

Naslov, račun in mapo lahko še vedno spremenite v nastavitvah. **Če pozabite ta račun** izbrišete račun in njegovo sejo Keychain za trenutni profil Safari.

## Varnost in delovanje

Spletne strani ne morejo konfigurirati računa ali zaupati potrdilu. Razširitev komunicira s svojim modulom Swift prek izvornega sporočanja. NAS zahteve gredo prek izoliranega mehanizma WebKit z onemogočenimi efemernimi shrambami in skripti strani; potrdilo se mora ujemati z odobrenim prstnim odtisom. NAS preusmeritve so zavrnjene. Geslo je šifrirano s ključem RSA, ki ga je zagotovil NAS, dne HTTPS.

Geslo, žeton in podatki za prijavo so shranjeni v Keychainu, ne v spletni shrambi ali tem repozitoriju. Začasna koda se po uporabi izbriše. Piškotki in identifikatorji spletnih mest Safari se nikoli ne prenesejo na NAS. Pri nekaterih torrentih z iste strani se majhna datoteka pridobi v pomnilniku s sejo Safari, nato pa se prenese na NAS brez lokalnega shranjevanja ali SMB; njegova velikost je omejena na 512 KiB.

Samodejno iskanje prostovoljno poizveduje `api.ugnas.com`: ta storitev vidi javni naslov IP povezave, vendar ne prejme gesla ali žetona NAS. Ročni vnos ni odvisen od te storitve.

Po dvoumnem odgovoru ali pretečenem roku se ne poskuša dodajati novih. Ponovna povezava in nov poskus sta dovoljena samo po izrecni zavrnitvi avtentikacije. **Naloga, ki jo sprejme NAS, ni dokaz, da je prenos končan.**

## Omejitve

- Safari ne nadomesti univerzalno vseh svojih prenosov. Samodejno prestrezanje zajema prepoznane hudourniške povezave in mehanizme; desni klik in ročni vnos dokončata to operacijo.
- Povezava HTTP mora biti dostopna neposredno prek NAS. Zaščitena vsebina seje spletnega mesta, potekla URL, zaščiteni videoposnetki in običajne datoteke, ustvarjene v `blob:` ali `data:`, se ne pretvorijo v javne povezave.
- Sledenje menija počaka približno 3,5 sekunde po vsakem odgovoru; obvestila in popravki imen se preverjajo približno vsakih 30 sekund. Safari zaprt, začasno ustavljen ali Mac v stanju spanja lahko zakasni te operacije.
- Neznani formati ne dobijo izmišljene razširitve. Preimenovanje se izvede po končanem prenosu; dejanska datoteka je popravljena, medtem ko lahko zgodovina prenosov ohrani svoje izvirno ime.
- Popravki ostajajo omejeni na nove naloge HTTP, ki so nedvoumno identificirane, brez prisilne zamenjave, z največ 100 čakajočimi operacijami in hrambo sedem dni. Seznami so omejeni na 10.000 nalog na kategorijo.
- Globalna nastavitev macOS ikon ostaja prednostna: **Temno → Samodejno** vam omogoča, da sledite temi. Ikona seznama statičnih razširitev Safari ohranja svojo jasno različico; logotipi menija in možnosti sledijo temi.

## Razvoj in testiranje

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

Testiranje JavaScript zahteva Node.js; Izvorno testiranje zahteva orodja macOS, Xcode, Python 3 in OpenSSL. Zaženejo začasni lokalni strežnik HTTPS na vratih 18443 in ne uporabljajo nobenega pravega računa NAS. Revizija 0.5.1 je vključevala 45 testov JavaScript in 121 izvornih kontrol. Glej [poročilo](../AUDIT-0.5.1.md).

- `Extension/`: meni, nastavitve, skripte Safari in ikone.
- `Xcode/`: Aplikacija AppKit, modul Swift, avtentikacija in transport NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Izvorna ikona s svetlim in temnim videzom.
- `Design/generate-icons.swift`: ustvarjanje PNG in prilagodljivega logotipa okna.
- `Tests/`: varnostni testi, preverjanje podatkov in obnašanje.

## Reference

- [odjemalec skupnosti ugnas-api](https://github.com/Fracizz/ugnas-api): sklic na protokol, brez kode tretje osebe, naložene s strani NAS.
- [Integracija skupnosti UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): referenca za dvojno preverjanje pristnosti.
- [Dokumentacija Apple Safari Spletne razširitve](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Če želite prijaviti težavo, ne priložite nobenega gesla, začasne kode, žetona, podpisanega URL, zasebnega torrenta ali izvoza Keychain. V primerih uporabite izmišljene podatke.

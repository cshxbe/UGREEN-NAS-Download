# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

Aplikacija macOS i proširenje Safari za slanje preuzimanja u aplikaciju **Preuzimanja** NAS UGREEN-a pod UGOS Pro, bez zadržavanja otvorene stranice NAS.

Izvori i DMG verzija: **0.6.1**. Neovisni projekt zajednice, nije povezan s UGREEN-om ili Appleom.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

Sučelje aplikacije i proširenja dostupno je na 34 jezika.

## Značajke

- Presretanje poveznica `.torrent` i `magnet:` na stranicama ovlaštenim u Safari.
- Akcija **Preuzmi na NAS** desnim klikom na izravno dostupnu vezu, sliku, video ili audio element.
- Ručno slanje URL iz izbornika proširenja.
- Račun i sesija u Keychain macOS; Podrška za dvofaktorsku autentifikaciju i povjerenje uređaja.
- Izborno traženje NAS putem UGREEN online usluge ili ručne adrese HTTPS.
- Popis preuzimanja, napredak i brzina; izborni završetak, isključivanje i obavijesti o pogreškama.
- Identifikacija naziva i tipova datoteka HTTP, s ispravkom naziva nakon preuzimanja kada je datoteka nedvosmisleno identificirana.
- Izvorne svijetle i tamne ikone i Safari logotipi prilagođeni temi sustava.

## Kompatibilnost

Projekt je konfiguriran za **macOS 27 ili noviji** i kompajliran je s **Xcode 27.1**, za Apple Silicon. NAS testovi obavljeni su s **DXP2800**, **UGOS Pro 1.20.0.0142** i **Preuzimanja 1.19.1.0004**. Ostale verzije nisu zajamčene: integracija se temelji na promatranim API-jima, bez stabilnog javnog ugovora UGREEN.

## Instalirajte iz DMG-a

[Preuzmite UGREEN NAS Download 0.6.1 za Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.1).

1. Otvorite DMG, povucite **UGREEN NAS Download** u **Aplikacije**, zatim otvorite aplikaciju.
2. U **Safari → Postavke → Napredno** omogućite značajke za web programere. U **Developer**, omogućite **Allow unsigned extensions**, zatim omogućite **UGREEN NAS Download** u **Extensions**.
3. Konfigurirajte NAS u postavkama proširenja.

Ovaj javni paket je potpisan lokalno (ad hoc) i nije ovjeren kod javnog bilježnika. macOS može blokirati njegovo početno otvaranje. Safari može tražiti da ponovno omogući dozvolu za nepotpisana proširenja nakon izlaska iz preglednika.

## Prevedi iz izvora

1. Klonirajte ovo spremište i otvorite `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. U **Signing & Capabilities** odaberite vlastiti Apple tim za dva cilja: aplikaciju i njezino proširenje. U repozitorij se ne upisuje osobni tim.
3. Odaberite shemu **UGREEN NAS Download**, odredište **My Mac**, zatim prevedite i pokrenite sa Xcode.
4. Aktivirajte proširenje u **Safari → Postavke → Proširenja**, zatim autorizirajte željena mjesta.
5. Otvorite postavke proširenja i konfigurirajte svoj NAS kako je opisano u nastavku.

ID-ovi primjera paketa su `com.example.UGREENNASDownload` i `com.example.UGREENNASDownload.Extension`. Ako ih trebate prilagoditi za svoj potpis, promijenite identifikatore projekta Xcode **i** odgovarajuće konstante u `Extension/background.js` i `ViewController.swift`: vrijednosti moraju ostati dosljedne.

Ovo javno izdanje koristi identifikatore i Keychain prostor odvojen od aplikacije za osobni razvoj. Zahtijeva vlastitu konfiguraciju NAS. Razvojni potpis ne predstavlja ovjerenu distribuciju i aktivacija može zahtijevati razvojne postavke Safari prikladne za vaš potpis.

Za provjeru kompilacije bez potpisa, iz korijena repozitorija:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Ova provjera proizvodi nepotpisanu aplikaciju; koristite svoj Apple tim za upotrebljivu razvojnu instalaciju u Safari. Zadržite stablo repozitorija: reference Xcode na `Extension` i `Design` su relativne.

## Konfigurirajte NAS

1. Unesite HTTPS adresu NAS s njegovim priključkom, vašim identifikatorom i apsolutnim odredišnim putem na NAS. Osobna polja su prema zadanim postavkama prazna.
2. Kliknite **Provjeri NAS certifikat**. Prije potvrde certifikata usporedite otisak prsta SHA-256 s pouzdanim izvorom.
3. Unesite lozinku i, ako je potrebno, dvostruki autentifikacijski kod. Vjerovati uređaju nije obavezno; bez njega može biti potreban novi kod kada sesija istekne.
4. Kliknite **Spremi i testiraj vezu**. Dopusti pristup lokalnoj mreži kada to zatraži macOS.
5. Po želji omogućite automatsko presretanje torrenta i magneta. Desni klik i ručno slanje ostaju neovisni o ovom prekidaču.

Adresa, račun i mapa još uvijek se mogu mijenjati u postavkama. **Zaboravljanje ovog računa** briše račun i njegovu Keychain sesiju za trenutni Safari profil.

## Sigurnost i rad

Web stranice ne mogu konfigurirati račun ili vjerovati certifikatu. Proširenje komunicira sa svojim Swift modulom putem izvornih poruka. Zahtjevi NAS prolaze kroz izolirani WebKit mehanizam s onemogućenom privremenom pohranom i skriptiranjem stranica; certifikat mora odgovarati odobrenom otisku prsta. NAS preusmjeravanja su odbijena. Lozinka je šifrirana pomoću ključa RSA koji daje NAS do HTTPS.

Lozinka, token i podaci za prijavu pohranjeni su u Keychainu, a ne u web pohrani ili ovom repozitoriju. Privremeni kod se briše nakon korištenja. Kolačići i identifikatori sa stranica Safari nikad se ne prenose na NAS. Za neke torrente s iste stranice, mala datoteka se dohvaća u memoriju sa sesijom Safari, zatim se prenosi na NAS bez lokalnog spremanja ili SMB; njegova je veličina ograničena na 512 KiB.

Automatsko pretraživanje dobrovoljno postavlja upite `api.ugnas.com`: ova usluga vidi javnu IP adresu veze, ali ne prima lozinku ili NAS token. Ručni unos ne ovisi o ovoj usluzi.

Ne pokušavaju se dodati novi dodaci nakon dvosmislenog odgovora ili isteka roka. Ponovno povezivanje i novi pokušaj dopušteni su samo nakon izričitog odbijanja autentifikacije. **Zadatak koji je prihvatio NAS nije dokaz da je preuzimanje dovršeno.**

## Ograničenja

- Safari ne zamjenjuje univerzalno sva svoja preuzimanja. Automatsko presretanje pokriva prepoznate torrent veze i mehanizme; desni klik i ručni unos dovršavaju ovu operaciju.
- Veza HTTP mora biti dostupna izravno putem NAS. Zaštićeni sadržaj sesije web-mjesta, URL, zaštićeni video zapisi i obične datoteke generirane u `blob:` ili `data:` ne pretvaraju se u javne veze.
- Praćenje izbornika čeka otprilike 3,5 sekunde nakon svakog odgovora; obavijesti i ispravci imena provjeravaju se otprilike svakih 30 sekundi. Safari zatvoren, suspendiran ili Mac u stanju mirovanja može odgoditi ove operacije.
- Nepoznati formati ne dobivaju izmišljeno proširenje. Preimenovanje se događa nakon završetka preuzimanja; stvarna datoteka je fiksna, dok povijest preuzimanja može zadržati izvorni naziv.
- Ispravci ostaju ograničeni na nove nedvosmisleno identificirane HTTP zadatke, bez prisilne zamjene, s najviše 100 operacija na čekanju i zadržavanjem od sedam dana. Popisi su ograničeni na 10 000 zadataka po kategoriji.
- Globalna postavka ikone macOS ostaje prioritet: **Tamno → Automatski** omogućuje praćenje teme. Statička ikona na popisu proširenja Safari ostaje u svojoj jasnoj verziji; logotipi izbornika i opcija prate temu.

## Razvoj i testiranje

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

JavaScript testiranje zahtijeva Node.js; Nativno testiranje zahtijeva alate macOS, Xcode, Python 3 i OpenSSL. Pokreću privremeni lokalni HTTPS poslužitelj na portu 18443 i ne koriste nikakve stvarne NAS račune. Revizija 0.5.1 uključivala je 45 JavaScript testova i 121 nativnu kontrolu. Vidi [izvješće](../AUDIT-0.5.1.md).

- `Extension/`: izbornik, postavke, Safari skripte i ikone.
- `Xcode/`: AppKit aplikacija, Swift modul, autentifikacija i prijenos NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Izvorna ikona sa svijetlim i tamnim izgledom.
- `Design/generate-icons.swift`: generiranje PNG-a i prilagodljivog logotipa prozora.
- `Tests/`: sigurnosno testiranje, provjera valjanosti podataka i ponašanja.

## Reference

- [ugnas-api](https://github.com/Fracizz/ugnas-api) klijent zajednice: referenca protokola, bez koda treće strane učitanog sa stranice NAS.
- [Integracija zajednice UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): referenca za dvostruku autentifikaciju.
- [Apple dokumentacija Safari Web ekstenzije](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Da biste prijavili problem, nemojte prilagati nikakvu lozinku, privremeni kod, token, potpisani URL, privatni torrent ili Keychain izvoz. Koristite fiktivne podatke u primjerima.

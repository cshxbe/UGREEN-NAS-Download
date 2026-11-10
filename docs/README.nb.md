# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

En macOS-applikasjon og en Safari-utvidelse for å sende nedlastinger til **Nedlastinger**-applikasjonen til en NAS UGREEN under UGOS Pro, uten å holde NAS-siden åpen.

Kilder og DMG-versjon: **0.6.1**. Uavhengig fellesskapsprosjekt, ikke tilknyttet UGREEN eller Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

App- og utvidelsesgrensesnittet er tilgjengelig på 34 språk.

## Funksjoner

- Avlytting av `.torrent`- og `magnet:`-lenker på nettsteder autorisert i Safari.
- Handling **Last ned til NAS** ved å høyreklikke på en direkte tilgjengelig lenke, bilde, video eller lydelement.
- Manuell sending av en URL fra utvidelsesmenyen.
- Konto og økt i nøkkelring macOS; Støtte for tofaktorautentisering og enhetstillit.
- Valgfritt søk etter NAS med UGREEN online-tjeneste, eller manuell HTTPS-adresse.
- Liste over nedlastinger, fremgang og hastighet; valgfri fullføring, avslutning og feilmeldinger.
- Identifikasjon av HTTP filnavn og typer, med navnekorrigering etter nedlasting når filen er entydig identifisert.
- Innfødte lyse og mørke ikoner, og Safari-logoer tilpasset systemtemaet.

## Kompatibilitet

Prosjektet er konfigurert for **macOS 27 eller nyere** og ble kompilert med **Xcode 27.1**, for Apple Silicon. NAS-tester ble utført med en **DXP2800**, **UGOS Pro 1.20.0.0142** og **Nedlastinger 1.19.1.0004**. Andre versjoner er ikke garantert: integrasjon er basert på observerte APIer, uten en stabil UGREEN offentlig kontrakt.

## Installer fra DMG

[Last ned UGREEN NAS Download 0.6.1 for Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.1).

1. Åpne DMG, dra **UGREEN NAS Download** inn i **Applikasjoner**, og åpne deretter appen.
2. Aktiver funksjoner for nettutviklere i **Safari → Innstillinger → Avansert**. Aktiver **Tillat usignerte utvidelser** i **Utvikler**, og aktiver deretter **UGREEN NAS Download** i **Utvidelser**.
3. Konfigurer NAS i utvidelsesinnstillingene.

Denne offentlige pakken er signert lokalt (ad hoc) og ikke attestert. macOS kan blokkere den første åpningen. Safari kan be om å aktivere tillatelse for usignerte utvidelser på nytt etter å ha avsluttet nettleseren.

## Kompiler fra kilden

1. Klon dette depotet og åpne `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. I **Signering og funksjoner** velger du ditt eget Apple-team for de to målene: applikasjonen og dens utvidelse. Ingen personlig team er lagt inn i depotet.
3. Velg skjemaet **UGREEN NAS Download**, destinasjon **Min Mac**, kompiler og start med Xcode.
4. Aktiver utvidelsen i **Safari → Innstillinger → Utvidelser**, og autoriser deretter de ønskede nettstedene.
5. Åpne utvidelsesinnstillingene og konfigurer din NAS som beskrevet nedenfor.

Eksempel på pakke-ID-ene er `com.example.UGREENNASDownload` og `com.example.UGREENNASDownload.Extension`. Hvis du trenger å tilpasse dem for signaturen din, endre prosjektidentifikatorene Xcode **og** de tilsvarende konstantene i `Extension/background.js` og `ViewController.swift`: verdiene må forbli konsistente.

Denne offentlige utgaven bruker identifikatorer og et nøkkelringområde atskilt fra applikasjonen for personlig utvikling. Den krever sin egen konfigurasjon av NAS. Utviklingssignaturen utgjør ikke en notarisert distribusjon og aktivering kan kreve Safari utviklingsinnstillinger som passer for din signatur.

For å sjekke en kompilering uten signatur, fra roten til depotet:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Denne sjekken produserer en usignert applikasjon; bruk Apple-teamet ditt for en brukbar utviklingsinstallasjon i Safari. Behold depottreet: referansene Xcode til `Extension` og `Design` er relative.

## Konfigurer NAS

1. Skriv inn HTTPS-adressen til NAS med porten, din identifikator og den absolutte destinasjonsbanen på NAS. Personlige felt er tomme som standard.
2. Klikk på **Sjekk NAS-sertifikatet**. Sammenlign SHA-256-fingeravtrykket med en pålitelig kilde før du bekrefter sertifikatet.
3. Skriv inn passordet og om nødvendig en dobbel autentiseringskode. Å stole på enheten er valgfritt; uten den kan det være nødvendig med en ny kode når økten utløper.
4. Klikk på **Lagre og test tilkoblingen**. Tillat tilgang til det lokale nettverket når macOS ber om det.
5. Aktiver automatisk avlytting av torrenter og magneter om ønskelig. Høyreklikk og manuell sending forblir uavhengig av denne bryteren.

Adressen, kontoen og mappen kan fortsatt endres i innstillingene. **Hvis du glemmer denne kontoen**, slettes kontoen og dens nøkkelringøkt for den gjeldende Safari-profilen.

## Sikkerhet og drift

Websider kan ikke konfigurere kontoen eller stole på et sertifikat. Utvidelsen kommuniserer med Swift-modulen via native meldinger. NAS-forespørsler går gjennom en isolert WebKit-motor med flyktig lagring og sideskripting deaktivert; sertifikatet må samsvare med det godkjente fingeravtrykket. NAS omdirigeringer nektes. Passordet er kryptert med RSA-nøkkelen levert av NAS, til HTTPS.

Passordet, tokenet og påloggingsinformasjonen lagres i nøkkelring, ikke i nettlagring eller dette depotet. Den midlertidige koden slettes etter bruk. Informasjonskapsler og identifikatorer fra Safari-nettsteder overføres aldri til NAS. For noen torrenter fra samme side hentes den lille filen i minnet med økten Safari, og overføres deretter til NAS uten lokal lagring eller SMB; størrelsen er begrenset til 512 KiB.

Automatisk søk spør frivillig `api.ugnas.com`: denne tjenesten ser den offentlige IP-adressen til tilkoblingen, men mottar ikke et passord eller NAS-token. Manuell inntasting er ikke avhengig av denne tjenesten.

Ingen nye tilføyelser forsøkes etter at et tvetydig svar eller en frist har gått ut. En ny tilkobling og et nytt forsøk er kun tillatt etter et eksplisitt avslag på autentisering. **En oppgave akseptert av NAS er ikke bevis på at nedlastingen er fullført.**

## Grenser

- Safari erstatter ikke alle nedlastingene. Automatisk avlytting dekker gjenkjente torrentkoblinger og mekanismer; høyreklikk og manuell inntasting fullfører denne operasjonen.
- En HTTP-kobling må være tilgjengelig direkte av NAS. Nettstedsøktbeskyttet innhold, utløpt URL, beskyttede videoer og vanlige filer generert i `blob:` eller `data:` konverteres ikke til offentlige lenker.
- Menysporing venter ca. 3,5 sekunder etter hvert svar; varsler og navnerettelser kontrolleres omtrent hvert 30. sekund. Safari lukket, suspendert eller en sovende Mac kan forsinke disse operasjonene.
- Ukjente formater mottar ikke en oppfunnet utvidelse. Gi nytt navn skjer etter at nedlastingen er fullført; den faktiske filen er fikset, mens nedlastingsloggen kan beholde sitt opprinnelige navn.
- Rettelser forblir begrenset til nye entydig identifiserte HTTP-oppgaver, uten tvungen erstatning, med maksimalt 100 ventende operasjoner og en oppbevaring på syv dager. Lister er begrenset til 10 000 oppgaver per kategori.
- Den globale macOS-ikoninnstillingen forblir prioritet: **Mørk → Automatisk** lar deg følge temaet. Det statiske ikonet i Safari utvidelseslisten forblir i sin klare versjon; meny- og alternativlogoene følger temaet.

## Utvikling og testing

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

JavaScript-testing krever Node.js; Innebygd testing krever macOS, Xcode-verktøy, Python 3 og OpenSSL. De starter en midlertidig lokal HTTPS-server på port 18443 og bruker ingen ekte NAS-kontoer. 0.5.1-revisjonen inkluderte 45 JavaScript-tester og 121 native kontroller. Se [rapporten](../AUDIT-0.5.1.md).

- `Extension/`: meny, innstillinger, Safari-skript og ikoner.
- `Xcode/`: AppKit-applikasjon, Swift-modul, autentisering og transport NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Innfødt ikon med lys og mørk utseende.
- `Design/generate-icons.swift`: generering av PNG-er og den adaptive logoen til vinduet.
- `Tests/`: sikkerhetstesting, datavalidering og oppførsel.

## Referanser

- [ugnas-api](https://github.com/Fracizz/ugnas-api) fellesskapsklient: protokollreferanse, uten tredjepartskode lastet fra en NAS-side.
- [Fellesskapsintegrasjon UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): referanse for dobbel autentisering.
- [Apple-dokumentasjon Safari Web Extensions](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

For å rapportere et problem, ikke legg ved passord, midlertidig kode, token, signert URL, privat torrent eller eksport av nøkkelring. Bruk fiktive data i eksemplene.

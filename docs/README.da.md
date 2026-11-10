# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

En macOS-applikation og en Safari-udvidelse til at sende downloads til **Downloads**-applikationen af ​​en NAS UGREEN under UGOS Pro uden at holde NAS-siden åben.

Kilder og DMG-version: **0.6.0**. Uafhængigt fællesskabsprojekt, ikke tilknyttet UGREEN eller Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

Appen og udvidelsesgrænsefladen er tilgængelig på 34 sprog.

## Funktioner

- Aflytning af `.torrent` og `magnet:` links på websteder godkendt i Safari.
- Handling **Download til NAS** ved at højreklikke på et direkte tilgængeligt link, billede, video eller lydelement.
- Manuel afsendelse af en URL fra udvidelsesmenuen.
- Konto og session i nøglering macOS; Understøttelse af to-faktor-godkendelse og enhedstillid.
- Valgfri søgning efter NAS ved hjælp af UGREEN-onlinetjenesten eller manuel HTTPS-adresse.
- Liste over downloads, fremskridt og hastighed; valgfri fuldførelse, nedlukning og fejlmeddelelser.
- Identifikation af HTTP filnavne og typer, med navnekorrektion efter download, når filen er entydigt identificeret.
- Indbyggede lyse og mørke ikoner og Safari-logoer tilpasset systemtemaet.

## Kompatibilitet

Projektet er konfigureret til **macOS 27 eller nyere** og blev kompileret med **Xcode 27.1**, til Apple Silicon. NAS tests blev udført med en **DXP2800**, **UGOS Pro 1.20.0.0142** og **Downloads 1.19.1.0004**. Andre versioner er ikke garanteret: Integration er baseret på observerede API'er uden en stabil UGREEN offentlig kontrakt.

## Installer fra DMG

[Download UGREEN NAS Download 0.6.0 til Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.0).

1. Åbn DMG, træk **UGREEN NAS Download** ind i **Applikationer**, og åbn derefter appen.
2. I **Safari → Indstillinger → Avanceret** skal du aktivere funktioner for webudviklere. I **Udvikler** skal du aktivere **Tillad usignerede udvidelser**, og derefter aktivere **UGREEN NAS Download** i **Udvidelser**.
3. Konfigurer NAS i udvidelsesindstillingerne.

Denne offentlige pakke er underskrevet lokalt (ad hoc) og ikke notariseret. macOS kan blokere dens første åbning. Safari kan bede om at genaktivere tilladelsen for usignerede udvidelser efter at have afsluttet browseren.

## Kompiler fra kilden

1. Klon dette lager og åbn `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. I **Signering og muligheder** skal du vælge dit eget Apple-team til de to mål: applikationen og dens udvidelse. Der er ikke indtastet noget personligt team i depotet.
3. Vælg skemaet **UGREEN NAS Download**, destination **Min Mac**, kompilér og start med Xcode.
4. Aktiver udvidelsen i **Safari → Indstillinger → Udvidelser**, og godkend derefter de ønskede websteder.
5. Åbn udvidelsesindstillingerne og konfigurer din NAS som beskrevet nedenfor.

Eksempler på bundt-id'er er `com.example.UGREENNASDownload` og `com.example.UGREENNASDownload.Extension`. Hvis du har brug for at tilpasse dem til din signatur, skal du ændre projektidentifikatorerne Xcode **og** de tilsvarende konstanter i `Extension/background.js` og `ViewController.swift`: Værdierne skal forblive konsistente.

Denne offentlige udgave bruger identifikatorer og et nøgleringsområde adskilt fra den personlige udviklingsapplikation. Det kræver sin egen konfiguration af NAS. Udviklingssignaturen udgør ikke en notariseret distribution, og aktivering kan kræve de Safari-udviklingsindstillinger, der passer til din signatur.

For at kontrollere en kompilering uden signatur, fra roden af depotet:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Denne kontrol frembringer en usigneret ansøgning; brug dit Apple-team til en brugbar udviklingsinstallation i Safari. Behold lagertræet: referencerne Xcode til `Extension` og `Design` er relative.

## Konfigurer NAS

1. Indtast HTTPS-adressen på NAS med dens port, din identifikator og den absolutte destinationssti på NAS. Personlige felter er tomme som standard.
2. Klik på **Kontroller NAS-certifikat**. Sammenlign SHA-256-fingeraftrykket med en pålidelig kilde, før du bekræfter certifikatet.
3. Indtast adgangskoden og om nødvendigt en dobbeltgodkendelseskode. At stole på enheden er valgfrit; uden det kan en ny kode være påkrævet, når sessionen udløber.
4. Klik på **Gem og test forbindelse**. Tillad adgang til det lokale netværk, når macOS anmoder om det.
5. Aktiver automatisk aflytning af torrents og magneter, hvis det ønskes. Højreklik og manuel afsendelse forbliver uafhængig af denne kontakt.

Adressen, kontoen og mappen kan stadig ændres i indstillingerne. **Hvis du glemmer denne konto**, slettes kontoen og dens nøglering-session for den aktuelle Safari-profil.

## Sikkerhed og drift

Websider kan ikke konfigurere kontoen eller stole på et certifikat. Udvidelsen kommunikerer med dets Swift-modul via native messaging. NAS-anmodninger går gennem en isoleret WebKit-motor med kortvarig lagring og sidescripting deaktiveret; certifikatet skal svare til det godkendte fingeraftryk. NAS omdirigeringer afvises. Adgangskoden er krypteret med RSA nøglen leveret af NAS, til HTTPS.

Adgangskoden, tokenet og loginoplysningerne gemmes i nøglering, ikke i weblageret eller dette lager. Den midlertidige kode slettes efter brug. Cookies og identifikatorer fra Safari-websteder overføres aldrig til NAS. For nogle torrents fra det samme websted hentes den lille fil i hukommelsen med sessionen Safari og overføres derefter til NAS uden lokal lagring eller SMB; dens størrelse er begrænset til 512 KiB.

Automatisk søgning forespørger frivilligt `api.ugnas.com`: denne tjeneste ser forbindelsens offentlige IP-adresse, men modtager ikke en adgangskode eller NAS-token. Manuel indtastning afhænger ikke af denne service.

Ingen nye tilføjelser forsøges efter et tvetydigt svar eller en deadline er udløbet. En genforbindelse og et nyt forsøg er kun tilladt efter et eksplicit afslag på godkendelse. **En opgave, der accepteres af NAS, er ikke et bevis på, at overførslen er fuldført.**

## Grænser

- Safari erstatter ikke alle dets downloads. Automatisk aflytning dækker genkendte torrent-links og -mekanismer; højreklik og manuel indtastning fuldfører denne handling.
- Et HTTP-link skal være tilgængeligt direkte af NAS. Sitesessionsbeskyttet indhold, udløbet URL, beskyttede videoer og almindelige filer genereret i `blob:` eller `data:` konverteres ikke til offentlige links.
- Menusporing venter cirka 3,5 sekunder efter hvert svar; meddelelser og navnerettelser kontrolleres cirka hvert 30. sekund. Safari lukket, suspenderet eller en sovende Mac kan forsinke disse operationer.
- Ukendte formater modtager ikke en opfundet udvidelse. Omdøbningen sker, efter at overførslen er fuldført; den faktiske fil er rettet, mens downloadhistorikken kan beholde sit oprindelige navn.
- Rettelser forbliver begrænset til nye utvetydigt identificerede HTTP-opgaver, uden tvungen udskiftning, med et maksimum på 100 afventende operationer og en opbevaring på syv dage. Lister er begrænset til 10.000 opgaver pr. kategori.
- Den globale macOS-ikonindstilling forbliver prioritet: **Mørk → Automatisk** giver dig mulighed for at følge temaet. Det statiske ikon i Safari-udvidelseslisten forbliver i sin klare version; menu- og valglogoerne følger temaet.

## Udvikling og test

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

JavaScript-test kræver Node.js; Native test kræver macOS, Xcode værktøjer, Python 3 og OpenSSL. De starter en midlertidig lokal HTTPS-server på port 18443 og bruger ingen rigtige NAS-konti. 0.5.1-revisionen omfattede 45 JavaScript-tests og 121 native kontroller. Se [rapporten](../AUDIT-0.5.1.md).

- `Extension/`: menu, indstillinger, Safari scripts og ikoner.
- `Xcode/`: AppKit-applikation, Swift-modul, autentificering og transport NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Indbygget ikon med lyse og mørke udseender.
- `Design/generate-icons.swift`: generering af PNG'er og vinduets adaptive logo.
- `Tests/`: sikkerhedstest, datavalidering og adfærd.

## Referencer

- [ugnas-api](https://github.com/Fracizz/ugnas-api) fællesskabsklient: protokolreference, uden tredjepartskode indlæst fra en NAS-side.
- [Fællesskabsintegration UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): reference til dobbeltgodkendelse.
- [Apple Dokumentation Safari Web Extensions](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

For at rapportere et problem skal du ikke vedhæfte nogen adgangskode, midlertidig kode, token, signeret URL, privat torrent eller eksport af nøglering. Brug fiktive data i eksemplerne.

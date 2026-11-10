# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

En macOS-applikation och en Safari-tillägg för att skicka nedladdningar till applikationen **Nedladdningar** för en UGREEN NAS under UGOS Pro, utan att hålla NAS-sidan öppen.

Källor och DMG-version: **0.6.1**. Oberoende community-projekt, inte anslutet till UGREEN eller Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

Appen och tilläggsgränssnittet är tillgängligt på 34 språk.

## Funktioner

- Avlyssning av `.torrent` och `magnet:` länkar på auktoriserade webbplatser i Safari.
- Åtgärd **Ladda ner till NAS** genom att högerklicka på en direkt tillgänglig länk, bild, video eller ljudelement.
- Skickar en URL manuellt från tilläggsmenyn.
- Konto och session i macOS Keychain; Stöd för tvåfaktorsautentisering och enhetsförtroende.
- Valfri NAS-sökning med hjälp av UGREEN-onlinetjänsten eller manuell HTTPS-adress.
- Lista över nedladdningar, framsteg och hastighet; valfritt slutförande, avstängning och felmeddelanden.
- Identifiering av HTTP-filnamn och -typer, med namnkorrigering efter nedladdning när filen är entydigt identifierad.
- Inbyggda ljusa och mörka ikoner och Safari-logotyper anpassade till systemtemat.

## Kompatibilitet

Projektet är konfigurerat för **macOS 27 eller senare** och kompilerades med **Xcode 27.1**, för Apple Silicon. NAS-testning utfördes med en **DXP2800**, **UGOS Pro 1.20.0.0142** och **Nedladdningar 1.19.1.0004**. Andra versioner är inte garanterade: integration är baserad på observerade API:er, utan ett stabilt UGREEN offentligt kontrakt.

## Installera från DMG

[Ladda ner UGREEN NAS Ladda ner 0.6.1 för Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.1).

1. Öppna DMG, dra **UGREEN NAS Download** till **Applications** och öppna sedan appen.
2. I **Safari → Inställningar → Avancerat**, aktivera funktioner för webbutvecklare. I **Utvecklare**, aktivera **Tillåt osignerade tillägg**, aktivera sedan **UGREEN NAS Download** i **Tillägg**.
3. Konfigurera NAS i tilläggsinställningarna.

Detta offentliga paket är undertecknat lokalt (ad hoc) och inte attesterat. macOS kan blockera dess första öppning. Safari kan be om att återaktivera osignerade tillägg efter att ha avslutat webbläsaren.

## Kompilera från källan

1. Klona det här förrådet och öppna `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. I **Signering och funktioner** väljer du ditt eget Apple-team för de två målen: applikationen och dess tillägg. Inget personligt team läggs in i förvaret.
3. Välj schemat **UGREEN NAS Download**, destination **Min Mac**, kompilera sedan och starta med Xcode.
4. Aktivera tillägget i **Safari → Inställningar → Tillägg**, auktorisera sedan önskade webbplatser.
5. Öppna tilläggsinställningarna och konfigurera din NAS enligt beskrivningen nedan.

Exempel på paket-ID:n är `com.example.UGREENNASDownload` och `com.example.UGREENNASDownload.Extension`. Om du behöver anpassa dem för din signatur, ändra Xcode-projektets identifierare **och** motsvarande konstanter i `Extension/background.js` och `ViewController.swift`: värdena ska förbli konsekventa.

Den här offentliga utgåvan använder identifierare och ett nyckelringutrymme separat från applikationen för personlig utveckling. Den kräver sin egen NAS-konfiguration. Utvecklarsignaturen utgör inte en attesterad distribution och aktivering kan kräva Safari-utvecklarinställningar som är lämpliga för din signatur.

För att kontrollera en kompilering utan signatur, från roten av förvaret:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Denna kontroll ger en osignerad applikation; Använd ditt Apple-team för en utvecklingsinstallation som kan användas i Safari. Behåll arkivträdet: Xcode-referenser till `Extension` och `Design` är relativa.

## Konfigurera NAS

1. Ange HTTPS-adressen för NAS:en med dess port, din identifierare och den absoluta destinationssökvägen på NAS:en. Personliga fält är tomma som standard.
2. Klicka på **Kontrollera SIN-certifikat**. Jämför SHA-256-fingeravtrycket med en pålitlig källa innan du bekräftar certifikatet.
3. Ange lösenordet och, om nödvändigt, en dubbel autentiseringskod. Att lita på enheten är valfritt; utan det kan en ny kod krävas när sessionen löper ut.
4. Klicka på **Spara och testa anslutning**. Tillåt lokal nätverksåtkomst när macOS begär det.
5. Aktivera automatisk avlyssning av torrenter och magneter om så önskas. Högerklickning och manuell sändning förblir oberoende av denna switch.

Adressen, kontot och mappen kan fortfarande ändras i inställningarna. **Glöm det här kontot** tar bort kontot och dess nyckelring-session för den aktuella Safari-profilen.

## Säkerhet och drift

Webbsidor kan inte konfigurera kontot eller lita på ett certifikat. Tillägget kommunicerar med sin Swift-modul via inbyggda meddelanden. NAS-förfrågningar går genom en isolerad WebKit-motor med tillfällig lagring och sidskript inaktiverat; certifikatet måste matcha det godkända fingeravtrycket. NAS-omdirigeringar nekas. Lösenordet är krypterat med RSA-nyckeln som tillhandahålls av NAS:en, över HTTPS.

Lösenordet, token och inloggningsinformationen lagras i Nyckelring, inte i webblagring eller detta förråd. Den tillfälliga koden raderas efter användning. Cookies och Safari-webbplatsidentifierare överförs aldrig till NAS:en. För vissa torrenter från samma sida hämtas den lilla filen från minnet med Safari-sessionen, och överförs sedan till NAS:en utan lokal säkerhetskopiering eller SMB; dess storlek är begränsad till 512 KiB.

Den automatiska sökningen frågar frivilligt `api.ugnas.com`: den här tjänsten ser den offentliga IP-adressen för anslutningen, men får inget lösenord eller NAS-token. Manuell inmatning är inte beroende av denna tjänst.

Inga nya tillägg görs efter att ett tvetydigt svar eller en deadline har passerat. En återanslutning och ett nytt försök är endast tillåtna efter ett uttryckligt avslag på autentisering. **En uppgift som accepteras av NAS är inte ett bevis på att nedladdningen är klar.**

## Gränser

- Safari tillåter inte att du universellt ersätter alla nedladdningar. Automatisk avlyssning täcker igenkända torrentlänkar och mekanismer; högerklicka och manuell inmatning slutför denna operation.
- En HTTP-länk måste vara tillgänglig direkt av NAS:en. Webbplatssessionsskyddat innehåll, utgångna webbadresser, skyddade videor och vanliga filer som genereras i `blob:` eller `data:` konverteras inte till offentliga länkar.
- Menyspårning väntar cirka 3,5 sekunder efter varje svar; meddelanden och namnkorrigeringar kontrolleras ungefär var 30:e sekund. Safari stängd, avstängd eller en vilande Mac kan fördröja dessa operationer.
- Okända format får inte ett påhittat tillägg. Byte av namn sker efter att nedladdningen är klar; den faktiska filen är fixad, medan nedladdningshistoriken kan behålla sitt ursprungliga namn.
- Korrigeringar förblir begränsade till otvetydigt identifierade nya HTTP-uppgifter, utan påtvingad ersättning, med maximalt 100 väntande operationer och en lagring på sju dagar. Listor är begränsade till 10 000 uppgifter per kategori.
- Den globala macOS-ikoninställningen förblir prioriterad: **Mörk → Automatisk** låter dig följa temat. Den statiska ikonen i Safari-tilläggslistan finns kvar i sin tydliga version; meny- och alternativlogotyperna följer temat.

## Utveckling och testning

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

JavaScript-testning kräver Node.js; Native testing kräver macOS, Xcode-verktyg, Python 3 och OpenSSL. De startar en tillfällig lokal HTTPS-server på port 18443 och använder inget riktigt NAS-konto. 0.5.1-revisionen inkluderade 45 JavaScript-tester och 121 inbyggda kontroller. Se [rapport](../AUDIT-0.5.1.md).

- `Extension/`: meny, inställningar, Safari-skript och ikoner.
- `Xcode/`: AppKit-applikation, Swift-modul, autentisering och NAS-transport.
- `Design/Adaptive/UGREENIcon.icon/`: Inbyggd ikon med ljusa och mörka utseenden.
- `Design/generate-icons.swift`: generering av PNG:er och fönstrets adaptiva logotyp.
- `Tests/`: säkerhetstester, datavalidering och beteende.

## Referenser

- [ugnas-api community-klient](https://github.com/Fracizz/ugnas-api): protokollreferens, utan tredjepartskod laddad från en NAS-sida.
- [UGREEN community integration](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): referens för dubbel autentisering.
- [Dokumentation för Apple Safari Web Extensions](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

För att rapportera ett problem ska du inte bifoga några lösenord, tillfälliga koder, tokens, signerade webbadresser, privata torrents eller Keychain-exporter. Använd fiktiva data i exemplen.

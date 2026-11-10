# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

Een macOS-applicatie en een Safari-extensie om downloads te verzenden naar de **Downloads**-applicatie van een NAS UGREEN onder UGOS Pro, zonder de NAS-pagina open te houden.

Bronnen en DMG-versie: **0.6.1**. Onafhankelijk gemeenschapsproject, niet aangesloten bij UGREEN of Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

De app- en extensie-interface is beschikbaar in 34 talen.

## Kenmerken

- Onderschepping van `.torrent`- en `magnet:`-links op sites die zijn geautoriseerd in Safari.
- Actie **Download naar de NAS** door met de rechtermuisknop op een direct toegankelijke link, afbeelding, video of audio-element te klikken.
- Handmatig verzenden van een URL vanuit het extensiemenu.
- Account en sessie in sleutelhanger macOS; Ondersteuning voor tweefactorauthenticatie en apparaatvertrouwen.
- Optioneel zoeken naar NAS via de UGREEN online service, of handmatig HTTPS-adres.
- Lijst met downloads, voortgang en snelheid; optionele voltooiing, afsluiting en foutmeldingen.
- Identificatie van HTTP-bestandsnamen en -typen, met naamcorrectie na het downloaden wanneer het bestand ondubbelzinnig wordt geïdentificeerd.
- Native lichte en donkere pictogrammen en Safari-logo's aangepast aan het systeemthema.

## Compatibiliteit

Het project is geconfigureerd voor **macOS 27 of hoger** en is gecompileerd met **Xcode 27.1**, voor Apple Silicon. NAS-tests zijn uitgevoerd met een **DXP2800**, **UGOS Pro 1.20.0.0142** en **Downloads 1.19.1.0004**. Andere versies zijn niet gegarandeerd: de integratie is gebaseerd op waargenomen API's, zonder een stabiel UGREEN-openbaar contract.

## Installeren vanuit DMG

[Download UGREEN NAS Download 0.6.1 voor Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.1).

1. Open de DMG, sleep **UGREEN NAS Download** naar **Applicaties** en open vervolgens de app.
2. Schakel in **Safari → Instellingen → Geavanceerd** functies voor webontwikkelaars in. Schakel in **Ontwikkelaar** **Niet-ondertekende extensies toestaan** in en schakel vervolgens **UGREEN NAS Download** in **Extensies** in.
3. Configureer de NAS in de extensie-instellingen.

Dit openbare pakket is lokaal ondertekend (ad hoc) en niet notarieel bekrachtigd. macOS kan de eerste opening ervan blokkeren. Safari kan na het afsluiten van de browser vragen om de toestemming voor niet-ondertekende extensies opnieuw in te schakelen.

## Compileer vanuit de bron

1. Kloon deze repository en open `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. Kies in **Signing & Capabilities** uw eigen Apple-team voor de twee doelen: de applicatie en de extensie ervan. Er is geen persoonlijk team ingevoerd in de repository.
3. Kies het schema **UGREEN NAS Download**, bestemming **Mijn Mac**, compileer en start vervolgens met Xcode.
4. Activeer de extensie in **Safari → Instellingen → Extensies** en autoriseer vervolgens de gewenste sites.
5. Open de extensie-instellingen en configureer uw NAS zoals hieronder beschreven.

De voorbeeldbundel-ID's zijn `com.example.UGREENNASDownload` en `com.example.UGREENNASDownload.Extension`. Als u ze voor uw handtekening wilt aanpassen, wijzigt u de project-ID's Xcode **en** de overeenkomstige constanten in `Extension/background.js` en `ViewController.swift`: de waarden moeten consistent blijven.

Deze openbare editie maakt gebruik van ID's en een sleutelhangerruimte die losstaat van de persoonlijke ontwikkelingsapplicatie. Het vereist een eigen configuratie van de NAS. De ontwikkelingshandtekening vormt geen notariële distributie en voor activering zijn mogelijk de Safari-ontwikkelingsinstellingen vereist die geschikt zijn voor uw handtekening.

Om een compilatie zonder handtekening te controleren, vanuit de hoofdmap van de repository:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Deze controle levert een niet-ondertekende aanvraag op; gebruik uw Apple-team voor een bruikbare ontwikkelinstallatie in Safari. Bewaar de repositoryboom: de verwijzingen Xcode tot `Extension` en `Design` zijn relatief.

## Configureer de NAS

1. Voer het HTTPS-adres van de NAS in met zijn poort, uw identificatie en het absolute bestemmingspad op de NAS. Persoonlijke velden zijn standaard leeg.
2. Klik op **Controleer het NAS-certificaat**. Vergelijk de SHA-256-vingerafdruk met een vertrouwde bron voordat u het certificaat bevestigt.
3. Voer het wachtwoord in en eventueel een dubbele authenticatiecode. Het vertrouwen op het apparaat is optioneel; zonder deze code kan een nieuwe code vereist zijn wanneer de sessie verloopt.
4. Klik op **Opslaan en verbinding testen**. Sta toegang tot het lokale netwerk toe wanneer daarom wordt gevraagd door macOS.
5. Schakel indien gewenst automatische onderschepping van torrents en magneten in. Rechtsklikken en handmatig verzenden blijven onafhankelijk van deze schakelaar.

Het adres, account en map kunnen nog steeds worden gewijzigd in de instellingen. **Als u dit account vergeet** worden het account en de bijbehorende sleutelhangersessie voor het huidige Safari-profiel verwijderd.

## Veiligheid en bediening

Webpagina's kunnen het account niet configureren of een certificaat vertrouwen. De extensie communiceert met zijn Swift-module via native messaging. NAS-verzoeken gaan via een geïsoleerde WebKit-engine waarbij kortstondige opslag en paginascripting zijn uitgeschakeld; het certificaat moet overeenkomen met de goedgekeurde vingerafdruk. NAS-omleidingen worden geweigerd. Het wachtwoord wordt gecodeerd met de RSA-sleutel die door de NAS wordt geleverd, naar HTTPS.

Het wachtwoord, het token en de inloggegevens worden opgeslagen in Keychain, niet in de webopslag of deze repository. De tijdelijke code wordt na gebruik gewist. Cookies en identificatiegegevens van Safari-sites worden nooit verzonden naar NAS. Voor sommige torrents van dezelfde site wordt het kleine bestand in het geheugen opgehaald met de sessie Safari en vervolgens verzonden naar de NAS zonder lokale opslag of SMB; de omvang is beperkt tot 512 KiB.

Automatisch zoeken vraagt vrijwillig `api.ugnas.com`: deze dienst ziet het openbare IP-adres van de verbinding, maar ontvangt geen wachtwoord of NAS-token. Handmatige invoer is niet afhankelijk van deze service.

Er worden geen nieuwe toevoegingen geprobeerd nadat een dubbelzinnig antwoord is gegeven of nadat een deadline is verstreken. Een herverbinding en een nieuwe poging zijn alleen toegestaan ​​na uitdrukkelijke weigering van authenticatie. **Een taak die door de NAS wordt geaccepteerd, is geen bewijs dat de download voltooid is.**

## Grenzen

- Safari vervangt niet universeel alle downloads. Automatische onderschepping omvat erkende torrent-links en -mechanismen; klikken met de rechtermuisknop en handmatige invoer voltooien deze handeling.
- Een HTTP-link moet rechtstreeks toegankelijk zijn voor de NAS. Door sitesessies beveiligde inhoud, verlopen URL, beveiligde video's en gewone bestanden gegenereerd in `blob:` of `data:` worden niet omgezet in openbare links.
- Menutracking wacht ongeveer 3,5 seconden na elk antwoord; meldingen en naamcorrecties worden ongeveer elke 30 seconden gecontroleerd. Safari gesloten, opgeschort of een slapende Mac kan deze bewerkingen vertragen.
- Onbekende formaten krijgen geen verzonnen extensie. Het hernoemen vindt plaats nadat het downloaden is voltooid; het daadwerkelijke bestand staat vast, terwijl de downloadgeschiedenis zijn oorspronkelijke naam kan behouden.
- Correcties blijven beperkt tot nieuwe, ondubbelzinnig geïdentificeerde HTTP-taken, zonder gedwongen vervanging, met een maximum van 100 lopende bewerkingen en een retentie van zeven dagen. Lijsten zijn beperkt tot 10.000 taken per categorie.
- De algemene macOS-pictograminstelling blijft prioriteit: Met **Donker → Automatisch** kunt u het thema volgen. Het statische pictogram in de Safari-extensielijst blijft in de duidelijke versie; het menu en de optielogo's volgen het thema.

## Ontwikkeling en testen

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

JavaScript-testen vereisen Node.js; Voor native tests zijn macOS-, Xcode-tools, Python 3 en OpenSSL vereist. Ze starten een tijdelijke lokale HTTPS-server op poort 18443 en gebruiken geen echte NAS-accounts. De audit 0.5.1 omvatte 45 JavaScript-tests en 121 native besturingselementen. Zie [het rapport](../AUDIT-0.5.1.md).

- `Extension/`: menu, instellingen, Safari-scripts en pictogrammen.
- `Xcode/`: AppKit-applicatie, Swift-module, authenticatie en transport NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Native icoon met lichte en donkere verschijningsvormen.
- `Design/generate-icons.swift`: generatie van PNG's en het adaptieve logo van het venster.
- `Tests/`: beveiligingstests, gegevensvalidatie en gedrag.

## Referenties

- [ugnas-api](https://github.com/Fracizz/ugnas-api) communityclient: protocolreferentie, zonder code van derden geladen vanaf een NAS-pagina.
- [Community-integratie UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): referentie voor dubbele authenticatie.
- [Apple-documentatie Safari Webextensies](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Om een ​​probleem te melden, mag u geen wachtwoord, tijdelijke code, token, ondertekende URL, privétorrent of sleutelhangerexport toevoegen. Gebruik fictieve gegevens in de voorbeelden.

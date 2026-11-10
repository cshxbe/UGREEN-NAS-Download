# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

MacOS-sovellus ja Safari-laajennus, jotka lähettävät latauksia UGOS Pron UGREEN NAS:n **Lataukset**-sovellukseen ilman, että NAS-sivua pidetään auki.

Lähteet ja DMG-versio: **0.6.1**. Itsenäinen yhteisöprojekti, joka ei ole sidoksissa UGREENiin tai Appleen.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

Sovelluksen ja laajennuksen käyttöliittymä on saatavilla 34 kielellä.

## Ominaisuudet

- Safarin valtuutettujen sivustojen linkkien `.torrent` ja `magnet:` sieppaaminen.
- Toimi **Lataa NAS:iin** napsauttamalla hiiren kakkospainikkeella suoraan käytettävissä olevaa linkkiä, kuvaa, videota tai äänielementtiä.
- URL-osoitteen manuaalinen lähettäminen laajennusvalikosta.
- Tili ja istunto macOS-avainnipussa; Tuki kaksivaiheiselle todennuksen ja laitteen luotettavuudelle.
- Valinnainen NAS-haku käyttämällä UGREEN-verkkopalvelua tai manuaalista HTTPS-osoitetta.
- Luettelo latauksista, edistymisestä ja nopeudesta; valinnaiset valmistumis-, sammutus- ja virheilmoitukset.
- HTTP-tiedostojen nimien ja tyyppien tunnistaminen ja nimen korjaus latauksen jälkeen, kun tiedosto tunnistetaan yksiselitteisesti.
- Natiivit vaaleat ja tummat kuvakkeet ja Safari-logot mukautettu järjestelmän teemaan.

## Yhteensopivuus

Projekti on määritetty **macOS 27:lle tai uudemmalle** ja se on käännetty **Xcode 27.1**:lla Apple Siliconille. NAS-testaus suoritettiin mallilla **DXP2800**, **UGOS Pro 1.20.0.0142** ja **Lataukset 1.19.1.0004**. Muita versioita ei taata: integrointi perustuu havaittuihin API:ihin ilman vakaata UGREEN-julkista sopimusta.

## Asenna DMG:ltä

[Lataa UGREEN NAS Download 0.6.1 Macille Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.1).

1. Avaa DMG, vedä **UGREEN NAS Download** **Applications**-kohtaan ja avaa sovellus.
2. Ota ominaisuudet käyttöön verkkokehittäjille kohdassa **Safari → Asetukset → Lisäasetukset**. Ota **Kehittäjä** käyttöön **Salli allekirjoittamattomat laajennukset** ja ota sitten käyttöön **UGREEN NAS -lataus** kohdassa **Laajennukset**.
3. Määritä NAS laajennusasetuksissa.

Tämä julkinen paketti on allekirjoitettu paikallisesti (ad hoc) eikä notaarin vahvistama. macOS voi estää sen ensimmäisen avaamisen. Safari saattaa pyytää ottamaan allekirjoittamattomat laajennukset uudelleen käyttöön selaimen sulkemisen jälkeen.

## Kääntää lähteestä

1. Kloonaa tämä arkisto ja avaa `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. Valitse **Signing & Capabilities** -kohdassa oma Apple-tiimisi kahdelle kohteelle: sovellukselle ja sen laajennukselle. Henkilökohtaista joukkuetta ei ole kirjattu arkistoon.
3. Valitse skeema **UGREEN NAS Download**, kohde **My Mac**, käännä ja käynnistä Xcodella.
4. Aktivoi laajennus kohdassa **Safari → Asetukset → Laajennukset** ja valtuuta sitten haluamasi sivustot.
5. Avaa laajennusasetukset ja määritä NAS alla kuvatulla tavalla.

Esimerkkipaketin tunnukset ovat `com.example.UGREENNASDownload` ja `com.example.UGREENNASDownload.Extension`. Jos sinun on mukautettava niitä allekirjoituksellesi, muokkaa Xcode-projektin tunnisteita **ja** vastaavia vakioita kohdissa `Extension/background.js` ja `ViewController.swift`: arvojen tulee pysyä yhdenmukaisina.

Tämä julkinen versio käyttää tunnisteita ja Keychain-tilaa henkilökohtaisesta kehityssovelluksesta erillään. Se vaatii oman NAS-kokoonpanon. Kehittäjän allekirjoitus ei ole notaarin vahvistama jakelu, ja aktivointi voi edellyttää allekirjoituksellesi sopivia Safari-kehittäjäasetuksia.

Voit tarkistaa kokoelman ilman allekirjoitusta arkiston juuresta seuraavasti:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Tämä tarkistus tuottaa allekirjoittamattoman sovelluksen; Käytä Apple-tiimiäsi Safarissa käytettävään kehitysasennukseen. Säilytä arkistopuu: Xcode-viitteet `Extension` ja `Design` ovat suhteellisia.

## Määritä NAS

1. Anna NAS:n HTTPS-osoite ja sen portti, tunnuksesi ja absoluuttinen kohdepolku NAS:ssa. Henkilökohtaiset kentät ovat oletuksena tyhjiä.
2. Napsauta **Tarkista SIN-todistus**. Vertaa SHA-256-sormenjälkeä luotettavaan lähteeseen ennen varmenteen vahvistamista.
3. Syötä salasana ja tarvittaessa kaksoisvarmennuskoodi. Laitteeseen luottaminen on valinnaista; ilman sitä, uusi koodi voidaan vaatia istunnon päättyessä.
4. Napsauta **Tallenna ja testaa yhteys**. Salli pääsy paikalliseen verkkoon, kun macOS pyytää sitä.
5. Ota torrentien ja magneettien automaattinen sieppaus käyttöön haluttaessa. Napsauta hiiren kakkospainikkeella ja manuaalinen lähetys ovat riippumattomia tästä kytkimestä.

Osoitetta, tiliä ja kansiota voi edelleen muokata asetuksissa. **Unohda tämä tili** poistaa tilin ja sen avainnipun-istunnon nykyisestä Safari-profiilista.

## Turvallisuus ja toiminta

Web-sivut eivät voi määrittää tiliä tai luottaa varmenteeseen. Laajennus kommunikoi Swift-moduulinsa kanssa natiiviviestinnällä. NAS-pyynnöt kulkevat erillisen WebKit-moottorin kautta, jossa lyhytaikainen tallennus ja sivujen komentosarjat on poistettu käytöstä; todistuksen on vastattava hyväksyttyä sormenjälkeä. NAS-uudelleenohjaukset evätään. Salasana on salattu NAS:n antamalla RSA-avaimella HTTPS:n kautta.

Salasana, tunnus ja kirjautumistiedot tallennetaan avainnippuun, ei verkkotallennustilaan tai tähän arkistoon. Väliaikainen koodi poistetaan käytön jälkeen. Evästeitä ja Safari-sivuston tunnisteita ei koskaan lähetetä NAS:iin. Joissakin saman sivuston torrenteissa pieni tiedosto noudetaan muistista Safari-istunnon avulla ja lähetetään sitten NAS:iin ilman paikallista varmuuskopiointia tai SMB:tä. sen koko on rajoitettu 512 KiB:iin.

Automaattinen haku kysyy vapaaehtoisesti `api.ugnas.com`: tämä palvelu näkee yhteyden julkisen IP-osoitteen, mutta ei saa salasanaa tai NAS-tunnusta. Manuaalinen syöttäminen ei riipu tästä palvelusta.

Uusia lisäyksiä ei yritetä epäselvän vastauksen tai määräajan umpeuduttua. Yhteyden muodostaminen uudelleen ja uusi yritys sallitaan vain todennuksen nimenomaisen kieltämisen jälkeen. **NAS:n hyväksymä tehtävä ei ole todiste siitä, että lataus on valmis.**

## Rajoitukset

- Safari ei salli sinun korvata kaikkia sen latauksia yleisesti. Automaattinen sieppaus kattaa tunnistetut torrent-linkit ja -mekanismit; Napsauta hiiren kakkospainikkeella ja syötä manuaalisesti.
- HTTP-linkin on oltava suoraan NAS:n käytettävissä. Sivuston istunnon suojattua sisältöä, vanhentuneita URL-osoitteita, suojattuja videoita ja tavallisia tiedostoja, jotka on luotu `blob:` tai `data:`, ei muunneta julkisiksi linkeiksi.
- Valikon seuranta odottaa noin 3,5 sekuntia jokaisen vastauksen jälkeen; ilmoitukset ja nimenkorjaukset tarkistetaan noin 30 sekunnin välein. Suljettu, keskeytetty Safari tai lepotilassa oleva Mac voi viivyttää näitä toimintoja.
- Tuntemattomat muodot eivät saa keksittyä laajennusta. Uudelleennimeäminen tapahtuu, kun lataus on valmis; varsinainen tiedosto on korjattu, kun taas lataushistoria voi säilyttää alkuperäisen nimensä.
- Korjaukset rajoitetaan yksiselitteisesti tunnistettuihin uusiin HTTP-tehtäviin ilman pakotettua korvaamista, enintään 100 odottavaa toimintoa ja seitsemän päivän säilytysaikaa. Luetteloissa on rajoitettu 10 000 tehtävää luokkaa kohti.
- Maailmanlaajuinen macOS-kuvakeasetus säilyy ensisijaisena: **Dark → Automatic** voit seurata teemaa. Staattinen kuvake Safari-laajennusten luettelossa pysyy selkeänä versiona; valikko- ja vaihtoehtologot seuraavat teemaa.

## Kehitys ja testaus

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

JavaScript-testaus vaatii Node.js:n; Natiivitestaus vaatii macOS:n, Xcode-työkalut, Python 3:n ja OpenSSL:n. He käynnistävät väliaikaisen paikallisen HTTPS-palvelimen portissa 18443 eivätkä käytä todellista NAS-tiliä. 0.5.1-tarkastus sisälsi 45 JavaScript-testiä ja 121 alkuperäistä kontrollia. Katso [raportti](../AUDIT-0.5.1.md).

- `Extension/`: valikko, asetukset, Safari-skriptit ja kuvakkeet.
- `Xcode/`: AppKit-sovellus, Swift-moduuli, todennus ja NAS-siirto.
- `Design/Adaptive/UGREENIcon.icon/`: Alkuperäinen kuvake vaalealla ja tummalla ilmeellä.
- `Design/generate-icons.swift`: PNG-tiedostojen ja ikkunan mukautuvan logon luominen.
- `Tests/`: tietoturvatestit, tietojen validointi ja käyttäytyminen.

## Viitteet

- [ugnas-api Community client](https://github.com/Fracizz/ugnas-api): protokollaviittaus, ilman NAS-sivulta ladattua kolmannen osapuolen koodia.
- [UGREEN-yhteisöintegraatio](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): kaksoistodennuksen viite.
- [Apple Safari Web Extensions -dokumentaatio](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Jos haluat ilmoittaa ongelmasta, älä liitä salasanoja, väliaikaisia ​​koodeja, tunnuksia, allekirjoitettuja URL-osoitteita, yksityisiä torrentteja tai avainnipun vientiä. Käytä esimerkeissä kuvitteellista dataa.

# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

Aplikace macOS a rozšíření Safari pro odesílání stažených souborů do aplikace **Downloads** aplikace NAS UGREEN pod UGOS Pro, aniž by byla ponechána otevřená stránka NAS.

Zdroje a verze DMG: **0.6.1**. Nezávislý komunitní projekt, který není spojen s UGREEN nebo Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

Rozhraní aplikace a rozšíření je k dispozici ve 34 jazycích.

## Vlastnosti

- Zachycení odkazů `.torrent` a `magnet:` na stránkách autorizovaných v Safari.
- Akce **Stahujte do NAS** kliknutím pravým tlačítkem myši na přímo dostupný odkaz, obrázek, video nebo audio prvek.
- Ruční odeslání URL z nabídky rozšíření.
- Účet a relace v Keychain macOS; Podpora dvoufaktorové autentizace a důvěryhodnosti zařízení.
- Volitelné vyhledávání NAS pomocí online služby UGREEN nebo ruční adresy HTTPS.
- Seznam stahování, průběh a rychlost; volitelná oznámení o dokončení, vypnutí a chybách.
- Identifikace názvů a typů souborů HTTP s opravou názvu po stažení, když je soubor jednoznačně identifikován.
- Nativní světlé a tmavé ikony a loga Safari přizpůsobená systémovému tématu.

## Kompatibilita

Projekt je nakonfigurován pro **macOS 27 nebo novější** a byl zkompilován s **Xcode 27.1** pro Apple Silicon. Testy NAS byly provedeny s **DXP2800**, **UGOS Pro 1.20.0.0142** a **Stahování 1.19.1.0004**. Jiné verze nejsou zaručeny: integrace je založena na pozorovaných API, bez stabilní veřejné zakázky UGREEN.

## Nainstalujte z DMG

[Stáhněte si UGREEN NAS Download 0.6.1 pro Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.1).

1. Otevřete DMG, přetáhněte **UGREEN NAS Download** do **Aplikace** a otevřete aplikaci.
2. V **Safari → Nastavení → Upřesnit** povolte funkce pro webové vývojáře. V **Vývojáři** povolte **Povolit nepodepsaná rozšíření** a poté povolte **UGREEN NAS Download** v **Rozšíření**.
3. Nakonfigurujte NAS v nastavení rozšíření.

Tento veřejný balíček je podepsán lokálně (ad hoc) a není notářsky ověřen. macOS může blokovat jeho počáteční otevření. Safari může po ukončení prohlížeče požádat o opětovné povolení povolení pro nepodepsaná rozšíření.

## Kompilace ze zdroje

1. Naklonujte toto úložiště a otevřete `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. V části **Podepisování a schopnosti** si vyberte svůj vlastní tým Apple pro dva cíle: aplikaci a její rozšíření. V úložišti není vložen žádný osobní tým.
3. Vyberte schéma **UGREEN NAS Download**, cíl **My Mac**, poté zkompilujte a spusťte pomocí Xcode.
4. Aktivujte rozšíření v **Safari → Nastavení → Rozšíření** a poté autorizujte požadované stránky.
5. Otevřete nastavení rozšíření a nakonfigurujte NAS, jak je popsáno níže.

Příklady ID svazků jsou `com.example.UGREENNASDownload` a `com.example.UGREENNASDownload.Extension`. Pokud je potřebujete upravit pro svůj podpis, upravte identifikátory projektu Xcode **a** odpovídající konstanty v `Extension/background.js` a `ViewController.swift`: hodnoty musí zůstat konzistentní.

Toto veřejné vydání používá identifikátory a klíčenku oddělené od aplikace osobního rozvoje. Vyžaduje vlastní konfiguraci NAS. Vývojový podpis nepředstavuje notářsky ověřenou distribuci a aktivace může vyžadovat vývojová nastavení Safari vhodná pro váš podpis.

Chcete-li zkontrolovat kompilaci bez podpisu, z kořenového adresáře úložiště:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Tato kontrola vytvoří nepodepsanou aplikaci; použijte svůj tým Apple pro použitelnou vývojovou instalaci v Safari. Udržujte strom úložiště: odkazy Xcode na `Extension` a `Design` jsou relativní.

## Nakonfigurujte NAS

1. Zadejte adresu HTTPS NAS s jeho portem, vaším identifikátorem a absolutní cílovou cestou na NAS. Osobní pole jsou ve výchozím nastavení prázdná.
2. Klikněte na **Zkontrolovat certifikát NAS**. Před potvrzením certifikátu porovnejte otisk prstu SHA-256 s důvěryhodným zdrojem.
3. Zadejte heslo a v případě potřeby dvojitý autentizační kód. Důvěřovat zařízení je volitelné; bez něj může být po vypršení relace vyžadován nový kód.
4. Klikněte na **Uložit a otestovat připojení**. Na žádost macOS povolte přístup k místní síti.
5. V případě potřeby povolte automatické zachycování torrentů a magnetů. Kliknutí pravým tlačítkem a ruční odeslání zůstávají na tomto přepínači nezávislé.

Adresu, účet a složku lze ještě upravit v nastavení. **Zapomenutí tohoto účtu** smaže účet a jeho relaci Keychain pro aktuální profil Safari.

## Bezpečnost a provoz

Webové stránky nemohou konfigurovat účet ani důvěřovat certifikátu. Rozšíření komunikuje se svým modulem Swift prostřednictvím nativních zpráv. Požadavky NAS procházejí izolovaným modulem WebKit s pomíjivým úložištěm a zakázaným skriptováním stránek; certifikát musí odpovídat schválenému otisku prstu. Přesměrování NAS jsou odmítnuta. Heslo je zašifrováno pomocí klíče RSA, který poskytuje NAS, až HTTPS.

Heslo, token a přihlašovací údaje jsou uloženy v Keychain, nikoli ve webovém úložišti nebo v tomto úložišti. Dočasný kód se po použití vymaže. Soubory cookie a identifikátory ze stránek Safari se nikdy nepřenášejí na NAS. U některých torrentů ze stejného místa je malý soubor načten do paměti s relací Safari a poté přenesen do NAS bez místního ukládání nebo SMB; jeho velikost je omezena na 512 kiB.

Automatické vyhledávání se dobrovolně dotazuje `api.ugnas.com`: tato služba vidí veřejnou IP adresu připojení, ale neobdrží heslo ani token NAS. Ruční zadávání nezávisí na této službě.

Po nejednoznačné odpovědi nebo uplynutí lhůty se nepokouší o žádné nové přidání. Opětovné připojení a nový pokus jsou povoleny pouze po výslovném odmítnutí ověření. **Úloha přijatá NAS není důkazem, že stahování bylo dokončeno.**

## Limity

- Safari univerzálně nenahrazuje všechna svá stahování. Automatické zachycení pokrývá rozpoznané odkazy a mechanismy torrentu; tuto operaci dokončíte kliknutím pravým tlačítkem a ručním zadáním.
- Odkaz HTTP musí být přístupný přímo z NAS. Obsah chráněný relací webu, URL, jehož platnost vypršela, chráněná videa a běžné soubory generované v `blob:` nebo `data:` nejsou převedeny na veřejné odkazy.
- Sledování nabídky čeká přibližně 3,5 sekundy po každé odpovědi; upozornění a opravy jmen jsou kontrolovány přibližně každých 30 sekund. Safari zavřený, pozastavený nebo spící Mac může tyto operace zpozdit.
- Neznámé formáty neobdrží vymyšlené rozšíření. K přejmenování dojde po dokončení stahování; skutečný soubor je opraven, zatímco historie stahování si může ponechat svůj původní název.
- Opravy zůstávají omezeny na nové jednoznačně identifikované úlohy HTTP, bez nucené výměny, s maximálně 100 nevyřízenými operacemi a uchováním po dobu sedmi dnů. Seznamy jsou omezeny na 10 000 úkolů na kategorii.
- Prioritou zůstává globální nastavení ikony macOS: **Tmavý → Automaticky** umožňuje sledovat motiv. Statická ikona v seznamu rozšíření Safari zůstává v přehledné verzi; loga nabídky a možností odpovídají tématu.

## Vývoj a testování

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

Testování JavaScriptu vyžaduje Node.js; Nativní testování vyžaduje nástroje macOS, Xcode, Python 3 a OpenSSL. Spouštějí dočasný místní server HTTPS na portu 18443 a nepoužívají žádné skutečné účty NAS. Audit 0.5.1 zahrnoval 45 testů JavaScriptu a 121 nativních ovládacích prvků. Viz [zpráva](../AUDIT-0.5.1.md).

- `Extension/`: nabídka, nastavení, skripty a ikony Safari.
- `Xcode/`: Aplikace AppKit, modul Swift, ověřování a transport NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Nativní ikona se světlým a tmavým vzhledem.
- `Design/generate-icons.swift`: generace PNG a adaptivní logo okna.
- `Tests/`: bezpečnostní testování, ověřování dat a chování.

## Reference

- [ugnas-api](https://github.com/Fracizz/ugnas-api) komunitní klient: odkaz na protokol, bez kódu třetí strany načteného ze stránky NAS.
- [Integrace komunity UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): reference pro dvojitou autentizaci.
- [Dokumentace Apple Safari Webová rozšíření](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Chcete-li nahlásit problém, nepřipojujte žádné heslo, dočasný kód, token, podepsané URL, soukromý torrent nebo export klíčenky. V příkladech používejte fiktivní data.

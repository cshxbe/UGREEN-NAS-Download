# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

Aplikácia pre macOS a rozšírenie Safari na odosielanie stiahnutých súborov do aplikácie **Downloads** zariadenia UGREEN NAS pod UGOS Pro bez toho, aby bola stránka NAS otvorená.

Zdroje a verzia DMG: **0.6.1**. Nezávislý komunitný projekt, ktorý nie je spojený s UGREEN alebo Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

Rozhranie aplikácie a rozšírenia je k dispozícii v 34 jazykoch.

## Vlastnosti

- Zachytávanie odkazov `.torrent` a `magnet:` na autorizovaných stránkach v Safari.
- Akcia **Stiahnite na NAS** kliknutím pravým tlačidlom myši na priamo dostupný odkaz, obrázok, video alebo audio prvok.
- Manuálne odoslanie adresy URL z ponuky rozšírenia.
- Účet a relácia v macOS Keychain; Podpora dvojfaktorovej autentifikácie a dôveryhodnosti zariadenia.
- Voliteľné vyhľadávanie NAS pomocou online služby UGREEN alebo manuálna HTTPS adresa.
- Zoznam sťahovaní, priebeh a rýchlosť; voliteľné upozornenia na dokončenie, vypnutie a chyby.
- Identifikácia názvov a typov súborov HTTP s opravou názvu po stiahnutí, keď je súbor jednoznačne identifikovaný.
- Natívne svetlé a tmavé ikony a logá Safari prispôsobené systémovej téme.

## Kompatibilita

Projekt je nakonfigurovaný pre **macOS 27 alebo novší** a bol skompilovaný s **Xcode 27.1** pre Apple Silicon. Testovanie NAS bolo vykonané s **DXP2800**, **UGOS Pro 1.20.0.0142** a **Downloads 1.19.1.0004**. Ostatné verzie nie sú garantované: integrácia je založená na pozorovaných API, bez stabilnej UGREEN verejnej zákazky.

## Nainštalujte z DMG

[Stiahnuť UGREEN NAS Stiahnuť 0.6.1 pre Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.1).

1. Otvorte DMG, potiahnite **UGREEN NAS Download** do **Applications** a otvorte aplikáciu.
2. V **Safari → Nastavenia → Rozšírené** povoľte funkcie pre vývojárov webu. V **Developer** povoľte **Povoliť nepodpísané rozšírenia** a potom povoľte **UGREEN NAS Download** v **Rozšíreniach**.
3. Nakonfigurujte NAS v nastaveniach rozšírenia.

Tento verejný balík je podpísaný lokálne (ad hoc) a nie je notársky overený. macOS môže zablokovať jeho prvé otvorenie. Safari môže po ukončení prehliadača požiadať o opätovné povolenie nepodpísaných rozšírení.

## Kompilovať zo zdroja

1. Naklonujte toto úložisko a otvorte `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. V časti **Podpisovanie a schopnosti** si vyberte svoj vlastný tím Apple pre dva ciele: aplikáciu a jej rozšírenie. V úložisku nie je zadaný žiadny osobný tím.
3. Vyberte schému **UGREEN NAS Download**, cieľ **My Mac**, potom skompilujte a spustite pomocou Xcode.
4. Aktivujte rozšírenie v **Safari → Nastavenia → Rozšírenia** a potom autorizujte požadované stránky.
5. Otvorte nastavenia rozšírenia a nakonfigurujte svoj NAS podľa popisu nižšie.

Príklady ID balíkov sú `com.example.UGREENNASDownload` a `com.example.UGREENNASDownload.Extension`. Ak ich potrebujete prispôsobiť pre svoj podpis, upravte identifikátory projektu Xcode **a** zodpovedajúce konštanty v `Extension/background.js` a `ViewController.swift`: hodnoty by mali zostať konzistentné.

Toto verejné vydanie používa identifikátory a priestor Keychain oddelený od aplikácie osobného rozvoja. Vyžaduje si vlastnú konfiguráciu NAS. Podpis vývojára nepredstavuje notársky overenú distribúciu a aktivácia môže vyžadovať nastavenia vývojára Safari vhodné pre váš podpis.

Ak chcete skontrolovať kompiláciu bez podpisu, z koreňového adresára úložiska:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Táto kontrola vytvorí nepodpísanú aplikáciu; Použite svoj tím Apple na vývojovú inštaláciu použiteľnú v Safari. Ponechajte strom úložiska: Odkazy Xcode na `Extension` a `Design` sú relatívne.

## Nakonfigurujte NAS

1. Zadajte HTTPS adresu NAS s jeho portom, váš identifikátor a absolútnu cieľovú cestu na NAS. Osobné polia sú predvolene prázdne.
2. Kliknite na **Skontrolovať certifikát SIN**. Pred potvrdením certifikátu porovnajte odtlačok SHA-256 s dôveryhodným zdrojom.
3. Zadajte heslo a v prípade potreby dvojitý overovací kód. Dôverovať zariadeniu je voliteľné; bez neho sa môže po skončení relácie vyžadovať nový kód.
4. Kliknite na **Uložiť a otestovať pripojenie**. Povoľte prístup k miestnej sieti, keď o to macOS požiada.
5. V prípade potreby povoľte automatické zachytenie torrentov a magnetov. Kliknutie pravým tlačidlom myši a manuálne odosielanie zostávajú nezávislé od tohto prepínača.

Adresu, účet a priečinok je možné ešte upraviť v nastaveniach. **Zabudnúť na tento účet** odstráni účet a jeho reláciu Keychain pre aktuálny profil Safari.

## Bezpečnosť a prevádzka

Webové stránky nemôžu konfigurovať účet ani dôverovať certifikátu. Rozšírenie komunikuje so svojím modulom Swift prostredníctvom natívnych správ. Požiadavky NAS prechádzajú cez izolovaný modul WebKit s dočasnou pamäťou a zakázaným skriptovaním stránok; certifikát sa musí zhodovať so schváleným odtlačkom prsta. Presmerovania NAS sú odmietnuté. Heslo je zašifrované pomocou kľúča RSA poskytnutého NAS cez HTTPS.

Heslo, token a prihlasovacie údaje sú uložené v Keychain, nie vo webovom úložisku alebo v tomto úložisku. Dočasný kód sa po použití vymaže. Súbory cookie a identifikátory stránok Safari sa nikdy neprenášajú do NAS. V prípade niektorých torrentov z tej istej lokality sa malý súbor načíta z pamäte pomocou relácie Safari a potom sa prenesie do NAS bez lokálnej zálohy alebo SMB; jeho veľkosť je obmedzená na 512 KiB.

Automatické vyhľadávanie sa dobrovoľne pýta `api.ugnas.com`: táto služba vidí verejnú IP adresu pripojenia, ale nedostane heslo ani token NAS. Manuálne zadávanie nezávisí od tejto služby.

Po nejednoznačnej odpovedi alebo uplynutí termínu sa nepokúšajú o žiadne nové pridania. Opätovné pripojenie a nový pokus sú povolené len po výslovnom odmietnutí overenia. **Úloha prijatá NAS nie je dôkazom dokončenia sťahovania.**

## Limity

- Safari neumožňuje univerzálne nahradiť všetky jeho stiahnuté súbory. Automatické odpočúvanie pokrýva rozpoznané odkazy a mechanizmy torrentu; túto operáciu dokončíte kliknutím pravým tlačidlom myši a manuálnym zadaním.
- Odkaz HTTP musí byť prístupný priamo z NAS. Obsah chránený reláciou stránky, adresy URL s uplynutou platnosťou, chránené videá a bežné súbory generované v kódoch `blob:` alebo `data:` nie sú konvertované na verejné odkazy.
- Sledovanie ponuky čaká približne 3,5 sekundy po každej odpovedi; oznámenia a opravy mien sa kontrolujú približne každých 30 sekúnd. Zatvorený, pozastavený alebo spiaci Mac Safari môže tieto operácie oddialiť.
- Neznáme formáty nedostanú vynájdené rozšírenie. K premenovaniu dôjde po dokončení sťahovania; skutočný súbor je opravený, zatiaľ čo história sťahovania si môže ponechať svoj pôvodný názov.
- Opravy zostávajú obmedzené na jednoznačne identifikované nové úlohy HTTP, bez núteného nahradenia, s maximálne 100 čakajúcimi operáciami a uchovávaním sedem dní. Zoznamy sú obmedzené na 10 000 úloh na kategóriu.
- Prioritou zostáva globálne nastavenie ikony macOS: **Tmavý → Automaticky** vám umožňuje sledovať motív. Statická ikona v zozname rozšírení Safari zostáva v prehľadnej verzii; logá ponuky a možností zodpovedajú téme.

## Vývoj a testovanie

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

Testovanie JavaScriptu vyžaduje Node.js; Natívne testovanie vyžaduje macOS, nástroje Xcode, Python 3 a OpenSSL. Spúšťajú dočasný lokálny HTTPS server na porte 18443 a nepoužívajú žiadny skutočný účet NAS. Audit 0.5.1 zahŕňal 45 testov JavaScript a 121 natívnych ovládacích prvkov. Pozri [správa](../AUDIT-0.5.1.md).

- `Extension/`: ponuka, nastavenia, skripty a ikony Safari.
- `Xcode/`: Aplikácia AppKit, modul Swift, autentifikácia a prenos NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Natívna ikona so svetlým a tmavým vzhľadom.
- `Design/generate-icons.swift`: generovanie PNG a adaptívne logo okna.
- `Tests/`: bezpečnostné testy, validácia údajov a správanie.

## Referencie

- [klient komunity ugnas-api](https://github.com/Fracizz/ugnas-api): odkaz na protokol, bez kódu tretej strany načítaného zo stránky NAS.
- [Integrácia komunity UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): odkaz na dvojitú autentifikáciu.
- [Dokumentácia Apple Safari Web Extensions](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Ak chcete nahlásiť problém, nepripájajte žiadne heslá, dočasné kódy, tokeny, podpísané adresy URL, súkromné ​​torrenty ani exporty kľúčenky. V príkladoch použite fiktívne údaje.

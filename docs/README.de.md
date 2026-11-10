# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

Eine macOS-Anwendung und eine Safari-Erweiterung zum Senden von Downloads an die **Downloads**-Anwendung eines NAS UGREEN unter UGOS Pro, ohne dass die NAS-Seite geöffnet bleibt.

Quellen und DMG-Version: **0.6.0**. Unabhängiges Community-Projekt, nicht verbunden mit UGREEN oder Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

Die App- und Erweiterungsoberfläche ist in 34 Sprachen verfügbar.

## Funktionen

- Abfangen von `.torrent`- und `magnet:`-Links auf in Safari autorisierten Websites.
- Aktion **Download zum NAS** durch Rechtsklick auf einen direkt zugänglichen Link, ein Bild, ein Video oder ein Audioelement.
- Manuelles Senden eines URL aus dem Erweiterungsmenü.
- Konto und Sitzung im Schlüsselbund macOS; Unterstützung für Zwei-Faktor-Authentifizierung und Gerätevertrauen.
- Optionale Suche nach NAS über den UGREEN-Onlinedienst oder manuelle Suche nach HTTPS-Adresse.
- Liste der Downloads, Fortschritt und Geschwindigkeit; optionale Abschluss-, Abschalt- und Fehlerbenachrichtigungen.
- Identifizierung von HTTP-Dateinamen und -typen, mit Namenskorrektur nach dem Download, wenn die Datei eindeutig identifiziert ist.
- Native helle und dunkle Symbole sowie an das Systemthema angepasste Safari-Logos.

## Kompatibilität

Das Projekt ist für **macOS 27 oder höher** konfiguriert und wurde mit **Xcode 27.1** für Apple Silicon kompiliert. NAS-Tests wurden mit einem **DXP2800**, **UGOS Pro 1.20.0.0142** und **Downloads 1.19.1.0004** durchgeführt. Andere Versionen sind nicht garantiert: Die Integration basiert auf beobachteten APIs, ohne einen stabilen öffentlichen UGREEN-Vertrag.

## Von DMG installieren

[UGREEN NAS Download 0.6.0 für Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.0) herunterladen.

1. Öffnen Sie die DMG, ziehen Sie **UGREEN NAS Download** in **Anwendungen** und öffnen Sie dann die App.
2. Aktivieren Sie unter **Safari → Einstellungen → Erweitert** Funktionen für Webentwickler. Aktivieren Sie im **Entwicklerprogramm** die Option **Unsignierte Erweiterungen zulassen** und dann **UGREEN NAS Download** unter **Erweiterungen**.
3. Konfigurieren Sie den NAS in den Erweiterungseinstellungen.

Dieses öffentliche Paket wird lokal (ad hoc) unterzeichnet und nicht notariell beglaubigt. macOS kann das anfängliche Öffnen blockieren. Safari fordert möglicherweise nach dem Beenden des Browsers dazu auf, die Berechtigung für nicht signierte Erweiterungen wieder zu aktivieren.

## Aus dem Quellcode kompilieren

1. Klonen Sie dieses Repository und öffnen Sie `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. Wählen Sie unter **Signierung und Funktionen** Ihr eigenes Apple-Team für die beiden Ziele aus: die Anwendung und ihre Erweiterung. Im Repository ist kein persönliches Team eingetragen.
3. Wählen Sie das Schema **UGREEN NAS Download**, das Ziel **Mein Mac**, kompilieren und starten Sie es dann mit Xcode.
4. Aktivieren Sie die Erweiterung unter **Safari → Einstellungen → Erweiterungen** und autorisieren Sie dann die gewünschten Websites.
5. Öffnen Sie die Erweiterungseinstellungen und konfigurieren Sie Ihren NAS wie unten beschrieben.

Die Beispiel-Bundle-IDs sind `com.example.UGREENNASDownload` und `com.example.UGREENNASDownload.Extension`. Wenn Sie sie für Ihre Signatur anpassen müssen, ändern Sie die Projektkennungen Xcode **und** die entsprechenden Konstanten in `Extension/background.js` und `ViewController.swift`: Die Werte müssen konsistent bleiben.

Diese öffentliche Ausgabe verwendet Identifikatoren und einen von der persönlichen Entwicklungsanwendung getrennten Schlüsselbundbereich. Es erfordert eine eigene Konfiguration des NAS. Die Entwicklungssignatur stellt keine notariell beglaubigte Verteilung dar und für die Aktivierung sind möglicherweise die für Ihre Signatur geeigneten Safari-Entwicklungseinstellungen erforderlich.

So überprüfen Sie eine Kompilierung ohne Signatur im Stammverzeichnis des Repositorys:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Diese Prüfung führt zu einer nicht signierten Anwendung. Nutzen Sie Ihr Apple-Team für eine nutzbare Entwicklungsinstallation in Safari. Behalten Sie den Repository-Baum bei: Die Verweise Xcode auf `Extension` und `Design` sind relativ.

## Konfigurieren Sie den NAS

1. Geben Sie die HTTPS-Adresse des NAS mit seinem Port, Ihre Kennung und den absoluten Zielpfad auf dem NAS ein. Persönliche Felder sind standardmäßig leer.
2. Klicken Sie auf **NAS-Zertifikat prüfen**. Vergleichen Sie den SHA-256-Fingerabdruck mit einer vertrauenswürdigen Quelle, bevor Sie das Zertifikat bestätigen.
3. Geben Sie das Passwort und ggf. einen doppelten Authentifizierungscode ein. Dem Gerät zu vertrauen ist optional; Andernfalls ist möglicherweise ein neuer Code erforderlich, wenn die Sitzung abläuft.
4. Klicken Sie auf **Verbindung speichern und testen**. Erlauben Sie den Zugriff auf das lokale Netzwerk, wenn Sie von macOS dazu aufgefordert werden.
5. Aktivieren Sie bei Bedarf das automatische Abfangen von Torrents und Magneten. Rechtsklick und manuelles Senden bleiben von diesem Schalter unabhängig.

Adresse, Konto und Ordner können noch in den Einstellungen geändert werden. **Wenn Sie dieses Konto vergessen**, werden das Konto und seine Schlüsselbundsitzung für das aktuelle Safari-Profil gelöscht.

## Sicherheit und Betrieb

Webseiten können das Konto nicht konfigurieren oder einem Zertifikat nicht vertrauen. Die Erweiterung kommuniziert mit ihrem Swift-Modul über natives Messaging. NAS-Anfragen durchlaufen eine isolierte WebKit-Engine mit deaktiviertem kurzlebigem Speicher und deaktiviertem Seitenskripting. Das Zertifikat muss mit dem genehmigten Fingerabdruck übereinstimmen. NAS-Weiterleitungen werden abgelehnt. Das Passwort wird mit dem vom NAS bereitgestellten Schlüssel RSA bis HTTPS verschlüsselt.

Das Passwort, das Token und die Anmeldeinformationen werden im Schlüsselbund gespeichert, nicht im Webspeicher oder in diesem Repository. Der temporäre Code wird nach der Nutzung gelöscht. Cookies und Identifikatoren von Safari-Sites werden niemals an NAS übertragen. Bei einigen Torrents von derselben Site wird die kleine Datei mit der Sitzung Safari im Speicher abgerufen und dann ohne lokale Speicherung an NAS oder SMB übertragen. seine Größe ist auf 512 KiB begrenzt.

Automatische Suche fragt freiwillig nach `api.ugnas.com`: Dieser Dienst sieht die öffentliche IP-Adresse der Verbindung, erhält jedoch kein Passwort oder NAS-Token. Die manuelle Eingabe ist von diesem Dienst nicht abhängig.

Nach einer mehrdeutigen Antwort oder nach Ablauf einer Frist werden keine neuen Ergänzungen mehr versucht. Eine erneute Verbindung und ein neuer Versuch sind nur nach ausdrücklicher Verweigerung der Authentifizierung zulässig. **Eine vom NAS akzeptierte Aufgabe ist kein Beweis dafür, dass der Download abgeschlossen ist.**

## Grenzen

- Safari ersetzt nicht alle seine Downloads. Das automatische Abfangen deckt anerkannte Torrent-Links und -Mechanismen ab. Ein Rechtsklick und eine manuelle Eingabe schließen diesen Vorgang ab.
- Auf einen HTTP-Link muss der NAS direkt zugreifen können. Durch Site-Sitzungen geschützte Inhalte, abgelaufene URL, geschützte Videos und normale Dateien, die in `blob:` oder `data:` generiert wurden, werden nicht in öffentliche Links umgewandelt.
- Die Menüverfolgung wartet nach jeder Antwort etwa 3,5 Sekunden. Benachrichtigungen und Namenskorrekturen werden etwa alle 30 Sekunden überprüft. Safari geschlossen, angehalten oder ein Mac im Ruhezustand kann diese Vorgänge verzögern.
- Unbekannte Formate erhalten keine erfundene Erweiterung. Die Umbenennung erfolgt nach Abschluss des Downloads; Die eigentliche Datei ist fixiert, während der Download-Verlauf seinen ursprünglichen Namen behalten kann.
- Korrekturen bleiben auf neue, eindeutig identifizierte HTTP-Aufgaben beschränkt, ohne erzwungenen Ersatz, mit maximal 100 ausstehenden Vorgängen und einer Aufbewahrungsfrist von sieben Tagen. Listen sind auf 10.000 Aufgaben pro Kategorie begrenzt.
- Die globale macOS-Symboleinstellung behält Priorität: **Dunkel → Automatisch** ermöglicht es Ihnen, dem Thema zu folgen. Das statische Symbol in der Safari-Erweiterungsliste bleibt in seiner klaren Version; Die Menü- und Optionslogos folgen dem Thema.

## Entwicklung und Tests

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

Für JavaScript-Tests ist Node.js erforderlich. Für native Tests sind die Tools macOS, Xcode, Python 3 und OpenSSL erforderlich. Sie starten einen temporären lokalen HTTPS-Server auf Port 18443 und verwenden keine echten NAS-Konten. Das 0.5.1-Audit umfasste 45 JavaScript-Tests und 121 native Kontrollen. Siehe [den Bericht](../AUDIT-0.5.1.md).

- `Extension/`: Menü, Einstellungen, Safari-Skripte und Symbole.
- `Xcode/`: AppKit-Anwendung, Swift-Modul, Authentifizierung und Transport NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Natives Symbol mit hellem und dunklem Erscheinungsbild.
- `Design/generate-icons.swift`: Generierung von PNGs und dem adaptiven Logo des Fensters.
- `Tests/`: Sicherheitstests, Datenvalidierung und Verhalten.

## Referenzen

- [ugnas-api](https://github.com/Fracizz/ugnas-api) Community-Client: Protokollreferenz, ohne Code von Drittanbietern, der von einer NAS-Seite geladen wurde.
- [Community-Integration UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): Referenz für doppelte Authentifizierung.
- [Apple-Dokumentation Safari Web Extensions](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Um ein Problem zu melden, fügen Sie kein Passwort, keinen temporären Code, keinen Token, keinen signierten URL, keinen privaten Torrent oder keinen Schlüsselbundexport bei. Verwenden Sie in den Beispielen fiktive Daten.

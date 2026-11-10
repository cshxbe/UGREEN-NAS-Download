# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

Aplikacja macOS i rozszerzenie Safari do wysyłania plików do pobrania do aplikacji **Pobrania** NAS UGREEN pod UGOS Pro, bez konieczności otwierania strony NAS.

Źródła i wersja DMG: **0.6.1**. Niezależny projekt społecznościowy, niezwiązany z UGREEN ani Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

Interfejs aplikacji i rozszerzeń jest dostępny w 34 językach.

## Funkcje

- Przechwytywanie łączy `.torrent` i `magnet:` na stronach autoryzowanych w Safari.
- Akcja **Pobierz do NAS**, klikając prawym przyciskiem myszy bezpośrednio dostępny link, obraz, element wideo lub audio.
- Ręczne wysyłanie URL z menu rozszerzeń.
- Konto i sesja w Keychain macOS; Obsługa uwierzytelniania dwuskładnikowego i zaufania urządzeń.
- Opcjonalne wyszukiwanie NAS przez usługę online UGREEN lub ręczne wyszukiwanie adresu HTTPS.
- Lista pobrań, postęp i prędkość; opcjonalne powiadomienia o zakończeniu, zamknięciu i błędach.
- Identyfikacja nazw i typów plików HTTP, z korektą nazwy po pobraniu w przypadku jednoznacznej identyfikacji pliku.
- Natywne jasne i ciemne ikony oraz logo Safari dostosowane do motywu systemu.

## Kompatybilność

Projekt jest skonfigurowany dla **macOS 27 lub nowszego** i został skompilowany z **Xcode 27.1** dla Apple Silicon. Testy NAS przeprowadzono z **DXP2800**, **UGOS Pro 1.20.0.0142** i **Downloads 1.19.1.0004**. Inne wersje nie są gwarantowane: integracja opiera się na obserwowanych API, bez stabilnej umowy publicznej UGREEN.

## Zainstaluj z DMG

[Pobierz UGREEN NAS Download 0.6.1 dla komputerów Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.1).

1. Otwórz DMG, przeciągnij **UGREEN NAS Download** do **Aplikacje**, a następnie otwórz aplikację.
2. W **Safari → Ustawienia → Zaawansowane** włącz funkcje dla twórców stron internetowych. W **Programista** włącz **Zezwalaj na niepodpisane rozszerzenia**, a następnie włącz **UGREEN NAS Download** w **Rozszerzenia**.
3. Skonfiguruj NAS w ustawieniach rozszerzenia.

Ten pakiet publiczny jest podpisywany lokalnie (ad hoc) i nie jest poświadczony notarialnie. macOS może blokować jego początkowe otwarcie. Safari może poprosić o ponowne włączenie uprawnień dla niepodpisanych rozszerzeń po wyjściu z przeglądarki.

## Kompiluj ze źródła

1. Sklonuj to repozytorium i otwórz `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. W **Podpisywanie i możliwości** wybierz własny zespół Apple dla dwóch celów: aplikacji i jej rozszerzenia. W repozytorium nie ma wpisanego żadnego osobistego zespołu.
3. Wybierz schemat **UGREEN NAS Download**, miejsce docelowe **Mój Mac**, następnie skompiluj i uruchom z Xcode.
4. Aktywuj rozszerzenie w **Safari → Ustawienia → Rozszerzenia**, a następnie autoryzuj żądane witryny.
5. Otwórz ustawienia rozszerzenia i skonfiguruj NAS w sposób opisany poniżej.

Przykładowe identyfikatory pakietów to `com.example.UGREENNASDownload` i `com.example.UGREENNASDownload.Extension`. Jeśli chcesz dostosować je do swojego podpisu, zmodyfikuj identyfikatory projektu Xcode **oraz** odpowiednie stałe w `Extension/background.js` i `ViewController.swift`: wartości muszą pozostać spójne.

Ta publiczna edycja wykorzystuje identyfikatory i przestrzeń pęku kluczy oddzieloną od aplikacji do rozwoju osobistego. Wymaga własnej konfiguracji NAS. Podpis programistyczny nie stanowi notarialnie poświadczonej dystrybucji, a aktywacja może wymagać ustawień programistycznych Safari odpowiednich dla Twojego podpisu.

Aby sprawdzić kompilację bez podpisu, z katalogu głównego repozytorium:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

W wyniku tej kontroli powstaje niepodpisany wniosek; skorzystaj ze swojego zespołu Apple, aby uzyskać użyteczną instalację programistyczną w Safari. Zachowaj drzewo repozytorium: odniesienia Xcode do `Extension` i `Design` są względne.

## Skonfiguruj NAS

1. Wprowadź adres HTTPS NAS z jego portem, swoim identyfikatorem i bezwzględną ścieżką docelową na NAS. Pola osobiste są domyślnie puste.
2. Kliknij **Sprawdź certyfikat NAS**. Przed potwierdzeniem certyfikatu porównaj odcisk palca SHA-256 z zaufanym źródłem.
3. Wprowadź hasło i, jeśli to konieczne, podwójny kod uwierzytelniający. Zaufanie urządzeniu jest opcjonalne; bez niego po wygaśnięciu sesji może być wymagany nowy kod.
4. Kliknij **Zapisz i przetestuj połączenie**. Zezwól na dostęp do sieci lokalnej na żądanie macOS.
5. W razie potrzeby włącz automatyczne przechwytywanie torrentów i magnesów. Kliknięcie prawym przyciskiem myszy i ręczne wysyłanie pozostają niezależne od tego przełącznika.

Adres, konto i folder można nadal modyfikować w ustawieniach. **Zapomnienie tego konta** powoduje usunięcie konta i sesji pęku kluczy dla bieżącego profilu Safari.

## Bezpieczeństwo i obsługa

Strony internetowe nie mogą konfigurować konta ani ufać certyfikatowi. Rozszerzenie komunikuje się ze swoim modułem Swift za pośrednictwem natywnych komunikatorów. Żądania NAS przechodzą przez izolowany silnik WebKit z wyłączoną pamięcią efemeryczną i skryptami stron; certyfikat musi odpowiadać zatwierdzonemu odciskowi palca. Przekierowania NAS są odrzucane. Hasło szyfrowane jest kluczem RSA dostarczonym przez NAS, do HTTPS.

Hasło, token i dane logowania są przechowywane w pęku kluczy, a nie w pamięci internetowej lub w tym repozytorium. Kod tymczasowy jest usuwany po użyciu. Pliki cookie i identyfikatory ze stron Safari nigdy nie są przesyłane do NAS. W przypadku niektórych torrentów z tej samej witryny mały plik jest pobierany do pamięci w sesji Safari, a następnie przesyłany do NAS bez lokalnego zapisywania lub SMB; jego rozmiar jest ograniczony do 512 KiB.

Automatyczne wyszukiwanie dobrowolnie odpytuje `api.ugnas.com`: ta usługa widzi publiczny adres IP połączenia, ale nie otrzymuje hasła ani tokena NAS. Wprowadzanie ręczne nie jest zależne od tej usługi.

Po niejednoznacznej odpowiedzi lub po upływie terminu nie podejmuje się prób dodawania nowych wpisów. Ponowne połączenie i nowa próba są dozwolone wyłącznie po wyraźnej odmowie uwierzytelnienia. **Zadanie zaakceptowane przez NAS nie stanowi dowodu zakończenia pobierania.**

## Limity

- Safari nie zastępuje uniwersalnie wszystkich swoich pobrań. Automatyczne przechwytywanie obejmuje rozpoznane łącza i mechanizmy torrentów; kliknięcie prawym przyciskiem myszy i ręczne wprowadzenie kończy tę operację.
- Łącze HTTP musi być dostępne bezpośrednio przez NAS. Treści chronione sesją witryny, wygasłe URL, chronione filmy i zwykłe pliki wygenerowane w `blob:` lub `data:` nie są konwertowane na łącza publiczne.
- Śledzenie menu czeka około 3,5 sekundy po każdej odpowiedzi; powiadomienia i korekty nazw są sprawdzane mniej więcej co 30 sekund. Zamknięty, zawieszony lub uśpiony komputer Mac Safari może opóźnić te operacje.
- Nieznane formaty nie otrzymują wymyślonego rozszerzenia. Zmiana nazwy następuje po zakończeniu pobierania; rzeczywisty plik jest naprawiony, a historia pobierania może zachować swoją oryginalną nazwę.
- Korekty pozostają ograniczone do nowych, jednoznacznie zidentyfikowanych zadań HTTP, bez wymuszonej wymiany, z maksymalnie 100 oczekującymi operacjami i przechowywaniem przez siedem dni. Listy są ograniczone do 10 000 zadań w każdej kategorii.
- Globalne ustawienie ikony macOS pozostaje priorytetem: **Ciemny → Automatyczny** umożliwia śledzenie motywu. Statyczna ikona na liście rozszerzeń Safari pozostaje w przejrzystej wersji; logo menu i opcji jest zgodne z motywem.

## Rozwój i testowanie

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

Testowanie JavaScript wymaga Node.js; Testowanie natywne wymaga narzędzi macOS, Xcode, Python 3 i OpenSSL. Uruchamiają tymczasowy lokalny serwer HTTPS na porcie 18443 i nie używają żadnych prawdziwych kont NAS. Audyt wersji 0.5.1 obejmował 45 testów JavaScript i 121 kontroli natywnych. Zobacz [raport](../AUDIT-0.5.1.md).

- `Extension/`: menu, ustawienia, skrypty i ikony Safari.
- `Xcode/`: aplikacja AppKit, moduł Swift, uwierzytelnianie i transport NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Ikona natywna z jasnym i ciemnym wyglądem.
- `Design/generate-icons.swift`: generacja plików PNG i adaptacyjnego logo okna.
- `Tests/`: testowanie bezpieczeństwa, sprawdzanie poprawności danych i zachowanie.

## Referencje

- [klient społeczności ugnas-api](https://github.com/Fracizz/ugnas-api): odniesienie do protokołu, bez kodu strony trzeciej ładowanego ze strony NAS.
- [Integracja ze społecznością UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): odniesienie do podwójnego uwierzytelniania.
- [Dokumentacja Apple Safari Rozszerzenia internetowe ](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Aby zgłosić problem, nie dołączaj żadnego hasła, kodu tymczasowego, tokena, podpisanego URL, prywatnego torrenta ani eksportu pęku kluczy. Użyj fikcyjnych danych w przykładach.

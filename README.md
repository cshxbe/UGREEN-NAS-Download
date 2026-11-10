# UGREEN NAS Download

[Français](docs/README.fr.md) · [🌐 34 languages](docs/LANGUAGES.md)

A macOS application and a Safari extension to send downloads to the **Downloads** application of a UGREEN NAS running UGOS Pro, without keeping the NAS page open.

Source and DMG version: **0.6.0**. Independent community project, not affiliated with UGREEN or Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Extension/icon-dark-128.png">
  <img src="Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

The app and extension are available in 34 languages. They use the preferred language when available and fall back to English. The translated documentation and interface strings are machine-translated and have been checked for layout and missing entries.

## Features

- Interception of `.torrent` and `magnet:` links on sites authorized in Safari.
- Action **Download to the NAS** by right-clicking on a directly accessible link, image, video or audio element.
- Manual sending of a URL from the extension menu.
- Account and session in Keychain macOS; Support for two-factor authentication and device trust.
- Optional search for NAS by UGREEN online service, or manual HTTPS address.
- List of downloads, progress and speed; optional completion, shutdown, and error notifications.
- Identification of HTTP file names and types, with name correction after download when the file is unambiguously identified.
- Native light and dark icons, and Safari logos adapted to the system theme.

## Compatibility

The project is configured for **macOS 27 or later** and was compiled with **Xcode 27.1**, for Apple Silicon. NAS tests were performed with a **DXP2800**, **UGOS Pro 1.20.0.0142** and **Downloads 1.19.1.0004**. Other versions are not guaranteed: integration is based on observed APIs, without a stable UGREEN public contract.

## Install from DMG

[Download UGREEN NAS Download 0.6.0 for Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.0).

1. Open the DMG, drag **UGREEN NAS Download** into **Applications**, then open the app.
2. In **Safari → Settings → Advanced**, enable features for web developers. In **Developer**, enable **Allow unsigned extensions**, then enable **UGREEN NAS Download** in **Extensions**.
3. Configure the NAS in the extension settings.

This public package is signed locally (ad hoc) and not notarized. macOS may block its initial opening. Safari may ask to re-enable permission for unsigned extensions after exiting the browser.

## Compile from source

1. Clone this repository and open `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. In **Signing & Capabilities**, choose your own Apple team for the two targets: the application and its extension. No personal team is entered in the repository.
3. Choose the schema **UGREEN NAS Download**, destination **My Mac**, then compile and launch with Xcode.
4. Activate the extension in **Safari → Settings → Extensions**, then authorize the desired sites.
5. Open the extension settings and configure your NAS as described below.

The example bundle IDs are `com.example.UGREENNASDownload` and `com.example.UGREENNASDownload.Extension`. If you need to customize them for your signature, modify the project identifiers Xcode **and** the corresponding constants in `Extension/background.js` and `ViewController.swift`: the values ​​must remain consistent.

This public edition uses identifiers and a Keychain space separate from the personal development application. It requires its own configuration of the NAS. The development signature does not constitute a notarized distribution and activation may require the Safari development settings appropriate for your signature.

To check a compilation without signature, from the root of the repository:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

This check produces an unsigned application; use your Apple team for a usable development installation in Safari. Keep the repository tree: the references Xcode to `Extension` and `Design` are relative.

## Configure the NAS

1. Enter the HTTPS address of the NAS with its port, your identifier and the absolute destination path on the NAS. Personal fields are empty by default.
2. Click **Check NAS certificate**. Compare the SHA-256 fingerprint with a trusted source before confirming the certificate.
3. Enter the password and, if necessary, a double authentication code. Trusting the device is optional; without it, a new code may be required when the session expires.
4. Click **Save and test connection**. Allow access to the local network when requested by macOS.
5. Enable automatic interception of torrents and magnets if desired. Right-clicking and manual sending remain independent of this switch.

The address, account and folder can still be modified in the settings. **Forgetting this account** deletes the account and its Keychain session for the current Safari profile.

## Safety and Operation

Web pages cannot configure the account or trust a certificate. The extension communicates with its Swift module via native messaging. NAS requests go through an isolated WebKit engine with ephemeral storage and page scripting disabled; the certificate must match the approved fingerprint. NAS redirects are refused. The password is encrypted with the RSA key provided by the NAS, to HTTPS.

The password, token, and login information are stored in Keychain, not in web storage or this repository. The temporary code is erased after use. Cookies and identifiers from Safari sites are never transmitted to NAS. For some torrents from the same site, the small file is retrieved in memory with the session Safari, then transmitted to the NAS without local saving or SMB; its size is limited to 512 KiB.

Automatic search voluntarily queries `api.ugnas.com`: this service sees the public IP address of the connection, but does not receive a password or NAS token. Manual entry does not depend on this service.

No new additions are attempted after an ambiguous response or a deadline has passed. A reconnection and a new attempt are only permitted after an explicit refusal of authentication. **A task accepted by the NAS is not proof that the download is complete.**

## Limits

- Safari does not universally replace all of its downloads. Automatic interception covers recognized torrent links and mechanisms; right-clicking and manual entry complete this operation.
- A HTTP link must be accessible directly by the NAS. Site session protected contents, expired URL, protected videos and ordinary files generated in `blob:` or `data:` are not converted into public links.
- Menu tracking waits approximately 3.5 seconds after each response; notifications and name corrections are checked approximately every 30 seconds. Safari closed, suspended, or a sleeping Mac can delay these operations.
- Unknown formats do not receive an invented extension. The renaming occurs after the download is complete; the actual file is fixed, while the Download history can keep its original name.
- Corrections remain limited to new unambiguously identified HTTP tasks, without forced replacement, with a maximum of 100 pending operations and a retention of seven days. Lists are limited to 10,000 tasks per category.
- The global macOS icon setting remains priority: **Dark → Automatic** allows you to follow the theme. The static icon in the Safari extension list remains in its clear version; the menu and options logos follow the theme.

## Development and testing

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

JavaScript testing requires Node.js; Native testing requires macOS, Xcode tools, Python 3, and OpenSSL. They start a temporary local HTTPS server on port 18443 and do not use any real NAS accounts. The 0.5.1 audit included 45 JavaScript tests and 121 native controls. See [the report](AUDIT-0.5.1.md).

- `Extension/`: menu, settings, Safari scripts and icons.
- `Xcode/`: AppKit application, Swift module, authentication and transport NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Native icon with light and dark appearances.
- `Design/generate-icons.swift`: generation of PNGs and the adaptive logo of the window.
- `Tests/`: security testing, data validation and behavior.

## References

- [ugnas-api](https://github.com/Fracizz/ugnas-api) community client: protocol reference, without third-party code loaded from a NAS page.
- [Community integration UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): reference for double authentication.
- [Apple Documentation Safari Web Extensions](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

To report a problem, do not attach any password, temporary code, token, signed URL, private torrent or Keychain export. Use fictitious data in the examples.

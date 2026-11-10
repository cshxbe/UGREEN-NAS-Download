# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

macOS 應用程式和 Safari 擴充程序，用於將下載內容傳送至 UGOS Pro 下 UGREEN NAS 的 **下載** 應用程序，而無需保持 NAS 頁面開啟。

來源和 DMG 版本：**0.6.0**。獨立社區項目，不隸屬於 UGREEN 或 Apple。

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

該應用程式和擴充介面有 34 種語言版本。

## 特點

- 攔截 Safari 中授權網站上的 `.torrent` 和 `magnet:` 連結。
- 操作 **透過右鍵點擊可直接存取的連結、圖像、影片或音訊元素，下載到 NAS**。
- 從擴充功能選單手動發送 URL。
- macOS 鑰匙圈中的帳戶和會話；支援雙重認證和裝置信任。
- 可選使用 UGREEN 線上服務或手動 HTTPS 位址搜尋 NAS。
- 下載清單、進度和速度；可選的完成、關閉和錯誤通知。
- 識別 HTTP 檔案名稱和類型，並在下載後明確識別檔案時進行名稱更正。
- 原生淺色和深色圖標，以及適應系統主題的 Safari 標誌。

## 相容性

此專案針對 **macOS 27 或更高版本**進行配置，並使用 **Xcode 27.1** 進行編譯，適用於 Apple Silicon。 NAS 測試使用 **DXP2800**、**UGOS Pro 1.20.0.0142** 和 **下載 1.19.1.0004** 進行。不保證其他版本：整合基於觀察到的 API，沒有穩定的 UGREEN 公共合約。

## 從 DMG 安裝

[下載 UGREEN NAS 下載 0.6.0 for Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.0)。

1. 開啟DMG，將**UGREEN NAS Download**拖入**應用程式**，然後開啟應用程式。
2. 在 **Safari → 設定 → 進階** 中，為 Web 開發人員啟用功能。在**開發人員**中，啟用**允許未簽署的擴充功能**，然後在**擴充**中啟用**UGREEN NAS 下載**。
3. 在擴充設定中配置 NAS。

此公共包是本地簽名（臨時）且未經過公證。 macOS 可能會阻止其初始開啟。退出瀏覽器後，Safari 可能會要求重新啟用未簽署的擴充功能。

## 從原始碼編譯

1. 克隆此儲存庫並開啟 `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`。
2. 在**簽名和功能**中，為兩個目標選擇您自己的 Apple 團隊：應用程式及其擴充功能。儲存庫中未輸入任何個人團隊。
3. 選擇架構 **UGREEN NAS 下載**、目標 **我的 Mac**，然後使用 Xcode 編譯並啟動。
4. 在 **Safari → 設定 → 擴展** 中啟動擴展，然後授權所需的站點。
5. 開啟擴充設定並按照如下所述配置您的 NAS。

範例捆綁 ID 為 `com.example.UGREENNASDownload` 和 `com.example.UGREENNASDownload.Extension`。如果您需要針對您的簽名進行自訂，請修改 Xcode 項目標識符 **和** `Extension/background.js` 和 `ViewController.swift` 中相應的常數：值應保持一致。

此公開版本使用與個人開發應用程式分開的識別碼和鑰匙圈空間。它需要自己的 NAS 配置。開發人員簽名並不構成經過公證的分發，啟動可能需要適合您簽名的 Safari 開發人員設定。

要從儲存庫的根目錄檢查沒有簽章的編譯：

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

此檢查會產生一份未簽署的申請；請您的 Apple 團隊進行可在 Safari 中使用的開發安裝。保留儲存庫樹：Xcode 對 `Extension` 和 `Design` 的引用是相對的。

## 設定網路儲存

1. 輸入 NAS 的 HTTPS 位址及其連接埠、您的識別碼以及 NAS 上的絕對目標路徑。個人欄位預設為空。
2. 按一下**檢查 SIN 證書**。在確認證書之前，將 SHA-256 指紋與可信任來源進行比較。
3. 輸入密碼，如有必要，輸入雙重驗證碼。信任該設備是可選的；如果沒有它，會話到期時可能需要新代碼。
4. 按一下**儲存並測試連線**。當 macOS 請求時允許本地網路存取。
5. 如果需要，啟用自動攔截種子和磁鐵。右鍵單擊和手動發送與此開關無關。

地址、帳戶和資料夾仍然可以在設定中修改。 **忘記此帳戶** 刪除目前 Safari 設定檔的帳戶及其鑰匙圈會話。

## 安全與操作

網頁無法設定帳戶或信任憑證。此擴充功能透過本機訊息傳遞與其 Swift 模組進行通訊。 NAS 請求通過隔離的 WebKit 引擎，並停用暫存和頁面腳本；憑證必須與核准的指紋相符。 NAS 重定向被拒絕。密碼使用 NAS 提供的 RSA 金鑰透過 HTTPS 進行加密。

密碼、令牌和登入資訊儲存在 Keychain 中，而不是儲存在 Web 儲存或此儲存庫中。臨時代碼在使用後將被刪除。 Cookie 和 Safari 網站識別碼永遠不會傳輸到 NAS。對於來自同一網站的某些種子，透過 Safari 會話從記憶體中檢索小文件，然後傳輸到 NAS，無需本地備份或 SMB；它的大小限制為 512 KiB。

自動搜尋主動查詢`api.ugnas.com`：此服務看到連接的公共IP位址，但不接收密碼或NAS令牌。手動輸入不依賴該服務。

在模稜兩可的答案或截止日期過後，不會嘗試添加任何新內容。僅在明確拒絕身份驗證後才允許重新連線和新的嘗試。 **NAS接受的任務並不能證明下載已完成。 **

## 限制

- Safari 不允許您普遍替換其所有下載內容。自動攔截涵蓋已識別的種子連結和機制；右鍵單擊並手動輸入即可完成此操作。
- HTTP 連結必須可由 NAS 直接存取。網站會話受保護的內容、過期的 URL、受保護的影片以及在`blob:`或`data:`中產生的普通檔案不會轉換為公共連結。
- 選單追蹤在每次回應後等待約 3.5 秒；大約每 30 秒檢查一次通知和名稱更正。 Safari 關閉、暫停或 Mac 處於睡眠狀態可能會延遲這些操作。
- 未知格式不會收到發明的副檔名。下載完成後進行重新命名；實際檔案是固定的，而下載歷史記錄可以保留其原始名稱。
- 修復仍然僅限於明確標識的新 HTTP 任務，無需強制替換，最多 100 個待處理操作並保留 7 天。每個類別的清單限制為 10,000 個任務。
- 全域 macOS 圖示設定仍然優先：**深色→自動**允許您遵循主題。 Safari 擴充功能清單中的靜態圖示仍保持清晰版本；選單和選項標誌遵循主題。

## 開發與測試

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

JavaScript 測試需要 Node.js；本機測試需要 macOS、Xcode 工具、Python 3 和 OpenSSL。他們在連接埠 18443 上啟動臨時本機 HTTPS 伺服器，並且不使用任何真實的 NAS 帳戶。 0.5.1 審核包括 45 個 JavaScript 測試和 121 個本機控制項。請參閱[報告](../AUDIT-0.5.1.md)。

- `Extension/`：選單、設定、Safari 腳本和圖示。
- `Xcode/`：AppKit 應用程式、Swift 模組、身份驗證和 NAS 傳輸。
- `Design/Adaptive/UGREENIcon.icon/`：具有淺色和深色外觀的原生圖示。
- `Design/generate-icons.swift`：產生PNG和視窗的自適應標誌。
- `Tests/`：安全測試、資料驗證與行為。

## 參考文獻

- [ugnas-api社群客戶端](https://github.com/Fracizz/ugnas-api)：協定參考，沒有從NAS頁面載入第三方程式碼。
- 【UGREEN社群整合](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py)：雙重認證參考。
- [Apple Safari Web 擴充文檔](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari)。

若要回報問題，請勿附加任何密碼、臨時代碼、令牌、簽名 URL、私人 torrent 或鑰匙串匯出。在範例中使用虛構資料。

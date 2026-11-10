# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

一个macOS应用程序和Safari扩展程序，用于将下载内容发送到UGOS Pro下的NASUGREEN的**下载**应用程序，而无需保持NAS页面打开。

来源和 DMG 版本：**0.6.0**。独立社区项目，不隶属于 UGREEN 或 Apple。

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

该应用程序和扩展界面有 34 种语言版本。

## 特点

- 在Safari授权的网站上拦截链接`.torrent`和`magnet:`。
- 操作 **通过右键单击可直接访问的链接、图像、视频或音频元素，下载到 NAS**。
- 从扩展菜单手动发送URL。
- 钥匙串中的帐户和会话macOS；支持双因素身份验证和设备信任。
- 可选使用 UGREEN 在线服务搜索NAS，或手动地址HTTPS。
- 下载列表、进度和速度；可选的完成、关闭和错误通知。
- 文件名和类型的识别HTTP，下载后明确识别文件后进行名称更正。
- 原生浅色和深色图标，以及适应系统主题的Safari徽标。

## 兼容性

该项目配置为 **macOS 27 或更高版本**，并使用 **Xcode 27.1** 进行编译，适用于 Apple Silicon。 NAS 测试是使用 **DXP2800**、**UGOS Pro 1.20.0.0142** 和 **下载 1.19.1.0004** 进行的。不保证其他版本：集成基于观察到的 API，没有稳定的 UGREEN 公共合约。

## 从 DMG 安装

[下载适用于 Mac Apple Silicon 的 UGREEN NAS Download 0.6.0](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.0)。

1. 打开DMG，将**UGREEN NAS Download**拖到**应用程序**中，然后打开应用程序。
2. 在**Safari→设置→高级**中，为Web开发人员启用功能。在**开发人员**中，启用**允许未签名的扩展**，然后在**扩展**中启用**UGREEN NAS Download**。
3. 在扩展设置中配置NAS。

此公共包是本地签名（临时）且未经过公证。 macOS 可能会阻止其初始打开。退出浏览器后，Safari可能会要求重新启用未签名扩展程序的权限。

## 从源代码编译

1. 克隆此存储库并打开`Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`。
2. 在**签名和功能**中，为两个目标选择您自己的 Apple 团队：应用程序及其扩展。存储库中未输入任何个人团队。
3. 选择方案 **UGREEN NAS Download**，目标 **My Mac**，然后使用 Xcode 编译并启动。
4. 在**Safari→设置→扩展**中激活扩展，然后授权所需的站点。
5. 打开扩展设置并按如下所述配置您的 NAS。

示例捆绑 ID 为 `com.example.UGREENNASDownload` 和 `com.example.UGREENNASDownload.Extension`。如果您需要针对您的签名进行自定义，请修改项目标识符Xcode **和** `Extension/background.js`和`ViewController.swift`中对应的常量：值必须保持一致。

此公共版本使用与个人开发应用程序分开的标识符和钥匙串空间。它需要自己的配置NAS。开发签名不构成经过公证的分发，激活可能需要适合您签名的开发设置Safari。

要从存储库的根目录检查没有签名的编译：

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

该检查会产生一份未签名的申请；使用您的 Apple 团队进行可在 Safari 中使用的开发安装。保留存储库树：Xcode到`Extension`和`Design`的引用是相对的。

## 配置NAS

1. 输入NAS的地址HTTPS及其端口、您的标识符以及NAS上的绝对目标路径。个人字段默认为空。
2. 点击**查看NAS**的证书。在确认证书之前，将指纹SHA-256与可信来源进行比较。
3. 输入密码，如有必要，输入双重验证码。信任该设备是可选的；如果没有它，会话到期时可能需要新代码。
4. 单击**保存并测试连接**。当 macOS 请求时允许访问本地网络。
5. 如果需要，启用自动拦截种子和磁铁。右键单击和手动发送与此开关无关。

地址、帐户和文件夹仍然可以在设置中修改。 **忘记此帐户**会删除当前配置文件Safari的帐户及其钥匙串会话。

## 安全与操作

网页无法配置帐户或信任证书。该扩展通过本机消息传递与其 Swift 模块进行通信。 NAS 请求通过隔离的 WebKit 引擎，并禁用临时存储和页面脚本；证书必须与批准的指纹匹配。 NAS 重定向被拒绝。密码使用NAS在HTTPS提供的密钥RSA进行加密。

密码、令牌和登录信息存储在 Keychain 中，而不是存储在 Web 存储或此存储库中。临时代码在使用后将被删除。 Cookie 和站点标识符 Safari 绝不会传输到 NAS。对于来自同一站点的某些种子，小文件会通过会话Safari在内存中检索，然后传输到NAS而不进行本地保存或SMB；它的大小限制为 512 KiB。

自动搜索会主动查询`api.ugnas.com`：此服务会看到连接的公共IP地址，但不会收到密码或令牌NAS。手动输入不依赖于该服务。

在模棱两可的答复或截止日期过后，不会尝试添加任何新内容。仅在明确拒绝身份验证后才允许重新连接和新的尝试。 **NAS接受的任务并不能证明下载已完成。**

## 限制

- Safari 不会普遍替换其所有下载内容。自动拦截涵盖已识别的种子链接和机制；右键单击并手动输入即可完成此操作。
- 链接 HTTP 必须可以通过 NAS 直接访问。站点会话受保护的内容、过期的URL、受保护的视频以及`blob:`或`data:`中生成的普通文件不会转换为公共链接。
- 菜单跟踪在每次响应后等待大约 3.5 秒；大约每 30 秒检查一次通知和名称更正。 Safari 关闭、挂起或睡眠的 Mac 可能会延迟这些操作。
- 未知格式不会收到发明的扩展名。下载完成后进行重命名；实际文件是固定的，而下载历史记录可以保留其原始名称。
- 更正仍仅限于明确标识的新任务HTTP，不强制替换，最多 100 个待处理操作，保留 7 天。每个类别的列表限制为 10,000 个任务。
- 图标的全局设置macOS仍然优先：**深色→自动**允许您遵循主题。静态扩展列表图标Safari保留清晰版本；菜单和选项徽标遵循主题。

## 开发与测试

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

JavaScript 测试需要 Node.js；本机测试需要 macOS、Xcode 工具、Python 3 和 OpenSSL。他们在端口 18443 上启动临时本地 HTTPS 服务器，并且不使用任何真实的 NAS 帐户。 0.5.1 审核包括 45 个 JavaScript 测试和 121 个本机控件。请参阅[报告](../AUDIT-0.5.1.md)。

- `Extension/`：菜单、设置、脚本Safari 和图标。
- `Xcode/`：AppKit 应用程序、Swift 模块、身份验证和传输NAS。
- `Design/Adaptive/UGREENIcon.icon/`：具有浅色和深色外观的原生图标。
- `Design/generate-icons.swift`：生成PNG和窗口的自适应徽标。
- `Tests/`：安全测试、数据验证和行为。

## 参考文献

- [ugnas-api社区客户端](https://github.com/Fracizz/ugnas-api)：协议参考，没有从页面NAS加载第三方代码。
- 【UGREEN社区整合](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py)：双重认证参考。
- [Apple 文档Safari Web 扩展](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari)。

要报告问题，请勿附加任何密码、临时代码、令牌、签名 URL、私人 torrent 或钥匙串导出。在示例中使用虚构数据。

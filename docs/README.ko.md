# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

macOS 애플리케이션 및 Safari 확장은 NAS 페이지를 열어두지 않고 UGOS Pro 아래에 있는 NAS UGREEN의 **다운로드** 애플리케이션으로 다운로드를 보냅니다.

소스 및 DMG 버전: **0.6.1**. UGREEN이나 Apple과 관련이 없는 독립 커뮤니티 프로젝트입니다.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

앱과 확장 인터페이스는 34개 언어로 제공됩니다.

## 특징

- Safari에서 승인된 사이트에서 `.torrent` 및 `magnet:` 링크를 차단합니다.
- 조치 직접 액세스할 수 있는 링크, 이미지, 비디오 또는 오디오 요소를 마우스 오른쪽 버튼으로 클릭하여 **NAS**를 다운로드합니다.
- 확장 메뉴에서 URL를 수동으로 보냅니다.
- 키체인 macOS의 계정 및 세션; 이중 인증 및 장치 신뢰를 지원합니다.
- UGREEN 온라인 서비스 또는 수동 HTTPS 주소를 통해 NAS를 선택적으로 검색할 수 있습니다.
- 다운로드, 진행률 및 속도 목록 선택적 완료, 종료 및 오류 알림.
- 파일이 명확하게 식별되면 다운로드 후 이름 수정을 통해 HTTP 파일 이름 및 유형을 식별합니다.
- 기본 밝은 아이콘과 어두운 아이콘, 시스템 테마에 맞게 조정된 Safari 로고.

## 호환성

프로젝트는 **macOS 27 이상**용으로 구성되었으며 Apple Silicon용 **Xcode 27.1**로 컴파일되었습니다. NAS 테스트는 **DXP2800**, **UGOS Pro 1.20.0.0142** 및 **다운로드 1.19.1.0004**를 사용하여 수행되었습니다. 다른 버전은 보장되지 않습니다. 통합은 안정적인 UGREEN 공개 계약 없이 관찰된 API를 기반으로 합니다.

## DMG에서 설치

[Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.1)용 UGREEN NAS Download 0.6.1을 다운로드하세요.

1. DMG를 열고 **UGREEN NAS Download**를 **응용 프로그램**으로 드래그한 다음 앱을 엽니다.
2. **Safari → 설정 → 고급**에서 웹 개발자를 위한 기능을 활성화하세요. **개발자**에서 **서명되지 않은 확장 허용**을 활성화한 다음 **확장 프로그램**에서 **UGREEN NAS Download**를 활성화합니다.
3. 확장 설정에서 NAS를 구성합니다.

이 공개 패키지는 로컬로(임시) 서명되었으며 공증되지 않았습니다. macOS는 초기 열기를 차단할 수 있습니다. Safari는 브라우저를 종료한 후 서명되지 않은 확장에 대한 권한을 다시 활성화하도록 요청할 수 있습니다.

## 소스에서 컴파일

1. 이 저장소를 복제하고 `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`를 엽니다.
2. **서명 및 기능**에서 애플리케이션과 해당 확장이라는 두 가지 대상에 대한 자체 Apple 팀을 선택합니다. 개인 팀은 저장소에 입력되지 않습니다.
3. 스키마 **UGREEN NAS Download**, 대상 **My Mac**을 선택한 다음 Xcode로 컴파일하고 실행합니다.
4. **Safari → 설정 → 확장 프로그램**에서 확장 프로그램을 활성화한 후 원하는 사이트를 인증하세요.
5. 확장 설정을 열고 아래 설명에 따라 NAS를 구성하세요.

예제 번들 ID는 `com.example.UGREENNASDownload` 및 `com.example.UGREENNASDownload.Extension`입니다. 서명을 위해 사용자 정의해야 하는 경우 프로젝트 식별자 Xcode **및** `Extension/background.js` 및 `ViewController.swift`의 해당 상수를 수정합니다. 값은 일관되게 유지되어야 합니다.

이 공개 버전은 개인 개발 애플리케이션과 별도로 식별자와 키체인 공간을 사용합니다. NAS의 자체 구성이 필요합니다. 개발 서명은 공증된 배포를 구성하지 않으며 활성화하려면 서명에 적합한 Safari 개발 설정이 필요할 수 있습니다.

서명 없이 컴파일을 확인하려면 저장소 루트에서 다음을 수행하세요.

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

이 확인을 통해 서명되지 않은 애플리케이션이 생성됩니다. Safari에서 사용 가능한 개발 설치를 위해 Apple 팀을 활용하세요. 저장소 트리를 유지하십시오. Xcode에서 `Extension` 및 `Design`에 대한 참조는 상대적입니다.

## NAS 구성

1. NAS의 HTTPS 주소와 해당 포트, 식별자 및 NAS의 절대 대상 경로를 입력하세요. 개인 필드는 기본적으로 비어 있습니다.
2. **NAS 인증서 확인**을 클릭하세요. 인증서를 확인하기 전에 SHA-256 지문을 신뢰할 수 있는 소스와 비교하세요.
3. 비밀번호를 입력하고, 필요한 경우 이중 인증 코드를 입력하세요. 장치를 신뢰하는 것은 선택 사항입니다. 그렇지 않으면 세션이 만료될 때 새 코드가 필요할 수 있습니다.
4. **저장 및 연결 테스트**를 클릭합니다. macOS에서 요청하면 로컬 네트워크에 대한 액세스를 허용합니다.
5. 원하는 경우 토렌트 및 자석의 자동 차단을 활성화합니다. 마우스 오른쪽 버튼 클릭과 수동 전송은 이 스위치와 별개로 유지됩니다.

주소, 계정 및 폴더는 설정에서 계속 수정할 수 있습니다. **이 계정을 잊어버리면** 현재 Safari 프로필에 대한 계정과 해당 키체인 세션이 삭제됩니다.

## 안전 및 운영

웹 페이지에서는 계정을 구성하거나 인증서를 신뢰할 수 없습니다. 확장은 기본 메시징을 통해 Swift 모듈과 통신합니다. NAS 요청은 임시 저장소와 페이지 스크립팅이 비활성화된 격리된 WebKit 엔진을 통과합니다. 인증서는 승인된 지문과 일치해야 합니다. NAS 리디렉션이 거부됩니다. 비밀번호는 NAS에서 HTTPS로 제공한 RSA 키를 사용하여 암호화됩니다.

비밀번호, 토큰, 로그인 정보는 웹 저장소나 이 저장소가 아닌 키체인에 저장됩니다. 임시코드는 사용 후 삭제됩니다. Safari 사이트의 쿠키 및 식별자는 NAS로 전송되지 않습니다. 동일한 사이트의 일부 토렌트의 경우 작은 파일은 Safari 세션을 사용하여 메모리에서 검색된 다음 로컬 저장 또는 SMB 없이 NAS로 전송됩니다. 크기는 512KiB로 제한됩니다.

자동 검색은 자발적으로 `api.ugnas.com`를 쿼리합니다. 이 서비스는 연결의 공용 IP 주소를 확인하지만 비밀번호나 NAS 토큰을 받지 않습니다. 수동 입력은 이 서비스에 의존하지 않습니다.

모호한 응답이 있거나 기한이 지난 후에는 새로운 추가가 시도되지 않습니다. 재연결 및 새로운 시도는 명시적으로 인증을 거부한 후에만 허용됩니다. **NAS가 수락한 작업은 다운로드가 완료되었다는 증거가 아닙니다.**

## 한도

- Safari는 모든 다운로드를 보편적으로 대체하지 않습니다. 자동 차단은 인식된 토렌트 링크 및 메커니즘을 포함합니다. 마우스 오른쪽 버튼을 클릭하고 수동으로 입력하면 이 작업이 완료됩니다.
- HTTP 링크는 NAS에서 직접 액세스할 수 있어야 합니다. 사이트 세션 보호 콘텐츠, 만료된 URL, 보호된 비디오 및 `blob:` 또는 `data:`에서 생성된 일반 파일은 공개 링크로 변환되지 않습니다.
- 메뉴 추적은 각 응답 후 약 3.5초 동안 기다립니다. 알림 및 이름 수정은 약 30초마다 확인됩니다. Safari가 닫혀 있거나 정지되었거나 잠자기 상태인 Mac에서는 이러한 작업이 지연될 수 있습니다.
- 알 수 없는 형식은 고안된 확장자를 받지 않습니다. 다운로드가 완료된 후 이름이 변경됩니다. 실제 파일은 수정되지만 다운로드 기록은 원래 이름을 유지할 수 있습니다.
- 수정 사항은 강제 교체 없이 명확하게 식별된 새로운 HTTP 작업으로 제한되며 최대 100개의 보류 작업과 7일간 보존됩니다. 목록은 카테고리당 10,000개의 작업으로 제한됩니다.
- 전역 macOS 아이콘 설정은 우선순위로 유지됩니다. **어두운 → 자동**을 사용하면 테마를 따를 수 있습니다. Safari 확장 목록의 정적 아이콘은 일반 버전으로 유지됩니다. 메뉴와 옵션 로고는 테마를 따릅니다.

## 개발 및 테스트

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

JavaScript 테스트에는 Node.js가 필요합니다. 기본 테스트에는 macOS, Xcode 도구, Python 3 및 OpenSSL이 필요합니다. 포트 18443에서 임시 로컬 HTTPS 서버를 시작하고 실제 NAS 계정을 사용하지 않습니다. 0.5.1 감사에는 45개의 JavaScript 테스트와 121개의 기본 컨트롤이 포함되었습니다. [보고서](../AUDIT-0.5.1.md).

- `Extension/`: 메뉴, 설정, Safari 스크립트 및 아이콘.
- `Xcode/`: AppKit 애플리케이션, Swift 모듈, 인증 및 전송 NAS.
- `Design/Adaptive/UGREENIcon.icon/`: 밝고 어두운 모양의 기본 아이콘입니다.
- `Design/generate-icons.swift`: PNG 생성 및 창의 적응형 로고.
- `Tests/`: 보안 테스트, 데이터 검증 및 동작.

## 참고자료

- [ugnas-api](https://github.com/Fracizz/ugnas-api) 커뮤니티 클라이언트: NAS 페이지에서 로드된 타사 코드가 없는 프로토콜 참조입니다.
- [커뮤니티 통합 UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): 이중인증 참고사항입니다.
- [Apple 문서 Safari 웹 확장](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

문제를 보고하려면 비밀번호, 임시 코드, 토큰, 서명된 URL, 개인 토렌트 또는 키체인 내보내기를 첨부하지 마세요. 예제에서는 가상 데이터를 사용합니다.

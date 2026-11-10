# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

Ứng dụng macOS và tiện ích mở rộng Safari để gửi các bản tải xuống tới ứng dụng **Tải xuống** của NAS UGREEN trong UGOS Pro mà không cần mở trang NAS.

Nguồn và phiên bản DMG: **0.6.0**. Dự án cộng đồng độc lập, không liên kết với UGREEN hay Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

Giao diện ứng dụng và tiện ích mở rộng có sẵn bằng 34 ngôn ngữ.

## Tính năng

- Chặn các liên kết `.torrent` và `magnet:` trên các trang web được ủy quyền trong Safari.
- Hành động **Tải xuống NAS** bằng cách nhấp chuột phải vào liên kết, hình ảnh, video hoặc phần tử âm thanh có thể truy cập trực tiếp.
- Gửi URL theo cách thủ công từ menu tiện ích mở rộng.
- Tài khoản và phiên trong chuỗi khóa macOS; Hỗ trợ xác thực hai yếu tố và tin cậy thiết bị.
- Tìm kiếm NAS tùy chọn bằng dịch vụ trực tuyến UGREEN hoặc địa chỉ HTTPS thủ công.
- Danh sách tải xuống, tiến độ và tốc độ; tùy chọn hoàn thành, tắt máy và thông báo lỗi.
- Nhận dạng tên và loại tệp HTTP, có sửa tên sau khi tải xuống khi tệp được xác định rõ ràng.
- Các biểu tượng sáng và tối gốc cũng như logo Safari phù hợp với chủ đề hệ thống.

## Khả năng tương thích

Dự án được định cấu hình cho **macOS 27 trở lên** và được biên dịch bằng **Xcode 27.1**, dành cho Apple Silicon. Thử nghiệm NAS được thực hiện với **DXP2800**, **UGOS Pro 1.20.0.0142** và **Tải xuống 1.19.1.0004**. Các phiên bản khác không được đảm bảo: việc tích hợp dựa trên các API được quan sát mà không có hợp đồng công khai UGREEN ổn định.

## Cài đặt từ DMG

[Tải xuống UGREEN NAS Tải xuống 0.6.0 cho Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.0).

1. Mở DMG, kéo **UGREEN NAS Download** vào **Applications**, sau đó mở ứng dụng.
2. Trong **Safari → Cài đặt → Nâng cao**, bật các tính năng dành cho nhà phát triển web. Trong **Nhà phát triển**, bật **Cho phép tiện ích mở rộng chưa được ký**, sau đó bật **Tải xuống NAS UGREEN** trong **Tiện ích mở rộng**.
3. Định cấu hình NAS trong cài đặt tiện ích mở rộng.

Gói công khai này được ký cục bộ (đặc biệt) và không được công chứng. macOS có thể chặn lần mở đầu tiên của nó. Safari có thể yêu cầu kích hoạt lại các tiện ích mở rộng chưa được ký sau khi thoát khỏi trình duyệt.

## Biên dịch từ nguồn

1. Sao chép kho lưu trữ này và mở `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. Trong **Ký & Khả năng**, hãy chọn nhóm Apple của riêng bạn cho hai mục tiêu: ứng dụng và tiện ích mở rộng của nó. Không có nhóm cá nhân nào được nhập vào kho lưu trữ.
3. Chọn lược đồ **UGREEN NAS Download**, đích **My Mac**, sau đó biên dịch và khởi chạy bằng Xcode.
4. Kích hoạt tiện ích mở rộng trong **Safari → Cài đặt → Tiện ích mở rộng**, sau đó ủy quyền cho các trang web mong muốn.
5. Mở cài đặt tiện ích mở rộng và định cấu hình NAS của bạn như mô tả bên dưới.

ID gói ví dụ là `com.example.UGREENNASDownload` và `com.example.UGREENNASDownload.Extension`. Nếu bạn cần tùy chỉnh chúng cho chữ ký của mình, hãy sửa đổi mã định danh dự án Xcode **và** các hằng số tương ứng trong `Extension/background.js` và `ViewController.swift`: các giá trị phải nhất quán.

Phiên bản công khai này sử dụng số nhận dạng và không gian Chuỗi khóa tách biệt với ứng dụng phát triển cá nhân. Nó yêu cầu cấu hình NAS riêng. Chữ ký của nhà phát triển không phải là bản phân phối có công chứng và việc kích hoạt có thể yêu cầu cài đặt của nhà phát triển Safari phù hợp với chữ ký của bạn.

Để kiểm tra phần biên dịch không có chữ ký, từ thư mục gốc của kho lưu trữ:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Việc kiểm tra này tạo ra một ứng dụng chưa được ký; Sử dụng nhóm Apple của bạn để cài đặt phát triển có thể sử dụng được trong Safari. Giữ cây kho lưu trữ: Các tham chiếu Xcode đến `Extension` và `Design` là tương đối.

## Cấu hình NAS

1. Nhập địa chỉ HTTPS của NAS cùng với cổng, mã nhận dạng của bạn và đường dẫn đích tuyệt đối trên NAS. Các trường cá nhân được để trống theo mặc định.
2. Nhấp vào **Kiểm tra chứng chỉ SIN**. So sánh dấu vân tay SHA-256 với nguồn đáng tin cậy trước khi xác nhận chứng chỉ.
3. Nhập mật khẩu và nếu cần, mã xác thực kép. Tin cậy thiết bị là tùy chọn; không có nó, có thể cần phải có mã mới khi phiên hết hạn.
4. Nhấp vào **Lưu và kiểm tra kết nối**. Cho phép truy cập mạng cục bộ khi macOS yêu cầu.
5. Cho phép tự động chặn torrent và nam châm nếu muốn. Nhấp chuột phải và gửi thủ công vẫn độc lập với công tắc này.

Địa chỉ, tài khoản và thư mục vẫn có thể được sửa đổi trong cài đặt. **Quên tài khoản này** sẽ xóa tài khoản và phiên Chuỗi khóa của tài khoản đó cho hồ sơ Safari hiện tại.

## An toàn và vận hành

Các trang web không thể định cấu hình tài khoản hoặc tin cậy chứng chỉ. Tiện ích mở rộng giao tiếp với mô-đun Swift thông qua tin nhắn gốc. Các yêu cầu NAS đi qua một công cụ WebKit bị cô lập với bộ lưu trữ tạm thời và tập lệnh trang bị vô hiệu hóa; chứng chỉ phải khớp với dấu vân tay đã được phê duyệt. Chuyển hướng NAS bị từ chối. Mật khẩu được mã hóa bằng khóa RSA do NAS cung cấp qua HTTPS.

Mật khẩu, mã thông báo và thông tin đăng nhập được lưu trữ trong Chuỗi khóa chứ không phải trong bộ nhớ web hoặc kho lưu trữ này. Mã tạm thời sẽ bị xóa sau khi sử dụng. Cookie và số nhận dạng trang web Safari không bao giờ được truyền tới NAS. Đối với một số torrent từ cùng một trang, tệp nhỏ được truy xuất từ ​​bộ nhớ bằng phiên Safari, sau đó được truyền đến NAS mà không cần bản sao lưu cục bộ hoặc SMB; kích thước của nó được giới hạn ở 512 KiB.

Tìm kiếm tự động truy vấn tự nguyện `api.ugnas.com`: dịch vụ này nhìn thấy địa chỉ IP công cộng của kết nối nhưng không nhận được mật khẩu hoặc mã thông báo NAS. Nhập thủ công không phụ thuộc vào dịch vụ này.

Không có sự bổ sung mới nào được thử sau khi có phản hồi không rõ ràng hoặc thời hạn đã trôi qua. Việc kết nối lại và thử lại chỉ được phép sau khi từ chối xác thực rõ ràng. **Một tác vụ được NAS chấp nhận không phải là bằng chứng cho thấy quá trình tải xuống đã hoàn tất.**

## Giới hạn

- Safari không cho phép bạn thay thế toàn bộ tất cả các bản tải xuống của nó. Tự động chặn bao gồm các liên kết và cơ chế torrent được công nhận; nhấp chuột phải và nhập thủ công sẽ hoàn tất thao tác này.
- NAS phải có thể truy cập trực tiếp vào liên kết HTTP. Nội dung được bảo vệ phiên trang web, URL hết hạn, video được bảo vệ và các tệp thông thường được tạo trong `blob:` hoặc `data:` không được chuyển đổi thành liên kết công khai.
- Theo dõi menu chờ khoảng 3,5 giây sau mỗi phản hồi; thông báo và sửa tên được kiểm tra khoảng 30 giây một lần. Safari bị đóng, bị treo hoặc máy Mac đang ở chế độ ngủ có thể trì hoãn các thao tác này.
- Các định dạng không xác định sẽ không nhận được tiện ích mở rộng được phát minh. Việc đổi tên xảy ra sau khi quá trình tải xuống hoàn tất; tệp thực tế đã được sửa, trong khi lịch sử Tải xuống có thể giữ nguyên tên gốc.
- Các bản sửa lỗi vẫn bị giới hạn ở các tác vụ HTTP mới được xác định rõ ràng mà không cần thay thế bắt buộc, với tối đa 100 thao tác đang chờ xử lý và thời gian lưu giữ là bảy ngày. Danh sách được giới hạn ở 10.000 nhiệm vụ cho mỗi danh mục.
- Cài đặt biểu tượng macOS toàn cầu vẫn được ưu tiên: **Tối → Tự động** cho phép bạn theo dõi chủ đề. Biểu tượng tĩnh trong danh sách tiện ích mở rộng Safari vẫn ở phiên bản rõ ràng; menu và các biểu tượng tùy chọn theo chủ đề.

## Phát triển và thử nghiệm

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

Kiểm tra JavaScript yêu cầu Node.js; Thử nghiệm gốc yêu cầu macOS, công cụ Xcode, Python 3 và OpenSSL. Họ khởi động máy chủ HTTPS cục bộ tạm thời trên cổng 18443 và không sử dụng bất kỳ tài khoản NAS thực nào. Quá trình kiểm tra 0.5.1 bao gồm 45 bài kiểm tra JavaScript và 121 điều khiển gốc. Xem [báo cáo](../AUDIT-0.5.1.md).

- `Extension/`: menu, cài đặt, tập lệnh và biểu tượng Safari.
- `Xcode/`: Ứng dụng AppKit, mô-đun Swift, xác thực và truyền tải NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Biểu tượng gốc với giao diện sáng và tối.
- `Design/generate-icons.swift`: tạo PNG và logo thích ứng của cửa sổ.
- `Tests/`: kiểm tra bảo mật, xác thực dữ liệu và hành vi.

## Tài liệu tham khảo

- [ứng dụng khách cộng đồng ugnas-api](https://github.com/Fracizz/ugnas-api): tham chiếu giao thức, không tải mã của bên thứ ba từ trang NAS.
- [Tích hợp cộng đồng UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): tham khảo để xác thực kép.
- [Tài liệu về Tiện ích mở rộng Web của Apple Safari](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Để báo cáo sự cố, không đính kèm bất kỳ mật khẩu, mã tạm thời, mã thông báo, URL đã ký, torrent riêng tư hoặc xuất Chuỗi khóa nào. Sử dụng dữ liệu hư cấu trong các ví dụ.

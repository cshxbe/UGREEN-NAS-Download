# UGREEN NAS Download

[English](../README.md) · [Français](README.fr.md) · [🌐 34](LANGUAGES.md)

Aplikasi macOS dan ekstensi Safari untuk mengirim unduhan ke aplikasi **Unduhan** dari UGREEN NAS di bawah UGOS Pro, tanpa membiarkan halaman NAS tetap terbuka.

Sumber dan versi DMG: **0.6.0**. Proyek komunitas independen, tidak berafiliasi dengan UGREEN atau Apple.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../Extension/icon-dark-128.png">
  <img src="../Extension/icon-128.png" width="96" height="96" alt="UGREEN NAS Download">
</picture>

Antarmuka aplikasi dan ekstensi tersedia dalam 34 bahasa.

## Fitur

- Intersepsi tautan `.torrent` dan `magnet:` di situs yang diotorisasi di Safari.
- Tindakan **Unduh ke NAS** dengan mengeklik kanan tautan, gambar, video, atau elemen audio yang dapat diakses langsung.
- Pengiriman URL secara manual dari menu ekstensi.
- Akun dan sesi di Gantungan Kunci macOS; Dukungan untuk otentikasi dua faktor dan kepercayaan perangkat.
- Pencarian opsional untuk NAS melalui layanan online UGREEN, atau alamat HTTPS manual.
- Daftar unduhan, kemajuan dan kecepatan; penyelesaian opsional, penghentian, dan pemberitahuan kesalahan.
- Identifikasi nama dan jenis file HTTP, dengan koreksi nama setelah diunduh ketika file teridentifikasi dengan jelas.
- Ikon terang dan gelap asli, dan logo Safari disesuaikan dengan tema sistem.

## Kompatibilitas

Proyek ini dikonfigurasi untuk **macOS 27 atau lebih baru** dan dikompilasi dengan **Xcode 27.1**, untuk Apple Silicon. Pengujian NAS dilakukan dengan **DXP2800**, **UGOS Pro 1.20.0.0142** dan **Downloads 1.19.1.0004**. Versi lain tidak dijamin: integrasi didasarkan pada API yang diamati, tanpa kontrak publik UGREEN yang stabil.

## Instal dari DMG

[Unduh UGREEN NAS Download 0.6.0 untuk Mac Apple Silicon](https://github.com/cshxbe/UGREEN-NAS-Download/releases/tag/v0.6.0).

1. Buka DMG, seret **UGREEN NAS Download** ke **Aplikasi**, lalu buka aplikasi.
2. Di **Safari → Pengaturan → Lanjutan**, aktifkan fitur untuk pengembang web. Di **Developer**, aktifkan **Izinkan ekstensi yang tidak ditandatangani**, lalu aktifkan **UGREEN NAS Download** di **Ekstensi**.
3. Konfigurasikan NAS di pengaturan ekstensi.

Paket umum ini ditandatangani secara lokal (ad hoc) dan tidak diaktakan. macOS mungkin memblokir pembukaan awalnya. Safari mungkin meminta untuk mengaktifkan kembali izin untuk ekstensi yang tidak ditandatangani setelah keluar dari browser.

## Kompilasi dari sumber

1. Kloning repositori ini dan buka `Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj`.
2. Di **Penandatanganan & Kemampuan**, pilih tim Apple Anda sendiri untuk dua target: aplikasi dan ekstensinya. Tidak ada tim pribadi yang dimasukkan ke dalam repositori.
3. Pilih skema **UGREEN NAS Download**, tujuan **My Mac**, lalu kompilasi dan luncurkan dengan Xcode.
4. Aktifkan ekstensi di **Safari → Pengaturan → Ekstensi**, lalu otorisasi situs yang diinginkan.
5. Buka pengaturan ekstensi dan konfigurasikan NAS Anda seperti dijelaskan di bawah.

Contoh ID bundelnya adalah `com.example.UGREENNASDownload` dan `com.example.UGREENNASDownload.Extension`. Jika Anda perlu menyesuaikannya untuk tanda tangan Anda, ubah pengidentifikasi proyek Xcode **dan** konstanta terkait di `Extension/background.js` dan `ViewController.swift`: nilainya harus tetap konsisten.

Edisi publik ini menggunakan pengidentifikasi dan ruang Gantungan Kunci yang terpisah dari aplikasi pengembangan pribadi. Ini memerlukan konfigurasi NAS sendiri. Tanda tangan pengembangan bukan merupakan distribusi yang disahkan oleh notaris dan aktivasi mungkin memerlukan pengaturan pengembangan Safari yang sesuai untuk tanda tangan Anda.

Untuk memeriksa kompilasi tanpa tanda tangan, dari root repositori:

```sh
xcodebuild \
  -project "Xcode/UGREEN NAS Download/UGREEN NAS Download.xcodeproj" \
  -scheme "UGREEN NAS Download" \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
```

Pemeriksaan ini menghasilkan aplikasi yang tidak ditandatangani; gunakan tim Apple Anda untuk instalasi pengembangan yang dapat digunakan di Safari. Pertahankan pohon repositori: referensi Xcode ke `Extension` dan `Design` bersifat relatif.

## Konfigurasikan NAS

1. Masukkan alamat HTTPS NAS beserta portnya, pengenal Anda, dan jalur tujuan absolut pada NAS. Bidang pribadi kosong secara default.
2. Klik **Periksa sertifikat NAS**. Bandingkan sidik jari SHA-256 dengan sumber tepercaya sebelum mengonfirmasi sertifikat.
3. Masukkan kata sandi dan, jika perlu, kode otentikasi ganda. Mempercayai perangkat adalah opsional; tanpanya, kode baru mungkin diperlukan saat sesi berakhir.
4. Klik **Simpan dan uji koneksi**. Izinkan akses ke jaringan lokal bila diminta oleh macOS.
5. Aktifkan intersepsi otomatis terhadap torrent dan magnet jika diinginkan. Klik kanan dan pengiriman manual tetap independen terhadap saklar ini.

Alamat, akun, dan folder masih dapat diubah di pengaturan. **Melupakan akun ini** akan menghapus akun dan sesi Rantai Kuncinya untuk profil Safari saat ini.

## Keamanan dan Pengoperasian

Halaman web tidak dapat mengonfigurasi akun atau mempercayai sertifikat. Ekstensi berkomunikasi dengan modul Swift-nya melalui pesan asli. Permintaan NAS melalui mesin WebKit yang terisolasi dengan penyimpanan sementara dan skrip halaman dinonaktifkan; sertifikat harus cocok dengan sidik jari yang disetujui. Pengalihan NAS ditolak. Kata sandi dienkripsi dengan kunci RSA yang disediakan oleh NAS, ke HTTPS.

Informasi kata sandi, token, dan login disimpan di Rantai Kunci, bukan di penyimpanan web atau repositori ini. Kode sementara dihapus setelah digunakan. Cookie dan pengidentifikasi dari situs Safari tidak pernah dikirimkan ke NAS. Untuk beberapa torrent dari situs yang sama, file kecil diambil di memori dengan sesi Safari, kemudian dikirim ke NAS tanpa penyimpanan lokal atau SMB; ukurannya dibatasi hingga 512 KiB.

Pencarian otomatis secara sukarela menanyakan `api.ugnas.com`: layanan ini melihat alamat IP publik koneksi, tetapi tidak menerima kata sandi atau token NAS. Entri manual tidak bergantung pada layanan ini.

Tidak ada penambahan baru yang dilakukan setelah tanggapan ambigu atau tenggat waktu telah berlalu. Sambungan ulang dan upaya baru hanya diperbolehkan setelah penolakan tegas terhadap autentikasi. **Tugas yang diterima oleh NAS bukan bukti bahwa pengunduhan telah selesai.**

## Batasan

- Safari tidak menggantikan semua unduhannya secara universal. Intersepsi otomatis mencakup tautan dan mekanisme torrent yang dikenali; klik kanan dan entri manual menyelesaikan operasi ini.
- Tautan HTTP harus dapat diakses langsung oleh NAS. Konten yang dilindungi sesi situs, URL yang kedaluwarsa, video yang dilindungi, dan file biasa yang dihasilkan di `blob:` atau `data:` tidak dikonversi menjadi tautan publik.
- Pelacakan menu menunggu sekitar 3,5 detik setelah setiap respons; pemberitahuan dan koreksi nama diperiksa kira-kira setiap 30 detik. Safari yang ditutup, ditangguhkan, atau Mac dalam mode tidur dapat menunda pengoperasian ini.
- Format yang tidak dikenal tidak menerima ekstensi yang diciptakan. Penggantian nama terjadi setelah pengunduhan selesai; file sebenarnya sudah diperbaiki, sedangkan riwayat Unduhan dapat mempertahankan nama aslinya.
- Koreksi tetap terbatas pada tugas HTTP baru yang teridentifikasi dengan jelas, tanpa penggantian paksa, dengan maksimum 100 operasi tertunda dan retensi tujuh hari. Daftar dibatasi hingga 10.000 tugas per kategori.
- Pengaturan ikon global macOS tetap menjadi prioritas: **Gelap → Otomatis** memungkinkan Anda mengikuti tema. Ikon statis di daftar ekstensi Safari tetap dalam versi aslinya; menu dan logo pilihan mengikuti tema.

## Pengembangan dan pengujian

```sh
node --test Tests/autonomous.test.cjs
bash Tests/run-native-tests.sh
```

Pengujian JavaScript memerlukan Node.js; Pengujian asli memerlukan alat macOS, Xcode, Python 3, dan OpenSSL. Mereka memulai server HTTPS lokal sementara pada port 18443 dan tidak menggunakan akun NAS nyata. Audit 0.5.1 mencakup 45 pengujian JavaScript dan 121 kontrol asli. Lihat [laporan](../AUDIT-0.5.1.md).

- `Extension/`: menu, pengaturan, skrip dan ikon Safari.
- `Xcode/`: Aplikasi AppKit, modul Swift, otentikasi dan transportasi NAS.
- `Design/Adaptive/UGREENIcon.icon/`: Ikon asli dengan tampilan terang dan gelap.
- `Design/generate-icons.swift`: pembuatan PNG dan logo adaptif jendela.
- `Tests/`: pengujian keamanan, validasi data, dan perilaku.

## Referensi

- [klien komunitas ugnas-api](https://github.com/Fracizz/ugnas-api): referensi protokol, tanpa kode pihak ketiga yang dimuat dari halaman NAS.
- [Integrasi komunitas UGREEN](https://github.com/Tom-Bom-badil/home-assistant_ugreen-nas/blob/main/custom_components/ugreen/api.py): referensi untuk otentikasi ganda.
- [Dokumentasi Apple Safari Ekstensi Web](https://developer.apple.com/documentation/safariservices/packaging-a-web-extension-for-safari).

Untuk melaporkan masalah, jangan lampirkan kata sandi, kode sementara, token, URL bertanda tangan, torrent pribadi, atau ekspor Rantai Kunci apa pun. Gunakan data fiktif dalam contoh.

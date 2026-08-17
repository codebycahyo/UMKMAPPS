# LegaliKas AI

<p align="center">
  <img src="assets/icons/logo_baru.png" alt="LegaliKas AI Logo" width="180"/>
</p>

<p align="center">
  <strong>Aplikasi Pembukuan & Legalitas UMKM Indonesia — AI On-Device, Full Offline!</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10.1+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Version" />
  <img src="https://img.shields.io/badge/Dart-3.0.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart Version" />
  <img src="https://img.shields.io/badge/SQLite-Offline-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite Offline" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License" />
</p>

---

## 📋 Daftar Isi

- [Tentang Aplikasi](#-tentang-aplikasi)
- [Fitur Utama](#-fitur-utama)
- [Teknologi & Dependensi](#-teknologi--dependensi)
- [Arsitektur & Struktur Folder](#-arsitektur--struktur-folder)
- [Memulai (Getting Started)](#-memulai-getting-started)
  - [Prasyarat](#prasyarat)
  - [Instalasi & Menjalankan](#instalasi--menjalankan)
- [Build APK & Distribusi](#-build-apk--distribusi)
  - [Build Debug APK](#build-debug-apk)
  - [Build Release APK](#build-release-apk)
  - [Build Split APK per ABI](#build-split-apk-per-abi-ukuran-ringan)
  - [Signing APK untuk Release](#signing-apk-untuk-release)
- [Kredensial Default](#-kredensial-default)
- [Desain & Aksesibilitas](#-desain--aksesibilitas)
- [Troubleshooting](#-troubleshooting)
- [Lisensi](#-lisensi)

---

## 💡 Tentang Aplikasi

**LegaliKas AI** adalah aplikasi kasir (POS), pembukuan keuangan, dan asisten legalitas usaha modern yang dirancang khusus untuk para pelaku Usaha Mikro, Kecil, dan Menengah (UMKM) di Indonesia.

Aplikasi ini beroperasi **100% Full Offline** dengan pemrosesan kecerdasan buatan (*AI On-Device*) tanpa memerlukan koneksi internet, kuota data, atau biaya langganan API eksternal. Semua data usaha dan keuangan tersimpan aman di database lokal perangkat pengguna.

### Mengapa LegaliKas AI?
1. **Solusi Lengkap 2-in-1**: Menggabungkan sistem kasir & pembukuan harian dengan pusat akselerasi perizinan usaha (Halal & NIB).
2. **Efisiensi Berbasis AI On-Device**: Catat pengeluaran lewat foto struk (OCR) dan catat transaksi via suara (Voice Input) tanpa kuota internet.
3. **Inklusif & Aksesibel**: Dirancang dengan standar aksesibilitas WCAG AA dan dukungan penuh screen reader (*TalkBack*) untuk membantu pelaku usaha difabel.

---

## ✨ Fitur Utama

### 🤖 1. AI On-Device & Otomasi Cerdas
- **OCR Smart Receipt Scanner**: Foto struk/nota belanja bahan baku fisik, sistem otomatis mengekstrak nama item, nominal, tanggal, dan nama toko secara instan menggunakan *Google ML Kit Text Recognition*.
- **Voice Bookkeeping (Pencatatan Suara)**: Input transaksi penjualan dan pengeluaran secara cepat hanya dengan berbicara dalam Bahasa Indonesia (*Speech-to-Text*).
- **Graceful Fallback Mode**: Jika tulisan struk buram atau suara tidak terbaca sempurna, pengguna dapat langsung mengedit dan mengonfirmasi data secara manual tanpa hambatan.

### 📜 2. Pusat Legalitas & Sertifikasi UMKM
- **Wizard Self-Declare Sertifikasi Halal (SEHATI)**: Formulir 5 langkah terpadu untuk pengisian berkas pernyataan mandiri sertifikasi halal:
  1. Informasi Pelaku Usaha & NIB
  2. Daftar Bahan Baku & Pemasok
  3. Proses Produksi Bersih & Terpisah
  4. Lokasi & Fasilitas Produksi
  5. Ringkasan & Ekspor Dokumen
- **Ekspor Dokumen Halal ke PDF**: Menghasilkan berkas PDF siap cetak / siap unggah ke portal resmi SiHalal/BPJPH.
- **Auto-Save Progress**: Progres pengisian formulir tersimpan otomatis di perangkat lokal.
- **Panduan NIB OSS RBA**: Petunjuk langkah demi langkah pembuatan Nomor Induk Berusaha berbasis risiko.

### 🛒 3. Kasir POS & Transaksi Penjualan
- **Pencatatan Pesanan Kasir Cepat**: Keranjang belanja interaktif dengan pemilihan produk, kuantitas, dan kalkulasi total otomatis.
- **Multi-Metode Pembayaran**: Mendukung Tunai (Cash), Transfer Bank, dan QRIS statis/dinamis.
- **Riwayat Transaksi & Struk**: Daftar pesanan lengkap dengan pencarian nomor struk (*Invoice ID*).

### 📓 4. Buku Kas & Pelacakan Biaya (Expense Tracking)
- **Pencatatan Arus Kas**: Catat dan pantau seluruh pengeluaran operasional dan belanja bahan baku usaha.
- **Audit Sumber Data**: Melacak asal pencatatan transaksi (apakah via *OCR*, *Voice*, atau *Manual*).

### 📦 5. Manajemen Produk & Pelanggan
- **Katalog Produk & Layanan**: Kelola harga satuan, kategori, dan deskripsi produk UMKM.
- **Database Pelanggan**: Simpan kontak pelanggan, alamat, serta riwayat loyalitas dan belanja pelanggan.

### 📊 6. Laporan Keuangan & Analitik Bisnis
- **Visualisasi Grafik**: Grafik pendapatan harian, mingguan, bulanan, dan tahunan (*FL Chart*).
- **Laba Rugi & Rekapitulasi**: Ringkasan omset penjualan, total pengeluaran, dan laba bersih usaha.
- **Ekspor Laporan ke Excel**: Ekspor rekapitulasi data transaksi dan keuangan ke format file `.xlsx`.

### 🖨️ 7. Konektivitas & Cetak Struk
- **Printer Thermal Bluetooth**: Mendukung pencetakan struk transaksi ke printer thermal ukuran 58mm dan 80mm dengan perintah ESC/POS.
- **Bagikan Struk via WhatsApp**: Kirim rincian nota/struk langsung ke nomor WhatsApp pelanggan.

### 👥 8. Manajemen Akun & Hak Akses (Multi-User)
- **Role Owner (Pemilik)**: Akses penuh ke dashboard laporan keuangan, pengaturan toko, manajemen user kasir, dan backup database.
- **Role Kasir**: Akses fokus untuk melayani transaksi kasir, input buku kas, dan cetak struk penjualan.

---

## 🛠️ Teknologi & Dependensi

| Teknologi / Package | Versi | Fungsi & Kegunaan |
|---------------------|-------|-------------------|
| **Flutter SDK** | 3.10.1+ | Framework aplikasi cross-platform |
| **Dart SDK** | 3.0.0+ | Bahasa pemrograman utama |
| **flutter_bloc** | ^9.1.1 | State Management arsitektur BLoC & Cubit |
| **sqflite** & **sqflite_common_ffi** | ^2.4.2 | Database SQLite lokal (on-device) |
| **google_mlkit_text_recognition** | ^0.14.0 | OCR nota & struk belanja on-device |
| **speech_to_text** | ^7.0.0 | Input pencatatan suara (Bahasa Indonesia) |
| **pdf** | ^3.11.1 | Generator berkas dokumen PDF Self-Declare Halal |
| **excel** | ^4.0.6 | Ekspor laporan keuangan ke format Excel (.xlsx) |
| **fl_chart** | ^1.1.1 | Grafik statistik dan visualisasi analitik |
| **print_bluetooth_thermal** | ^1.1.9 | Konektivitas cetak struk via printer thermal Bluetooth |
| **esc_pos_utils_plus** | ^2.0.3 | Formatting dan perintah ESC/POS printer |
| **share_plus** | ^12.0.1 | Fitur share struk & file dokumen |
| **url_launcher** | ^6.3.2 | Integrasi link eksternal (WhatsApp, panduan OSS) |
| **image_picker** & **camera** | ^1.1.2 | Pengambilan foto nota belanja via kamera / galeri |
| **shared_preferences** | ^2.5.4 | Penyimpanan session & preferensi toko |
| **google_fonts** | ^7.0.2 | Tipografi aplikasi (Poppins) |
| **intl** | ^0.20.2 | Format tanggal, waktu, dan mata uang Rupiah |
| **crypto** | ^3.0.6 | Enkripsi hashing password pengguna |
| **permission_handler** | ^12.0.1 | Manajemen izin (Kamera, Mikrofon, Bluetooth, Storage) |

---

## 🏗️ Arsitektur & Struktur Folder

Proyek ini dibangun menggunakan pola arsitektur modular yang rapi dan terpisah berdasarkan tanggung jawab (*Separation of Concerns*):

```
lib/
├── core/
│   ├── constants/       # Konstanta aplikasi, warna (Teal Theme), format waktu & uang
│   ├── services/        # Service modul (OCR ML Kit, Voice Input, Printer Bluetooth, WhatsApp, Export)
│   ├── theme/           # Design system, tema warna, spacing, & styling aksesibel WCAG AA
│   └── utils/           # Helper fungsi, voice transaction parser, password hasher
├── data/
│   ├── database/        # DatabaseHelper SQLite, tabel skema & skrip migrasi
│   ├── models/          # Data model (Order, Customer, Service, ExpenseEntry, User, Payment)
│   └── repositories/    # Repository layer untuk operasi CRUD database lokal
├── logic/
│   └── cubits/          # State management BLoC/Cubit:
│       ├── auth/        # Otentikasi dan sesi pengguna
│       ├── customer/    # Pengelolaan data pelanggan
│       ├── expense/     # Pengelolaan buku kas & pengeluaran (OCR/Voice/Manual)
│       ├── order/       # Pengelolaan transaksi kasir & pesanan
│       ├── report/      # Pengolahan laporan keuangan & analitik
│       ├── service/     # Pengelolaan produk & layanan
│       └── user/        # Pengelolaan akun pengguna & kasir
├── presentation/
│   ├── screens/         # Tampilan UI Aplikasi:
│   │   ├── auth/        # Layar Login
│   │   ├── customers/   # Daftar & formulir data pelanggan
│   │   ├── dashboard/   # Dashboard utama & statistik ringkas
│   │   ├── expense/     # Layar scan nota OCR, catat suara, & buku kas
│   │   ├── halal_wizard/# Wizard Self-Declare Halal 5 langkah & ekspor PDF
│   │   ├── legalitas/   # Pusat Hub Legalitas & Perizinan UMKM
│   │   ├── nib_guide/   # Panduan Interaktif Pembuatan NIB OSS RBA
│   │   ├── onboarding/  # Layar Onboarding pengenalan fitur
│   │   ├── orders/      # Layar kasir POS, keranjang, & riwayat struk
│   │   ├── reports/     # Layar laporan keuangan, grafik, & ekspor Excel
│   │   ├── services/    # Daftar & formulir katalog produk/jasa
│   │   ├── settings/    # Pengaturan toko, Bluetooth printer, & kelola kasir
│   │   └── main_screen.dart # Navigasi utama (Bottom Navigation Bar)
│   └── widgets/         # Komponen UI reusable, modal, dialog, & widget aksesibilitas
└── main.dart            # Entry point aplikasi
```

---

## 🚀 Memulai (Getting Started)

### Prasyarat
Pastikan sistem Anda telah terpasang perangkat lunak berikut:
- **Flutter SDK**: `>= 3.10.1` (Direkomendasikan Flutter 3.22+)
- **Dart SDK**: `>= 3.0.0`
- **Android Studio** atau **Visual Studio Code** (dengan ekstensi Flutter & Dart)
- **Android SDK Platform** & **Java Development Kit (JDK 17)**

### Instalasi & Menjalankan

1. **Clone repositori**:
   ```bash
   git clone https://github.com/codebycahyo/UMKMAPPS.git
   cd UMKMAPPS
   ```

2. **Unduh seluruh dependensi**:
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi di emulator atau device fisik**:
   ```bash
   flutter run
   ```

> 💡 **Tips Device Fisik**: Untuk mencoba fitur **OCR Scan Nota** dan **Pencatatan Suara**, disarankan menggunakan perangkat Android fisik agar kamera dan mikrofon dapat berfungsi secara optimal.

---

## 📱 Build APK & Distribusi

### Build Debug APK
Cocok untuk pengujian cepat di perangkat pengembang:
```bash
flutter build apk --debug
```
*Output*: `build/app/outputs/flutter-apk/app-debug.apk`

### Build Release APK
Untuk instalasi langsung di perangkat pengguna:
```bash
flutter build apk --release
```
*Output*: `build/app/outputs/flutter-apk/app-release.apk`

### Build Split APK per ABI (Ukuran Ringan)
Menghasilkan file APK terpisah dengan ukuran lebih kecil (~15–18 MB):
```bash
flutter build apk --release --split-per-abi
```
*Output*:
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` *(Direkomendasikan untuk sebagian besar smartphone Android modern)*
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` *(Untuk perangkat Android 32-bit)*

### Signing APK untuk Release

1. **Generate Keystore**:
   ```bash
   keytool -genkey -v -keystore ~/legalikas-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias legalikas
   ```

2. **Buat file konfigurasi `android/key.properties`**:
   ```properties
   storePassword=your_keystore_password
   keyPassword=your_key_password
   keyAlias=legalikas
   storeFile=/path/to/legalikas-release-key.jks
   ```

3. **Build App Bundle (AAB) untuk Google Play Store**:
   ```bash
   flutter build appbundle --release
   ```
   *Output*: `build/app/outputs/bundle/release/app-release.aab`

---

## 🔐 Kredensial Default

Setelah instalasi pertama kali, Anda dapat masuk menggunakan akun default berikut:

| Role | Username | Password Default | Hak Akses |
|------|----------|------------------|-----------|
| **Owner (Pemilik Usaha)** | `owner` | `admin123` | Akses penuh (Kasir, Buku Kas, Legalitas, Laporan, Pengaturan) |
| **Kasir** | Dibuat oleh Owner | Ditentukan Owner | Akses transaksi kasir, input kas, dan cetak struk |

> ⚠️ **Catatan Keamanan**: Demi keamanan data usaha, segera ubah password akun default pada menu **Pengaturan > Akun & Pengguna** setelah login pertama kali.

---

## 🎨 Desain & Aksesibilitas

### 🎨 Sistem Warna (Teal Nature Palette)
- **Primary**: `#0F766E` (Deep Teal)
- **Primary Light**: `#14B8A6` (Teal Light)
- **Primary Dark**: `#0D5F58` (Teal Dark)
- **Accent / Alert**: `#D97706` (Amber Warm)
- **Background**: `#F0FDFA` (Soft Mint Tint)
- **Surface / Card**: `#FFFFFF` (Pure White)

### ♿ Aksesibilitas (Inklusif & Ramah Disabilitas)
- **Dukungan TalkBack / Screen Reader**: Komponen utama dilengkapi anotasi `Semantics` yang jelas untuk tunanetra.
- **Target Sentuh Ergonomis**: Seluruh tombol interaktif memiliki target sentuh minimum `48x48 dp`.
- **Kontras Warna Standar WCAG AA**: Rasio kontras tinggi antara teks dan latar belakang untuk memudahkan keterbacaan dalam kondisi pencahayaan terang maupun redup.
- **Alternatif Input Suara**: Membantu pengguna dengan keterbatasan mobilitas fisik dalam mencatat pembukuan keuangan.

---

## 🔧 Troubleshooting

### 1. Error: Gradle build failed
Bersihkan cache build Flutter dan Gradle:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### 2. Printer Thermal Bluetooth Tidak Terhubung
1. Pastikan Bluetooth pada perangkat Android dalam keadaan aktif.
2. Lakukan *Pairing* terlebih dahulu antara printer dan perangkat melalui menu **Pengaturan Bluetooth Android**.
3. Buka menu **Pengaturan Toko & Printer** di aplikasi, lalu pilih printer yang telah terhubung.

### 3. Izin Akses Kamera / Mikrofon Ditolak
Pastikan izin kamera (untuk scan nota) dan mikrofon (untuk input suara) telah diizinkan melalui **Pengaturan Aplikasi Android > Izin (Permissions)**.

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah **MIT License**. Silakan lihat berkas [LICENSE](LICENSE) untuk informasi lebih lanjut.
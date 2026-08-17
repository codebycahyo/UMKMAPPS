# Prompt: Transformasi Codebase "Laundry JagoFlutter" → "LegaliKas AI"

> Cara pakai: copy-paste seluruh prompt di bawah ini ke Claude Code (atau AI coding assistant lain) setelah repo `POS-Apps` sudah di-clone ke local/workspace-mu. Prompt ini dirancang bertahap (fase per fase) supaya agent tidak kewalahan mengubah semuanya sekaligus.

---

## PROMPT UTAMA

Kamu sedang bekerja di repo Flutter bernama **"Laundry JagoFlutter"** (POS kasir laundry offline). Tugasmu adalah mentransformasikan codebase ini menjadi aplikasi baru bernama **"LegaliKas AI"** — aplikasi pembukuan & legalitas UMKM berbasis AI on-device, untuk kompetisi IT FEST DIY 2026.

### Konteks Produk LegaliKas AI

LegaliKas AI menyasar pelaku UMKM di DIY (termasuk penyandang disabilitas) yang kesulitan: (1) mencatat transaksi harian secara manual, dan (2) memenuhi tenggat sertifikasi halal wajib SEHATI. Aplikasi harus **100% offline-first** (memakai infrastruktur sqflite yang sudah ada di repo), dengan tiga fitur inti baru:

1. **OCR Nota Belanja** — foto struk/nota belanja bahan baku → otomatis diekstrak jadi entri pengeluaran (item, harga, tanggal, supplier) menggunakan Google ML Kit Text Recognition (on-device, gratis, tanpa API key).
2. **Pencatatan Suara (Voice Bookkeeping)** — pengguna cukup bicara ("terjual nasi goreng dua puluh ribu") → otomatis diparse jadi entri transaksi masuk. Pakai `speech_to_text` package (on-device recognition, Bahasa Indonesia).
3. **Wizard Self-Declare Halal** — form wizard multi-step yang memandu pemilik UMKM mengisi pernyataan diri halal sesuai skema SEHATI (bahan baku, proses produksi, lokasi), lalu men-generate ringkasan siap unduh/print untuk diajukan.

Aksesibilitas adalah prioritas desain: semua flow input harus bisa dituntaskan lewat suara atau navigasi screen-reader (TalkBack), bukan hanya sentuh.

---

### FASE 1 — Rebranding & Pembersihan Base

- Ganti semua identitas aplikasi dari "Laundry JagoFlutter" → **"LegaliKas AI"**:
  - `lib/core/constants/app_constants.dart`: `appName`
  - `android/app/src/main/AndroidManifest.xml`: `android:label`
  - `pubspec.yaml`: `name`, `description`
  - Package name: ubah dari `com.jagoflutter.laundryoffline` ke `com.legalikas.ai` (pakai `change_app_package_name` package sesuai README)
  - Ganti logo di `assets/icons/` (placeholder dulu, aku akan supply logo final belakangan)
- Hapus/nonaktifkan sementara modul yang spesifik-laundry dan tidak relevan:
  - `presentation/screens/services/` (paket layanan laundry) — akan digantikan modul "Kategori Usaha" generik
  - Field-field di model `Order` yang spesifik laundry (misal jenis cucian, berat kiloan) — generalisasi jadi model `Transaction` yang lebih umum (deskripsi, kategori, jumlah, tipe: masuk/keluar)
- **Pertahankan** (jangan diubah struktur besarnya): `core/theme`, `logic/cubits` pattern BLoC, `data/database` (sqflite helper), `presentation/widgets` reusable, fitur cetak struk thermal, export Excel, share WhatsApp, sistem multi-user Owner/Kasir.
- Update skema warna di `core/theme` dari ungu/violet (`#7B2D8E`) ke palet baru yang mencerminkan kepercayaan & legalitas — sarankan hijau tosca/teal (`#0F766E`) sebagai primary, dengan aksen emas untuk elemen "halal/verified". Tunggu konfirmasi saya sebelum finalize warna.

Setelah Fase 1 selesai, tampilkan ringkasan file yang diubah dan minta konfirmasi sebelum lanjut ke Fase 2.

---

### FASE 2 — Modul OCR Nota Belanja

- Tambahkan dependency `google_mlkit_text_recognition` ke `pubspec.yaml`.
- Buat struktur baru:
  ```
  lib/
  ├── data/
  │   ├── models/
  │   │   └── expense_entry.dart        # item, harga, tanggal, supplier, sumber (OCR/manual)
  │   └── repositories/
  │       └── expense_repository.dart
  ├── logic/cubits/
  │   └── expense/
  │       ├── expense_cubit.dart
  │       └── expense_state.dart
  ├── core/services/
  │   └── ocr_service.dart              # wrapper ML Kit: image -> raw text -> parsed fields
  └── presentation/screens/
      └── expense/
          ├── scan_receipt_screen.dart  # kamera + preview hasil OCR
          └── expense_list_screen.dart
  ```
- `ocr_service.dart` harus punya fungsi `parseReceiptText(String rawText) -> ExpenseEntry` yang mencoba mengekstrak: nominal total (regex angka terbesar/pola "Total"), tanggal (regex format umum nota Indonesia), nama item per baris. Untuk baris yang gagal diparse otomatis, tampilkan raw text supaya user bisa edit manual — **jangan pernah blokir user kalau OCR gagal**, selalu sediakan fallback input manual.
- Simpan hasil scan ke tabel SQLite baru `expenses`, migrasi lewat `data/database` helper yang sudah ada (ikuti pola migration existing, jangan bikin sistem migrasi baru).
- UI: setelah foto diambil, tampilkan hasil parsing dalam form yang bisa diedit sebelum disimpan (jangan auto-save tanpa konfirmasi user).

---

### FASE 3 — Modul Pencatatan Suara

- Tambahkan dependency `speech_to_text` dan `permission_handler` (sudah ada di pubspec, tinggal tambah permission mic).
- Buat `core/services/voice_input_service.dart`: wrapper untuk start/stop listening, dengan locale `id_ID`.
- Buat parser sederhana `core/utils/voice_transaction_parser.dart` yang mengenali pola kalimat umum pedagang kecil, misalnya:
  - "terjual/laku [item] [nominal]" → transaksi masuk
  - "beli/bayar [item] [nominal]" → transaksi keluar
  - Kalau parser tidak yakin, tampilkan transkrip mentah + minta user pilih kategori manual lewat dropdown besar (bukan mengetik) — ini penting untuk aksesibilitas.
- Tambahkan floating action button mic di `dashboard` yang bisa dipicu dengan satu tap, beri feedback visual (waveform/pulsing) selama mendengarkan, dan haptic feedback saat selesai — ini krusial untuk pengguna low-vision.
- Semua entri baik dari OCR maupun voice masuk ke tabel `expenses`/`transactions` yang sama, dengan field `source: 'ocr' | 'voice' | 'manual'` supaya bisa dibedakan di laporan.

---

### FASE 4 — Wizard Self-Declare Halal (SEHATI)

- Buat modul wizard multi-step terpisah:
  ```
  lib/presentation/screens/halal_wizard/
  ├── halal_wizard_screen.dart       # controller step (PageView/Stepper)
  ├── steps/
  │   ├── step_business_info.dart
  │   ├── step_ingredients.dart      # daftar bahan baku, checklist bahan wajib waspada (gelatin, alkohol, dll)
  │   ├── step_production_process.dart
  │   ├── step_location.dart
  │   └── step_summary_export.dart   # generate PDF/ringkasan siap unduh
  └── logic/halal_wizard_cubit.dart  # state per-step, validasi sebelum next
  ```
- Setiap step harus: (a) bisa dituntaskan dengan navigasi keyboard/screen-reader penuh, (b) punya progress indicator jelas, (c) tidak kehilangan data kalau app di-minimize (persist ke local storage per step).
- Step ringkasan akhir men-generate dokumen (pakai `pdf` atau reuse pola export Excel yang sudah ada di `core/services/`) yang berisi checklist self-declare siap dibawa ke pendamping halal/pengajuan SEHATI.
- Referensi field yang wajib ada (cek ulang ke pedoman SEHATI terbaru kalau ragu — jangan asumsikan): nama pelaku usaha, NIB, daftar bahan baku, nama pemasok bahan, proses produksi singkat, pernyataan tidak menggunakan bahan haram/najis.

---

### FASE 5 — Integrasi Dashboard & QA Aksesibilitas

- Update `dashboard_screen.dart` supaya menampilkan 3 entry point besar (bukan menu kecil): "Scan Nota", "Catat Suara", "Wizard Halal" — ukuran tombol minimal 48x48dp, kontras warna sesuai WCAG AA.
- Tambahkan `Semantics` widget di semua elemen interaktif baru untuk kompatibilitas TalkBack.
- Jalankan `flutter analyze` dan pastikan tidak ada warning baru dari modul yang ditambahkan.
- Buat file `docs/PERUBAHAN_LEGALIKAS.md` yang mencatat: apa yang diubah dari base laundry app, dependency baru yang ditambahkan, dan known limitations (misal: akurasi OCR untuk nota tulisan tangan masih terbatas) — ini akan dipakai sebagai bahan dokumentasi teknis untuk laporan lomba.

---

### Instruksi Kerja untuk Agent

- Kerjakan **satu fase per giliran**, jangan loncat fase sebelum aku konfirmasi fase sebelumnya berjalan (`flutter run` tidak error).
- Jangan hapus fitur existing (cetak struk, export Excel, share WhatsApp, multi-user) — fitur-fitur itu tetap relevan dan akan di-reuse untuk modul laporan LegaliKas AI.
- Setiap kali menambah dependency baru, jelaskan singkat alasannya di chat sebelum menjalankan `flutter pub get`.
- Kalau ada bagian yang butuh keputusan desain (warna, copy text, field wajib SEHATI), **tanyakan dulu**, jangan berasumsi.

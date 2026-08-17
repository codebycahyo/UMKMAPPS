# Perubahan dari Base "Laundry JagoFlutter" → "LegaliKas AI"

## Ringkasan
Codebase ini awalnya adalah aplikasi POS kasir laundry offline "Laundry JagoFlutter" yang dikembangkan oleh JagoFlutter.com. Aplikasi telah ditransformasi menjadi **LegaliKas AI** — aplikasi pembukuan & legalitas UMKM berbasis AI on-device untuk kompetisi IT FEST DIY 2026.

## Perubahan Identitas
| Aspek | Sebelum | Sesudah |
|-------|---------|---------|
| Nama App | Laundry JagoFlutter / POS Kasir Pintar | LegaliKas AI |
| Package Name | com.jagoflutter.laundryoffline | com.legalikas.ai (planned) |
| Warna Primary | Ungu #7B2D8E / Biru #1E88E5 | Teal #0F766E |
| Target User | Owner laundry | Pelaku UMKM DIY (termasuk difabel) |
| Invoice Prefix | WAZ / LNDR | LKS |

## Dependency Baru
| Package | Versi | Fungsi |
|---------|-------|--------|
| `google_mlkit_text_recognition` | ^0.14.0 | OCR nota belanja on-device |
| `speech_to_text` | ^7.0.0 | Voice input, locale id_ID |
| `pdf` | ^3.11.1 | Export PDF ringkasan wizard halal |
| `image_picker` | ^1.1.2 | Ambil foto nota dari kamera |
| `camera` | ^0.11.0+2 | Akses kamera untuk OCR |

## Fitur Baru

### 1. OCR Nota Belanja (Scan Nota)
- Foto nota/struk belanja bahan baku → auto-extract item, harga, tanggal
- Menggunakan Google ML Kit Text Recognition (on-device, gratis)
- Fallback: jika OCR gagal parse, user edit manual
- Data tersimpan di tabel `expenses` dengan `source='ocr'`

### 2. Pencatatan Suara (Voice Bookkeeping)
- User bicara ("terjual nasi goreng dua puluh ribu") → auto-parse jadi transaksi
- Menggunakan `speech_to_text` package (on-device, Bahasa Indonesia)
- Fallback: jika parser tidak yakin, tampilkan dropdown kategori manual
- Data tersimpan di tabel `expenses` dengan `source='voice'`

### 3. Wizard Self-Declare Halal (SEHATI)
- Form wizard 5 step untuk mengisi pernyataan diri halal
- Step: Info Usaha → Bahan Baku → Proses Produksi → Lokasi → Ringkasan
- Generate PDF ringkasan siap unduh/print
- Progress di-persist ke local storage (tidak hilang jika app di-minimize)
- Navigable penuh via TalkBack (screen reader)

## Perubahan Database
- Versi database: 2 → 3
- Tabel baru: `expenses` (id, type, item, nominal, tanggal, supplier, source, raw_text, created_at)
- Index baru: idx_expenses_type, idx_expenses_source, idx_expenses_date

## Fitur yang Dipertahankan (Tidak Diubah)
- Authentication (Login owner/kasir, role-based access)
- CRUD Orders, Customers, Services
- Laporan (Harian/Mingguan/Bulanan/Custom)
- Export Excel
- Share WhatsApp
- Cetak struk thermal Bluetooth
- Multi-user (Owner/Kasir)
- Onboarding (content diperbarui)

## Aksesibilitas
- Semua elemen interaktif baru memiliki `Semantics` label
- Target tap minimum 48x48dp
- Kontras warna WCAG AA (primary teal #0F766E)
- Wizard halal fully navigable via TalkBack
- Voice input sebagai alternatif keyboard

## Known Limitations
1. Akurasi OCR untuk nota tulisan tangan masih terbatas
2. Voice recognition memerlukan real device (emulator terbatas)
3. Voice parser hanya mendukung pola kalimat umum pedagang kecil
4. Wizard halal hanya generate dokumen siap-ajukan, bukan submit otomatis ke SEHATI
5. Semua fitur baru 100% offline, tidak memerlukan koneksi internet

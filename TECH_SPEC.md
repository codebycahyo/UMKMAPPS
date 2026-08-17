# TECH SPEC — LegaliKas AI
(Pelengkap PRD.md — jangan duplikasi konteks produk di sini, hanya teknis.)

## Base Repo
`codebycahyo/POS-Apps` ("Laundry JagoFlutter"). Pertahankan: `core/theme`, pola BLoC/Cubit, `data/database` (sqflite + migration), cetak struk thermal, export Excel, share WhatsApp, multi-user Owner/Kasir.
Generalisasi/hapus: modul `services/` (paket laundry), field kiloan/jenis cucian pada model `Order`.

## Package Baru
| Package | Fungsi |
|---|---|
| `google_mlkit_text_recognition` | OCR nota, on-device |
| `speech_to_text` | Voice input, locale `id_ID` |
| `pdf` | Export ringkasan wizard halal |
| (reuse) `permission_handler` | Izin mic & kamera |

## Struktur Folder Tambahan
```
lib/
├── data/models/expense_entry.dart      # item, harga, tanggal, supplier, source: ocr|voice|manual
├── data/repositories/expense_repository.dart
├── logic/cubits/expense/
├── core/services/ocr_service.dart      # parseReceiptText(String) -> ExpenseEntry
├── core/services/voice_input_service.dart
├── core/utils/voice_transaction_parser.dart
├── presentation/screens/expense/{scan_receipt_screen, expense_list_screen}.dart
└── presentation/screens/halal_wizard/
    ├── halal_wizard_screen.dart
    ├── steps/{step_business_info, step_ingredients, step_production_process, step_location, step_summary_export}.dart
    └── logic/halal_wizard_cubit.dart
```

## Skema Data Baru
**Tabel `expenses`/`transactions`** (migrasi via helper existing di `data/database`):
- id, type (masuk/keluar), item, nominal, tanggal, supplier (nullable), source (ocr|voice|manual), raw_text (nullable, untuk audit OCR/voice gagal parse)

**Wizard Halal** — persist per-step ke local storage, field minimum (verifikasi ulang ke pedoman SEHATI resmi sebelum final): nama usaha, NIB, daftar bahan baku, pemasok, proses produksi singkat, pernyataan bebas bahan haram/najis.

## Aturan Parsing (fallback wajib)
- OCR gagal ekstrak field → tampilkan raw text, user edit manual sebelum save. Jangan auto-save tanpa konfirmasi.
- Voice tidak dikenali pola → tampilkan transkrip + dropdown kategori manual (bukan keyboard).

## Aksesibilitas (checklist implementasi)
- `Semantics` di semua widget interaktif baru
- Target tap minimal 48x48dp
- Kontras warna WCAG AA (tema baru: primary teal `#0F766E`, bukan violet lama)
- Wizard halal harus fully navigable via TalkBack (uji manual sebelum submit lomba)

## Definition of Done per Fitur
- `flutter analyze` bersih dari warning baru
- Fallback manual teruji (matikan izin mic/kamera → app tidak crash)
- Data tersimpan & muncul benar di modul laporan existing

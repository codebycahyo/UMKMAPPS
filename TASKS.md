# TASKS — LegaliKas AI
(Kerjakan berurutan. Centang sebelum lanjut fase berikutnya. Detail teknis: lihat TECH_SPEC.md. Konteks produk: lihat PRD.md — jangan minta dijelaskan ulang, baca dulu file itu.)

## Fase 1 — Rebranding & Pembersihan
- [ ] Ganti nama app di app_constants.dart, AndroidManifest.xml, pubspec.yaml
- [ ] Ganti package name → com.legalikas.ai
- [ ] Hapus modul services/ (paket laundry)
- [ ] Generalisasi model Order → Transaction (hapus field kiloan/jenis cucian)
- [ ] Update tema warna (primary teal #0F766E) — TUNGGU KONFIRMASI sebelum finalize
- [ ] `flutter run` sukses tanpa error
- [ ] STOP, laporkan ringkasan perubahan, tunggu konfirmasi lanjut

## Fase 2 — OCR Nota
- [ ] Tambah google_mlkit_text_recognition ke pubspec
- [ ] Buat expense_entry.dart, expense_repository.dart, expense_cubit.dart
- [ ] Buat ocr_service.dart dengan parseReceiptText()
- [ ] Buat scan_receipt_screen.dart (kamera + form edit hasil OCR sebelum save)
- [ ] Migrasi tabel expenses via helper existing
- [ ] Test: OCR gagal parse → fallback manual jalan, tidak crash
- [ ] STOP, tunggu konfirmasi lanjut

## Fase 3 — Voice Bookkeeping
- [ ] Tambah speech_to_text + permission mic
- [ ] Buat voice_input_service.dart (locale id_ID)
- [ ] Buat voice_transaction_parser.dart (pola "terjual/laku X", "beli/bayar X")
- [ ] Tambah FAB mic di dashboard + feedback visual/haptic
- [ ] Test: parser tidak yakin → fallback dropdown manual jalan
- [ ] STOP, tunggu konfirmasi lanjut

## Fase 4 — Wizard Halal SEHATI
- [ ] Verifikasi field wajib ke pedoman SEHATI resmi (jangan asumsi — tanya user jika ragu)
- [ ] Buat halal_wizard_screen.dart + 5 step screens + halal_wizard_cubit.dart
- [ ] Persist progress per-step ke local storage
- [ ] Buat step_summary_export.dart (generate PDF ringkasan)
- [ ] Test: navigasi penuh via TalkBack tanpa sentuh
- [ ] STOP, tunggu konfirmasi lanjut

## Fase 5 — Integrasi & QA
- [ ] Update dashboard: 3 entry point besar (Scan Nota, Catat Suara, Wizard Halal)
- [ ] Semantics widget di semua elemen baru
- [ ] `flutter analyze` bersih
- [ ] Tulis docs/PERUBAHAN_LEGALIKAS.md (perubahan dari base, dependency baru, known limitations)
- [ ] Demo end-to-end: scan → tersimpan → muncul di laporan, < 15 detik offline

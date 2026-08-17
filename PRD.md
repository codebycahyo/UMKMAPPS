# PRD — LegaliKas AI

## 1. Ringkasan
Aplikasi pembukuan + legalitas UMKM, offline-first, Flutter. Base codebase: fork "Laundry JagoFlutter" (POS-Apps repo) — arsitektur BLoC/sqflite dipertahankan, fitur laundry-spesifik digeneralisasi.

## 2. Target User
UMKM mikro di DIY, termasuk pelaku usaha difabel. Asumsi device: Android low-mid end, koneksi internet tidak stabil/tidak ada.

## 3. Masalah
- Pencatatan transaksi manual → rawan hilang/salah catat.
- Tenggat sertifikasi halal wajib SEHATI → proses pengisian dokumen rumit bagi pelaku usaha awam.

## 4. Fitur Inti (scope kompetisi/MVP)
| # | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| F1 | Scan Nota (OCR) | Foto nota → auto-extract item/harga/tanggal, fallback edit manual | P0 |
| F2 | Catat Suara | Ucapan → parsed jadi transaksi masuk/keluar, fallback pilih manual | P0 |
| F3 | Wizard Halal SEHATI | Form multi-step → generate ringkasan siap unduh | P0 |
| F4 | Dashboard & Laporan | Reuse modul report/export Excel/print struk existing | P1 (sudah ada, tinggal adaptasi) |
| F5 | Aksesibilitas | Semantics/TalkBack di semua entry point baru, kontras WCAG AA | P0 (cross-cutting, bukan fitur terpisah) |

## 5. Di Luar Scope (MVP)
- Sinkronisasi cloud/multi-device
- Integrasi langsung ke sistem SEHATI resmi (hanya generate dokumen siap-ajukan, bukan submit otomatis)
- OCR tulisan tangan
- Multi-bahasa daerah selain Bahasa Indonesia

## 6. Kriteria Sukses (demo lomba)
- Alur scan nota → tersimpan → muncul di laporan: < 15 detik, tanpa internet.
- Alur catat suara → transaksi tercatat: 1 tap + ucapan, tanpa mengetik.
- Wizard halal bisa diselesaikan penuh via screen reader (uji dengan TalkBack aktif).

## 7. Non-Functional Requirements
- 100% offline untuk fitur inti F1–F3 (tidak butuh API key/koneksi eksternal).
- Tidak pernah blok user jika AI/OCR/voice gagal parse — selalu ada fallback input manual.
- Reuse struktur sqflite migration yang sudah ada di base repo, jangan bikin sistem baru.

## 8. Dependensi Referensi
- Detail teknis (model data, struktur folder, package): lihat `TECH_SPEC.md`
- Breakdown kerja per fase: lihat `TASKS.md`

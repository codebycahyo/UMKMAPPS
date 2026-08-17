# POS Kasir Pintar - Design Document

## 1. Pendahuluan
**POS Kasir Pintar** adalah aplikasi Point of Sale (POS) berbasis Flutter yang beroperasi secara offline. Pada awalnya aplikasi ini dikembangkan khusus untuk bisnis Laundry, namun telah dimodifikasi (rebranding) menjadi aplikasi kasir general (umum) yang dapat digunakan oleh berbagai jenis toko atau penyedia layanan.

## 2. Fitur Utama
- **Manajemen Autentikasi:** Login untuk kasir/admin.
- **Dashboard & Laporan:** Ringkasan penjualan, transaksi terakhir, dan status pesanan.
- **Manajemen Produk/Layanan:** Menambahkan, mengedit, dan menghapus produk atau layanan toko.
- **Manajemen Pelanggan:** Menyimpan database pelanggan beserta riwayat transaksi.
- **Pembuatan Pesanan (Order):** Pembuatan struk pesanan untuk pelanggan.
- **Pembayaran:** Pencatatan status pembayaran (Lunas/Belum Lunas).
- **Cetak Struk (Bluetooth):** Terintegrasi dengan printer thermal bluetooth untuk mencetak invoice.
- **Notifikasi WhatsApp:** Mengirimkan invoice atau pemberitahuan pesanan ke WhatsApp pelanggan.
- **Ekspor Laporan (Excel):** Fitur untuk mengunduh laporan keuangan berformat `.xlsx`.

## 3. Teknologi yang Digunakan
- **Framework:** Flutter (Dart)
- **State Management:** `flutter_bloc`
- **Database Lokal:** `sqflite` (SQLite)
- **Local Storage:** `shared_preferences` (untuk data ringan/sesi)

## 4. Struktur Database (Schema)
Aplikasi ini menggunakan SQLite secara lokal untuk menyimpan seluruh data.
- **`users`**: Data pengguna (Kasir, Admin, Owner).
- **`customers`**: Data pelanggan toko.
- **`services`**: Data produk atau layanan yang ditawarkan (sebelumnya bernama paket laundry).
- **`orders`**: Data transaksi pesanan secara umum (menyimpan total belanja, status, diskon/pajak).
- **`order_items`**: Detail produk/layanan yang dipesan dalam satu order.
- **`payments`**: Data pembayaran dari sebuah order.
- **`app_settings`**: Konfigurasi umum toko (Nama Toko, Alamat, Prefix Invoice, dll).

## 5. UI / UX & Desain
- **Tema Warna:** Modern dengan nuansa warna utama (Primary) yang bisa disesuaikan, didesain untuk kenyamanan visual (clean design).
- **Terminologi:** Telah diadaptasi dari yang awalnya bersifat *Laundry-centric* (misal: "Paket Laundry", "Cucian") menjadi lebih *General* (misal: "Produk/Layanan", "Toko", "Pesanan").
- **Komponen:**
  - `CustomButton`: Tombol standar yang digunakan di seluruh aplikasi.
  - `CustomTextField`: Input text field dengan validasi seragam.
  - `StatusBadge`: Label visual untuk menandakan status order (misal: Baru, Selesai, Diambil, dsb).

## 6. Pengembangan Lanjutan
Karena aplikasi ini 100% offline, langkah selanjutnya yang bisa dikembangkan:
1. Sinkronisasi dengan database cloud (Firebase/Supabase) untuk backup online.
2. Fitur multi-outlet.
3. Manajemen inventaris / stok barang (saat ini sistem berfokus pada layanan atau produk tanpa kalkulasi sisa stok otomatis).

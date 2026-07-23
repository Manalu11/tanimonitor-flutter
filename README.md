# TaniMonitor 🌱

Aplikasi mobile berbasis Flutter untuk membantu petani dan pemilik lahan memantau kondisi tanaman secara praktis, tanpa bergantung pada koneksi internet.

## Fitur
- 🔐 Autentikasi pengguna (Login & Registrasi)
- 🌾 Manajemen data tanaman/lahan (CRUD)
- 📊 Simulasi data sensor (suhu, kelembaban tanah & udara) secara real-time
- 📈 Grafik riwayat data sensor (fl_chart)
- ⏰ Reminder terjadwal untuk aktivitas perawatan tanaman
- ⚠️ Notifikasi otomatis saat kelembaban melewati ambang batas
- 👤 Manajemen profil pengguna dengan foto profil

## Teknologi
- **Framework**: Flutter
- **Basis Data**: SQLite (via `sqflite`)
- **Notifikasi**: `flutter_local_notifications`
- **Background Task**: `workmanager`
- **Grafik**: `fl_chart`

## Arsitektur
Aplikasi berjalan sepenuhnya secara lokal (client-side only) tanpa backend/server. Seluruh data disimpan pada basis data SQLite lokal, dan proses simulasi sensor serta notifikasi berjalan melalui background scheduler pada perangkat.

Dokumentasi arsitektur lengkap (Software Architecture Document) tersedia sebagai bagian dari tugas mata kuliah terkait.

## Cara Menjalankan
\`\`\`bash
git clone https://github.com/Manalu11/tanimonitor-flutter.git
cd tanimonitor-flutter
flutter pub get
flutter run
\`\`\`

## Pengembang
Marcahaya — Teknik Informatika, Sekolah Tinggi Teknologi Bontang (STITEK Bontang)

## Lisensi
Proyek ini dikembangkan sebagai bagian dari tugas mata kuliah Software Architecture (RPL643) dan Mobile Programming (RPL645).

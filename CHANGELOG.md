# Changelog

Semua perubahan penting pada aplikasi **GS PRO Mobile** didokumentasikan dalam dokumen ini.
Format ini mengacu pada [Keep a Changelog](https://keepachangelog.com/id/1.0.0/) dan mematuhi [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.2.0+5] - 2026-10-22

### Ditambahkan (Added)
- **Checker Role & Check Action**: Penambahan tombol `Check` untuk peran checker serta penegasan hak akses approver per dokumen pada Purchase Requisition (PR) dan Purchase Order (PO).
- **E-Signature Approval**: Tanda tangan digital (e-sign) terintegrasi pada saat melakukan tindakan `Approve` maupun `Reject` dokumen PR dan PO.
- **Attachment Preview & Download**: Kemampuan melihat pratinjau (preview) dan mengunduh berkas lampiran pendukung dokumen purchasing langsung dari aplikasi.
- **Project Detail & Member Popup**: Nomor proyek pada halaman detail requisition dapat diklik untuk menampilkan modal informasi proyek dan anggota tim.
- **Approved Qty Column**: Penambahan kolom kuantiti yang disetujui (*Approved Qty*) pada tabel rincian item PR.
- **Android ProGuard & R8 Optimization**: Penerapan minifikasi kode, shrinking resource, dan proteksi bytecode Java/Kotlin native serta plugin pihak ketiga pada build release.
- **Automated AAB Build Script**: Skrip `scripts/build_aab.sh` untuk memudahkan proses kompilasi Android App Bundle siap rilis ke Google Play Store dengan dukungan FVM, environment switching, dan obfuscation.

### Diperbaiki (Fixed)
- **Kuantiti Approval Dialog**: Pembatasan input kuantiti persetujuan agar tidak melebihi kuantiti approver sebelumnya (bukan lagi selalu mengacu pada kuantiti awal).
- **Mapping JSON API**: Perbaikan parsing model data untuk daftar dan detail requisition serta order.
- **File Handling**: Penanganan format dan penyimpanan berkas dokumen secara lokal pada penyimpanan perangkat.

### Pemeliharaan (Chores)
- Sinkronisasi Flutter SDK ke versi `3.41.6` melalui FVM dan pembaruan `pubspec.lock`.
- Penyusunan dokumentasi penandatanganan rilis Android pada `docs/ANDROID_SIGNING_GUIDE.md`.

---

## [1.1.0+4] - 2026-09-04

### Ditambahkan (Added)
- Alur kerja persetujuan berjenjang (multi-level approver) untuk Purchase Order dan Purchase Requisition.
- Fitur penolakan dokumen (*Reject*) disertai input alasan pembatalan.
- Integrasi informasi perangkat (`device_info_plus`) dan paket aplikasi (`package_info_plus`).
- Pengaturan upload keystore Android dan konfigurasi rilis Play Store.

### Diperbaiki (Fixed)
- Penyesuaian tata letak antarmuka agar responsif pada berbagai ukuran layar ponsel.
- Penanganan timeout koneksi API dan feedback error yang lebih informatif ke pengguna.

---

## [1.0.0+1] - 2026-08-01

### Ditambahkan (Added)
- Rilis perdana aplikasi **GS PRO Mobile**.
- Modul Autentikasi: Login menggunakan kredensial perusahaan dan penyimpanan sesi aman via `shared_preferences`.
- Halaman Utama (Dashboard): Ringkasan status pengadaan dan jalan pintas ke dokumen aktif.
- Manajemen Profil Pengguna dan ganti kata sandi.

---

## 📱 Google Play Console Release Notes (What's New)

Gunakan teks di bawah ini pada kolom **Release Notes** saat mengunggah AAB ke Google Play Console:

### Versi Bahasa Indonesia (id-ID)
```text
Pembaruan GS PRO Mobile v1.2.0:
• Penambahan fitur tanda tangan digital (e-sign) pada approval PR & PO.
• Tombol Check untuk peran checker dan hak akses approval per dokumen.
• Pratinjau dan unduh lampiran dokumen langsung di aplikasi.
• Info detail proyek dan anggota tim dapat diakses dari detail requisition.
• Kolom Approved Qty pada rincian item PR.
• Optimasi performa dan stabilitas aplikasi.
```

### Versi Bahasa Inggris (en-US)
```text
What's new in GS PRO Mobile v1.2.0:
• Digital e-signature for PR & PO approval/rejection.
• Check button for checker role and refined per-document approver rights.
• Preview and download document attachments directly in-app.
• Clickable project numbers showing project details and team members.
• Approved Qty column in PR item details.
• Performance optimizations and stability improvements.
```

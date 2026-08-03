# Firebase TRIVA

Konfigurasi Firebase harus dibuat untuk identitas resmi:

```powershell
flutterfire configure `
  --android-package-name=id.rnq.triva `
  --ios-bundle-id=id.rnq.triva
```

File hasil konfigurasi yang mengandung credential atau identifier privat harus
mengikuti kebijakan secret repo. Jangan menyalin token, private key, atau isi
credential ke dokumentasi.

Setelah konfigurasi tersedia, inisialisasi Firebase harus dilakukan di
`apps/main/lib/bootstrap.dart` dan diverifikasi melalui build Android serta test
service terkait.

## Android signing dan Google Sign-In

Google Sign-In Android mencocokkan tiga identitas sekaligus: package
`id.rnq.triva`, SHA-1 sertifikat yang menandatangani APK di perangkat, dan OAuth
client pada project `triva-7138e`. Upload certificate bukan selalu sertifikat
yang diterima pengguna karena Google Play menandatangani ulang app bundle.

Project ini memiliki tiga SHA-1 yang harus tetap terdaftar pada Firebase:

- upload certificate: `B9:08:47:53:4E:31:03:FB:92:3E:6A:14:21:A6:33:1C:7F:6D:6C:85`;
- Play App Signing lama: `F3:CC:12:24:34:AA:F0:B0:DE:B3:61:63:23:1B:F5:08:BB:A9:C4:F7`;
- Play App Signing saat ini: `B6:D1:7F:3D:5F:F2:C8:A8:68:DC:50:E8:2F:8C:3E:C3:25:7B:F3:99`.

Play App Signing saat ini memakai SHA-256
`0D:12:91:8F:B2:09:80:5D:B8:59:3F:65:C1:3C:3C:E3:E5:5A:AE:17:3A:BB:B0:3E:FD:4A:DB:49:9B:8F:39:F7`.
Fingerprint itu harus ikut didaftarkan agar konfigurasi Firebase lengkap.

Sebelum setiap rilis Play:

1. Ambil metadata generated APK untuk version code Play terbaru melalui Google
   Play Developer API dan cocokkan `certificateSha256Hash` dengan daftar SHA
   Firebase.
2. Bila Play mengganti atau meng-upgrade app-signing key, download satu generated
   APK, ambil SHA-1 dengan `apksigner verify --print-certs`, lalu daftarkan SHA-1
   dan SHA-256 tersebut ke aplikasi Android Firebase.
3. Download ulang konfigurasi, jangan memakai `google-services.json` lama:

   ```bash
   firebase apps:sdkconfig android \
     1:1074553653742:android:a577626fe1b33fcda526ff \
     --project triva-7138e \
     -o apps/main/android/app/google-services.json
   ```

4. Jalankan test konfigurasi dan build app bundle release. Pastikan version code
   lebih tinggi daripada semua track Play sebelum upload.

Perubahan fingerprint di Firebase memperbaiki rilis yang sudah terpasang tanpa
menunggu update aplikasi, tetapi file konfigurasi repo tetap harus disegarkan
agar build dan audit berikutnya tidak memakai daftar OAuth client yang stale.

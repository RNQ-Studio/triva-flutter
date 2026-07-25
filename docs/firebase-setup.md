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

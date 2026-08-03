# TRIVA Flutter

Aplikasi pelanggan TRIVA (Trade-In Vehicle Appraisal) untuk Android dan web.

## Android release signing

Material signing bersifat lokal/secret dan tidak boleh masuk Git. Salin
`apps/main/android/key.properties.example` menjadi
`apps/main/android/key.properties`, lalu arahkan `storeFile` ke upload keystore
yang disimpan di lokasi aman. Build release akan gagal jika konfigurasi signing
tidak lengkap; ia tidak pernah fallback ke debug signing.

Sesudah menaikkan version name/code, build APK production dengan:

```bash
dart run melos run build:android:main
```

CI yang akan membuat artefak signed harus mematerialisasi keystore dan
`key.properties` dari secret store sebelum build, lalu menghapusnya kembali.

Produk ini membantu pelanggan Auto2000 Kertajaya memahami indikasi nilai
kendaraan, memantau appraisal, dan melanjutkan hasilnya ke layanan kendaraan.

## Identitas aplikasi

- Nama: `TRIVA`
- Android application ID: `id.rnq.triva`
- iOS bundle ID: `id.rnq.triva`
- Package Dart: `triva_app`
- Production API: `https://triva.ramadhanrosihadi.web.id/api/`

Logo utama berasal dari
`../triva-docs/referensi/DKD - Auto2000 Kertajaya (TRIVA).pptx`.
Turunan aset dan aturan regenerasinya berada di
[`apps/main/assets/branding/README.md`](apps/main/assets/branding/README.md).

## Struktur

```text
apps/main                 aplikasi TRIVA
packages/core             konfigurasi, network, storage, theme, l10n
packages/features_shared  auth, profil, notifikasi, settings
```

Dependency internal bergerak satu arah:

```text
apps/main -> features_shared -> core
```

## Menjalankan

```powershell
dart pub get
dart run melos bootstrap
dart run melos run dev
```

Environment dipilih melalui `--dart-define=ENV=dev|staging|prod`.

## Quality gate

```powershell
dart run melos run l10n
dart run melos run codegen
dart run melos run format:check
dart run melos run analyze
dart run melos run test
dart run melos run build:android:main
```

## Web production

Web production memakai Firebase project `triva-7138e`, Hosting site/target
`triva`, dan URL:

```text
https://triva.web.app/
```

Pada browser desktop, seluruh Navigator dirender dalam viewport mobile selebar
480 px yang terpusat. Browser mobile tetap memakai lebar perangkatnya.

Build dan deploy dijalankan terpisah agar artifact yang akan dipublikasikan
dapat diverifikasi terlebih dahulu:

```powershell
dart run melos run build:web:main
dart run melos run deploy:web:main
```

Firebase CLI harus sudah terautentikasi ke akun yang memiliki akses ke project
tersebut. Konfigurasi target dan Hosting berada di
`apps/main/.firebaserc` serta `apps/main/firebase.json`.

Database Drift pada web memakai `apps/main/web/sqlite3.wasm` dari release
`sqlite3-3.3.1` dan `apps/main/web/drift_worker.js` dari release
`drift-2.33.0`. Versi kedua asset harus selalu mengikuti `pubspec.lock`.
Firebase Authentication juga harus mengizinkan domain `triva.web.app`, dan
OAuth web client ID publik dikonfigurasi melalui meta tag di
`apps/main/web/index.html`.

Requirement produk, kontrak API, dan current state lintas stack berada di
`../triva-docs`.

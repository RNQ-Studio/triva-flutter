# Arsitektur TRIVA Flutter

## Batas workspace

TRIVA memakai satu aplikasi rilis dan dua package internal:

```text
apps/main
packages/features_shared
packages/core
```

`apps/main` menyusun route dan fitur khusus produk. `features_shared` memiliki
fitur lintas surface seperti auth, profil, notifikasi, dan settings.
`core` memiliki infrastruktur tanpa ketergantungan ke layer di atasnya.

## Aturan dependency

```text
apps/main -> features_shared -> core
```

Import antar-package harus melalui barrel publik. State memakai Riverpod,
navigasi memakai GoRouter, request HTTP memakai Dio, preference non-sensitif
memakai shared preferences, dan token memakai secure storage.

## Kontrak runtime

- Production API root:
  `https://triva.ramadhanrosihadi.web.id/api/`
- API v1 dipanggil dengan path relatif `v1/...`.
- Response backend memakai envelope `success`, `message`, `data`, dan optional
  `meta`, `code`, atau `errors`.
- Token auth dibaca dari `data`.

Kontrak lengkap dan target MVP berada di `../triva-docs`.

Flutter web memakai `WebMobileViewport` di root aplikasi agar seluruh route
tetap memiliki komposisi mobile pada browser desktop. `MediaQuery` di dalam
Navigator dibatasi ke 480 px, sedangkan browser mobile memakai lebar aslinya.

## Identitas visual

Theme menggunakan navy TRIVA sebagai warna utama, teal sebagai aksen, dan
merah merek hanya untuk identitas/logo serta semantik error yang sesuai. Semua
spacing dan radius baru memakai token di `packages/core/lib/src/theme`.

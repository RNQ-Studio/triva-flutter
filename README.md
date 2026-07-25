# TRIVA Flutter

Aplikasi pelanggan TRIVA (Trade-In Vehicle Appraisal) untuk Android dan web.
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
packages/features_shared  auth, onboarding, profil, notifikasi, settings
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

Requirement produk, kontrak API, dan current state lintas stack berada di
`../triva-docs`.

# Codex Instructions — TRIVA Flutter

Baca `../AGENTS.md` sebelum bekerja. Instruksi root tersebut tetap berlaku.

## Scope dan Sumber Kebenaran

Repo ini adalah monorepo Dart/Melos:

```text
apps/main        aplikasi TRIVA utama
apps/variant     aplikasi varian/starter; jangan diasumsikan ikut rilis
packages/core    config, network, storage, theme, l10n, database, services
packages/features_shared
                 auth, profile, notifications, settings
```

Baca `ARCHITECTURE.md` untuk aturan dependency dan
`../triva-docs/API_CONTRACT.md` sebelum mengubah integrasi API. Kontrak backend
tetap ditentukan oleh `triva-web/routes/api.php`, Form Request, API Resource,
test, dan payload live.

## Aturan Arsitektur

- Dependency internal satu arah: `apps/* -> features_shared -> core`.
- Package lain harus mengimpor barrel `package:core/core.dart` atau
  `package:features_shared/features_shared.dart`, bukan `lib/src` package lain.
- Fitur shared berada di `packages/features_shared/lib/src/<feature>`.
  Fitur khusus app berada di `apps/<app>/lib/features/<feature>`.
- Pertahankan pemisahan `data`, `domain`, dan `presentation` untuk fitur bisnis.
- Networking melalui `DioClient`; token sensitif melalui
  `SecureStorageService`; preference non-sensitif boleh memakai shared
  preferences.
- State memakai Riverpod. Ubah file sumber dan regenerasi `.g.dart` dengan
  build runner; jangan mengedit generated file secara manual.
- Route global memakai `AppRoutes`; komposisi route final tetap di masing-masing
  app.
- Tambahkan string user-facing ke ARB dan jalankan gen-l10n. Hindari hard-coded
  copy baru bila surface sudah memakai localization.

## Kontrak API

- Target production yang benar adalah
  `https://triva.ramadhanrosihadi.web.id/api/`, kemudian endpoint relatif
  `v1/...`.
- Jangan menganggap nilai di `MainConfig` selalu benar. Verifikasi
  `../triva-docs/CURRENT_STATE.md`; pada snapshot awal repo masih menunjuk
  domain starter lama.
- Response Laravel memakai envelope `success`, `message`, `data`, optional
  `meta`, dan optional `code/errors`.
- Token login/refresh berada di dalam `data`, bukan otomatis di root response.
- Semua perubahan endpoint harus menyertakan parsing test atau repository test
  untuk payload sukses dan error.
- Jangan menyimpan access/refresh token di SharedPreferences atau mencetaknya
  ke log.

## UI dan Product Behavior

- Aplikasi utama adalah pengalaman appraisal/trade-in yang cepat, dapat
  dipercaya, dan mudah dipindai; hindari tampilan starter generik.
- Setiap screen async yang relevan harus menangani loading, empty, content,
  error, dan retry. Form juga harus memiliki validation, submitting/disabled
  state, serta feedback sukses/gagal.
- Gunakan design token/theme yang ada. Jaga layout compact, hierarchy jelas,
  touch target memadai, responsive, dan aman terhadap keyboard serta text
  scaling.
- Jangan membawa metadata admin/internal ke surface customer.
- Pastikan alur upload foto, appraisal, booking, simulasi kredit, dan notifikasi
  tetap dapat dilanjutkan setelah app restart atau jaringan gagal bila fitur
  tersebut dikerjakan.

## Perintah

Jalankan dari root `triva-flutter`:

```powershell
dart pub get
dart run melos bootstrap
dart run melos run l10n
dart run melos run codegen
dart run melos run format:check
dart run melos run analyze
dart run melos run test
```

Target lebih sempit:

```powershell
dart run melos run test:core
dart run melos run test:features_shared
dart run melos run test:main
dart run melos run build:android:main
```

Gunakan `dart run melos ...` agar tidak bergantung pada instalasi Melos global.
Setelah mengubah file Dart, jalankan formatter hanya pada file/scope yang
berubah sebelum gate penuh.

## Verifikasi Integrasi

Untuk perubahan full-stack:

1. Pastikan backend test untuk endpoint lulus.
2. Uji parsing model/datasource Flutter terhadap envelope aktual.
3. Jalankan app dengan environment yang dimaksud.
4. Uji offline/error/401 dan refresh token bila menyentuh auth.
5. Untuk release Android yang diminta, build APK prod, install ke perangkat
   target, buka app, dan buktikan screen/flow yang berubah.

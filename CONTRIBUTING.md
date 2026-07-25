# Kontribusi TRIVA Flutter

Kerjakan perubahan sebagai satu irisan terverifikasi dan jaga dependency
`apps/main -> features_shared -> core`.

Sebelum commit:

```powershell
dart run melos run l10n
dart run melos run codegen
dart run melos run format:check
dart run melos run analyze
dart run melos run test
```

Jangan commit secret, file `.env`, keystore, `key.properties`, token, atau
konfigurasi Firebase privat. Commit harus menjelaskan hasil perubahan dan tidak
mencampur perubahan lokal di luar scope.

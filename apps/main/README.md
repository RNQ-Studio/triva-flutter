# TRIVA app

Entry point aplikasi pelanggan TRIVA.

```powershell
flutter run --dart-define=ENV=dev
flutter build apk --release --dart-define=ENV=prod
```

Identitas native:

- Android: `id.rnq.triva`
- iOS: `id.rnq.triva`
- Web title: `TRIVA`

Launcher icon dibuat dari aset resmi di `assets/branding/` dengan:

```powershell
dart run flutter_launcher_icons
```

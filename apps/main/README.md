# TRIVA app

Entry point aplikasi pelanggan TRIVA.

```powershell
flutter run --dart-define=ENV=dev
flutter build apk --release --dart-define=ENV=prod
flutter build web --release --dart-define=ENV=prod
firebase deploy --only hosting:triva --project triva-7138e
```

Identitas native:

- Android: `id.rnq.triva`
- iOS: `id.rnq.triva`
- Web title: `TRIVA`
- Web production: `https://triva.web.app/`

Launcher icon dibuat dari aset resmi di `assets/branding/` dengan:

```powershell
dart run flutter_launcher_icons
```

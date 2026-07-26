# features_shared

Fitur bersama aplikasi TRIVA yang berada di atas `core`:

- branding dan logo;
- auth dan biometrik;
- profil;
- notifikasi;
- pengaturan tema dan bahasa.

Public API digunakan melalui:

```dart
import 'package:features_shared/features_shared.dart';
```

Package ini boleh bergantung pada `core`, tetapi tidak boleh mengimpor
`apps/main`. Fitur yang hanya dimiliki aplikasi pelanggan tetap ditempatkan di
`apps/main/lib/features`.

Verifikasi:

```powershell
flutter test packages/features_shared/test
dart analyze packages/features_shared
```

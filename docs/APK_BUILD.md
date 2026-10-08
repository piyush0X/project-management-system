# Android APK Build

Before release, set `mobile/lib/config/api_config.dart` to:

```dart
class ApiConfig {
  static const String baseUrl =
      'https://project-management-backend-sg3k.onrender.com/api';
}
```

Then:

```powershell
cd C:\Users\piyus\Desktop\project-management-system\mobile
flutter pub get
flutter doctor
flutter build apk --release
```

Expected output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Install for final testing:

```powershell
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

Test login, dashboard, projects, tasks, search/filter, logout, network errors and web ↔ Android synchronization.

Optional architecture-specific builds:

```powershell
flutter build apk --release --split-per-abi
```

# Flutter Setup

Requirements: Flutter SDK, Android SDK/Android Studio, Android device/emulator and ADB.

```powershell
cd C:\Users\piyus\Desktop\project-management-system\mobile
flutter pub get
```

For local physical-device testing, the current API is:

```dart
static const String baseUrl = 'http://127.0.0.1:5000/api';
```

Use ADB reverse:

```powershell
adb reverse tcp:5000 tcp:5000
flutter run
```

For production, change the API to:

```text
https://project-management-backend-sg3k.onrender.com/api
```

The app includes authentication, secure token storage, dashboard, projects, tasks, search/filter, pull-to-refresh, theme switching, logout, token-expiry handling and network error handling.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _themeKey = 'dark_mode';

  // Get saved theme preference
  static Future<bool> getDarkMode() async {
    final value = await _storage.read(
      key: _themeKey,
    );

    return value == 'true';
  }

  // Save theme preference
  static Future<void> saveDarkMode(bool isDark) async {
    await _storage.write(
      key: _themeKey,
      value: isDark.toString(),
    );
  }
}
import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../services/auth_service.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> goToLogin() async {
    await AuthService.clearToken();

    final navigator = navigatorKey.currentState;

    if (navigator == null) {
      return;
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          isDarkMode: false,
          onToggleTheme: () {},
        ),
      ),
      (route) => false,
    );
  }
}
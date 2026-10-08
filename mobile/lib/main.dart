import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/projects_screen.dart';

import 'services/auth_service.dart';
import 'services/theme_service.dart';

import 'utils/app_navigator.dart';

void main() {
  runApp(const ProjectManagementApp());
}

class ProjectManagementApp extends StatefulWidget {
  const ProjectManagementApp({super.key});

  @override
  State<ProjectManagementApp> createState() =>
      _ProjectManagementAppState();
}

class _ProjectManagementAppState
    extends State<ProjectManagementApp> {
  bool isDarkMode = false;
  bool themeLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedDarkMode = await ThemeService.getDarkMode();

    if (!mounted) return;

    setState(() {
      isDarkMode = savedDarkMode;
      themeLoading = false;
    });
  }

  Future<void> toggleTheme() async {
    final newDarkMode = !isDarkMode;

    setState(() {
      isDarkMode = newDarkMode;
    });

    await ThemeService.saveDarkMode(newDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    // Show a small loading screen while the saved theme is being loaded.
    if (themeLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      navigatorKey: AppNavigator.navigatorKey,

      title: 'Project Manager',

      // GLOBAL THEME CONTROL
      themeMode:
          isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // LIGHT THEME
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      // DARK THEME
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // Authentication decides whether Login or Dashboard appears.
      home: AuthGate(
        isDarkMode: isDarkMode,
        onToggleTheme: toggleTheme,
      ),

      // Existing routes
      routes: {
        '/login': (_) => LoginScreen(
  isDarkMode: isDarkMode,
  onToggleTheme: toggleTheme,
),

        '/register': (_) => RegisterScreen(
  isDarkMode: isDarkMode,
  onToggleTheme: toggleTheme,
),

        '/projects': (_) => const ProjectsScreen(),

        '/dashboard': (_) => DashboardScreen(
              isDarkMode: isDarkMode,
              onToggleTheme: toggleTheme,
            ),
      },
    );
  }
}


// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const AuthGate({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    try {
      final token = await AuthService.getToken();

      if (!mounted) return;

      setState(() {
        isLoggedIn =
            token != null && token.isNotEmpty;

        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Checking authentication
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // User is logged in
    if (isLoggedIn) {
      return DashboardScreen(
        isDarkMode: widget.isDarkMode,
        onToggleTheme: widget.onToggleTheme,
      );
    }

    // User is not logged in
    return LoginScreen(
  isDarkMode: widget.isDarkMode,
  onToggleTheme: widget.onToggleTheme,
);
  }
}
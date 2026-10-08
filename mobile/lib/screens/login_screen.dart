import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';


class LoginScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const LoginScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });


  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final _formKey =
      GlobalKey<FormState>();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _loading = false;

  bool _obscurePassword = true;

  String? _error;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }


  Future<void> _login() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {

      await AuthService.login(
        email:
            _emailController.text.trim(),

        password:
            _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DashboardScreen(
                isDarkMode: widget.isDarkMode,
                onToggleTheme: widget.onToggleTheme,
              ),
        ),
        (route) => false,
      );

    } catch (error) {

      if (!mounted) return;

      setState(() {
        _error =
            error.toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                );
      });

    } finally {

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding:
                const EdgeInsets.all(24),

            child: Form(

              key: _formKey,

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [

                  const Icon(
                    Icons.task_alt,
                    size: 70,
                    color: Colors.blue,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    'Project Manager',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Login to manage your projects',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  if (_error != null)
                    Container(
                      padding:
                          const EdgeInsets.all(12),
                      margin:
                          const EdgeInsets.only(
                            bottom: 16,
                          ),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.red.shade50,
                        borderRadius:
                            BorderRadius.circular(
                              8,
                            ),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color:
                              Colors.red.shade700,
                        ),
                      ),
                    ),

                  TextFormField(
                    controller:
                        _emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(
                      labelText: 'Email',
                      prefixIcon:
                          Icon(Icons.email_outlined),
                      border:
                          OutlineInputBorder(),
                    ),
                    validator: (value) {

                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Email is required';
                      }

                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextFormField(
                    controller:
                        _passwordController,
                    obscureText:
                        _obscurePassword,
                    decoration:
                        InputDecoration(
                      labelText: 'Password',
                      prefixIcon:
                          const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon:
                          IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                      ),
                      border:
                          const OutlineInputBorder(),
                    ),
                    validator: (value) {

                      if (value == null ||
                          value.isEmpty) {
                        return 'Password is required';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    height: 50,

                    child: ElevatedButton(
                      onPressed:
                          _loading
                              ? null
                              : _login,

                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Login',
                            ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextButton(
                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RegisterScreen(
                                isDarkMode: widget.isDarkMode,
                                onToggleTheme: widget.onToggleTheme,
                              ),
                        ),
                      );
                    },

                    child: const Text(
                      "Don't have an account? Register",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
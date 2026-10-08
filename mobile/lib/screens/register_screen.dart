import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const RegisterScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final _formKey =
      GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  bool _loading = false;

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;

  String? _error;


  @override
  void dispose() {

    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }


  Future<void> _register() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {

      await AuthService.register(
        fullName:
            _nameController.text.trim(),

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

      appBar: AppBar(
        title: const Text(
          'Create Account',
        ),
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(24),

          child: Form(

            key: _formKey,

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [

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
                          BorderRadius.circular(8),
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
                      _nameController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon:
                        Icon(Icons.person_outline),
                    border:
                        OutlineInputBorder(),
                  ),
                  validator: (value) {

                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Full name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 16,
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

                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 16,
                ),

                TextFormField(
                  controller:
                      _confirmPasswordController,
                  obscureText:
                      _obscureConfirmPassword,
                  decoration:
                      InputDecoration(
                    labelText:
                        'Confirm Password',
                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),
                    suffixIcon:
                        IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border:
                        const OutlineInputBorder(),
                  ),
                  validator: (value) {

                    if (value == null ||
                        value.isEmpty) {
                      return 'Confirm your password';
                    }

                    if (value !=
                        _passwordController.text) {
                      return 'Passwords do not match';
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
                            : _register,

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
                            'Create Account',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
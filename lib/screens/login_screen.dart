import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/validators.dart';
import '../repositories/firebase_auth_repository.dart';
import 'register_screen.dart';

/// Secure Sign-In Portal for RecipeBox
/// Author: Nguyen Vinh Phu (QE180136)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _credentialsFormKey = GlobalKey<FormState>();
  final _authRepository = FirebaseAuthRepository();

  final TextEditingController _mailFieldController = TextEditingController();
  final TextEditingController _passFieldController = TextEditingController();

  AutovalidateMode _validationPolicy = AutovalidateMode.disabled;
  bool _isAuthenticationPending = false;
  String? _serverErrorMessage;
  bool _maskSecretText = true;

  @override
  void dispose() {
    _mailFieldController.dispose();
    _passFieldController.dispose();
    super.dispose();
  }

  Future<void> _processUserLogin() async {
    setState(() {
      _validationPolicy = AutovalidateMode.onUserInteraction;
      _serverErrorMessage = null;
    });

    if (!_credentialsFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isAuthenticationPending = true);

    final outcome = await _authRepository.logIn(
      email: _mailFieldController.text,
      password: _passFieldController.text,
    );

    if (!mounted) return;

    if (outcome.isSuccess) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      setState(() {
        _serverErrorMessage = outcome.errorOrNull;
        _isAuthenticationPending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceCanvas,
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: AppTheme.primaryEmerald,
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _credentialsFormKey,
              autovalidateMode: _validationPolicy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryEmerald,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign in to access your recipe collection',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  // Email input
                  TextFormField(
                    controller: _mailFieldController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                    ),
                    validator: RecipeValidators.validateEmail,
                  ),
                  const SizedBox(height: 18),

                  // Password input
                  TextFormField(
                    controller: _passFieldController,
                    obscureText: _maskSecretText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _maskSecretText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _maskSecretText = !_maskSecretText),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                  ),
                  const SizedBox(height: 26),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isAuthenticationPending ? null : _processUserLogin,
                    child: _isAuthenticationPending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Login'),
                  ),

                  // Server Error Box
                  if (_serverErrorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _serverErrorMessage!,
                              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: AppTheme.primaryEmerald,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
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

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/validators.dart';
import '../repositories/firebase_auth_repository.dart';
import 'login_screen.dart';

/// User Registration Interface for RecipeBox
/// Author: Nguyen Vinh Phu (QE180136)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _signupFormKey = GlobalKey<FormState>();
  final _authRepository = FirebaseAuthRepository();

  final TextEditingController _emailFieldController = TextEditingController();
  final TextEditingController _passwordFieldController = TextEditingController();
  final TextEditingController _confirmPassFieldController = TextEditingController();

  AutovalidateMode _validationPolicy = AutovalidateMode.disabled;
  bool _isRegistering = false;
  String? _serverErrorMessage;
  bool _hideSecretKey = true;
  bool _hideConfirmKey = true;

  @override
  void dispose() {
    _emailFieldController.dispose();
    _passwordFieldController.dispose();
    _confirmPassFieldController.dispose();
    super.dispose();
  }

  Future<void> _executeRegistration() async {
    setState(() {
      _validationPolicy = AutovalidateMode.onUserInteraction;
      _serverErrorMessage = null;
    });

    if (!_signupFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isRegistering = true);

    final outcome = await _authRepository.signUp(
      email: _emailFieldController.text,
      password: _passwordFieldController.text,
    );

    if (!mounted) return;

    if (outcome.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful'),
          backgroundColor: Color(0xFF16A34A),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1800));
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else {
      setState(() {
        _serverErrorMessage = outcome.errorOrNull;
        _isRegistering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceCanvas,
      appBar: AppBar(
        title: const Text('Register'),
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
              key: _signupFormKey,
              autovalidateMode: _validationPolicy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryEmerald,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign up to start organizing your private recipes',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  const SizedBox(height: 26),

                  // Email Input
                  TextFormField(
                    controller: _emailFieldController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                    ),
                    validator: RecipeValidators.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  TextFormField(
                    controller: _passwordFieldController,
                    obscureText: _hideSecretKey,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hideSecretKey ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _hideSecretKey = !_hideSecretKey),
                      ),
                    ),
                    validator: RecipeValidators.validatePassword,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPassFieldController,
                    obscureText: _hideConfirmKey,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hideConfirmKey ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _hideConfirmKey = !_hideConfirmKey),
                      ),
                    ),
                    validator: (v) => RecipeValidators.validateConfirmPassword(
                      v,
                      _passwordFieldController.text,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit
                  ElevatedButton(
                    onPressed: _isRegistering ? null : _executeRegistration,
                    child: _isRegistering
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Register'),
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

                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Login',
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

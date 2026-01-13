import 'package:flutter/material.dart';
import 'package:inventory_app/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _hasMinLen = false;
  bool _hasUpper = false;
  bool _hasLower = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Widget _buildRequirementRow(String text, bool ok) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.close,
            color: ok ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter email';
                  final emailRegex = RegExp(
                    r'^[\w\-.]+@([\w\-]+\.)+[A-Za-z]{2,}$',
                  );
                  if (!emailRegex.hasMatch(v.trim()))
                    return 'Invalid email format';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                onChanged: (v) {
                  setState(() {
                    _hasMinLen = v.length >= 8;
                    _hasUpper = RegExp(r'[A-Z]').hasMatch(v);
                    _hasLower = RegExp(r'[a-z]').hasMatch(v);
                    _hasNumber = RegExp(r'\d').hasMatch(v);
                    _hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(v);
                  });
                },
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter password';
                  if (!(_hasMinLen &&
                      _hasUpper &&
                      _hasLower &&
                      _hasNumber &&
                      _hasSpecial)) {
                    return 'Password does not meet all requirements';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Password requirements checklist
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRequirementRow('Has length of 8', _hasMinLen),
                  _buildRequirementRow('A capital letter', _hasUpper),
                  _buildRequirementRow('A small letter', _hasLower),
                  _buildRequirementRow('A special character', _hasSpecial),
                  _buildRequirementRow('A number', _hasNumber),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        if (!(_formKey.currentState?.validate() ?? false))
                          return;
                        // ensure password checklist flags are up-to-date before submission
                        final pv = _passCtrl.text;
                        _hasMinLen = pv.length >= 8;
                        _hasUpper = RegExp(r'[A-Z]').hasMatch(pv);
                        _hasLower = RegExp(r'[a-z]').hasMatch(pv);
                        _hasNumber = RegExp(r'\d').hasMatch(pv);
                        _hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(pv);
                        if (!(_hasMinLen &&
                            _hasUpper &&
                            _hasLower &&
                            _hasNumber &&
                            _hasSpecial)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password does not meet all requirements',
                              ),
                            ),
                          );
                          return;
                        }
                        setState(() => _loading = true);
                        try {
                          await authService.value.createAccount(
                            email: _emailCtrl.text.trim(),
                            password: _passCtrl.text,
                          );
                          Navigator.pushReplacementNamed(context, '/home');
                        } on FirebaseAuthException catch (e) {
                          String msg;
                          switch (e.code) {
                            case 'email-already-in-use':
                              msg =
                                  'That email is already registered. Try signing in instead.';
                              break;
                            case 'weak-password':
                              msg =
                                  'That password is too weak. Use a stronger password with uppercase, numbers, and symbols.';
                              break;
                            case 'invalid-email':
                              msg =
                                  'That email doesn\'t look right. Please check and try again.';
                              break;
                            case 'operation-not-allowed':
                              msg =
                                  'Email/password sign-in isn\'t enabled. Please contact support.';
                              break;
                            case 'invalid-credential':
                            case 'invalid-verification-code':
                              msg =
                                  'The information provided is invalid or expired. Please try again.';
                              break;
                            case 'expired-action-code':
                            case 'invalid-action-code':
                              msg =
                                  'This link or code has expired or is invalid. Please request a new one.';
                              break;
                            case 'too-many-requests':
                              msg =
                                  'Too many attempts. Please wait and try again later.';
                              break;
                            default:
                              msg =
                                  e.message ??
                                  'Registration failed. Please try again.';
                          }
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Register failed: ${e.toString()}'),
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                child: _loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Register'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

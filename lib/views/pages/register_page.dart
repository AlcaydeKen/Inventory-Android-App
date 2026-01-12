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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
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
                    final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[A-Za-z]{2,}$');
                  if (!emailRegex.hasMatch(v.trim())) return 'Invalid email format';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter password';
                  final pwdRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{6,}$');
                  if (!pwdRegex.hasMatch(v)) return 'Password must be at least 6 characters and include uppercase, lowercase, number, and special character';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        if (!(_formKey.currentState?.validate() ?? false)) return;
                        setState(() => _loading = true);
                        try {
                          await authService.value.createAccount(email: _emailCtrl.text.trim(), password: _passCtrl.text);
                          Navigator.pushReplacementNamed(context, '/home');
                        } on FirebaseAuthException catch (e) {
                          String msg;
                          switch (e.code) {
                            case 'email-already-in-use':
                              msg = 'That email is already registered. Try signing in instead.';
                              break;
                            case 'weak-password':
                              msg = 'That password is too weak. Use a stronger password with uppercase, numbers, and symbols.';
                              break;
                            case 'invalid-email':
                              msg = 'That email doesn\'t look right. Please check and try again.';
                              break;
                            case 'operation-not-allowed':
                              msg = 'Email/password sign-in isn\'t enabled. Please contact support.';
                              break;
                            case 'invalid-credential':
                            case 'invalid-verification-code':
                              msg = 'The information provided is invalid or expired. Please try again.';
                              break;
                            case 'expired-action-code':
                            case 'invalid-action-code':
                              msg = 'This link or code has expired or is invalid. Please request a new one.';
                              break;
                            case 'too-many-requests':
                              msg = 'Too many attempts. Please wait and try again later.';
                              break;
                            default:
                              msg = e.message ?? 'Registration failed. Please try again.';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Register failed: ${e.toString()}')));
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                child: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Register'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Have an account? Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

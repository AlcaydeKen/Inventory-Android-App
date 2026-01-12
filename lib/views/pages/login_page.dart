import 'package:flutter/material.dart';
import 'package:inventory_app/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
      appBar: AppBar(title: const Text('Login')),
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
                  if (v.length < 6) return 'Password must be at least 6 characters';
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
                          await authService.value.signIn(email: _emailCtrl.text.trim(), password: _passCtrl.text);
                          Navigator.pushReplacementNamed(context, '/home');
                        } on FirebaseAuthException catch (e) {
                          String msg;
                          switch (e.code) {
                            case 'user-not-found':
                              msg = 'We couldn\'t find an account with that email.';
                              break;
                            case 'wrong-password':
                              msg = 'Email or password don\'t match. Please try again.';
                              break;
                            case 'invalid-email':
                              msg = 'That email doesn\'t look right. Please check and try again.';
                              break;
                            case 'user-disabled':
                              msg = 'This account has been disabled. Please contact support.';
                              break;
                            case 'invalid-credential':
                            case 'invalid-verification-code':
                              msg = 'The login information is invalid or expired. Please try again.';
                              break;
                            case 'expired-action-code':
                            case 'invalid-action-code':
                              msg = 'This link or code has expired or is invalid. Request a new one.';
                              break;
                            case 'too-many-requests':
                              msg = 'Too many attempts. Please wait a while and try again.';
                              break;
                            default:
                              msg = e.message ?? 'Login failed. Please try again.';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                child: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Login'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Create account'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/reset'),
                    child: const Text('Forgot password?'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

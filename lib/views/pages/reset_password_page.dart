import 'package:flutter/material.dart';
import 'package:inventory_app/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        if (!(_formKey.currentState?.validate() ?? false)) return;
                        setState(() => _loading = true);
                        try {
                          await authService.value.resetPassword(email: _emailCtrl.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link sent')));
                          Navigator.pushReplacementNamed(context, '/login');
                        } on FirebaseAuthException catch (e) {
                          String msg;
                          switch (e.code) {
                            case 'user-not-found':
                              msg = 'We couldn\'t find an account with that email.';
                              break;
                            case 'invalid-email':
                              msg = 'That email doesn\'t look right. Please check and try again.';
                              break;
                            case 'expired-action-code':
                            case 'invalid-action-code':
                              msg = 'This reset link is invalid or has expired. Request a new one.';
                              break;
                            case 'too-many-requests':
                              msg = 'Too many requests. Please wait and try again later.';
                              break;
                            default:
                              msg = e.message ?? 'Reset failed. Please try again.';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reset failed: ${e.toString()}')));
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                child: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Send reset link'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Back to login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

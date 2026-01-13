import 'package:flutter/material.dart';
import 'package:inventory_app/auth/auth_service.dart';
import 'logs_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _usernameCtrl = TextEditingController();
  final _deletePasswordCtrl = TextEditingController();
  bool _obscureDeletePwd = true;
  bool _deleting = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _deletePasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _showSetUsernameDialog(String? current) async {
    _usernameCtrl.text = current ?? '';
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set username'),
        content: TextField(
          controller: _usernameCtrl,
          decoration: const InputDecoration(hintText: 'Enter username'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final v = _usernameCtrl.text.trim();
              if (v.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username cannot be empty')));
                return;
              }
              try {
                await authService.value.updateUsername(username: v);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username updated')));
                setState(() {});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: ${e.toString()}')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleChangePassword() async {
    final user = authService.value.currentUser;
    final email = user?.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No email is set on your account. Please add an email first.')));
      return;
    }

    try {
      await authService.value.resetPassword(email: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset link sent to your email')));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No account found for your email — nothing was sent.')));
        return;
      }
      String msg;
      switch (e.code) {
        case 'invalid-email':
          msg = 'Your account email looks invalid. Please check your account settings.';
          break;
        case 'too-many-requests':
          msg = 'Too many attempts. Please wait and try again later.';
          break;
        default:
          msg = e.message ?? 'Could not send reset link. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not send reset link: ${e.toString()}')));
    }
  }

  Future<void> _confirmAndDeleteAccount(String? email) async {
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No email is set on your account.')));
      return;
    }

    _deletePasswordCtrl.text = '';
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Delete account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This will permanently delete your account and all data tied to it. This action cannot be undone.'),
              const SizedBox(height: 12),
              TextField(
                controller: _deletePasswordCtrl,
                obscureText: _obscureDeletePwd,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  hintText: 'Enter your password to confirm',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureDeletePwd ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureDeletePwd = !_obscureDeletePwd),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final pwd = _deletePasswordCtrl.text.trim();
                if (pwd.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your password to confirm.')));
                  return;
                }
                try {
                  setState(() => _deleting = true);
                  await authService.value.deleteAccount(email: email, password: pwd);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted')));
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                } on FirebaseAuthException catch (e) {
                  String msg;
                  switch (e.code) {
                    case 'wrong-password':
                      msg = 'Password is incorrect. Account not deleted.';
                      break;
                    case 'user-not-found':
                      msg = 'No account found for this email.';
                      break;
                    case 'requires-recent-login':
                      msg = 'Recent sign-in required. Please sign in again and try.';
                      break;
                    default:
                      msg = e.message ?? 'Failed to delete account. Please try again.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete account: ${e.toString()}')));
                } finally {
                  setState(() => _deleting = false);
                }
              },
              child: _deleting ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.value.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final username = user?.displayName;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text('Profile', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (username != null && username.isNotEmpty)
                        Row(
                          children: [
                            Expanded(child: Text(username)),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => _showSetUsernameDialog(username),
                              child: const Text('Edit username'),
                            ),
                          ],
                        )
                      else ...[
                        const Text('No username set', style: TextStyle(color: Colors.red)),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: () => _showSetUsernameDialog(username), child: const Text('Set username')),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _handleChangePassword,
                child: const Text('Change password'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _confirmAndDeleteAccount(user?.email),
                child: const Text('Delete account'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const Logs()));
                },
                child: const Text('View Logs'),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  try {
                    await authService.value.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign out failed: ${e.toString()}')));
                  }
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        );
      },
    );
  }
}
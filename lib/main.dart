import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inventory_app/views/widget_tree.dart';
import 'package:inventory_app/views/pages/login_page.dart';
import 'package:inventory_app/views/pages/register_page.dart';
import 'package:inventory_app/views/pages/reset_password_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/reset': (context) => const ResetPasswordPage(),
        '/home': (context) => const WidgetTree(),
      },
    );
  }
}

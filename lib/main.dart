import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
  int currentIndex = 0;
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
      home: Scaffold(
        appBar: AppBar(title: Text('Inventory App'), centerTitle: true),
        body: [
          Center(child: Text('Inventory')),
          Center(child: Text('Manage')),
          Center(child: Text('Order')),
          Center(child: Text('Profile')),
        ][currentIndex],

        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.inventory),
              label: 'Inventory',
            ),
            NavigationDestination(icon: Icon(Icons.edit), label: 'Manage'),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart),
              label: 'Order',
            ),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],

          onDestinationSelected: (int value) {
            setState(() {
              currentIndex = value;
            });
          },
          selectedIndex: currentIndex,
        ),
      ),
    );
  }
}

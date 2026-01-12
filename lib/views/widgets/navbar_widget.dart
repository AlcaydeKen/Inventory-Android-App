import 'package:flutter/material.dart';
import 'package:inventory_app/data/notifiers.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: selectedPageNotifier, builder: (context, selectedPage, child) {
      return NavigationBar(
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
            selectedPageNotifier.value = value;
          },
          selectedIndex: selectedPage,
        );
    },);
  }
}
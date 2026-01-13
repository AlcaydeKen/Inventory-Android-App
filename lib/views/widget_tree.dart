import 'package:flutter/material.dart';
import 'package:inventory_app/data/notifiers.dart';
import 'package:inventory_app/views/pages/inventory_page.dart';
import 'package:inventory_app/views/pages/manage_page.dart';
import 'package:inventory_app/views/pages/order_page.dart';
import 'package:inventory_app/views/pages/cart_page.dart';
import 'package:inventory_app/views/pages/profile_page.dart';
import 'package:inventory_app/views/pages/purchases_page.dart';

import 'widgets/navbar_widget.dart';

List<Widget> pages = [
  Inventory(),
  Manage(),
  Order(),
  Cart(),
  Purchases(),
  Profile(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Inventory App'), centerTitle: true),
        body: ValueListenableBuilder(valueListenable: selectedPageNotifier, builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },),
        bottomNavigationBar: NavbarWidget(),
      );
  }
}
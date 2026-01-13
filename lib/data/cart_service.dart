import 'package:flutter/widgets.dart';

ValueNotifier<Map<String, Map<String, dynamic>>> cartItems = ValueNotifier(
  <String, Map<String, dynamic>>{},
);

class CartService {
  void addItem({required String id, required String name, required int qty}) {
    final map = cartItems.value;
    final existing = map[id];
    if (existing != null) {
      existing['qty'] = (existing['qty'] as int) + qty;
    } else {
      map[id] = {'name': name, 'qty': qty};
    }
    cartItems.value = Map.from(map);
  }

  void updateQty({required String id, required int qty}) {
    final map = cartItems.value;
    if (map.containsKey(id)) {
      if (qty <= 0) {
        map.remove(id);
      } else {
        map[id]!['qty'] = qty;
      }
      cartItems.value = Map.from(map);
    }
  }

  void removeItem(String id) {
    final map = cartItems.value;
    map.remove(id);
    cartItems.value = Map.from(map);
  }

  void clear() {
    cartItems.value = {};
  }
}

final cartService = CartService();

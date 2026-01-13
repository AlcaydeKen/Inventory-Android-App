import 'package:flutter/material.dart';
import '../../data/cart_service.dart';
import '../../data/purchases_service.dart';
import '../../auth/auth_service.dart';
import '../../data/logs_service.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, Map<String, dynamic>>>(
      valueListenable: cartItems,
      builder: (context, items, _) {
        if (items.isEmpty) return const Center(child: Text('Cart is empty'));

        final entries = items.entries.toList();
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, i) {
                  final id = entries[i].key;
                  final data = entries[i].value;
                  final name = data['name'] as String;
                  final qty = data['qty'] as int;
                  return ListTile(
                    title: Text(name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: qty > 1
                              ? () {
                                  cartService.updateQty(id: id, qty: qty - 1);
                                  logsService.logEvent(
                                    text: 'Decreased qty for $name to ${qty - 1}',
                                    meta: {'itemId': id, 'qty': qty - 1},
                                  );
                                }
                              : () {
                                  cartService.removeItem(id);
                                  logsService.logEvent(
                                    text: 'Removed $name from cart',
                                    meta: {'itemId': id},
                                  );
                                },
                        ),
                        Text('$qty'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () =>
                              cartService.updateQty(id: id, qty: qty + 1),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () async {
                  final uid = authService.value.currentUser?.uid;
                  if (uid == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please sign in to place orders'),
                      ),
                    );
                    return;
                  }

                  try {
                    final ref = await purchasesService.placeOrder(
                      items: items,
                      userId: uid,
                    );
                    // log purchase event
                    await logsService.logEvent(
                      text: 'Placed order ${ref.id}',
                      meta: {
                        'purchaseId': ref.id,
                        'items': items.entries.map((e) => {'itemId': e.key, 'name': e.value['name'], 'qty': e.value['qty']}).toList(),
                      },
                    );
                    cartService.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order placed: ${ref.id}')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to place order: $e')),
                    );
                  }
                },
                child: const Text('Place Order'),
              ),
            ),
          ],
        );
      },
    );
  }
}

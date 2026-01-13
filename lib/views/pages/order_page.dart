import 'package:flutter/material.dart';
import '../../data/items_service.dart';
import '../../data/cart_service.dart';
import '../../data/logs_service.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search items',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: ItemsService().streamItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) return const Center(child: Text('No items'));

              final docs = snapshot.data!.docs;
              final filtered = _query.isEmpty
                  ? docs
                  : docs.where((d) {
                      final name = (d.data()['lowercaseName'] ?? '').toString();
                      return name.contains(_query);
                    }).toList();

              if (filtered.isEmpty) return const Center(child: Text('No matching items'));

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final d = filtered[i];
                  final data = d.data();
                  final name = data['name'] ?? '';
                  final avail = (data['qty'] ?? 0) as int;
                  return ListTile(
                    title: Text(name),
                    subtitle: Text('Available: $avail'),
                    trailing: ElevatedButton(
                      onPressed: avail <= 0
                          ? null
                          : () async {
                              int qty = 1;
                              await showDialog(
                                context: context,
                                builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
                                  return AlertDialog(
                                    title: Text('Add $name'),
                                    content: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: qty > 1
                                              ? () => setSt(() => qty--)
                                              : null,
                                        ),
                                        Text('$qty'),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: qty < avail ? () => setSt(() => qty++) : null,
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                      ElevatedButton(
                                        onPressed: () async {
                                          cartService.addItem(id: d.id, name: name, qty: qty);
                                          await logsService.logEvent(
                                            text: 'Added $qty x $name to cart',
                                            meta: {'itemId': d.id, 'qty': qty},
                                          );
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Added $qty x $name to cart')),
                                          );
                                        },
                                        child: const Text('Add'),
                                      ),
                                    ],
                                  );
                                }),
                              );
                            },
                      child: const Text('Add'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


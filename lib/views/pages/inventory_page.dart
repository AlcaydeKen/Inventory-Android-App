import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_app/data/items_service.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text('Inventory', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search items',
            ),
            onChanged: (v) => setState(() => _search = v.trim()),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: itemsService.value.streamItems(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs
                      .map(
                        (d) => {'id': d.id, 'name': d['name'], 'qty': d['qty']},
                      )
                      .where(
                        (item) =>
                            _search.isEmpty ||
                            item['name'].toString().toLowerCase().contains(
                              _search.toLowerCase(),
                            ),
                      )
                      .toList();

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: DataTable(
                        columnSpacing: 48.0,
                        horizontalMargin: 24.0,
                        headingRowHeight: 56.0,
                        columns: const [
                          DataColumn(label: Text('Item Name')),
                          DataColumn(label: Text('Qty')),
                        ],
                        rows: docs.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(item['name'] ?? ''),
                                ),
                              ),
                              DataCell(
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(item['qty'].toString()),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_app/data/items_service.dart';

class Manage extends StatefulWidget {
  const Manage({super.key});

  @override
  State<Manage> createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? item}) async {
    final nameCtrl = TextEditingController(
      text: item != null ? item['name'] : '',
    );
    final qtyCtrl = TextEditingController(
      text: item != null ? item['qty'].toString() : '',
    );
    final isEdit = item != null;

    String? nameError;
    bool loading = false;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'Edit item' : 'Add item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Item Name'),
                onChanged: (_) {
                  if (nameError != null) setState(() => nameError = null);
                },
              ),
              if (nameError != null) ...[
                const SizedBox(height: 6),
                Text(
                  nameError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 8),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Qty'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      final qtyText = qtyCtrl.text.trim();
                      final qty = int.tryParse(qtyText) ?? -1;
                      if (name.isEmpty || qty < 0) {
                        setState(() => nameError = null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please provide valid name and quantity',
                            ),
                          ),
                        );
                        return;
                      }

                      setState(() => loading = true);

                      final lc = name.toLowerCase();
                      final exists = await itemsService.value.duplicateExists(
                        lc,
                        excludeId: isEdit ? item['id'] : null,
                      );
                      if (exists) {
                        setState(() {
                          nameError = 'An item with that name already exists.';
                          loading = false;
                        });
                        return;
                      }

                      try {
                        if (isEdit) {
                          await itemsService.value.updateItem(
                            id: item['id'],
                            name: name,
                            qty: qty,
                          );
                        } else {
                          await itemsService.value.addItem(
                            name: name,
                            qty: qty,
                          );
                        }
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to save item: ${e.toString()}',
                            ),
                          ),
                        );
                        setState(() => loading = false);
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEdit ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item'),
        content: Text('Delete "${item['name']}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await itemsService.value.deleteItem(id: item['id']);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item deleted')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'Manage Items',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
                            (d) => {
                              'id': d.id,
                              'name': d['name'],
                              'qty': d['qty'],
                            },
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
                              DataColumn(label: Text('Actions')),
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
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () =>
                                              _showAddEditDialog(item: item),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _confirmDelete(item),
                                          tooltip: 'Delete',
                                        ),
                                      ],
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

          Positioned(
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
              child: FloatingActionButton(
                onPressed: () => _showAddEditDialog(),
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

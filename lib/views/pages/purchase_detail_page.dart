import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/purchases_service.dart';

class PurchaseDetailPage extends StatelessWidget {
  final String purchaseId;
  const PurchaseDetailPage({super.key, required this.purchaseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: FutureBuilder(
        future: purchasesService.getPurchase(purchaseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Purchase not found'));
          }
          final data = snapshot.data!.data()!;
          final id = snapshot.data!.id;
          final items = (data['items'] as List<dynamic>?) ?? [];
          final ts = data['createdAt'] as Timestamp?;
          final date = ts != null
              ? DateFormat.yMd().add_jm().format(ts.toDate())
              : 'Unknown';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Purchase ID: $id',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Date: $date'),
                const SizedBox(height: 16),
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final it = items[i] as Map<String, dynamic>;
                      return ListTile(
                        title: Text(it['name'] ?? ''),
                        trailing: Text('Qty: ${it['qty'] ?? 0}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

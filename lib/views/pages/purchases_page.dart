import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/purchases_service.dart';
import '../../auth/auth_service.dart';
import 'purchase_detail_page.dart';

class Purchases extends StatelessWidget {
  const Purchases({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.value.authStateChanges,
      builder: (context, authSnap) {
        final user = authSnap.data;
        return StreamBuilder(
          stream: purchasesService.streamPurchases(userId: user?.uid),
          builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No purchases'));
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i];
            final data = d.data();
            final ts = data['createdAt'] as Timestamp?;
            final date = ts != null
                ? DateFormat.yMd().add_jm().format(ts.toDate())
                : 'Unknown';
            final total = data['totalItems'] ?? 0;
            return ListTile(
              title: Text('Purchase ${d.id}'),
              subtitle: Text('$total items • $date'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PurchaseDetailPage(purchaseId: d.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
      },
    );
  }
}

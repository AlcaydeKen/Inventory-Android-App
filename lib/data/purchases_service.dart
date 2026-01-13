import 'package:cloud_firestore/cloud_firestore.dart';

class PurchasesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('purchases');

  CollectionReference<Map<String, dynamic>> get _itemsCol =>
      _db.collection('items');

  Future<DocumentReference<Map<String, dynamic>>> placeOrder({
    required Map<String, Map<String, dynamic>> items,
    String? userId,
  }) async {
    final docRef = _col.doc();
    await _db.runTransaction((tx) async {
      final itemRefs = items.keys.map((id) => _itemsCol.doc(id)).toList();
      final snaps = await Future.wait(itemRefs.map((r) => tx.get(r)));

      final itemList = <Map<String, dynamic>>[];
      for (var i = 0; i < snaps.length; i++) {
        final snap = snaps[i];
        final id = itemRefs[i].id;
        final requested = items[id];
        if (!snap.exists) throw Exception('Item $id not found');
        final stock = (snap.data()?['qty'] ?? 0) as int;
        final reqQty = (requested?['qty'] ?? 0) as int;
        final currentName =
            snap.data()?['name'] as String? ?? requested?['name'];
        if (stock < reqQty) {
          throw Exception('Not enough stock for $currentName');
        }
        itemList.add({'itemId': id, 'name': currentName, 'qty': reqQty});
      }

      for (var i = 0; i < snaps.length; i++) {
        final snap = snaps[i];
        final id = itemRefs[i].id;
        final stock = (snap.data()?['qty'] ?? 0) as int;
        final reqQty = (items[id]?['qty'] ?? 0) as int;
        tx.update(itemRefs[i], {'qty': stock - reqQty});
      }

      final data = {
        'items': itemList,
        'createdAt': FieldValue.serverTimestamp(),
        'totalItems': itemList.fold<int>(0, (s, i) => s + (i['qty'] as int)),
        if (userId != null) 'userId': userId,
      };

      tx.set(docRef, data);
    });

    return docRef;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPurchases({
    String? userId,
  }) {
    final q = userId == null
        ? _col.orderBy('createdAt', descending: true)
        : _col
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true);
    return q.snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getPurchase(String id) async {
    return await _col.doc(id).get();
  }
}

final purchasesService = PurchasesService();

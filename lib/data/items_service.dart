import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

ValueNotifier<ItemsService> itemsService = ValueNotifier(ItemsService());

class ItemsService {
  final CollectionReference<Map<String, dynamic>> _col = FirebaseFirestore
      .instance
      .collection('items');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamItems() {
    return _col.orderBy('name').snapshots();
  }

  Future<bool> duplicateExists(
    String lowercaseName, {
    String? excludeId,
  }) async {
    final q = await _col.where('lowercaseName', isEqualTo: lowercaseName).get();
    if (excludeId != null) return q.docs.any((d) => d.id != excludeId);
    return q.docs.isNotEmpty;
  }

  Future<DocumentReference<Map<String, dynamic>>> addItem({
    required String name,
    required int qty,
  }) async {
    final data = {
      'name': name,
      'qty': qty,
      'lowercaseName': name.toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    return await _col.add(data);
  }

  Future<void> updateItem({
    required String id,
    required String name,
    required int qty,
  }) async {
    final data = {
      'name': name,
      'qty': qty,
      'lowercaseName': name.toLowerCase(),
    };
    await _col.doc(id).update(data);
  }

  Future<void> deleteItem({required String id}) async {
    await _col.doc(id).delete();
  }
}

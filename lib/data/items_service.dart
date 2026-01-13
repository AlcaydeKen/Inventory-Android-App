import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'logs_service.dart';

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
    final ref = await _col.add(data);
    try {
      await logsService.logEvent(
        text: 'Added item $name',
        meta: {'itemId': ref.id, 'name': name, 'qty': qty},
      );
    } catch (_) {}
    return ref;
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
    try {
      await logsService.logEvent(
        text: 'Updated item $name',
        meta: {'itemId': id, 'name': name, 'qty': qty},
      );
    } catch (_) {}
  }

  Future<void> deleteItem({required String id}) async {
    String? name;
    try {
      final snap = await _col.doc(id).get();
      name = snap.data()?['name'] as String?;
    } catch (_) {}
    await _col.doc(id).delete();
    try {
      await logsService.logEvent(
        text: 'Deleted item ${name ?? id}',
        meta: {'itemId': id, 'name': name},
      );
    } catch (_) {}
  }
}

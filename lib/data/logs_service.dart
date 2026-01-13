import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_service.dart';

class LogsService {
  final CollectionReference<Map<String, dynamic>> _col = FirebaseFirestore
      .instance
      .collection('logs');

  Future<void> logEvent({
    required String text,
    Map<String, dynamic>? meta,
  }) async {
    final uid = authService.value.currentUser?.uid;
    if (uid == null) return;
    final data = {
      'userId': uid,
      'timestamp': FieldValue.serverTimestamp(),
      'text': text,
      'meta': meta ?? {},
    };
    await _col.add(data);
  }
}

final logsService = LogsService();

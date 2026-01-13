import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/auth_service.dart';

class Logs extends StatelessWidget {
  const Logs({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.value.authStateChanges,
      builder: (context, authSnap) {
        final user = authSnap.data;
        if (user == null) {
          return const Center(child: Text('Please sign in to view logs'));
        }

        final stream = FirebaseFirestore.instance
            .collection('logs')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots();

        return Scaffold(
          appBar: AppBar(title: const Text('Logs')),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Center(child: Text('No logs'));
              }

              final docs = snap.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  final data = d.data();
                  final ts = data['timestamp'] as Timestamp?;
                  final text = data['text'] ?? data['message'] ?? '';
                  final date = ts != null
                      ? ts.toDate().toLocal().toString()
                      : '';
                  return ListTile(title: Text(text), subtitle: Text(date));
                },
              );
            },
          ),
        );
      },
    );
  }
}

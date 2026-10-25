import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerActionService {
  static Future<void> createRequest({
    required String action,
    required Map<String, Object?> details,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to submit this request.');
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('requests')
        .add({
          'action': action,
          'details': details,
          'status': 'submitted',
          'createdAt': FieldValue.serverTimestamp(),
        });
  }
}

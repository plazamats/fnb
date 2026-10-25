import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FnbActivity {
  const FnbActivity({
    required this.type,
    required this.title,
    required this.detail,
    required this.amount,
    required this.createdAt,
  });

  final String type;
  final String title;
  final String detail;
  final String amount;
  final DateTime createdAt;

  Map<String, Object> toMap() => {
    'type': type,
    'title': title,
    'detail': detail,
    'amount': amount,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory FnbActivity.fromMap(Map<String, dynamic> map) => FnbActivity(
    type: map['type'] as String? ?? 'activity',
    title: map['title'] as String? ?? 'Business activity',
    detail: map['detail'] as String? ?? '',
    amount: map['amount'] as String? ?? '',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}

class FnbDataService {
  static bool get isReady => Firebase.apps.isNotEmpty;

  static Stream<List<FnbActivity>> watchRecentActivity() {
    final user = FirebaseAuth.instance.currentUser;
    if (!isReady || user == null) return Stream.value(const []);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc('spaza')
        .collection('activity')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FnbActivity.fromMap(doc.data()))
              .toList(),
        );
  }

  static Future<void> recordStockAdded({
    required int itemCount,
    required String amount,
  }) async {
    await _recordActivity(
      FnbActivity(
        type: 'stock',
        title: 'Stock added from invoice',
        detail: 'Today • $itemCount items',
        amount: '+ $amount',
        createdAt: DateTime.now(),
      ),
      rtdbData: {'itemCount': itemCount, 'amount': amount},
    );
  }

  static Future<void> recordSale({
    required String detail,
    required String amount,
  }) async {
    await _recordActivity(
      FnbActivity(
        type: 'sale',
        title: 'Sale recorded by voice',
        detail: detail,
        amount: amount,
        createdAt: DateTime.now(),
      ),
      rtdbData: {'detail': detail, 'amount': amount},
    );
  }

  static Future<void> _recordActivity(
    FnbActivity activity, {
    required Map<String, Object> rtdbData,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (!isReady || user == null) {
      throw StateError('Sign in to save business activity.');
    }

    final firestoreActivity = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc('spaza')
        .collection('activity')
        .doc();
    final realtimeActivity = FirebaseDatabase.instance
        .ref('users/${user.uid}/businesses/spaza/activity')
        .push();

    await Future.wait([
      firestoreActivity.set(activity.toMap()),
      realtimeActivity.set({
        ...rtdbData,
        'type': activity.type,
        'title': activity.title,
        'createdAt': ServerValue.timestamp,
      }),
    ]);
  }
}

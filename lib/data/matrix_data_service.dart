import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatrixProduct {
  const MatrixProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.business,
    this.quantity = 0,
  });

  final String id;
  final String name;
  final double price;
  final String business;
  final int quantity;

  factory MatrixProduct.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return MatrixProduct(
      id: snapshot.id,
      name: data['name'] as String? ?? 'Unnamed product',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      business: data['business'] as String? ?? 'spaza',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, Object> toMap() => {
    'name': name,
    'price': price,
    'business': business,
    'quantity': quantity,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

class MatrixDataService {
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static User? get _user => FirebaseAuth.instance.currentUser;

  static bool get isSignedIn => _user != null;

  static CollectionReference<Map<String, dynamic>> _collection(
    String business,
  ) {
    final user = _user;
    if (user == null) {
      throw StateError('Sign in to manage your business records.');
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc(business)
        .collection('products');
  }

  static Stream<List<MatrixProduct>> watchProducts(String business) {
    final user = _user;
    if (user == null) return Stream.value(const []);
    return _collection(business)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(MatrixProduct.fromSnapshot).toList(),
        );
  }

  static Future<void> saveProduct({
    required String business,
    required String name,
    required double price,
    int quantity = 0,
  }) async {
    final products = _collection(business);
    final duplicate = await products
        .where('name', isEqualTo: name.trim())
        .limit(1)
        .get();
    if (duplicate.docs.isNotEmpty) {
      throw StateError('This product is already on the price list.');
    }
    await products.add(
      MatrixProduct(
        id: '',
        name: name.trim(),
        price: price,
        business: business,
        quantity: quantity,
      ).toMap(),
    );
  }

  static Future<void> updateProduct({
    required String business,
    required String id,
    required String name,
    required double price,
    required int quantity,
  }) async {
    await _collection(business).doc(id).update({
      'name': name.trim(),
      'price': price,
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> saveSelectedBusiness(String business) async {
    final user = _user;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set({
      'selectedBusiness': business,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> recordBusinessEvent({
    required String business,
    required String type,
    required Map<String, Object?> data,
  }) async {
    final user = _user;
    if (user == null) {
      throw StateError('Sign in to save this business event.');
    }
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc(business)
        .collection('events')
        .add({
          'type': type,
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }
}

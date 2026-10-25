import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/empties_model.dart';
import '../models/loan_model.dart';
import '../models/markdown_model.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';

class MatrixFirestoreService {
  static FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }
  static User? get _user {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance.currentUser;
  }

  // In-memory fallback caches initialized with starter data per Figma designs:
  static final List<MatrixProduct> _spazaProductsSeed = [
    const MatrixProduct(
      id: 'spaza_bread_1',
      name: 'Albany Superior Brown Bread 700g',
      price: 18.00,
      business: 'spaza',
      costPrice: 14.50,
      quantity: 24,
      category: 'Bakery',
    ),
    const MatrixProduct(
      id: 'spaza_milk_1',
      name: 'Clover Full Cream Fresh Milk 1L',
      price: 22.00,
      business: 'spaza',
      costPrice: 17.80,
      quantity: 18,
      category: 'Dairy',
    ),
    const MatrixProduct(
      id: 'spaza_sunlight_1',
      name: 'Sunlight Dishwashing Liquid 750ml',
      price: 24.50,
      business: 'spaza',
      costPrice: 19.00,
      quantity: 12,
      category: 'Household',
    ),
    const MatrixProduct(
      id: 'spaza_maize_1',
      name: 'White Star Super Maize Meal 2.5kg',
      price: 36.00,
      business: 'spaza',
      costPrice: 29.00,
      quantity: 30,
      category: 'Grains',
    ),
  ];

  static final List<MatrixProduct> _liquorProductsSeed = [
    const MatrixProduct(
      id: 'liq_blacklabel_1',
      name: 'Carling Black Label 6-pack (330ml)',
      price: 110.00,
      business: 'liquor',
      costPrice: 88.00,
      quantity: 45,
      category: 'Beer',
    ),
    const MatrixProduct(
      id: 'liq_savanna_1',
      name: 'Savanna Dry Cider 6-pack (330ml)',
      price: 135.00,
      business: 'liquor',
      costPrice: 108.00,
      quantity: 32,
      category: 'Cider',
    ),
    const MatrixProduct(
      id: 'liq_castle_1',
      name: 'Castle Lager 750ml Returnable Bottle',
      price: 25.00,
      business: 'liquor',
      costPrice: 19.50,
      quantity: 72,
      category: 'Returnable',
    ),
    const MatrixProduct(
      id: 'liq_amstel_1',
      name: 'Amstel Lager 6-pack (330ml)',
      price: 118.00,
      business: 'liquor',
      costPrice: 94.00,
      quantity: 26,
      category: 'Beer',
    ),
  ];

  static final List<MarkdownItem> _markdownSeed = [
    MarkdownItem(
      id: 'md_1',
      productName: 'Clover Milk 1L',
      reason: MarkdownReason.nearExpiry,
      originalPrice: 22.00,
      expiryDate: DateTime.now().add(const Duration(days: 1)),
      notes: 'Best before tomorrow morning',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    MarkdownItem(
      id: 'md_2',
      productName: 'Albany Brown Bread',
      reason: MarkdownReason.damaged,
      originalPrice: 18.00,
      notes: 'Squashed packaging during unloading',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static final List<MzansiTransaction> _transactionsSeed = [
    MzansiTransaction(
      id: 'tx_1',
      type: TransactionType.sale,
      business: 'spaza',
      amount: 90.00,
      description: 'Sale: 5 Eggs + 2 Loaves bread',
      source: 'voice',
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
    MzansiTransaction(
      id: 'tx_2',
      type: TransactionType.tillDraw,
      business: 'spaza',
      amount: 150.00,
      description: 'Family grocery till withdrawal',
      source: 'voice',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    MzansiTransaction(
      id: 'tx_3',
      type: TransactionType.stockArrival,
      business: 'spaza',
      amount: 1250.00,
      description: 'Wholesale Invoice Delivery: Bread & Milk',
      source: 'scanner',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  static LiquorEmptiesState _emptiesState = const LiquorEmptiesState();
  static LoanStatus _loanStatus = const LoanStatus();

  // Stream controllers for real-time reactivity in both online & fallback modes:
  static final _productControllers = <String, StreamController<List<MatrixProduct>>>{
    'spaza': StreamController<List<MatrixProduct>>.broadcast(),
    'liquor': StreamController<List<MatrixProduct>>.broadcast(),
  };

  static final _transactionController = StreamController<List<MzansiTransaction>>.broadcast();
  static final _markdownController = StreamController<List<MarkdownItem>>.broadcast();
  static final _emptiesController = StreamController<LiquorEmptiesState>.broadcast();
  static final _loanController = StreamController<LoanStatus>.broadcast();

  static void _initStreams() {
    _productControllers['spaza']?.add(List.unmodifiable(_spazaProductsSeed));
    _productControllers['liquor']?.add(List.unmodifiable(_liquorProductsSeed));
    _transactionController.add(List.unmodifiable(_transactionsSeed));
    _markdownController.add(List.unmodifiable(_markdownSeed));
    _emptiesController.add(_emptiesState);
    _loanController.add(_loanStatus);
  }

  static bool _initialized = false;
  static void ensureInitialized() {
    if (!_initialized) {
      _initialized = true;
      _initStreams();
    }
  }

  // --- PRODUCTS ---
  static Stream<List<MatrixProduct>> watchProducts(String business) {
    ensureInitialized();
    final user = _user;
    if (user != null && _firestore != null) {
      try {
        return _firestore!
            .collection('users')
            .doc(user.uid)
            .collection('businesses')
            .doc(business)
            .collection('products')
            .where('isArchived', isEqualTo: false)
            .snapshots()
            .map((snapshot) {
              if (snapshot.docs.isEmpty) {
                return business == 'spaza' ? _spazaProductsSeed : _liquorProductsSeed;
              }
              return snapshot.docs.map(MatrixProduct.fromSnapshot).toList();
            })
            .handleError((_) => business == 'spaza' ? _spazaProductsSeed : _liquorProductsSeed);
      } catch (_) {
        // Fallback below
      }
    }
    final currentList = business == 'spaza' ? _spazaProductsSeed : _liquorProductsSeed;
    final activeOnly = currentList.where((p) => !p.isArchived).toList();
    final controller = _productControllers[business];
    if (controller != null) {
      return Stream<List<MatrixProduct>>.multi((emitter) {
        emitter.add(activeOnly);
        final sub = controller.stream.listen(
          emitter.add,
          onError: emitter.addError,
          onDone: emitter.close,
        );
        emitter.onCancel = () => sub.cancel();
      });
    }
    return Stream.value(activeOnly);
  }

  static Future<void> saveProduct({
    required String business,
    required String name,
    required double price,
    double costPrice = 0.0,
    int quantity = 0,
    String? barcode,
    String category = 'General',
  }) async {
    ensureInitialized();
    final list = business == 'spaza' ? _spazaProductsSeed : _liquorProductsSeed;
    final exists = list.any((p) => !p.isArchived && p.name.trim().toLowerCase() == name.trim().toLowerCase());
    if (exists) {
      throw StateError('A product with the name "$name" already exists on this price list.');
    }

    final newProduct = MatrixProduct(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      price: price,
      business: business,
      costPrice: costPrice,
      quantity: quantity,
      barcode: barcode,
      category: category,
      updatedAt: DateTime.now(),
    );

    list.insert(0, newProduct);
    _productControllers[business]?.add(List.unmodifiable(list));

    final user = _user;
    if (user != null && _firestore != null) {
      try {
        await _firestore!
            .collection('users')
            .doc(user.uid)
            .collection('businesses')
            .doc(business)
            .collection('products')
            .doc(newProduct.id)
            .set(newProduct.toMap());
      } catch (_) {}
    }
  }

  static Future<void> updateProduct({
    required String business,
    required String id,
    required String name,
    required double price,
    required int quantity,
  }) async {
    ensureInitialized();
    final list = business == 'spaza' ? _spazaProductsSeed : _liquorProductsSeed;
    final idx = list.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final updated = list[idx].copyWith(
        name: name.trim(),
        price: price,
        quantity: quantity,
        updatedAt: DateTime.now(),
      );
      list[idx] = updated;
      _productControllers[business]?.add(List.unmodifiable(list));

      final user = _user;
      if (user != null && _firestore != null) {
        try {
          await _firestore!
              .collection('users')
              .doc(user.uid)
              .collection('businesses')
              .doc(business)
              .collection('products')
              .doc(id)
              .update(updated.toMap());
        } catch (_) {}
      }
    }
  }

  static Future<void> archiveProduct({
    required String business,
    required String id,
  }) async {
    ensureInitialized();
    final list = business == 'spaza' ? _spazaProductsSeed : _liquorProductsSeed;
    final idx = list.indexWhere((p) => p.id == id);
    if (idx != -1) {
      // Soft-delete to preserve historical sales records!
      list.removeAt(idx); // Remove from active visible list
      _productControllers[business]?.add(List.unmodifiable(list));

      final user = _user;
      if (user != null && _firestore != null) {
        try {
          await _firestore!
              .collection('users')
              .doc(user.uid)
              .collection('businesses')
              .doc(business)
              .collection('products')
              .doc(id)
              .update({'isArchived': true, 'archivedAt': FieldValue.serverTimestamp()});
        } catch (_) {}
      }
    }
  }

  // --- TRANSACTIONS ---
  static Stream<List<MzansiTransaction>> watchTransactions(String business) {
    ensureInitialized();
    return _transactionController.stream.map(
      (list) => list.where((t) => t.business == business).toList(),
    );
  }

  static List<MzansiTransaction> getSnapshotTransactions(String business) {
    ensureInitialized();
    return _transactionsSeed.where((t) => t.business == business).toList();
  }

  static Future<void> recordTransaction(MzansiTransaction tx) async {
    ensureInitialized();
    _transactionsSeed.insert(0, tx);
    _transactionController.add(List.unmodifiable(_transactionsSeed));

    final user = _user;
    if (user != null && _firestore != null) {
      try {
        await _firestore!
            .collection('users')
            .doc(user.uid)
            .collection('businesses')
            .doc(tx.business)
            .collection('transactions')
            .doc(tx.id)
            .set(tx.toMap());
      } catch (_) {}
    }
  }

  // --- MARKDOWNS ---
  static Stream<List<MarkdownItem>> watchMarkdowns() {
    ensureInitialized();
    return _markdownController.stream;
  }

  static Future<void> recordMarkdown(MarkdownItem item) async {
    ensureInitialized();
    _markdownSeed.insert(0, item);
    _markdownController.add(List.unmodifiable(_markdownSeed));

    final user = _user;
    if (user != null && _firestore != null) {
      try {
        await _firestore!
            .collection('users')
            .doc(user.uid)
            .collection('businesses')
            .doc('spaza')
            .collection('markdowns')
            .doc(item.id)
            .set(item.toMap());
      } catch (_) {}
    }
  }

  static Future<void> approveMarkdownPrice(String id, double discountPrice) async {
    ensureInitialized();
    final idx = _markdownSeed.indexWhere((m) => m.id == id);
    if (idx != -1) {
      final current = _markdownSeed[idx];
      final updated = MarkdownItem(
        id: current.id,
        productName: current.productName,
        reason: current.reason,
        originalPrice: current.originalPrice,
        approvedDiscountPrice: discountPrice,
        expiryDate: current.expiryDate,
        notes: current.notes,
        status: 'discount_approved',
        createdAt: current.createdAt,
      );
      _markdownSeed[idx] = updated;
      _markdownController.add(List.unmodifiable(_markdownSeed));
    }
  }

  // --- EMPTIES ---
  static Stream<LiquorEmptiesState> watchEmpties() {
    ensureInitialized();
    return _emptiesController.stream;
  }

  static Future<void> updateEmpties(LiquorEmptiesState state) async {
    ensureInitialized();
    _emptiesState = state.copyWith(lastUpdated: DateTime.now());
    _emptiesController.add(_emptiesState);

    final user = _user;
    if (user != null && _firestore != null) {
      try {
        await _firestore!
            .collection('users')
            .doc(user.uid)
            .collection('businesses')
            .doc('liquor')
            .collection('empties')
            .doc('state')
            .set(_emptiesState.toMap());
      } catch (_) {}
    }
  }

  // --- LOAN ---
  static Stream<LoanStatus> watchLoanStatus() {
    ensureInitialized();
    return _loanController.stream;
  }

  static Future<void> advanceLoanStep(int nextStep) async {
    ensureInitialized();
    _loanStatus = _loanStatus.copyWith(
      currentStep: nextStep,
      isApproved: nextStep >= 2,
      isDisbursed: nextStep >= 3,
    );
    _loanController.add(_loanStatus);
  }
}

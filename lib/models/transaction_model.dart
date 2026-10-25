import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  sale,
  expense,
  stockArrival,
  tillDraw;

  String get label => switch (this) {
    TransactionType.sale => 'Sale',
    TransactionType.expense => 'Shop Expense',
    TransactionType.stockArrival => 'Stock Delivery',
    TransactionType.tillDraw => 'Family Till Draw',
  };

  bool get isRevenue => this == TransactionType.sale;
  bool get isShopCost => this == TransactionType.expense || this == TransactionType.stockArrival;
  bool get isFamilyCost => this == TransactionType.tillDraw;
}

class MzansiTransaction {
  const MzansiTransaction({
    required this.id,
    required this.type,
    required this.business,
    required this.amount,
    required this.description,
    this.productName,
    this.quantity = 1,
    this.source = 'manual', // 'voice', 'scanner', 'manual'
    this.languageCode = 'en',
    this.rawTranscript,
    required this.timestamp,
  });

  final String id;
  final TransactionType type;
  final String business; // 'spaza' or 'liquor'
  final double amount;
  final String description;
  final String? productName;
  final int quantity;
  final String source;
  final String languageCode;
  final String? rawTranscript;
  final DateTime timestamp;

  factory MzansiTransaction.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final typeStr = data['type'] as String? ?? 'sale';
    final type = switch (typeStr) {
      'expense' => TransactionType.expense,
      'stockArrival' || 'stock' => TransactionType.stockArrival,
      'tillDraw' || 'draw' => TransactionType.tillDraw,
      _ => TransactionType.sale,
    };

    return MzansiTransaction(
      id: doc.id,
      type: type,
      business: data['business'] as String? ?? 'spaza',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] as String? ?? '',
      productName: data['productName'] as String?,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      source: data['source'] as String? ?? 'manual',
      languageCode: data['languageCode'] as String? ?? 'en',
      rawTranscript: data['rawTranscript'] as String?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
    'type': type.name,
    'business': business,
    'amount': amount,
    'description': description,
    'productName': productName,
    'quantity': quantity,
    'source': source,
    'languageCode': languageCode,
    'rawTranscript': rawTranscript,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}

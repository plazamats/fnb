import 'package:cloud_firestore/cloud_firestore.dart';

class MatrixProduct {
  const MatrixProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.business,
    this.costPrice = 0.0,
    this.quantity = 0,
    this.barcode,
    this.category = 'General',
    this.isArchived = false,
    this.updatedAt,
  });

  final String id;
  final String name;
  final double price;
  final String business; // 'spaza' or 'liquor'
  final double costPrice;
  final int quantity;
  final String? barcode;
  final String category;
  final bool isArchived;
  final DateTime? updatedAt;

  MatrixProduct copyWith({
    String? id,
    String? name,
    double? price,
    String? business,
    double? costPrice,
    int? quantity,
    String? barcode,
    String? category,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return MatrixProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      business: business ?? this.business,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      isArchived: isArchived ?? this.isArchived,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory MatrixProduct.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return MatrixProduct(
      id: snapshot.id,
      name: data['name'] as String? ?? 'Unnamed product',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      business: data['business'] as String? ?? 'spaza',
      costPrice: (data['costPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      barcode: data['barcode'] as String?,
      category: data['category'] as String? ?? 'General',
      isArchived: data['isArchived'] as bool? ?? false,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, Object?> toMap() => {
    'name': name,
    'price': price,
    'business': business,
    'costPrice': costPrice,
    'quantity': quantity,
    'barcode': barcode,
    'category': category,
    'isArchived': isArchived,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

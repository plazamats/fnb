import 'package:cloud_firestore/cloud_firestore.dart';

enum MarkdownReason {
  nearExpiry('Near expiry'),
  broken('Broken'),
  damaged('Damaged');

  const MarkdownReason(this.label);
  final String label;
}

class MarkdownItem {
  const MarkdownItem({
    required this.id,
    required this.productName,
    required this.reason,
    required this.originalPrice,
    this.approvedDiscountPrice,
    this.expiryDate,
    this.notes = '',
    this.status = 'flagged', // 'flagged', 'discount_approved', 'discarded'
    required this.createdAt,
  });

  final String id;
  final String productName;
  final MarkdownReason reason;
  final double originalPrice;
  final double? approvedDiscountPrice;
  final DateTime? expiryDate;
  final String notes;
  final String status;
  final DateTime createdAt;

  factory MarkdownItem.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    final reasonStr = data['reason'] as String? ?? 'nearExpiry';
    final reason = switch (reasonStr) {
      'broken' => MarkdownReason.broken,
      'damaged' => MarkdownReason.damaged,
      _ => MarkdownReason.nearExpiry,
    };

    return MarkdownItem(
      id: snapshot.id,
      productName: data['productName'] as String? ?? 'Item',
      reason: reason,
      originalPrice: (data['originalPrice'] as num?)?.toDouble() ?? 0.0,
      approvedDiscountPrice: (data['approvedDiscountPrice'] as num?)?.toDouble(),
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
      notes: data['notes'] as String? ?? '',
      status: data['status'] as String? ?? 'flagged',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
    'productName': productName,
    'reason': reason.name,
    'originalPrice': originalPrice,
    'approvedDiscountPrice': approvedDiscountPrice,
    'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
    'notes': notes,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

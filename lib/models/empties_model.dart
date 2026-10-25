import 'package:cloud_firestore/cloud_firestore.dart';

class LiquorEmptiesState {
  const LiquorEmptiesState({
    this.sabCratesInStock = 14,
    this.sabCratesReturned = 8,
    this.heinekenCratesInStock = 9,
    this.heinekenCratesReturned = 5,
    this.customerBottlesOut = 28,
    this.customerBottlesReturned = 19,
    this.lastUpdated,
  });

  final int sabCratesInStock;
  final int sabCratesReturned;
  final int heinekenCratesInStock;
  final int heinekenCratesReturned;
  final int customerBottlesOut;
  final int customerBottlesReturned;
  final DateTime? lastUpdated;

  LiquorEmptiesState copyWith({
    int? sabCratesInStock,
    int? sabCratesReturned,
    int? heinekenCratesInStock,
    int? heinekenCratesReturned,
    int? customerBottlesOut,
    int? customerBottlesReturned,
    DateTime? lastUpdated,
  }) {
    return LiquorEmptiesState(
      sabCratesInStock: sabCratesInStock ?? this.sabCratesInStock,
      sabCratesReturned: sabCratesReturned ?? this.sabCratesReturned,
      heinekenCratesInStock: heinekenCratesInStock ?? this.heinekenCratesInStock,
      heinekenCratesReturned: heinekenCratesReturned ?? this.heinekenCratesReturned,
      customerBottlesOut: customerBottlesOut ?? this.customerBottlesOut,
      customerBottlesReturned: customerBottlesReturned ?? this.customerBottlesReturned,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory LiquorEmptiesState.fromMap(Map<String, dynamic> data) {
    return LiquorEmptiesState(
      sabCratesInStock: (data['sabCratesInStock'] as num?)?.toInt() ?? 14,
      sabCratesReturned: (data['sabCratesReturned'] as num?)?.toInt() ?? 8,
      heinekenCratesInStock: (data['heinekenCratesInStock'] as num?)?.toInt() ?? 9,
      heinekenCratesReturned: (data['heinekenCratesReturned'] as num?)?.toInt() ?? 5,
      customerBottlesOut: (data['customerBottlesOut'] as num?)?.toInt() ?? 28,
      customerBottlesReturned: (data['customerBottlesReturned'] as num?)?.toInt() ?? 19,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, Object?> toMap() => {
    'sabCratesInStock': sabCratesInStock,
    'sabCratesReturned': sabCratesReturned,
    'heinekenCratesInStock': heinekenCratesInStock,
    'heinekenCratesReturned': heinekenCratesReturned,
    'customerBottlesOut': customerBottlesOut,
    'customerBottlesReturned': customerBottlesReturned,
    'lastUpdated': FieldValue.serverTimestamp(),
  };
}

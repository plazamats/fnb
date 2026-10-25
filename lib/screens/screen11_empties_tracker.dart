import 'package:flutter/material.dart';
import '../models/empties_model.dart';
import '../services/matrix_firestore_service.dart';
import '../widgets/fnb_brand_header.dart';

class Screen11EmptiesTracker extends StatelessWidget {
  const Screen11EmptiesTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FnbBrandHeader(
        title: 'Liquor Empties Tracker',
        subtitle: 'Crates & Returnable Bottle Auditing',
      ),
      body: StreamBuilder<LiquorEmptiesState>(
        stream: MatrixFirestoreService.watchEmpties(),
        builder: (context, snapshot) {
          final state = snapshot.data ?? const LiquorEmptiesState();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: fnbPaleTeal,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xff8ce1e5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.recycling, color: fnbTeal, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deposit & Crate Reconciliation',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: fnbDark),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Supplier categories remain separate to prevent duplicate counting and reconcile wholesaler crate deposits accurately.',
                            style: TextStyle(fontSize: 10, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // SAB Crates Card
              _SupplierCrateCard(
                brand: 'SAB (South African Breweries)',
                brandColor: const Color(0xffa81d22),
                icon: Icons.inventory_2_outlined,
                cratesInStock: state.sabCratesInStock,
                cratesReturned: state.sabCratesReturned,
                onStockDelta: (delta) {
                  final newStock = (state.sabCratesInStock + delta).clamp(0, 9999);
                  MatrixFirestoreService.updateEmpties(state.copyWith(sabCratesInStock: newStock));
                },
                onReturnedDelta: (delta) {
                  final newRet = (state.sabCratesReturned + delta).clamp(0, 9999);
                  MatrixFirestoreService.updateEmpties(state.copyWith(sabCratesReturned: newRet));
                },
              ),
              const SizedBox(height: 14),

              // Heineken Crates Card
              _SupplierCrateCard(
                brand: 'Heineken Beverages',
                brandColor: const Color(0xff007a33),
                icon: Icons.inventory_2_outlined,
                cratesInStock: state.heinekenCratesInStock,
                cratesReturned: state.heinekenCratesReturned,
                onStockDelta: (delta) {
                  final newStock = (state.heinekenCratesInStock + delta).clamp(0, 9999);
                  MatrixFirestoreService.updateEmpties(state.copyWith(heinekenCratesInStock: newStock));
                },
                onReturnedDelta: (delta) {
                  final newRet = (state.heinekenCratesReturned + delta).clamp(0, 9999);
                  MatrixFirestoreService.updateEmpties(state.copyWith(heinekenCratesReturned: newRet));
                },
              ),
              const SizedBox(height: 14),

              // Customer Bottle Circulation Card
              Card(
                elevation: 0,
                color: fnbSoft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xffe2eeee)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.people_outline, color: fnbTeal),
                          SizedBox(width: 8),
                          Text(
                            'Customer Bottle Circulation',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: fnbDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _CounterRow(
                        label: 'Bottles taken home by customers',
                        count: state.customerBottlesOut,
                        onChanged: (delta) {
                          final newVal = (state.customerBottlesOut + delta).clamp(0, 9999);
                          MatrixFirestoreService.updateEmpties(state.copyWith(customerBottlesOut: newVal));
                        },
                      ),
                      const Divider(height: 20),
                      _CounterRow(
                        label: 'Bottles returned by customers',
                        count: state.customerBottlesReturned,
                        onChanged: (delta) {
                          final newVal = (state.customerBottlesReturned + delta).clamp(0, 9999);
                          MatrixFirestoreService.updateEmpties(state.copyWith(customerBottlesReturned: newVal));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SupplierCrateCard extends StatelessWidget {
  const _SupplierCrateCard({
    required this.brand,
    required this.brandColor,
    required this.icon,
    required this.cratesInStock,
    required this.cratesReturned,
    required this.onStockDelta,
    required this.onReturnedDelta,
  });

  final String brand;
  final Color brandColor;
  final IconData icon;
  final int cratesInStock;
  final int cratesReturned;
  final ValueChanged<int> onStockDelta;
  final ValueChanged<int> onReturnedDelta;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: fnbSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xffe2eeee)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: brandColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  brand,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: fnbDark),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _CounterRow(
              label: 'Full/Empty Crates in Store',
              count: cratesInStock,
              onChanged: onStockDelta,
            ),
            const Divider(height: 20),
            _CounterRow(
              label: 'Crates Returned to Distributor',
              count: cratesReturned,
              onChanged: onReturnedDelta,
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.count,
    required this.onChanged,
  });

  final String label;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 12, color: fnbDark)),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.black45, size: 20),
          onPressed: () => onChanged(-1),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 36, minHeight: 28),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xffd5e5e5)),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: fnbTeal),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: fnbTeal, size: 20),
          onPressed: () => onChanged(1),
        ),
      ],
    );
  }
}

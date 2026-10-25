import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/matrix_firestore_service.dart';
import '../widgets/fnb_brand_header.dart';
import 'screen15_liquor_price_list.dart';

class Screen09ScannedLiquor extends StatefulWidget {
  const Screen09ScannedLiquor({super.key});

  @override
  State<Screen09ScannedLiquor> createState() => _Screen09ScannedLiquorState();
}

class _Screen09ScannedLiquorState extends State<Screen09ScannedLiquor> {
  bool _isSaving = false;

  // Extracted Liquor products from camera/barcode scan
  final List<MatrixProduct> _scannedLiquorItems = [
    const MatrixProduct(
      id: 'scan_liq_1',
      name: 'Carling Black Label 750ml Returnable Bottle',
      price: 26.00,
      costPrice: 20.00,
      quantity: 48,
      business: 'liquor',
      category: 'Returnable',
      barcode: '6001002011111',
    ),
    const MatrixProduct(
      id: 'scan_liq_2',
      name: 'Savanna Dry Cider 500ml Can',
      price: 34.00,
      costPrice: 27.50,
      quantity: 24,
      business: 'liquor',
      category: 'Cider',
      barcode: '6001002022222',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FnbBrandHeader(
        title: 'Scanned Liquor Items',
        subtitle: 'Review & Save to Liquor Catalogue',
      ),
      body: ListView(
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
                Icon(Icons.local_bar_outlined, color: fnbTeal),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Scanned beverage items identified. Per regulatory isolation requirements, items are saved to your dedicated Liquor Price List.',
                    style: TextStyle(fontSize: 11, color: fnbDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'EXTRACTED BEVERAGES (2)',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fnbTeal, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),

          for (int i = 0; i < _scannedLiquorItems.length; i++) ...[
            _ScannedLiquorCard(product: _scannedLiquorItems[i]),
            const SizedBox(height: 10),
          ],

          const SizedBox(height: 24),

          // Confirm and Save to All Price List Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: fnbTeal),
              onPressed: _isSaving ? null : _confirmAndSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _isSaving ? 'Validating...' : 'Confirm and Save to All Price List',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndSave() async {
    setState(() => _isSaving = true);
    int savedCount = 0;
    List<String> errors = [];

    for (final item in _scannedLiquorItems) {
      try {
        await MatrixFirestoreService.saveProduct(
          business: 'liquor',
          name: item.name,
          price: item.price,
          costPrice: item.costPrice,
          quantity: item.quantity,
          barcode: item.barcode,
          category: item.category,
        );
        savedCount++;
      } on StateError catch (e) {
        errors.add(e.message);
      } catch (e) {
        errors.add('Failed to save ${item.name}');
      }
    }

    setState(() => _isSaving = false);
    if (!mounted) return;

    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Validation Notice'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saved $savedCount item(s) to Liquor Price List.'),
              const SizedBox(height: 8),
              ...errors.map((e) => Text('• $e', style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const Screen15LiquorPriceList()),
                );
              },
              child: const Text('View Price List'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully added $savedCount items to Liquor Price List.'),
          backgroundColor: fnbTeal,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Screen15LiquorPriceList()),
      );
    }
  }
}

class _ScannedLiquorCard extends StatelessWidget {
  const _ScannedLiquorCard({required this.product});

  final MatrixProduct product;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: fnbSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xffe2eeee)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.sports_bar_outlined, color: fnbTeal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: fnbDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Barcode: ${product.barcode} • Type: ${product.category}',
                        style: const TextStyle(fontSize: 10, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cost: R ${product.costPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
                Text('Qty: ${product.quantity} units', style: const TextStyle(fontSize: 11)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: fnbTeal),
                  ),
                  child: Text(
                    'R ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: fnbTeal, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

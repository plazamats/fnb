import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/matrix_firestore_service.dart';
import '../widgets/fnb_brand_header.dart';
import 'screen14_spaza_price_list.dart';

class Screen08ScannedSpaza extends StatefulWidget {
  const Screen08ScannedSpaza({super.key});

  @override
  State<Screen08ScannedSpaza> createState() => _Screen08ScannedSpazaState();
}

class _Screen08ScannedSpazaState extends State<Screen08ScannedSpaza> {
  bool _isSaving = false;

  // Extracted Spaza products from camera/barcode scan
  final List<MatrixProduct> _scannedItems = [
    const MatrixProduct(
      id: 'scan_spaza_1',
      name: 'Albany Superior White Bread 700g',
      price: 19.50,
      costPrice: 15.00,
      quantity: 20,
      business: 'spaza',
      category: 'Bakery',
      barcode: '6001001012345',
    ),
    const MatrixProduct(
      id: 'scan_spaza_2',
      name: 'Danone Ultra Mel Vanilla Custard 1L',
      price: 32.00,
      costPrice: 25.50,
      quantity: 12,
      business: 'spaza',
      category: 'Dairy',
      barcode: '6001001098765',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FnbBrandHeader(
        title: 'Scanned Spaza Items',
        subtitle: 'Review & Save to Price List',
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
                Icon(Icons.inventory_2_outlined, color: fnbTeal),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Extracted products from camera scan. Validate prices and quantities before saving to your Spaza price list.',
                    style: TextStyle(fontSize: 11, color: fnbDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'EXTRACTED PRODUCTS (2)',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fnbTeal, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),

          for (int i = 0; i < _scannedItems.length; i++) ...[
            _ScannedProductCard(
              product: _scannedItems[i],
              onPriceChanged: (newPrice) {
                setState(() {
                  _scannedItems[i] = _scannedItems[i].copyWith(price: newPrice);
                });
              },
            ),
            const SizedBox(height: 10),
          ],

          const SizedBox(height: 24),

          // Confirm and Save to Price List Button
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
                _isSaving ? 'Saving to Price List...' : 'Confirm and Save to Price List',
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

    for (final item in _scannedItems) {
      try {
        await MatrixFirestoreService.saveProduct(
          business: 'spaza',
          name: item.name,
          price: item.price,
          costPrice: item.costPrice,
          quantity: item.quantity,
          barcode: item.barcode,
          category: item.category,
        );
        savedCount++;
      } on StateError catch (e) {
        // Duplicate detection
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
              Text('Saved $savedCount item(s) to Price List.'),
              const SizedBox(height: 8),
              ...errors.map((e) => Text('• $e', style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const Screen14SpazaPriceList()),
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
          content: Text('Successfully added $savedCount products to Spaza Shop Price List.'),
          backgroundColor: fnbTeal,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Screen14SpazaPriceList()),
      );
    }
  }
}

class _ScannedProductCard extends StatelessWidget {
  const _ScannedProductCard({
    required this.product,
    required this.onPriceChanged,
  });

  final MatrixProduct product;
  final ValueChanged<double> onPriceChanged;

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
                  child: const Icon(Icons.shopping_basket_outlined, color: fnbTeal),
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
                        'Barcode: ${product.barcode} • Cat: ${product.category}',
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
                Text('Cost Price: R ${product.costPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
                Text('Qty: ${product.quantity} units', style: const TextStyle(fontSize: 11)),
                Row(
                  children: [
                    const Text('Selling: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
          ],
        ),
      ),
    );
  }
}

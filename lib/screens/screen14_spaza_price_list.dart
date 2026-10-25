import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/matrix_firestore_service.dart';
import '../widgets/fnb_brand_header.dart';
import 'screen08_scanned_spaza.dart';

class Screen14SpazaPriceList extends StatefulWidget {
  const Screen14SpazaPriceList({super.key});

  @override
  State<Screen14SpazaPriceList> createState() => _Screen14SpazaPriceListState();
}

class _Screen14SpazaPriceListState extends State<Screen14SpazaPriceList> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: fnbDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spaza Shop Price List', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fnbDark)),
            Text('Daily Essentials & Groceries', style: TextStyle(fontSize: 10, color: fnbTeal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: fnbTeal),
            tooltip: 'Add Product',
            onPressed: () => _showAddProductDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: fnbDark),
            tooltip: 'Scan Item to Price List',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const Screen08ScannedSpaza()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xffe2eeee), height: 1),
        ),
      ),
      body: StreamBuilder<List<MatrixProduct>>(
        stream: MatrixFirestoreService.watchProducts('spaza'),
        builder: (context, snapshot) {
          final allProducts = snapshot.data ?? [];
          final filtered = allProducts.where((p) {
            if (_filter.isEmpty) return true;
            return p.name.toLowerCase().contains(_filter.toLowerCase()) ||
                p.category.toLowerCase().contains(_filter.toLowerCase());
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Search Bar
              TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _filter = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search products or categories (e.g. Bread, Milk)',
                  hintStyle: const TextStyle(fontSize: 11),
                  prefixIcon: const Icon(Icons.search, size: 18, color: fnbTeal),
                  suffixIcon: _filter.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _filter = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: fnbSoft,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffe2eeee)),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Products (${filtered.length})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fnbDark),
                  ),
                  const Text(
                    'Removing products preserves sales history',
                    style: TextStyle(fontSize: 9, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('No products found matching your search.'),
                  ),
                )
              else
                for (final item in filtered) ...[
                  _PriceListCard(
                    product: item,
                    onEdit: () => _showEditProductDialog(context, item),
                    onDelete: () => _confirmArchive(context, item),
                  ),
                  const SizedBox(height: 8),
                ],
            ],
          );
        },
      ),
    );
  }

  static Future<void> _showAddProductDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'General');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Spaza Product'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Product Name (e.g. Albany Bread)'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                ),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Selling Price (ZAR)', prefixText: 'R '),
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Valid price required' : null,
                ),
                TextFormField(
                  controller: costCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Cost Price (ZAR)', prefixText: 'R '),
                ),
                TextFormField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock Quantity'),
                ),
                TextFormField(
                  controller: catCtrl,
                  decoration: const InputDecoration(labelText: 'Category (Bakery, Dairy, etc.)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: fnbTeal),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Save to Spaza List'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await MatrixFirestoreService.saveProduct(
          business: 'spaza',
          name: nameCtrl.text.trim(),
          price: double.parse(priceCtrl.text.trim()),
          costPrice: double.tryParse(costCtrl.text.trim()) ?? 0.0,
          quantity: int.tryParse(qtyCtrl.text.trim()) ?? 0,
          category: catCtrl.text.trim().isEmpty ? 'General' : catCtrl.text.trim(),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added to Spaza Price List.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  static Future<void> _showEditProductDialog(BuildContext context, MatrixProduct product) async {
    final nameCtrl = TextEditingController(text: product.name);
    final priceCtrl = TextEditingController(text: product.price.toStringAsFixed(2));
    final qtyCtrl = TextEditingController(text: product.quantity.toString());
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Spaza Product'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Selling Price (ZAR)', prefixText: 'R '),
                validator: (v) => double.tryParse(v ?? '') == null ? 'Valid price required' : null,
              ),
              TextFormField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock Units'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: fnbTeal),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await MatrixFirestoreService.updateProduct(
        business: 'spaza',
        id: product.id,
        name: nameCtrl.text.trim(),
        price: double.parse(priceCtrl.text.trim()),
        quantity: int.tryParse(qtyCtrl.text.trim()) ?? product.quantity,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated.')),
        );
      }
    }
  }

  static Future<void> _confirmArchive(BuildContext context, MatrixProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from Active Price List?'),
        content: Text(
          'Remove "${product.name}"? '
          'Historical sales records will remain preserved and will not be affected.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove Product'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await MatrixFirestoreService.archiveProduct(business: 'spaza', id: product.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product removed from active list (historical data kept safe).')),
        );
      }
    }
  }
}

class _PriceListCard extends StatelessWidget {
  const _PriceListCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final MatrixProduct product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: fnbSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xffe2eeee)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.inventory_2_outlined, color: fnbTeal),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fnbDark),
        ),
        subtitle: Text(
          'Category: ${product.category} • In Stock: ${product.quantity}',
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'R ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: fnbTeal,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: fnbDark),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

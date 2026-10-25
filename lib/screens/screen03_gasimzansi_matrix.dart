import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/shop_type.dart';
import '../services/app_state.dart';
import '../services/matrix_firestore_service.dart';
import '../widgets/fnb_brand_header.dart';
import 'screen04_choose_shop.dart';
import 'screen14_spaza_price_list.dart';
import 'screen15_liquor_price_list.dart';

class Screen03GasiMzansiMatrix extends StatelessWidget {
  const Screen03GasiMzansiMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    final state = MzansiAppState.of(context);
    final isSpaza = state.activeShop == ShopType.spaza;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: fnbDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GasiMzansi Matrix',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fnbDark),
            ),
            Text(
              state.activeShop.label,
              style: const TextStyle(fontSize: 10, color: fnbTeal, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          // Price list icon opens associated business price list
          IconButton(
            icon: const Icon(Icons.receipt_long, color: fnbTeal),
            tooltip: 'Open Price List',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => isSpaza
                      ? const Screen14SpazaPriceList()
                      : const Screen15LiquorPriceList(),
                ),
              );
            },
          ),
          // Switch Shop
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: fnbDark),
            tooltip: 'Switch Shop',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const Screen04ChooseShop()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xffe2eeee), height: 1),
        ),
      ),
      body: StreamBuilder<List<MatrixProduct>>(
        stream: MatrixFirestoreService.watchProducts(state.activeShop.id),
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: fnbPaleTeal,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xff8ce1e5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.storefront, color: fnbTeal, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${state.activeShop.shortLabel} Matrix View',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: fnbDark,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'Add, edit, or remove products below. Removing a product preserves historical sales.',
                                    style: TextStyle(fontSize: 10, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Catalogue (${products.length})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: fnbDark,
                            ),
                          ),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: fnbTeal,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Product', style: TextStyle(fontSize: 11)),
                            onPressed: () => _showAddProductDialog(context, state.activeShop.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (products.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('No active products. Tap "+ Add Product" to create one.'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xffe5eeee)),
                          ),
                          color: fnbSoft,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isSpaza ? Icons.inventory_2_outlined : Icons.local_bar_outlined,
                                color: fnbTeal,
                              ),
                            ),
                            title: Text(
                              product.name,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Stock: ${product.quantity} • Cost: R ${product.costPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'R ${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: fnbTeal,
                                    fontSize: 13,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: fnbDark),
                                  onPressed: () => _showEditProductDialog(context, product),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                  tooltip: 'Remove from active price list (preserves history)',
                                  onPressed: () => _confirmArchive(context, product),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static Future<void> _showAddProductDialog(BuildContext context, String businessId) async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Product'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              TextFormField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Selling Price (ZAR)', prefixText: 'R '),
                validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid price' : null,
              ),
              TextFormField(
                controller: costCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cost Price (Optional)', prefixText: 'R '),
              ),
              TextFormField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Initial Stock Quantity'),
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
            child: const Text('Save to Matrix'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await MatrixFirestoreService.saveProduct(
          business: businessId,
          name: nameCtrl.text.trim(),
          price: double.parse(priceCtrl.text.trim()),
          costPrice: double.tryParse(costCtrl.text.trim()) ?? 0.0,
          quantity: int.tryParse(qtyCtrl.text.trim()) ?? 0,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added to Matrix and synced to Firebase.')),
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
        title: const Text('Edit Product & Price'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              TextFormField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Selling Price (ZAR)', prefixText: 'R '),
                validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid price' : null,
              ),
              TextFormField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
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
        business: product.business,
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
        title: const Text('Remove from Active List?'),
        content: Text(
          'Are you sure you want to remove "${product.name}"? '
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
      await MatrixFirestoreService.archiveProduct(business: product.business, id: product.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product removed from active list (historical data kept safe).')),
        );
      }
    }
  }
}

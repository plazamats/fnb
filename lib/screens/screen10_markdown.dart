import 'package:flutter/material.dart';
import '../models/markdown_model.dart';
import '../services/matrix_firestore_service.dart';
import '../widgets/fnb_brand_header.dart';

class Screen10Markdown extends StatelessWidget {
  const Screen10Markdown({super.key});

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
            Text('Markdown Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fnbDark)),
            Text('Spaza Shop Stock Management', style: TextStyle(fontSize: 10, color: fnbTeal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_outlined, color: fnbTeal),
            tooltip: 'Flag Item for Markdown',
            onPressed: () => _showFlagItemDialog(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xffe2eeee), height: 1),
        ),
      ),
      body: StreamBuilder<List<MarkdownItem>>(
        stream: MatrixFirestoreService.watchMarkdowns(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xfffff8e1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xffffe082)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_outlined, color: Color(0xfff57f17), size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Items Needing Attention',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: fnbDark),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Review the flagged reason before applying any markdown. Per business policy, no discount is applied automatically.',
                            style: TextStyle(fontSize: 10, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Flagged Inventory (${items.length})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: fnbDark),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: fnbTeal,
                      side: const BorderSide(color: fnbTeal),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    icon: const Icon(Icons.flag_outlined, size: 14),
                    label: const Text('Flag New Item', style: TextStyle(fontSize: 10)),
                    onPressed: () => _showFlagItemDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('No items currently flagged for markdown.'),
                  ),
                )
              else
                for (final item in items) ...[
                  _MarkdownCard(item: item),
                  const SizedBox(height: 10),
                ],
            ],
          );
        },
      ),
    );
  }

  static Future<void> _showFlagItemDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    MarkdownReason reason = MarkdownReason.nearExpiry;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Flag Item for Markdown'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<MarkdownReason>(
                initialValue: reason,
                decoration: const InputDecoration(labelText: 'Flag Reason'),
                items: MarkdownReason.values.map((r) {
                  return DropdownMenuItem(value: r, child: Text(r.label));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => reason = v);
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Original Price (ZAR)', prefixText: 'R '),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes / Expiry details'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: fnbTeal),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Flag Item'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      final newItem = MarkdownItem(
        id: 'md_${DateTime.now().millisecondsSinceEpoch}',
        productName: nameCtrl.text.trim().isEmpty ? 'Flagged Item' : nameCtrl.text.trim(),
        reason: reason,
        originalPrice: double.tryParse(priceCtrl.text.trim()) ?? 20.0,
        notes: notesCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      await MatrixFirestoreService.recordMarkdown(newItem);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item flagged and recorded in markdown tracker.')),
        );
      }
    }
  }
}

class _MarkdownCard extends StatelessWidget {
  const _MarkdownCard({required this.item});

  final MarkdownItem item;

  @override
  Widget build(BuildContext context) {
    final isDiscounted = item.status == 'discount_approved';

    return Card(
      elevation: 0,
      color: fnbSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isDiscounted ? fnbTeal : const Color(0xffe2eeee),
          width: isDiscounted ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.reason == MarkdownReason.nearExpiry
                      ? Icons.access_time_filled_outlined
                      : Icons.warning_amber_rounded,
                  color: item.reason == MarkdownReason.nearExpiry ? Colors.orange : Colors.redAccent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: fnbDark),
                      ),
                      Text(
                        'Reason: ${item.reason.label} • ${item.notes.isEmpty ? 'Inspected' : item.notes}',
                        style: const TextStyle(fontSize: 10, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDiscounted ? fnbPaleTeal : const Color(0xffffeedb),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isDiscounted ? 'Discount Approved' : 'Pending Review',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isDiscounted ? fnbTeal : const Color(0xffc26100),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Original: R ${item.originalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
                if (isDiscounted && item.approvedDiscountPrice != null)
                  Text(
                    'Markdown Price: R ${item.approvedDiscountPrice!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: fnbTeal,
                    ),
                  )
                else
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: const Size(60, 26),
                      foregroundColor: fnbTeal,
                    ),
                    onPressed: () => _approveDiscount(context, item),
                    child: const Text('Approve Discount', style: TextStyle(fontSize: 10)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _approveDiscount(BuildContext context, MarkdownItem item) async {
    final discountCtrl = TextEditingController(
      text: (item.originalPrice * 0.75).toStringAsFixed(2), // 25% suggested
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Markdown Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${item.productName}'),
            Text('Original Price: R ${item.originalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            TextFormField(
              controller: discountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Approved Markdown Price (ZAR)', prefixText: 'R '),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: fnbTeal),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Price'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final price = double.tryParse(discountCtrl.text.trim()) ?? (item.originalPrice * 0.75);
      await MatrixFirestoreService.approveMarkdownPrice(item.id, price);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Markdown price R ${price.toStringAsFixed(2)} approved for ${item.productName}.')),
        );
      }
    }
  }
}

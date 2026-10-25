import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'fnb_brand_header.dart';

class TransactionConfirmDialog extends StatefulWidget {
  const TransactionConfirmDialog({
    super.key,
    required this.initialType,
    required this.initialAmount,
    required this.initialDescription,
    this.productName,
    this.quantity = 1,
    required this.source,
    this.rawTranscript,
  });

  final TransactionType initialType;
  final double? initialAmount;
  final String initialDescription;
  final String? productName;
  final int quantity;
  final String source;
  final String? rawTranscript;

  @override
  State<TransactionConfirmDialog> createState() => _TransactionConfirmDialogState();
}

class _TransactionConfirmDialogState extends State<TransactionConfirmDialog> {
  late TransactionType _type;
  late TextEditingController _amountCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _productCtrl;
  late TextEditingController _qtyCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _amountCtrl = TextEditingController(
      text: widget.initialAmount != null ? widget.initialAmount!.toStringAsFixed(2) : '',
    );
    _descCtrl = TextEditingController(text: widget.initialDescription);
    _productCtrl = TextEditingController(text: widget.productName ?? '');
    _qtyCtrl = TextEditingController(text: widget.quantity.toString());
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _productCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.verified_outlined, color: fnbTeal),
          const SizedBox(width: 8),
          const Text('Review Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.rawTranscript != null && widget.rawTranscript!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: fnbPaleTeal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Voice note: "${widget.rawTranscript}"',
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ),
              const Text('Transaction Type', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<TransactionType>(
                initialValue: _type,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: TransactionType.values.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t.label, style: const TextStyle(fontSize: 12)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _type = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (ZAR)',
                  prefixText: 'R ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (val) {
                  final parsed = double.tryParse(val ?? '');
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productCtrl,
                decoration: InputDecoration(
                  labelText: 'Item / Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: 'Description / Notes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: fnbTeal),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final amount = double.parse(_amountCtrl.text.trim());
              final tx = MzansiTransaction(
                id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                type: _type,
                business: '', // Populated by caller
                amount: amount,
                description: _descCtrl.text.trim().isEmpty ? _type.label : _descCtrl.text.trim(),
                productName: _productCtrl.text.trim().isEmpty ? null : _productCtrl.text.trim(),
                quantity: int.tryParse(_qtyCtrl.text.trim()) ?? 1,
                source: widget.source,
                rawTranscript: widget.rawTranscript,
                timestamp: DateTime.now(),
              );
              Navigator.of(context).pop(tx);
            }
          },
          child: const Text('Confirm & Save'),
        ),
      ],
    );
  }
}

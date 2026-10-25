import 'package:flutter/material.dart';
import '../models/shop_type.dart';
import '../models/transaction_model.dart';
import '../services/app_state.dart';
import '../services/matrix_firestore_service.dart';
import '../widgets/fnb_brand_header.dart';
import '../widgets/transaction_confirm_dialog.dart';
import 'screen08_scanned_spaza.dart';
import 'screen09_scanned_liquor.dart';

class Screen06Scanner extends StatefulWidget {
  const Screen06Scanner({super.key});

  @override
  State<Screen06Scanner> createState() => _Screen06ScannerState();
}

class _Screen06ScannerState extends State<Screen06Scanner> {
  int _scanMode = 0; // 0 = Barcode, 1 = Receipt / Invoice

  @override
  Widget build(BuildContext context) {
    final state = MzansiAppState.of(context);
    final isSpaza = state.activeShop == ShopType.spaza;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _scanMode == 0 ? 'Barcode Scanner' : 'Invoice & Receipt OCR',
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode Selector
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Product Barcode', style: TextStyle(fontSize: 11)),
                  selected: _scanMode == 0,
                  selectedColor: fnbTeal,
                  backgroundColor: Colors.white24,
                  labelStyle: TextStyle(color: _scanMode == 0 ? Colors.white : Colors.white70),
                  onSelected: (val) => setState(() => _scanMode = 0),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Invoice / Receipt', style: TextStyle(fontSize: 11)),
                  selected: _scanMode == 1,
                  selectedColor: fnbTeal,
                  backgroundColor: Colors.white24,
                  labelStyle: TextStyle(color: _scanMode == 1 ? Colors.white : Colors.white70),
                  onSelected: (val) => setState(() => _scanMode = 1),
                ),
              ],
            ),
          ),

          // Camera Viewfinder Simulation
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: const Color(0xff151a1c),
                  child: Center(
                    child: Icon(
                      _scanMode == 0 ? Icons.qr_code_scanner : Icons.receipt_long_outlined,
                      size: 96,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                // Reticle Box
                Container(
                  width: 280,
                  height: _scanMode == 0 ? 200 : 320,
                  decoration: BoxDecoration(
                    border: Border.all(color: fnbTeal, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                // Reticle Corners
                Positioned(
                  bottom: 30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _scanMode == 0
                          ? 'Point camera at product barcode'
                          : 'Align wholesale receipt within frame',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Capture Controls and Test Simulation Triggers
          Container(
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            child: Column(
              children: [
                const Text(
                  'TAP TO SCAN OR SIMULATE TEST CAPTURE',
                  style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 0.6),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Simulation Button 1: Product Scan
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: fnbTeal),
                      icon: const Icon(Icons.qr_code, size: 18),
                      label: Text(
                        isSpaza ? 'Scan Spaza Item' : 'Scan Liquor Item',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () {
                        // Routing: Spaza -> Screen 8, Liquor -> Screen 9
                        if (isSpaza) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const Screen08ScannedSpaza()),
                          );
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const Screen09ScannedLiquor()),
                          );
                        }
                      },
                    ),
                    // Simulation Button 2: Receipt OCR Review
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      icon: const Icon(Icons.receipt, size: 18),
                      label: const Text('Scan Receipt', style: TextStyle(fontSize: 12)),
                      onPressed: () => _handleReceiptScan(context, state.activeShop.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReceiptScan(BuildContext context, String businessId) async {
    // OCR Extraction Simulation: Does not silently save; routes to confirmation review!
    final confirmedTx = await showDialog<MzansiTransaction>(
      context: context,
      builder: (ctx) => const TransactionConfirmDialog(
        initialType: TransactionType.stockArrival,
        initialAmount: 485.50,
        initialDescription: 'Wholesale Invoice #WH-9821: Flour & Sugar',
        productName: 'Wholesale Bulk Supplies',
        quantity: 1,
        source: 'scanner',
      ),
    );

    if (confirmedTx != null && context.mounted) {
      final txToSave = MzansiTransaction(
        id: confirmedTx.id,
        type: confirmedTx.type,
        business: businessId,
        amount: confirmedTx.amount,
        description: confirmedTx.description,
        productName: confirmedTx.productName,
        quantity: confirmedTx.quantity,
        source: 'scanner',
        timestamp: DateTime.now(),
      );

      await MatrixFirestoreService.recordTransaction(txToSave);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wholesale receipt confirmed and saved to shop ledger.')),
        );
        Navigator.of(context).pop();
      }
    }
  }
}

import 'package:flutter/material.dart';
import '../widgets/fnb_brand_header.dart';
import 'screen04_choose_shop.dart';
import 'screen05_main_hub.dart';
import 'screen20_fnb_microloan.dart';

class Screen02MenuHome extends StatelessWidget {
  const Screen02MenuHome({super.key});

  @override
  Widget build(BuildContext context) {
    final menuCategories = [
      ('Transact', [
        ('Send Money with eWallet', Icons.send_to_mobile_outlined),
      ]),
      ('Merchant Tools (Mzansi Matrix)', [
        ('Open Merchant Hub', Icons.storefront_outlined),
        ('Switch Active Shop', Icons.swap_horiz_outlined),
        ('Price List Management', Icons.list_alt_outlined),
        ('Stock Invoice Scanner', Icons.document_scanner_outlined),
        ('Voice Ledger Capture', Icons.mic_outlined),
      ]),
      ('Borrow & Grow', [
        ('FNB Mobi Loan / Microloan', Icons.monetization_on_outlined),
        ('Overdraft & Merchant Advance', Icons.trending_up_outlined),
      ]),
      ('Support & Security', [
        ('Settings & Profile', Icons.settings_outlined),
        ('Security Center & Fraud Prevention', Icons.security_outlined),
        ('Contact 24/7 FNB Business Support', Icons.support_agent_outlined),
      ]),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FnbBrandHeader(
        title: 'F&B Menu',
        subtitle: 'Navigation & Banking Services',
        showBackButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: fnbPaleTeal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: fnbTeal),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Informational overview of all services connected to your account and informal merchant profile.',
                    style: TextStyle(fontSize: 11, color: fnbDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final cat in menuCategories) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                cat.$1.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: fnbTeal,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xffe5eeee)),
              ),
              color: fnbSoft,
              child: Column(
                children: cat.$2.map((item) {
                  return ListTile(
                    leading: Icon(item.$2, color: fnbTeal, size: 20),
                    title: Text(item.$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
                    onTap: () {
                      if (item.$1 == 'Open Merchant Hub') {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const Screen05MainHub()),
                        );
                      } else if (item.$1 == 'Switch Active Shop') {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const Screen04ChooseShop()),
                        );
                      } else if (item.$1.contains('Microloan')) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const Screen20FnbMicroloan()),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const Screen05MainHub()),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

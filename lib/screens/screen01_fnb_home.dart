import 'package:flutter/material.dart';
import '../models/shop_type.dart';
import '../services/app_state.dart';
import '../widgets/fnb_brand_header.dart';
import 'screen03_gasimzansi_matrix.dart';
import 'screen04_choose_shop.dart';
import 'screen05_main_hub.dart';

class Screen01FnbHome extends StatelessWidget {
  const Screen01FnbHome({super.key});

  @override
  Widget build(BuildContext context) {
    final state = MzansiAppState.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: fnbTeal,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'FNB',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Mzansi Matrix',
              style: TextStyle(
                color: fnbDark,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: fnbTeal),
            tooltip: 'Switch Business',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const Screen04ChooseShop()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: fnbDark),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          // Selected Business Context Banner
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const Screen04ChooseShop()),
            ),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: fnbPaleTeal,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xff8ce1e5), width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    state.activeShop == ShopType.spaza
                        ? Icons.storefront_outlined
                        : Icons.local_bar_outlined,
                    color: fnbTeal,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ACTIVE BUSINESS ACCOUNT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: fnbTeal,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          state.activeShop.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: fnbDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: fnbTeal),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Mzansi Matrix Feature Card
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const Screen03GasiMzansiMatrix()),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff053f47), Color(0xff00a8b5)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: fnbTeal.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'GasiMzansi Matrix',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap to explore the full Matrix scroll view and live shop price list.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Quick Action Navigation Grid
          const Text(
            'Quick Business Actions',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: fnbDark),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _QuickActionTile(
                icon: Icons.qr_code_scanner,
                label: 'Capture',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Screen05MainHub()),
                ),
              ),
              _QuickActionTile(
                icon: Icons.mic_none,
                label: 'Voice Note',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Screen05MainHub()),
                ),
              ),
              _QuickActionTile(
                icon: Icons.insights,
                label: 'Progress',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Screen05MainHub()),
                ),
              ),
              _QuickActionTile(
                icon: Icons.account_balance,
                label: 'Microloan',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Screen05MainHub()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: fnbSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xffe5eeee)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fnbTeal, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fnbDark),
            ),
          ],
        ),
      ),
    );
  }
}

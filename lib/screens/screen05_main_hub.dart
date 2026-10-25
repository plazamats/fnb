import 'package:flutter/material.dart';
import '../models/app_language.dart';
import '../models/shop_type.dart';
import '../services/app_state.dart';
import '../widgets/fnb_brand_header.dart';
import 'screen04_choose_shop.dart';
import 'screen06_scanner.dart';
import 'screen07_voice_capture.dart';
import 'screen10_markdown.dart';
import 'screen11_empties_tracker.dart';
import 'screen12_spaza_progress.dart';
import 'screen13_liquor_progress.dart';
import 'screen14_spaza_price_list.dart';
import 'screen15_liquor_price_list.dart';
import 'screen20_fnb_microloan.dart';

class Screen05MainHub extends StatelessWidget {
  const Screen05MainHub({super.key});

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
          icon: const Icon(Icons.add_circle_outline, color: fnbTeal, size: 24),
          tooltip: 'Add to Price List',
          onPressed: () {
            // Top-left plus icon: Opens the selected shop's price list
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => isSpaza
                    ? const Screen14SpazaPriceList()
                    : const Screen15LiquorPriceList(),
              ),
            );
          },
        ),
        title: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const Screen04ChooseShop()),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: fnbPaleTeal,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xff8ce1e5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSpaza ? Icons.storefront_outlined : Icons.local_bar_outlined,
                  size: 16,
                  color: fnbTeal,
                ),
                const SizedBox(width: 6),
                Text(
                  state.activeShop.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: fnbDark,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: fnbTeal),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          // Language selector
          PopupMenuButton<AppLanguage>(
            tooltip: 'Language',
            icon: const Icon(Icons.translate, color: fnbDark, size: 20),
            onSelected: (lang) => state.setLanguage(lang),
            itemBuilder: (ctx) => AppLanguage.values.map((l) {
              return PopupMenuItem(
                value: l,
                child: Row(
                  children: [
                    if (l == state.activeLanguage)
                      const Icon(Icons.check, size: 16, color: fnbTeal)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 6),
                    Text(l.displayName),
                  ],
                ),
              );
            }).toList(),
          ),
          // Top-right notification bell: Screen 10 (Spaza) or Screen 11 (Liquor)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: fnbDark),
                tooltip: isSpaza ? 'Markdown Alerts' : 'Liquor Empties Tracker',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => isSpaza
                          ? const Screen10Markdown()
                          : const Screen11EmptiesTracker(),
                    ),
                  );
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xffe2eeee), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          // Multilingual Greeting
          Text(
            state.activeLanguage.greeting,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 2),
          Text(
            isSpaza ? 'Spaza Merchant Operations' : 'Liquor Store Operations',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: fnbDark,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 18),

          // Hero Section: The 4 Main Actions
          const Text(
            'PRIMARY ACTIONS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fnbTeal,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              // 1. Capture (Screen 6)
              Expanded(
                child: _HeroActionCard(
                  title: 'Capture',
                  subtitle: 'Barcode & Invoice Scanner',
                  icon: Icons.camera_alt_outlined,
                  color: const Color(0xff053f47),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Screen06Scanner()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 2. Microphone (Screen 7)
              Expanded(
                child: _HeroActionCard(
                  title: 'Microphone',
                  subtitle: 'Voice Note Ledger',
                  icon: Icons.mic_outlined,
                  color: fnbTeal,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Screen07VoiceCapture()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 3. My Progress (Screen 12 or 13)
              Expanded(
                child: _HeroActionCard(
                  title: 'My Progress',
                  subtitle: isSpaza ? 'Spaza Financial Dashboard' : 'Liquor Store Dashboard',
                  icon: Icons.insights_outlined,
                  color: const Color(0xff00828c),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => isSpaza
                          ? const Screen12SpazaProgress()
                          : const Screen13LiquorProgress(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 4. F&B Microloan (Screen 20)
              Expanded(
                child: _HeroActionCard(
                  title: 'F&B Microloan',
                  subtitle: 'Pre-Approved Growth Capital',
                  icon: Icons.monetization_on_outlined,
                  color: const Color(0xff025f69),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Screen20FnbMicroloan()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Operational Quick Links
          const Text(
            'ACTIVE INVENTORY & LEDGER TOOLS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fnbTeal,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xffe2eeee)),
            ),
            color: fnbSoft,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.list_alt, color: fnbTeal),
                  ),
                  title: Text(
                    isSpaza ? 'Spaza Shop Price List' : 'Liquor Shop Price List',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Manage prices, products and current inventory', style: TextStyle(fontSize: 10)),
                  trailing: const Icon(Icons.chevron_right, color: fnbTeal),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => isSpaza
                          ? const Screen14SpazaPriceList()
                          : const Screen15LiquorPriceList(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSpaza ? Icons.warning_amber_outlined : Icons.recycling_outlined,
                      color: fnbTeal,
                    ),
                  ),
                  title: Text(
                    isSpaza ? 'Markdown & Expiry Alerts' : 'Liquor Empties & Crate Tracker',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    isSpaza
                        ? 'Flag near-expiry and damaged stock'
                        : 'SAB & Heineken returnable bottle counts',
                    style: const TextStyle(fontSize: 10),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: fnbTeal),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => isSpaza
                          ? const Screen10Markdown()
                          : const Screen11EmptiesTracker(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActionCard extends StatelessWidget {
  const _HeroActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

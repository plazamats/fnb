import 'package:flutter/material.dart';
import '../models/shop_type.dart';
import '../services/app_state.dart';
import '../widgets/fnb_brand_header.dart';

class Screen04ChooseShop extends StatelessWidget {
  const Screen04ChooseShop({super.key});

  @override
  Widget build(BuildContext context) {
    final state = MzansiAppState.of(context);

    final futureBusinesses = [
      ('Hair Salon', Icons.content_cut_outlined, 'Styling, barber cuts and salon supplies'),
      ('Car Wash', Icons.local_car_wash_outlined, 'Wash bays, chemical stock and queue tracking'),
      ('Shisa Nyama', Icons.outdoor_grill_outlined, 'Meat orders, braai packs and beverage pairing'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FnbBrandHeader(
        title: 'Choose Your Shop',
        subtitle: 'Select Active Informal Enterprise',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const Text(
            'Which business are you managing today?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: fnbDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your inventory, price list, notifications, voice captures and financial reports are kept strictly separated by enterprise.',
            style: TextStyle(fontSize: 11, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // Active Available Shop Options
          for (final shop in ShopType.values) ...[
            _ShopOptionCard(
              shop: shop,
              isSelected: state.activeShop == shop,
              onSelect: () {
                state.setShop(shop);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Switched to ${shop.label}. Inventory and reports updated.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Coming Soon Section
          Row(
            children: const [
              Icon(Icons.lock_clock_outlined, size: 16, color: fnbTeal),
              SizedBox(width: 8),
              Text(
                'ADDITIONAL BUSINESS TYPES (COMING SOON)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: fnbTeal,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          for (final item in futureBusinesses)
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              color: const Color(0xfffafafa),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xffededed)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.$2, color: Colors.black45, size: 20),
                ),
                title: Row(
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xffffeedb),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Coming Soon',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xffc26100)),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(item.$3, style: const TextStyle(fontSize: 9, color: Colors.black38)),
                trailing: const Icon(Icons.lock_outline, size: 16, color: Colors.black26),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShopOptionCard extends StatelessWidget {
  const _ShopOptionCard({
    required this.shop,
    required this.isSelected,
    required this.onSelect,
  });

  final ShopType shop;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? fnbPaleTeal : fnbSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? fnbTeal : const Color(0xffe2eeee),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: fnbTeal.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? fnbTeal : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                shop == ShopType.spaza ? Icons.storefront_outlined : Icons.local_bar_outlined,
                color: isSelected ? Colors.white : fnbTeal,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        shop.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? fnbDark : Colors.black87,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: fnbTeal,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shop.subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? fnbTeal : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}

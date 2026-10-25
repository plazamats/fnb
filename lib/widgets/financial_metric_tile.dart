import 'package:flutter/material.dart';
import 'fnb_brand_header.dart';

class FinancialMetricTile extends StatelessWidget {
  const FinancialMetricTile({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    this.subtitle,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final double amount;
  final String? subtitle;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? fnbPaleTeal : fnbSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight ? fnbTeal : const Color(0xffe5eeee),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 20, color: fnbTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                    color: fnbDark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
          Text(
            'R ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: highlight ? fnbTeal : fnbDark,
            ),
          ),
        ],
      ),
    );
  }
}

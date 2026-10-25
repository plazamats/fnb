import 'package:flutter/material.dart';
import '../models/financial_overview_model.dart';
import '../models/transaction_model.dart';
import '../services/app_state.dart';
import '../services/financial_calculator_service.dart';
import '../services/matrix_firestore_service.dart';
import '../widgets/advice_speech_bubble.dart';
import '../widgets/financial_metric_tile.dart';
import '../widgets/fnb_brand_header.dart';
import 'screen19_month_end_overview.dart';
import 'screen20_fnb_microloan.dart';

class Screen18PaydayOverview extends StatelessWidget {
  const Screen18PaydayOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final state = MzansiAppState.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FnbBrandHeader(
        title: '25th-Day Financial Overview',
        subtitle: 'Payday Influx & Weekend Restock (25th - 28th)',
      ),
      body: StreamBuilder<List<MzansiTransaction>>(
        stream: MatrixFirestoreService.watchTransactions(state.activeShop.id),
        builder: (context, snapshot) {
          final txs = snapshot.data ?? MatrixFirestoreService.getSnapshotTransactions(state.activeShop.id);
          final summary = FinancialCalculatorService.calculate(
            period: FinancialPeriod.payday,
            transactions: txs,
            language: state.activeLanguage,
          );

          // Affordability check: Only recommend restocking if cash reserves cover order
          final isRestockAffordable = summary.availableToSpend >= 1200.00;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cycle Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: fnbPaleTeal,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xff8ce1e5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.paid_outlined, size: 20, color: fnbTeal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Payday Cycle (25th) Active • ${state.activeShop.label}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fnbDark),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const Screen19MonthEndOverview()),
                      ),
                      child: const Text('Month-End >', style: TextStyle(fontSize: 11, color: fnbTeal)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Speech Bubble with Personalised Payday Restocking Recommendation
              AdviceSpeechBubble(
                adviceText: isRestockAffordable
                    ? summary.adviceText
                    : 'Payday is here! However, cash reserves are currently tight (under R 1,200). Focus on fast-moving high-margin bread before ordering heavy stock.',
                tag: '25th-Day Weekend Restock Advice',
              ),
              const SizedBox(height: 20),

              // Affordability Check Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isRestockAffordable ? const Color(0xffe8f8f0) : const Color(0xfffff4e5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isRestockAffordable ? const Color(0xff2e7d32) : const Color(0xffe65100),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isRestockAffordable ? Icons.check_circle_outline : Icons.info_outline,
                      color: isRestockAffordable ? const Color(0xff2e7d32) : const Color(0xffe65100),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isRestockAffordable
                            ? 'Affordability Verified: Cash reserves cover recommended weekend cold drink and bread restocking.'
                            : 'Caution: Preserve working capital. Do not over-extend on credit without guaranteed turnover.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isRestockAffordable ? const Color(0xff1b5e20) : const Color(0xffbf360c),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Financial Metrics Breakdown
              const Text(
                'PAYDAY CASH POSITION',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fnbTeal, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),

              FinancialMetricTile(
                icon: Icons.storefront_outlined,
                title: 'Shop Costs (Committed Orders)',
                subtitle: 'Cold beverages, bakery, wholesale top-ups',
                amount: summary.shopCosts,
              ),
              FinancialMetricTile(
                icon: Icons.family_restroom_outlined,
                title: 'Family Costs',
                subtitle: 'Household groceries & month-end family draws',
                amount: summary.familyCosts,
              ),
              FinancialMetricTile(
                icon: Icons.savings_outlined,
                title: 'Payday Savings Buffer',
                subtitle: 'Automatic profit set-aside',
                amount: summary.savings,
              ),
              FinancialMetricTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Available Funds to Restock',
                subtitle: 'Liquid ZAR available for stock purchase',
                amount: summary.availableToSpend,
                highlight: true,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: fnbTeal),
                  icon: const Icon(Icons.monetization_on_outlined),
                  label: const Text('Top Up Stock via FNB Microloan'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Screen20FnbMicroloan()),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

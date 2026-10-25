import 'package:flutter/material.dart';
import '../models/financial_overview_model.dart';
import '../models/transaction_model.dart';
import '../services/app_state.dart';
import '../services/financial_calculator_service.dart';
import '../services/matrix_firestore_service.dart';
import '../widgets/advice_speech_bubble.dart';
import '../widgets/financial_metric_tile.dart';
import '../widgets/fnb_brand_header.dart';
import 'screen16_sassa_overview.dart';
import 'screen20_fnb_microloan.dart';

class Screen19MonthEndOverview extends StatelessWidget {
  const Screen19MonthEndOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final state = MzansiAppState.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FnbBrandHeader(
        title: 'Month-End Financial Overview',
        subtitle: 'Wholesale Reconciliation & Bulk Deals',
      ),
      body: StreamBuilder<List<MzansiTransaction>>(
        stream: MatrixFirestoreService.watchTransactions(state.activeShop.id),
        builder: (context, snapshot) {
          final txs = snapshot.data ?? MatrixFirestoreService.getSnapshotTransactions(state.activeShop.id);
          final summary = FinancialCalculatorService.calculate(
            period: FinancialPeriod.monthEnd,
            transactions: txs,
            language: state.activeLanguage,
          );

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
                    const Icon(Icons.event_repeat, size: 20, color: fnbTeal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Month-End Reconciliation • ${state.activeShop.label}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fnbDark),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const Screen16SassaOverview()),
                      ),
                      child: const Text('Back to SASSA >', style: TextStyle(fontSize: 11, color: fnbTeal)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Speech Bubble: Wholesaler combo deals guidance
              AdviceSpeechBubble(
                adviceText: summary.adviceText,
                tag: 'Month-End Wholesaler Combo Advice',
              ),
              const SizedBox(height: 20),

              // Monthly Net Profit Summary Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: fnbSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe2eeee)),
                ),
                child: Column(
                  children: [
                    const Text('Total Monthly Net Profit', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      'R ${summary.takeHomeAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: fnbTeal),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gross Monthly Turnover: R ${summary.grossSales.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 10, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Financial Metrics Breakdown
              const Text(
                'MONTH-END AUDITED TOTALS',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fnbTeal, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),

              FinancialMetricTile(
                icon: Icons.storefront_outlined,
                title: 'Shop Operating Costs',
                subtitle: 'Total monthly supplier and inventory expenditure',
                amount: summary.shopCosts,
              ),
              FinancialMetricTile(
                icon: Icons.family_restroom_outlined,
                title: 'Cumulative Family Draws',
                subtitle: 'All household draws recorded via voice or register',
                amount: summary.familyCosts,
              ),
              FinancialMetricTile(
                icon: Icons.savings_outlined,
                title: 'Accumulated Savings',
                subtitle: 'Total profits retained for business security',
                amount: summary.savings,
              ),
              FinancialMetricTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Cleared Liquidity to Reinvest',
                subtitle: 'Available funds for wholesale combo deals',
                amount: summary.availableToSpend,
                highlight: true,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: fnbTeal),
                  icon: const Icon(Icons.monetization_on_outlined),
                  label: const Text('View Available Microloan Top-up Options'),
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

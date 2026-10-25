import 'package:flutter/material.dart';
import '../models/financial_overview_model.dart';
import '../models/transaction_model.dart';
import '../services/app_state.dart';
import '../services/financial_calculator_service.dart';
import '../services/matrix_firestore_service.dart';
import '../widgets/advice_speech_bubble.dart';
import '../widgets/financial_metric_tile.dart';
import '../widgets/fnb_brand_header.dart';
import 'screen17_mid_month_overview.dart';
import 'screen20_fnb_microloan.dart';

class Screen16SassaOverview extends StatelessWidget {
  const Screen16SassaOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final state = MzansiAppState.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FnbBrandHeader(
        title: 'SASSA Financial Overview',
        subtitle: 'Grant Payment Period (1st - 7th of Month)',
      ),
      body: StreamBuilder<List<MzansiTransaction>>(
        stream: MatrixFirestoreService.watchTransactions(state.activeShop.id),
        builder: (context, snapshot) {
          final txs = snapshot.data ?? MatrixFirestoreService.getSnapshotTransactions(state.activeShop.id);
          final summary = FinancialCalculatorService.calculate(
            period: FinancialPeriod.sassa,
            transactions: txs,
            language: state.activeLanguage,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Period Indicator Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: fnbPaleTeal,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xff8ce1e5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: fnbTeal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'SASSA Cycle Active • ${state.activeShop.label}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fnbDark),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const Screen17MidMonthOverview()),
                      ),
                      child: const Text('Next Cycle >', style: TextStyle(fontSize: 11, color: fnbTeal)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Speech Bubble with Personalised Money Management Advice
              AdviceSpeechBubble(
                adviceText: summary.adviceText,
                tag: 'SASSA Grant Spending Insight',
              ),
              const SizedBox(height: 20),

              // Take-Home Hero
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: fnbSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe2eeee)),
                ),
                child: Column(
                  children: [
                    const Text('Take-Home Amount / Profit', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      'R ${summary.takeHomeAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: fnbTeal),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gross SASSA Revenue: R ${summary.grossSales.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 10, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Categorized Breakdown
              const Text(
                'SASSA PERIOD EXPENSE & SAVINGS LEDGER',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fnbTeal, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),

              FinancialMetricTile(
                icon: Icons.storefront_outlined,
                title: 'Shop Costs',
                subtitle: 'Replenishing basic foods (Maize, Bread, Milk)',
                amount: summary.shopCosts,
              ),
              FinancialMetricTile(
                icon: Icons.family_restroom_outlined,
                title: 'Family Costs',
                subtitle: 'Personal & household living expenses taken from till',
                amount: summary.familyCosts,
              ),
              FinancialMetricTile(
                icon: Icons.savings_outlined,
                title: 'Additional Savings',
                subtitle: 'Emergency reserve set aside from grant rush',
                amount: summary.savings,
              ),
              FinancialMetricTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Amount Available to Spend',
                subtitle: 'Liquid working balance after essential costs',
                amount: summary.availableToSpend,
                highlight: true,
              ),
              const SizedBox(height: 20),

              // Microloan Link
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: fnbTeal),
                  icon: const Icon(Icons.monetization_on_outlined),
                  label: const Text('View F&B Microloan Top-up Options'),
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

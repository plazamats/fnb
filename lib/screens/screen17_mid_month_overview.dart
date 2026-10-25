import 'package:flutter/material.dart';
import '../models/financial_overview_model.dart';
import '../models/transaction_model.dart';
import '../services/app_state.dart';
import '../services/financial_calculator_service.dart';
import '../services/matrix_firestore_service.dart';
import '../widgets/advice_speech_bubble.dart';
import '../widgets/financial_metric_tile.dart';
import '../widgets/fnb_brand_header.dart';
import 'screen18_payday_overview.dart';
import 'screen20_fnb_microloan.dart';

class Screen17MidMonthOverview extends StatelessWidget {
  const Screen17MidMonthOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final state = MzansiAppState.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FnbBrandHeader(
        title: 'Mid-Month Financial Overview',
        subtitle: 'Cash Flow & Inventory Discipline (8th - 24th)',
      ),
      body: StreamBuilder<List<MzansiTransaction>>(
        stream: MatrixFirestoreService.watchTransactions(state.activeShop.id),
        builder: (context, snapshot) {
          final txs = snapshot.data ?? MatrixFirestoreService.getSnapshotTransactions(state.activeShop.id);
          final summary = FinancialCalculatorService.calculate(
            period: FinancialPeriod.midMonth,
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
                    const Icon(Icons.show_chart, size: 20, color: fnbTeal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Mid-Month Cycle Active • ${state.activeShop.label}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fnbDark),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const Screen18PaydayOverview()),
                      ),
                      child: const Text('25th Day >', style: TextStyle(fontSize: 11, color: fnbTeal)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Contextual Speech Bubble: Control spending & steady cash flow
              AdviceSpeechBubble(
                adviceText: summary.adviceText,
                tag: 'Mid-Month Cash Preservation Guidance',
              ),
              const SizedBox(height: 20),

              // Profit & Cash Reserves Container
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: fnbSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffe2eeee)),
                ),
                child: Column(
                  children: [
                    const Text('Available Cash to Preserve', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      'R ${summary.availableToSpend.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: fnbTeal),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Maintain steady cash buffer until Payday (25th)',
                      style: TextStyle(fontSize: 10, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Financial Metrics Breakdown
              const Text(
                'MID-MONTH FINANCIAL LEDGER',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fnbTeal, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),

              FinancialMetricTile(
                icon: Icons.storefront_outlined,
                title: 'Shop Costs',
                subtitle: 'Routine maintenance & daily replacements',
                amount: summary.shopCosts,
              ),
              FinancialMetricTile(
                icon: Icons.family_restroom_outlined,
                title: 'Family Costs',
                subtitle: 'Controlled household till drawings',
                amount: summary.familyCosts,
              ),
              FinancialMetricTile(
                icon: Icons.savings_outlined,
                title: 'Preserved Savings',
                subtitle: 'Emergency buffer held safely in account',
                amount: summary.savings,
              ),
              FinancialMetricTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Net Take-Home Position',
                subtitle: 'Calculated margin after mid-month expenses',
                amount: summary.takeHomeAmount,
                highlight: true,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: fnbTeal),
                  icon: const Icon(Icons.monetization_on_outlined),
                  label: const Text('Check Microloan Top-up Status'),
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

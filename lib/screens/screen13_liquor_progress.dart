import 'package:flutter/material.dart';
import '../models/financial_overview_model.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../services/app_state.dart';
import '../services/financial_calculator_service.dart';
import '../services/matrix_firestore_service.dart';
import '../widgets/advice_speech_bubble.dart';
import '../widgets/financial_metric_tile.dart';
import '../widgets/fnb_brand_header.dart';
import 'screen11_empties_tracker.dart';
import 'screen15_liquor_price_list.dart';
import 'screen16_sassa_overview.dart';
import 'screen17_mid_month_overview.dart';
import 'screen18_payday_overview.dart';
import 'screen19_month_end_overview.dart';
import 'screen20_fnb_microloan.dart';

class Screen13LiquorProgress extends StatefulWidget {
  const Screen13LiquorProgress({super.key});

  @override
  State<Screen13LiquorProgress> createState() => _Screen13LiquorProgressState();
}

class _Screen13LiquorProgressState extends State<Screen13LiquorProgress> {
  FinancialPeriod _selectedPeriod = FinancialPeriod.sassa;

  @override
  Widget build(BuildContext context) {
    final state = MzansiAppState.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: fnbDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Progress (Liquor Shop)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: fnbDark)),
            Text('Beverage Revenue & Empties', style: TextStyle(fontSize: 10, color: fnbTeal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.recycling_outlined, color: fnbTeal),
            tooltip: 'Empties Tracker',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const Screen11EmptiesTracker()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.price_change_outlined, color: fnbTeal),
            tooltip: 'View Liquor Price List',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const Screen15LiquorPriceList()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xffe2eeee), height: 1),
        ),
      ),
      body: StreamBuilder<List<MzansiTransaction>>(
        stream: MatrixFirestoreService.watchTransactions('liquor'),
        builder: (context, txSnapshot) {
          final transactions = txSnapshot.data ?? MatrixFirestoreService.getSnapshotTransactions('liquor');
          final summary = FinancialCalculatorService.calculate(
            period: _selectedPeriod,
            transactions: transactions,
            language: state.activeLanguage,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              // Period Filter Choice Chips
              const Text(
                'SELECT ACCOUNTING CYCLE',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fnbTeal, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: FinancialPeriod.values.map((p) {
                    final isSel = _selectedPeriod == p;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(p.label, style: const TextStyle(fontSize: 11)),
                        selected: isSel,
                        selectedColor: fnbPaleTeal,
                        side: BorderSide(color: isSel ? fnbTeal : const Color(0xffd5e5e5)),
                        onSelected: (_) => setState(() => _selectedPeriod = p),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Take-Home Cash / Profit Header Card (Liquor specific)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff12353b), Color(0xff00828c)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: fnbTeal.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Liquor Store Net Profit',
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'R ${summary.takeHomeAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cycle: ${_selectedPeriod.label} • Separate from Spaza Records',
                      style: const TextStyle(color: Colors.white60, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Dynamic Advice Speech Bubble in Owner's Chosen Language
              AdviceSpeechBubble(
                adviceText: summary.adviceText,
                tag: '${_selectedPeriod.label} Liquor Guidance',
              ),
              const SizedBox(height: 18),

              // Financial Metrics Breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Liquor Financial Overview',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: fnbDark),
                  ),
                  TextButton(
                    onPressed: () => _navigateToPeriodDetail(context, _selectedPeriod),
                    child: const Text('Detailed Breakdown', style: TextStyle(fontSize: 11, color: fnbTeal)),
                  ),
                ],
              ),
              FinancialMetricTile(
                icon: Icons.local_bar_outlined,
                title: 'Beverage Restocking Costs',
                subtitle: 'SAB & Heineken invoice orders',
                amount: summary.shopCosts,
              ),
              FinancialMetricTile(
                icon: Icons.family_restroom_outlined,
                title: 'Family / Personal Draws',
                subtitle: 'Till draws from liquor counter',
                amount: summary.familyCosts,
              ),
              FinancialMetricTile(
                icon: Icons.savings_outlined,
                title: 'Reserved Deposit Capital',
                subtitle: 'Retained for crate deposit reconciliation',
                amount: summary.savings,
              ),
              FinancialMetricTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Available Cash to Spend',
                subtitle: 'Cleared business liquidity',
                amount: summary.availableToSpend,
                highlight: true,
              ),
              const SizedBox(height: 18),

              // Trending Liquor Products Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Selling Beverages',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: fnbDark),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const Screen15LiquorPriceList()),
                    ),
                    child: const Text('View Catalogue', style: TextStyle(fontSize: 11, color: fnbTeal)),
                  ),
                ],
              ),
              StreamBuilder<List<MatrixProduct>>(
                stream: MatrixFirestoreService.watchProducts('liquor'),
                builder: (context, prodSnapshot) {
                  final prods = (prodSnapshot.data ?? []).take(3).toList();
                  if (prods.isEmpty) return const SizedBox.shrink();

                  return Column(
                    children: prods.map((p) {
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 6),
                        color: fnbSoft,
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.sports_bar_outlined, color: fnbTeal, size: 18),
                          title: Text(p.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          subtitle: Text('In Stock: ${p.quantity} • Category: ${p.category}', style: const TextStyle(fontSize: 9)),
                          trailing: Text(
                            'R ${p.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: fnbTeal, fontSize: 12),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Empties Audit Summary Link Card
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Screen11EmptiesTracker()),
                ),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: fnbPaleTeal,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xff8ce1e5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.recycling, color: fnbTeal, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Returnable Empties Status',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: fnbDark),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'SAB & Heineken deposit counts ready for auditing',
                              style: TextStyle(fontSize: 10, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: fnbTeal),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // F&B Microloan Pre-Approval Section
              Card(
                elevation: 0,
                color: fnbSoft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xffe2eeee)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.monetization_on_outlined, color: fnbTeal, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Liquor Wholesale Working Capital',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: fnbDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Qualify for an FNB Microloan based on your consistent beverage sales history.',
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: fnbTeal),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const Screen20FnbMicroloan()),
                          ),
                          child: const Text('View Microloan Eligibility', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToPeriodDetail(BuildContext context, FinancialPeriod period) {
    Widget target = switch (period) {
      FinancialPeriod.sassa => const Screen16SassaOverview(),
      FinancialPeriod.midMonth => const Screen17MidMonthOverview(),
      FinancialPeriod.payday => const Screen18PaydayOverview(),
      FinancialPeriod.monthEnd => const Screen19MonthEndOverview(),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => target));
  }
}

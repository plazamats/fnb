enum FinancialPeriod {
  sassa('SASSA period', 'sassa'),
  midMonth('Mid-month', 'mid_month'),
  payday('25th day', 'payday'),
  monthEnd('Month-end', 'month_end');

  const FinancialPeriod(this.label, this.key);
  final String label;
  final String key;
}

class FinancialSummary {
  const FinancialSummary({
    required this.period,
    required this.shopCosts,
    required this.familyCosts,
    required this.savings,
    required this.availableToSpend,
    required this.takeHomeAmount,
    required this.grossSales,
    required this.adviceText,
  });

  final FinancialPeriod period;
  final double shopCosts;
  final double familyCosts;
  final double savings;
  final double availableToSpend;
  final double takeHomeAmount;
  final double grossSales;
  final String adviceText;
}

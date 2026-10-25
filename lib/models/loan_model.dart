enum LoanApplicationStep {
  qualification(1, 'Qualification', 'Verified from consistent ledger history'),
  approval(2, 'Approval', 'Formal credit verification & FNB affordability check'),
  disbursement(3, 'Access Funds Now', 'Immediate disbursement to your FNB Business Account');

  const LoanApplicationStep(this.number, this.title, this.description);
  final int number;
  final String title;
  final String description;
}

class LoanStatus {
  const LoanStatus({
    this.eligibleAmount = 5000.0,
    this.currentStep = 1, // 1 = qualification active, 2 = approval, 3 = funds ready
    this.isQualified = true,
    this.isApproved = false,
    this.isDisbursed = false,
    this.existingLoanBalance = 1500.0,
    this.availableTopUp = 5000.0,
  });

  final double eligibleAmount;
  final int currentStep;
  final bool isQualified;
  final bool isApproved;
  final bool isDisbursed;
  final double existingLoanBalance;
  final double availableTopUp;

  LoanStatus copyWith({
    double? eligibleAmount,
    int? currentStep,
    bool? isQualified,
    bool? isApproved,
    bool? isDisbursed,
    double? existingLoanBalance,
    double? availableTopUp,
  }) {
    return LoanStatus(
      eligibleAmount: eligibleAmount ?? this.eligibleAmount,
      currentStep: currentStep ?? this.currentStep,
      isQualified: isQualified ?? this.isQualified,
      isApproved: isApproved ?? this.isApproved,
      isDisbursed: isDisbursed ?? this.isDisbursed,
      existingLoanBalance: existingLoanBalance ?? this.existingLoanBalance,
      availableTopUp: availableTopUp ?? this.availableTopUp,
    );
  }
}

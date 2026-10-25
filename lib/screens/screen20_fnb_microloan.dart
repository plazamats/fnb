import 'package:flutter/material.dart';
import '../models/loan_model.dart';
import '../services/matrix_firestore_service.dart';
import '../widgets/fnb_brand_header.dart';

class Screen20FnbMicroloan extends StatelessWidget {
  const Screen20FnbMicroloan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const FnbBrandHeader(
        title: 'FNB Mobi Loan / Microloan',
        subtitle: 'Informal Merchant Growth Facility',
      ),
      body: StreamBuilder<LoanStatus>(
        stream: MatrixFirestoreService.watchLoanStatus(),
        builder: (context, snapshot) {
          final loan = snapshot.data ?? const LoanStatus();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hero Halala Offer Banner (from Figma)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff053f47), Color(0xff00a8b5)],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PRE-ASSESSED CAPITAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Halala! You may qualify for a R5,000 microloan.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Let\'s restock your shelves today based on your verified business recording activity.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: fnbTeal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () => _handleApplyNow(context, loan),
                      child: const Text(
                        'Apply Now',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Application Steps (Step 1 Completed, Step 2 & 3 initially greyed out per specification)
              const Text(
                'APPLICATION PROGRESSION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: fnbTeal,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 12),

              // Step 1: Qualification (Completed / Active teal)
              _StepProgressTile(
                stepNumber: '1',
                title: 'Qualification',
                subtitle: 'Verified eligible amount: R ${loan.eligibleAmount.toStringAsFixed(2)} based on confirmed ledger records.',
                isActive: true,
                isCompleted: loan.isQualified,
                icon: Icons.check_circle,
              ),
              const SizedBox(height: 8),

              // Step 2: Approval (Initially disabled / greyed out)
              _StepProgressTile(
                stepNumber: '2',
                title: 'Approval',
                subtitle: loan.isApproved
                    ? 'Credit criteria and affordability checks satisfied.'
                    : 'Initially locked until preceding qualification checks and customer consent are submitted.',
                isActive: loan.currentStep >= 2,
                isCompleted: loan.isApproved,
                icon: loan.isApproved ? Icons.check_circle : Icons.lock_outline,
              ),
              const SizedBox(height: 8),

              // Step 3: Access Funds Now (Initially disabled / greyed out)
              _StepProgressTile(
                stepNumber: '3',
                title: 'Access Funds Now',
                subtitle: loan.isDisbursed
                    ? 'Funds disbursed to your FNB Business Account.'
                    : 'Initially locked until formal approval and disbursement terms are accepted.',
                isActive: loan.currentStep >= 3,
                isCompleted: loan.isDisbursed,
                icon: loan.isDisbursed ? Icons.check_circle : Icons.lock_outline,
              ),
              const SizedBox(height: 24),

              // Top-Up Section (from Figma)
              Card(
                elevation: 0,
                color: fnbPaleTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xff8ce1e5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.upgrade_outlined, color: fnbTeal, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Get more with a top-up',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: fnbDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Eligible customers could access additional funds of up to R5,000 and potentially save on initiation fees compared with taking a new loan.',
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Existing Loan Balance', style: TextStyle(fontSize: 9, color: Colors.black54)),
                                Text(
                                  'R ${loan.existingLoanBalance.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: fnbDark),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Available Top-Up', style: TextStyle(fontSize: 9, color: Colors.black54)),
                                Text(
                                  'R ${loan.availableTopUp.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: fnbTeal),
                                ),
                              ],
                            ),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: fnbTeal),
                            onPressed: () => _handleTopUp(context, loan),
                            child: const Text('Top Up', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Responsible Lending & Terms Disclosure
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: fnbSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Responsible Lending Notice: Eligibility, fees, interest rates, and available amounts are subject to FNB credit and affordability assessments. Consent is required before accessing funding.',
                  style: TextStyle(fontSize: 9, color: Colors.black54, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<void> _handleApplyNow(BuildContext context, LoanStatus loan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Microloan Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Step 1 (Qualification) is verified via your active shop ledger.'),
            SizedBox(height: 8),
            Text('Proceeding will submit your consented business activity to FNB Affordability & Credit Assessment for Step 2 (Approval).'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: fnbTeal),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Proceed to Step 2'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await MatrixFirestoreService.advanceLoanStep(2);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Qualification submitted! Step 2 Approval evaluation in progress.')),
        );
      }
    }
  }

  static Future<void> _handleTopUp(BuildContext context, LoanStatus loan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('FNB Loan Top-Up'),
        content: Text(
          'Top up existing balance of R ${loan.existingLoanBalance.toStringAsFixed(2)} with an additional R ${loan.availableTopUp.toStringAsFixed(2)}? '
          'Savings on initiation fees will be verified against official FNB credit policy.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: fnbTeal),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Top-Up Request'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Top-up enquiry recorded. An FNB Business Specialist will review your request.')),
        );
      }
    }
  }
}

class _StepProgressTile extends StatelessWidget {
  const _StepProgressTile({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.isCompleted,
    required this.icon,
  });

  final String stepNumber;
  final String title;
  final String subtitle;
  final bool isActive;
  final bool isCompleted;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final circleColor = isCompleted
        ? fnbTeal
        : (isActive ? fnbTeal : Colors.black26);

    return Card(
      elevation: 0,
      color: isActive ? fnbSoft : const Color(0xfffafafa),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isActive ? const Color(0xffd5e5e5) : const Color(0xffededed),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: circleColor,
          foregroundColor: Colors.white,
          child: isCompleted
              ? const Icon(Icons.check, size: 16)
              : Text(stepNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        title: Text(
          'Step $stepNumber: $title',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isActive ? fnbDark : Colors.black45,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 10, color: isActive ? Colors.black87 : Colors.black38),
        ),
        trailing: Icon(icon, size: 18, color: circleColor),
      ),
    );
  }
}

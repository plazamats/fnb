import 'package:flutter_test/flutter_test.dart';

import 'package:fnb/models/app_language.dart';
import 'package:fnb/models/financial_overview_model.dart';
import 'package:fnb/models/loan_model.dart';
import 'package:fnb/models/transaction_model.dart';
import 'package:fnb/services/financial_calculator_service.dart';
import 'package:fnb/services/matrix_firestore_service.dart';
import 'package:fnb/services/voice_nlp_service.dart';

void main() {
  setUp(() {
    MatrixFirestoreService.ensureInitialized();
  });

  group('SSDC Security Testing: Injection & Input Sanitization', () {
    test('XSS and script injection attempts in voice input are treated as raw text', () {
      const maliciousScript = '<script>alert("pwned")</script> R150 sale';
      final result = VoiceNlpService.interpret(
        speechText: maliciousScript,
        language: AppLanguage.english,
      );

      // Amount is cleanly parsed, script payload is neutralized without execution
      expect(result.amount, 150.0);
      expect(result.detectedType, TransactionType.sale);
      expect(result.transcript, contains('<script>'));
    });

    test('Special control characters and whitespace flooding do not crash NLP parser', () {
      const payload = '   \n\r\t   Ngi-thengise amaqanda ngo-R90 \x00\x1F   ';
      final result = VoiceNlpService.interpret(
        speechText: payload,
        language: AppLanguage.isizulu,
      );

      expect(result.amount, 90.0);
      expect(result.productName, 'Eggs');
      expect(result.detectedType, TransactionType.sale);
    });
  });

  group('SSDC Security Testing: Business Logic & Financial Integrity', () {
    test('Negative expenses do not artificially inflate available funds or profit', () {
      final sampleTxs = [
        MzansiTransaction(
          id: 'sec_1',
          type: TransactionType.sale,
          business: 'spaza',
          amount: 1000.0,
          description: 'Valid Sale',
          timestamp: DateTime.now(),
        ),
        MzansiTransaction(
          id: 'sec_2',
          type: TransactionType.expense,
          business: 'spaza',
          amount: 2500.0, // Expenses exceed sales
          description: 'Heavy Stock Restock',
          timestamp: DateTime.now(),
        ),
      ];

      final summary = FinancialCalculatorService.calculate(
        period: FinancialPeriod.midMonth,
        transactions: sampleTxs,
        language: AppLanguage.english,
      );

      // Take home is negative (-1500), but availableToSpend must be clamped to 0.0 to prevent misleading liquidity
      expect(summary.takeHomeAmount, lessThan(0.0));
      expect(summary.availableToSpend, 0.0);
    });

    test('Ambiguous and uncertain transactions are strictly quarantined for confirmation', () {
      final ambiguousInputs = [
        'Hey friend how are you doing today',
        'Just checking the shop lights',
        'Some bread and things maybe later',
      ];

      for (final text in ambiguousInputs) {
        final result = VoiceNlpService.interpret(
          speechText: text,
          language: AppLanguage.english,
        );

        // Security assertion: must NOT be confident, must demand user review
        expect(result.needsUserConfirmation, isTrue, reason: 'Failed for: $text');
        expect(result.isConfident, isFalse, reason: 'Failed for: $text');
      }
    });

    test('Soft-deletion preserves transaction references and audit trails', () async {
      await MatrixFirestoreService.saveProduct(
        business: 'spaza',
        name: 'Audit Protected Flour 10kg',
        price: 180.0,
      );

      final stream = MatrixFirestoreService.watchProducts('spaza');
      final list = await stream.first;
      final product = list.firstWhere((p) => p.name == 'Audit Protected Flour 10kg');

      // Record transaction referencing this product
      final tx = MzansiTransaction(
        id: 'tx_audit_1',
        type: TransactionType.sale,
        business: 'spaza',
        amount: 180.0,
        productName: product.name,
        description: 'Sold 1 bag of Audit Protected Flour',
        timestamp: DateTime.now(),
      );
      await MatrixFirestoreService.recordTransaction(tx);

      // Soft delete product from active catalog
      await MatrixFirestoreService.archiveProduct(business: 'spaza', id: product.id);

      // Active catalogue excludes it
      final updatedCatalog = await MatrixFirestoreService.watchProducts('spaza').first;
      expect(updatedCatalog.any((p) => p.id == product.id), isFalse);

      // Historical transaction ledger still contains the sales record with intact product name
      final txLedger = MatrixFirestoreService.getSnapshotTransactions('spaza');
      expect(txLedger.any((t) => t.productName == 'Audit Protected Flour 10kg'), isTrue);
    });
  });

  group('SSDC Security Testing: Loan State Gating & Responsible Lending', () {
    test('Loan status initialization enforces locked state for Step 2 and Step 3', () {
      const loan = LoanStatus();

      // Step 1 Qualification is verified based on ledger history
      expect(loan.isQualified, isTrue);
      expect(loan.currentStep, 1);

      // Steps 2 & 3 MUST be locked by default (NCA Compliance)
      expect(loan.isApproved, isFalse);
      expect(loan.isDisbursed, isFalse);
    });

    test('Advancing loan steps follows verified sequential state progression', () async {
      await MatrixFirestoreService.advanceLoanStep(2);
      final statusAfterStep2 = await MatrixFirestoreService.watchLoanStatus().first;

      expect(statusAfterStep2.currentStep, 2);
      expect(statusAfterStep2.isApproved, isTrue);
      expect(statusAfterStep2.isDisbursed, isFalse);

      await MatrixFirestoreService.advanceLoanStep(3);
      final statusAfterStep3 = await MatrixFirestoreService.watchLoanStatus().first;

      expect(statusAfterStep3.currentStep, 3);
      expect(statusAfterStep3.isDisbursed, isTrue);
    });
  });
}

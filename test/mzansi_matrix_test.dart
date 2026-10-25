import 'package:flutter_test/flutter_test.dart';

import 'package:fnb/main.dart';
import 'package:fnb/models/app_language.dart';
import 'package:fnb/models/financial_overview_model.dart';
import 'package:fnb/models/transaction_model.dart';
import 'package:fnb/services/financial_calculator_service.dart';
import 'package:fnb/services/matrix_firestore_service.dart';
import 'package:fnb/services/voice_nlp_service.dart';

void main() {
  setUp(() {
    MatrixFirestoreService.ensureInitialized();
  });

  group('Mzansi Matrix Voice NLP & Multilingual Processing', () {
    test('isiZulu sale interpretation extracts quantity, product, and amount', () {
      final res = VoiceNlpService.interpret(
        speechText: 'Ngi-thengise amaqanda amahlanu ngo-R90.',
        language: AppLanguage.isizulu,
      );
      expect(res.detectedType, TransactionType.sale);
      expect(res.amount, 90.0);
      expect(res.productName, 'Eggs');
      expect(res.quantity, 5);
      expect(res.isConfident, isTrue);
    });

    test('Sesotho till draw interpretation extracts family draw amount', () {
      final res = VoiceNlpService.interpret(
        speechText: 'Ke tsere R100 mo tilleng.',
        language: AppLanguage.sesotho,
      );
      expect(res.detectedType, TransactionType.tillDraw);
      expect(res.amount, 100.0);
      expect(res.isConfident, isTrue);
    });

    test('Afrikaans sale interpretation extracts beer packs and price', () {
      final res = VoiceNlpService.interpret(
        speechText: 'Ek het 2 kiste Castle Lager verkoop vir R240.',
        language: AppLanguage.afrikaans,
      );
      expect(res.detectedType, TransactionType.sale);
      expect(res.amount, 240.0);
      expect(res.productName, 'Castle Lager');
      expect(res.quantity, 2);
    });

    test('isiXhosa stock arrival extracts delivery', () {
      final res = VoiceNlpService.interpret(
        speechText: 'Ndithwalise iibhokisi zobisi ezimbini ngo-R140.',
        language: AppLanguage.isixhosa,
      );
      expect(res.detectedType, TransactionType.stockArrival);
      expect(res.amount, 140.0);
      expect(res.productName, 'Milk 1L');
      expect(res.quantity, 2);
    });

    test('Ambiguous voice entry triggers needsUserConfirmation', () {
      final res = VoiceNlpService.interpret(
        speechText: 'Just some random chat without clear price',
        language: AppLanguage.english,
      );
      expect(res.needsUserConfirmation, isTrue);
      expect(res.isConfident, isFalse);
    });
  });

  group('Financial Overview Calculations & Business Rules', () {
    test('Calculates shop costs, family costs, savings, and take-home correctly', () {
      final sampleTxs = [
        MzansiTransaction(
          id: '1',
          type: TransactionType.sale,
          business: 'spaza',
          amount: 5000.0,
          description: 'Sales',
          timestamp: DateTime.now(),
        ),
        MzansiTransaction(
          id: '2',
          type: TransactionType.stockArrival,
          business: 'spaza',
          amount: 2000.0,
          description: 'Stock',
          timestamp: DateTime.now(),
        ),
        MzansiTransaction(
          id: '3',
          type: TransactionType.tillDraw,
          business: 'spaza',
          amount: 500.0,
          description: 'Personal draw',
          timestamp: DateTime.now(),
        ),
      ];

      final summary = FinancialCalculatorService.calculate(
        period: FinancialPeriod.sassa,
        transactions: sampleTxs,
        language: AppLanguage.english,
      );

      expect(summary.grossSales, 5000.0);
      expect(summary.shopCosts, 2000.0);
      expect(summary.familyCosts, 500.0);
      // grossMargin = 3000, 10% savings = 300
      expect(summary.savings, 300.0);
      // takeHome = 5000 - 2000 - 500 - 300 = 2200
      expect(summary.takeHomeAmount, 2200.0);
      expect(summary.availableToSpend, 2200.0);
      expect(summary.adviceText, contains('SASSA'));
    });

    test('Financial advice adapts to selected language', () {
      final summaryZulu = FinancialCalculatorService.calculate(
        period: FinancialPeriod.midMonth,
        transactions: [],
        language: AppLanguage.isizulu,
      );
      expect(summaryZulu.adviceText, contains('Phakathi nenyanga'));

      final summarySesotho = FinancialCalculatorService.calculate(
        period: FinancialPeriod.payday,
        transactions: [],
        language: AppLanguage.sesotho,
      );
      expect(summarySesotho.adviceText, contains('Letsatsi la moputso'));
    });
  });

  group('Catalog & Price List Data Integrity', () {
    test('Saving duplicate product name throws StateError', () async {
      // Clover Milk is in seed
      expect(
        () => MatrixFirestoreService.saveProduct(
          business: 'spaza',
          name: 'Clover Full Cream Fresh Milk 1L',
          price: 25.0,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('Archiving a product soft-deletes and removes from active list', () async {
      await MatrixFirestoreService.saveProduct(
        business: 'spaza',
        name: 'Temporary Test Product',
        price: 15.0,
      );

      final productsBefore = MatrixFirestoreService.watchProducts('spaza');
      final list1 = await productsBefore.first;
      final created = list1.firstWhere((p) => p.name == 'Temporary Test Product');

      await MatrixFirestoreService.archiveProduct(business: 'spaza', id: created.id);

      final productsAfter = MatrixFirestoreService.watchProducts('spaza');
      final list2 = await productsAfter.first;
      expect(list2.any((p) => p.id == created.id), isFalse);
    });
  });

  group('UI Widget Rendering & Navigation', () {
    testWidgets('App renders Home, switches tabs to Menu and Merchant Hub', (tester) async {
      await tester.pumpWidget(const FnbApp());
      await tester.pumpAndSettle();

      expect(find.text('Mzansi Matrix'), findsOneWidget);
      expect(find.text('GasiMzansi Matrix'), findsOneWidget);

      // Tap F&B Menu tab
      await tester.tap(find.text('F&B Menu').last);
      await tester.pumpAndSettle();
      expect(find.text('MERCHANT TOOLS (MZANSI MATRIX)'), findsOneWidget);

      // Tap Merchant Hub tab
      await tester.tap(find.text('Merchant Hub'));
      await tester.pumpAndSettle();
      expect(find.text('PRIMARY ACTIONS'), findsOneWidget);
      expect(find.text('Capture'), findsWidgets);
      expect(find.text('Microphone'), findsWidgets);
      expect(find.text('F&B Microloan'), findsWidgets);
    });

    testWidgets('More screen displays all 20 screens catalogue', (tester) async {
      await tester.pumpWidget(const FnbApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      expect(find.text('FIGMA SPECIFICATION SCREEN CATALOGUE'), findsOneWidget);
      expect(find.text('Screen 3: GasiMzansi Matrix'), findsOneWidget);
      expect(find.text('Screen 6: Scanner'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Screen 20: FNB Microloan'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Screen 20: FNB Microloan'), findsOneWidget);
    });
  });
}

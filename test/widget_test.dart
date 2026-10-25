import 'package:flutter_test/flutter_test.dart';

import 'package:fnb/main.dart';

void main() {
  testWidgets('FNB home dashboard renders core content and quick actions', (tester) async {
    await tester.pumpWidget(const FnbApp());
    await tester.pumpAndSettle();

    expect(find.text('Free Delivery Friday'), findsNothing);
    expect(find.text('GasiMzansi Matrix'), findsOneWidget);
    expect(find.text('Capture'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches between Home, Menu, Merchant Hub and Progress', (tester) async {
    await tester.pumpWidget(const FnbApp());
    await tester.pumpAndSettle();

    // Verify Tab 0 Home
    expect(find.text('Mzansi Matrix'), findsOneWidget);

    // Switch to Tab 1 F&B Menu
    await tester.tap(find.text('F&B Menu').last);
    await tester.pumpAndSettle();
    expect(find.text('F&B Menu'), findsWidgets);

    // Switch to Tab 3 My progress
    await tester.tap(find.text('My progress'));
    await tester.pumpAndSettle();
    expect(find.text('Take Home Cash / Net Profit'), findsOneWidget);
  });
}

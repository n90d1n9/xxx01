import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_search_summary_notice.dart';

void main() {
  testWidgets('search summary notice renders clear and recovery actions', (
    tester,
  ) async {
    var cleared = false;
    var recovered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSearchSummaryNotice(
            title: 'No matching saves',
            message: '1 matching save available in Synced.',
            clearActionLabel: 'Clear',
            clearActionKey: const ValueKey('clear-action'),
            recoveryActionLabel: 'Show Synced',
            recoveryActionKey: const ValueKey('recover-action'),
            onClear: () => cleared = true,
            onRecover: () => recovered = true,
          ),
        ),
      ),
    );

    expect(find.text('No matching saves'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Show Synced'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('clear-action')));
    await tester.tap(find.byKey(const ValueKey('recover-action')));

    expect(cleared, isTrue);
    expect(recovered, isTrue);
  });

  testWidgets('search summary notice hides recovery action when omitted', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSSearchSummaryNotice(
            title: '1 matching product',
            message: 'Searching "latte" in Products.',
            clearActionLabel: 'Clear',
            onClear: () {},
          ),
        ),
      ),
    );

    expect(find.text('1 matching product'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
}

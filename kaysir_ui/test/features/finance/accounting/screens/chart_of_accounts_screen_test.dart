import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/screens/chart_of_accounts_screen.dart';

void main() {
  testWidgets('shows seeded chart of accounts and filters rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ChartOfAccountsScreen())),
    );

    expect(find.text('Chart of Accounts'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Chart setup is ready for posting.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('chart-of-accounts-search')),
      'revenue',
    );
    await tester.pump();

    expect(find.text('Sales Revenue'), findsOneWidget);
    expect(find.text('Cash'), findsNothing);
  });

  testWidgets('adds a custom account through the screen form', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ChartOfAccountsScreen())),
    );

    await tester.tap(find.byKey(const ValueKey('chart-of-accounts-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('chart-of-accounts-code-field')),
      '6100',
    );
    await tester.enterText(
      find.byKey(const ValueKey('chart-of-accounts-name-field')),
      'Cloud subscription expense',
    );
    await tester.tap(
      find.byKey(const ValueKey('chart-of-accounts-save-account')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('chart-of-accounts-search')),
      'cloud subscription',
    );
    await tester.pump();

    expect(find.text('Cloud subscription expense'), findsOneWidget);
    expect(find.text('6100'), findsOneWidget);
  });
}

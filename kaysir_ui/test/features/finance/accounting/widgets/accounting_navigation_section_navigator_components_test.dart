import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_catalog.dart';
import 'package:kaysir/features/finance/accounting/widgets/accounting_navigation_section_navigator_components.dart';

void main() {
  test('builds stable accounting section anchor ids', () {
    expect(accountingSectionAnchorId('Close & Ledger'), 'close-ledger');
    expect(
      accountingSectionAnchorId('  Financial Reporting  '),
      'financial-reporting',
    );
  });

  testWidgets('selects accounting workspace sections from navigator chips', (
    tester,
  ) async {
    AccountingMenuSection? selectedSection;
    final reportingSection = accountingMenuSections.singleWhere(
      (section) => section.name == 'Financial Reporting',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationSectionNavigator(
            sections: accountingMenuSections,
            onSelected: (section) => selectedSection = section,
          ),
        ),
      ),
    );

    expect(find.text('Section Navigator'), findsOneWidget);
    expect(find.text('Close & Ledger'), findsOneWidget);
    expect(find.text('Financial Reporting'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey('accounting-section-jump-financial-reporting'),
        ),
        matching: find.text('${reportingSection.destinations.length}'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-section-jump-financial-reporting')),
    );
    await tester.pump();

    expect(selectedSection?.name, 'Financial Reporting');
  });

  testWidgets('opens accounting screens from the compact launcher menu', (
    tester,
  ) async {
    AccountingMenuDestination? selectedDestination;
    final screenCount = accountingMenuSections.fold<int>(
      0,
      (total, section) => total + section.screenDestinations.length,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationSectionNavigator(
            sections: accountingMenuSections,
            onSelected: (_) {},
            onDestinationSelected:
                (destination) => selectedDestination = destination,
          ),
        ),
      ),
    );

    expect(find.text('$screenCount screens'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('accounting-section-destination-menu')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-destination-menu-item-trial-balance'),
      ),
    );
    await tester.pumpAndSettle();

    expect(selectedDestination?.name, 'Trial Balance');
  });
}

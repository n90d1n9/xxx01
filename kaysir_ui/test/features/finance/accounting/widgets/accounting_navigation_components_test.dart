import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_catalog.dart';
import 'package:kaysir/features/finance/accounting/widgets/accounting_navigation_components.dart';

void main() {
  testWidgets('opens accounting screens from the workspace header launcher', (
    tester,
  ) async {
    AccountingMenuDestination? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationHeader(
            onDestinationSelected:
                (destination) => selectedDestination = destination,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('accounting-header-destination-menu')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-header-destination-menu')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey('accounting-destination-menu-item-chart-of-accounts'),
      ),
    );
    await tester.pumpAndSettle();

    expect(selectedDestination?.name, 'Chart of Accounts');
  });

  testWidgets('separates financial reporting screens from focus shortcuts', (
    tester,
  ) async {
    final reportingSection = accountingMenuSections.singleWhere(
      (section) => section.name == 'Financial Reporting',
    );
    final screenCount = reportingSection.screenDestinations.length;
    final shortcutCount = reportingSection.shortcutDestinations.length;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AccountingNavigationSectionGrid(section: reportingSection),
          ),
        ),
      ),
    );

    expect(find.byType(AccountingNavigationTile), findsNWidgets(screenCount));
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey(
            'accounting-section-summary-screens-Financial Reporting',
          ),
        ),
        matching: find.text('$screenCount Screens'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey(
            'accounting-section-summary-shortcuts-Financial Reporting',
          ),
        ),
        matching: find.text('$shortcutCount Shortcuts'),
      ),
      findsOneWidget,
    );
    expect(find.byType(AccountingNavigationShortcutStrip), findsOneWidget);
    expect(find.text('Focus Shortcuts'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('accounting-shortcut-group-Management Measures'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('accounting-shortcut-group-Report Release')),
      findsOneWidget,
    );
    expect(find.byType(ActionChip), findsNWidgets(shortcutCount));
    expect(find.text('Management Measures'), findsNWidgets(2));
    expect(find.text('Report Release'), findsNWidgets(2));
    expect(find.text('Checklist'), findsOneWidget);
    expect(find.text('Approval'), findsOneWidget);
    expect(find.text('Reconciliation'), findsOneWidget);
    expect(find.text('Export Evidence'), findsOneWidget);
    expect(find.text('Audit'), findsOneWidget);
    expect(find.text('Sign-off'), findsOneWidget);
    expect(find.text('Evidence'), findsOneWidget);
    expect(find.text('Distribution'), findsOneWidget);
    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('Retention'), findsOneWidget);
    expect(find.text('Filing'), findsOneWidget);
  });

  test('catalog exposes screens and shortcuts separately', () {
    expect(
      accountingMenuScreenDestinations.every(
        (destination) => destination.registerRoute,
      ),
      isTrue,
    );
    expect(
      accountingMenuShortcutDestinations.every(
        (destination) => !destination.registerRoute,
      ),
      isTrue,
    );
    expect(accountingMenuShortcutDestinations.length, 11);
  });
}

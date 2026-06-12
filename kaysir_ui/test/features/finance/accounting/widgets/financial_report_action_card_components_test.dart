import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_action_card_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial report action card components', () {
    testWidgets('renders reusable title row with optional clear action', (
      tester,
    ) async {
      var cleared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportActionCardTitleRow(
              icon: Icons.verified_rounded,
              color: Colors.teal,
              title: 'Prepared by accounting',
              clearTooltip: 'Clear sign-off',
              showClearAction: true,
              onClear: () => cleared = true,
            ),
          ),
        ),
      );

      expect(find.text('Prepared by accounting'), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);

      await tester.tap(find.byTooltip('Clear sign-off'));
      await tester.pump();

      expect(cleared, isTrue);
    });

    testWidgets('renders reusable resolution line summary', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportActionCardResolutionLine(
              statusLabel: 'Approved',
              actorName: 'Controller',
              actorContext: ' / Jan 31, 2026 10:00 / EVD-1',
              note: 'Disclosure evidence matched the report pack.',
            ),
          ),
        ),
      );

      expect(
        find.text(
          'Approved by Controller / Jan 31, 2026 10:00 / EVD-1 | Disclosure evidence matched the report pack.',
        ),
        findsOneWidget,
      );
      expect(find.byType(FinancialReportTintedSurface), findsOneWidget);
    });
  });
}

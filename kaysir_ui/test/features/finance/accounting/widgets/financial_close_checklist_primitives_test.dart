import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_close_checklist.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_close_checklist_item_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_close_checklist_summary_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_close_status_pill.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial close checklist primitives', () {
    testWidgets('renders shared status and count pills', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FinancialCloseStatusPill(
                  label: 'Ready to close',
                  color: Colors.teal.shade700,
                  isDarkMode: false,
                ),
                const FinancialCloseChecklistCountPills(
                  readyCount: 2,
                  reviewCount: 1,
                  blockedCount: 0,
                  isDarkMode: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Ready to close'), findsOneWidget);
      expect(find.text('Ready 2'), findsOneWidget);
      expect(find.text('Review 1'), findsOneWidget);
      expect(find.text('Blocked 0'), findsOneWidget);
      expect(
        find.byType(FinancialReportTintedSurface),
        findsAtLeastNWidgets(4),
      );
    });

    testWidgets('renders checklist item card with status evidence', (
      tester,
    ) async {
      const item = FinancialCloseChecklistItem(
        id: 'bank',
        title: 'Bank reconciliation unresolved',
        description: 'Material bank reconciliation difference remains open.',
        status: FinancialCloseItemStatus.blocked,
        reference: 'BANK-300',
        amountLabel: r'$12,000 variance',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialCloseChecklistItemCard(
              item: item,
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Bank reconciliation unresolved'), findsOneWidget);
      expect(find.text('Blocked'), findsOneWidget);
      expect(find.text('BANK-300'), findsOneWidget);
      expect(find.text(r'$12,000 variance'), findsOneWidget);
      expect(
        find.byType(FinancialReportTintedSurface),
        findsAtLeastNWidgets(1),
      );
      expect(
        financialCloseItemStatusIcon(FinancialCloseItemStatus.blocked),
        Icons.warning_rounded,
      );
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_close_checklist.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_close_checklist_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_panel_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial close checklist components', () {
    testWidgets('summarizes close readiness counts and progress', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: FinancialCloseChecklistSummary(
                checklist: _checklist(),
                isClosed: false,
                isDarkMode: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Period Close Readiness'), findsOneWidget);
      expect(find.textContaining('FY 2026'), findsOneWidget);
      expect(find.text('1 blocker(s)'), findsOneWidget);
      expect(find.text('33%'), findsOneWidget);
      expect(find.text('Ready 1'), findsOneWidget);
      expect(find.text('Review 1'), findsOneWidget);
      expect(find.text('Blocked 1'), findsOneWidget);
    });

    testWidgets('renders responsive checklist item cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(980, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: FinancialCloseChecklistItemGrid(
                items: _checklist().items,
                isDarkMode: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Trial balance locked'), findsOneWidget);
      expect(find.text('Receivables reviewed'), findsOneWidget);
      expect(find.text('Bank reconciliation unresolved'), findsOneWidget);
      expect(find.text('GL-100'), findsOneWidget);
      expect(find.text(r'$12,000 variance'), findsOneWidget);
      expect(
        find.byType(
          FinancialReportResponsiveWrapGrid<FinancialCloseChecklistItem>,
        ),
        findsOneWidget,
      );
      expect(
        find.byType(FinancialReportTintedSurface),
        findsAtLeastNWidgets(3),
      );
    });

    testWidgets('renders empty checklist state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialCloseChecklistItemGrid(items: [], isDarkMode: false),
          ),
        ),
      );

      expect(
        find.text('No close checklist items are available for this period.'),
        findsOneWidget,
      );
      expect(find.byType(FinancialReportPanelEmptyState), findsOneWidget);
    });
  });
}

FinancialCloseChecklist _checklist() {
  return FinancialCloseChecklist(
    periodLabel: 'FY 2026',
    generatedAt: DateTime(2026, 12, 31, 18),
    totalDebit: 100000,
    totalCredit: 100000,
    trialBalanceVariance: 0,
    items: const [
      FinancialCloseChecklistItem(
        id: 'trial-balance',
        title: 'Trial balance locked',
        description: 'The trial balance is balanced and ready for reporting.',
        status: FinancialCloseItemStatus.ready,
        reference: 'GL-100',
      ),
      FinancialCloseChecklistItem(
        id: 'receivables',
        title: 'Receivables reviewed',
        description: 'Aging and expected credit loss review remains pending.',
        status: FinancialCloseItemStatus.review,
        reference: 'AR-210',
      ),
      FinancialCloseChecklistItem(
        id: 'bank',
        title: 'Bank reconciliation unresolved',
        description: 'Material bank reconciliation difference remains open.',
        status: FinancialCloseItemStatus.blocked,
        reference: 'BANK-300',
        amountLabel: r'$12,000 variance',
      ),
    ],
  );
}

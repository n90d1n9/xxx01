import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_compliance_chip.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_compliance_summary_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial report compliance components', () {
    testWidgets('renders reusable readiness summary primitives', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                FinancialReportComplianceHeader(isDarkMode: false),
                FinancialReportComplianceReadinessBadge(
                  percent: 75,
                  helperText: '3 of 4 controls',
                  color: Colors.teal,
                  isDarkMode: false,
                ),
                FinancialReportComplianceSummaryStats(
                  readyCount: 3,
                  openCount: 1,
                  exceptionCount: 0,
                  isDarkMode: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('SAK / IFRS Readiness'), findsOneWidget);
      expect(find.text('75% ready'), findsOneWidget);
      expect(find.text('3 of 4 controls'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Exceptions'), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsNWidgets(4));
    });

    testWidgets('renders compliance chip status and evidence tooltip', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FinancialReportComplianceChip(
                item: _materialItem,
                isDarkMode: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Revenue tie-out'), findsOneWidget);
      expect(find.text('Material'), findsOneWidget);
      expect(
        find.byTooltip(
          'PSAK 72: Revenue mapping does not reconcile to the ledger.\n'
          r'Current variance $9,500.00'
          '\n'
          r'Material exception threshold $5,000.00 (Revenue)',
        ),
        findsOneWidget,
      );
      expect(financialReportComplianceItemStatus(_materialItem), 'Material');
      expect(find.byType(FinancialReportTintedSurface), findsOneWidget);
    });
  });
}

const _materialItem = FinancialReportComplianceItem(
  id: 'revenue',
  title: 'Revenue tie-out',
  description: 'Revenue mapping does not reconcile to the ledger.',
  standardReference: 'PSAK 72',
  isSatisfied: false,
  variance: 9500,
  materialityThreshold: 5000,
  materialityBasis: 'Revenue',
);

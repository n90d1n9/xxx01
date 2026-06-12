import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_reference_pill.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_row_surface_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_statement_line_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial report statement line components', () {
    testWidgets('renders reusable column headers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportStatementColumnHeader(
              isDarkMode: false,
              comparativeLabel: 'FY 2025',
            ),
          ),
        ),
      );

      expect(find.text('Line item'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('FY 2025'), findsOneWidget);
      expect(find.text('Variance'), findsOneWidget);
    });

    testWidgets('renders compact comparative line pills and note reference', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportStatementLineRow(
              line: FinancialReportLine(
                label: 'Revenue',
                amount: 8000,
                comparativeAmount: 7500,
                noteReference: '2',
              ),
              isDarkMode: false,
              showComparative: true,
              useComparativeColumns: false,
            ),
          ),
        ),
      );

      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('Note 2'), findsOneWidget);
      expect(find.text(r'Current $8,000.00'), findsOneWidget);
      expect(find.text(r'Comparative $7,500.00'), findsOneWidget);
      expect(find.text(r'Variance $500.00'), findsOneWidget);
      expect(find.byType(FinancialReportRowSurface), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsNWidgets(4));
    });

    testWidgets('renders variance text and shared reference pill', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FinancialReportStatementVarianceText(
                  variance: -125,
                  isDarkMode: false,
                ),
                FinancialReportReferencePill(
                  reference: 'PSAK 1',
                  isDarkMode: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text(r'Variance -$125.00'), findsOneWidget);
      expect(find.text('PSAK 1'), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsOneWidget);
    });
  });
}

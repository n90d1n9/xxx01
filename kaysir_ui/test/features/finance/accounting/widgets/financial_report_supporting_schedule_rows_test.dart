import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_row_surface_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_schedule_evidence_trail.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_supporting_schedule_rows.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial report supporting schedule row primitives', () {
    testWidgets('renders amount pills and exposes amount colors', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Wrap(
              children: [
                FinancialReportScheduleAmountPill(
                  label: 'Current',
                  amount: 1200,
                  isDarkMode: false,
                ),
                FinancialReportScheduleAmountPill(
                  label: 'Variance',
                  amount: -250,
                  isDarkMode: false,
                  isVariance: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text(r'Current $1,200.00'), findsOneWidget);
      expect(find.text(r'Variance -$250.00'), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsNWidgets(2));
      expect(
        financialReportScheduleAmountColor(-1, false, true),
        Colors.red.shade700,
      );
    });

    testWidgets('renders source column header and compact line row', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FinancialReportScheduleColumnHeader(isDarkMode: false),
                FinancialReportScheduleLineRow(
                  line: FinancialReportScheduleLine(
                    label: 'Cash receipts',
                    amount: 12000,
                    comparativeAmount: 10000,
                    sourceCategory: 'Operating cash',
                    noteReference: '7',
                  ),
                  isDarkMode: false,
                  useColumns: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Source line'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Comparative'), findsOneWidget);
      expect(find.text('Variance'), findsOneWidget);
      expect(find.text('Cash receipts'), findsOneWidget);
      expect(find.text('Operating cash - Note 7'), findsOneWidget);
      expect(find.text(r'Current $12,000.00'), findsOneWidget);
      expect(find.text(r'Comparative $10,000.00'), findsOneWidget);
      expect(find.text(r'Variance $2,000.00'), findsOneWidget);
      expect(find.byType(FinancialReportRowSurface), findsOneWidget);
      expect(
        find.byType(FinancialReportTintedSurface),
        findsAtLeastNWidgets(3),
      );
    });

    testWidgets('renders structured evidence trail chips with shared tint', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportScheduleEvidenceTrail(
              sourceCategory:
                  'Stale timing difference / Escalate / Overdue / '
                  'Review Cleared / Owner Controller',
              noteReference: '3',
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Stale timing difference'), findsOneWidget);
      expect(find.text('Escalate'), findsOneWidget);
      expect(find.text('Overdue'), findsOneWidget);
      expect(find.text('Review Cleared'), findsOneWidget);
      expect(find.text('Owner Controller'), findsOneWidget);
      expect(find.text('Note 3'), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsNWidgets(6));
    });
  });
}

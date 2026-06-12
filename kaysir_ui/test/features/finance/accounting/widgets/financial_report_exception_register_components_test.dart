import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_exception_register_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial report exception register components', () {
    testWidgets('summarizes clear register state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportExceptionRegisterHeader(
              periodLabel: 'FY 2026',
              exceptionCount: 0,
              blockerCount: 0,
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Report Exception Register'), findsOneWidget);
      expect(find.textContaining('FY 2026'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsOneWidget);
    });

    testWidgets('summarizes open blockers and empty state copy', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FinancialReportExceptionRegisterHeader(
                  periodLabel: 'FY 2026',
                  exceptionCount: 3,
                  blockerCount: 2,
                  isDarkMode: false,
                ),
                FinancialReportExceptionEmptyState(isDarkMode: false),
              ],
            ),
          ),
        ),
      );

      expect(find.text('3 open'), findsOneWidget);
      expect(find.text('2 blocker(s)'), findsOneWidget);
      expect(find.text('No unresolved report exceptions'), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsNWidgets(3));
    });

    testWidgets('renders evidence pills through the shared tinted surface', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportExceptionEvidencePill(
              icon: Icons.rule_rounded,
              label: 'Materiality 1% of total assets',
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Materiality 1% of total assets'), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsOneWidget);
    });
  });
}

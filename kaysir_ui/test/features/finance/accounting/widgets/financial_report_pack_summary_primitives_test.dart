import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_pack_header_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_pack_metric_components.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

void main() {
  group('financial report pack summary primitives', () {
    testWidgets('renders info chip and readiness meter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const FinancialReportPackInfoChip(
                  icon: Icons.calendar_month_rounded,
                  label: 'FY 2026',
                  isDarkMode: false,
                ),
                FinancialReportPackReadinessMeter(
                  readinessRatio: 0.75,
                  readinessPercent: 75,
                  accent: Colors.teal.shade700,
                  textColor: Colors.black87,
                  mutedColor: Colors.grey.shade700,
                  isDarkMode: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('FY 2026'), findsOneWidget);
      expect(find.text('Readiness'), findsOneWidget);
      expect(find.text('75% report-pack checks ready'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders metric card and exposes metric colors', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportMetricCard(
              metric: FinancialReportMetric(
                label: 'Net Income',
                amount: 5000,
                comparativeAmount: 5500,
                helperText: 'Current year performance',
              ),
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Net Income'), findsOneWidget);
      expect(find.text(r'$5,000.00'), findsOneWidget);
      expect(find.text('Current year performance'), findsOneWidget);
      expect(find.text(r'-$500.00'), findsOneWidget);
      expect(find.byType(AppSurface), findsOneWidget);
      expect(
        financialReportMetricVarianceColor(-1, false),
        Colors.red.shade700,
      );
    });
  });
}

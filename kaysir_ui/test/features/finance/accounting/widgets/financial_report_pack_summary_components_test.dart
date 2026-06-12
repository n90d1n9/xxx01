import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_pack_summary_components.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

void main() {
  group('financial report pack summary components', () {
    testWidgets('render report identity readiness and metrics', (tester) async {
      final pack = _pack();

      await tester.binding.setSurfaceSize(const Size(1040, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    FinancialReportPackSummaryHeader(
                      pack: pack,
                      isDarkMode: false,
                    ),
                    const SizedBox(height: 12),
                    FinancialReportPackMetricGrid(
                      metrics: pack.metrics,
                      isDarkMode: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('Kaysir Advisory Financial Report Pack'),
        findsOneWidget,
      );
      expect(find.text('SAK Indonesia - Indonesia - IDR'), findsOneWidget);
      expect(find.text('FY 2026'), findsOneWidget);
      expect(find.text('As of 31 Dec 2026'), findsOneWidget);
      expect(find.text('Compare FY 2025'), findsOneWidget);
      expect(find.text('50% report-pack checks ready'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(AppSurface), findsNWidgets(3));
      expect(find.byType(FinancialReportPackMetricGrid), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text(r'$12,000.00'), findsOneWidget);
      expect(find.text('Closing bank balance'), findsOneWidget);
      expect(find.text('Net Income'), findsOneWidget);
      expect(find.text(r'$5,000.00'), findsOneWidget);
      expect(find.text(r'-$500.00'), findsOneWidget);
    });
  });
}

FinancialReportPack _pack() {
  return FinancialReportPack(
    entityName: 'Kaysir Advisory',
    frameworkName: 'SAK Indonesia',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'FY 2026',
    asOfLabel: '31 Dec 2026',
    comparativePeriodLabel: 'FY 2025',
    comparativeAsOfLabel: '31 Dec 2025',
    periodStart: DateTime(2026),
    periodEnd: DateTime(2026, 12, 31),
    generatedAt: DateTime(2026, 12, 31, 18),
    statements: const [
      FinancialReportStatement(
        kind: FinancialReportStatementKind.financialPosition,
        title: 'Statement of Financial Position',
        subtitle: 'As of 31 Dec 2026',
        lines: [],
      ),
    ],
    notes: const [],
    complianceItems: const [
      FinancialReportComplianceItem(
        id: 'ready',
        title: 'Primary statements prepared',
        description: 'All primary statements are available.',
        standardReference: 'PSAK 1',
        isSatisfied: true,
      ),
      FinancialReportComplianceItem(
        id: 'review',
        title: 'Management review pending',
        description: 'Review sign-off is still pending.',
        standardReference: 'Internal control',
        isSatisfied: false,
      ),
    ],
    metrics: const [
      FinancialReportMetric(
        label: 'Cash',
        amount: 12000,
        helperText: 'Closing bank balance',
      ),
      FinancialReportMetric(
        label: 'Net Income',
        amount: 5000,
        comparativeAmount: 5500,
        helperText: 'Current year performance',
      ),
    ],
  );
}

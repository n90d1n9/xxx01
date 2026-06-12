import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_statement_components.dart';

void main() {
  group('financial report statement components', () {
    testWidgets('render wide comparative statement columns', (tester) async {
      await tester.binding.setSurfaceSize(const Size(980, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: FinancialReportStatementCard(
                pack: _pack(),
                statement: _financialPositionStatement(),
                isDarkMode: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Statement of Financial Position'), findsOneWidget);
      expect(find.text('PSAK 1'), findsOneWidget);
      expect(find.text('Line item'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('31 Dec 2025'), findsOneWidget);
      expect(find.text('Variance'), findsOneWidget);
      expect(find.text('Assets'), findsOneWidget);
      expect(find.text('Cash and bank'), findsOneWidget);
      expect(find.text('Note 1'), findsOneWidget);
      expect(find.text(r'$12,000.00'), findsOneWidget);
      expect(find.text(r'$13,000.00'), findsOneWidget);
      expect(find.text(r'-$1,000.00'), findsOneWidget);
    });

    testWidgets('stacks comparative amounts on compact widths', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: FinancialReportStatementCard(
                pack: _pack(),
                statement: _incomeStatement(),
                isDarkMode: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Profit or Loss and OCI'), findsOneWidget);
      expect(find.text('Line item'), findsNothing);
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text(r'Current $8,000.00'), findsOneWidget);
      expect(find.text(r'FY 2025 $7,500.00'), findsOneWidget);
      expect(find.text(r'Variance $500.00'), findsOneWidget);
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
    statements: [_financialPositionStatement(), _incomeStatement()],
    notes: const [],
    complianceItems: const [
      FinancialReportComplianceItem(
        id: 'ready',
        title: 'Primary statements prepared',
        description: 'All primary statements are available.',
        standardReference: 'PSAK 1',
        isSatisfied: true,
      ),
    ],
    metrics: const [],
  );
}

FinancialReportStatement _financialPositionStatement() {
  return const FinancialReportStatement(
    kind: FinancialReportStatementKind.financialPosition,
    title: 'Statement of Financial Position',
    subtitle: 'As of 31 Dec 2026',
    standardReferences: ['PSAK 1'],
    lines: [
      FinancialReportLine(
        label: 'Assets',
        type: FinancialReportLineType.section,
      ),
      FinancialReportLine(
        label: 'Cash and bank',
        amount: 12000,
        comparativeAmount: 13000,
        noteReference: '1',
      ),
    ],
  );
}

FinancialReportStatement _incomeStatement() {
  return const FinancialReportStatement(
    kind: FinancialReportStatementKind.profitOrLossAndOci,
    title: 'Profit or Loss and OCI',
    subtitle: 'For FY 2026',
    lines: [
      FinancialReportLine(
        label: 'Revenue',
        amount: 8000,
        comparativeAmount: 7500,
      ),
    ],
  );
}

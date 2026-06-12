import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_pack_layout_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_pack_view.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_statement_components.dart';

void main() {
  group('financial report pack layout components', () {
    testWidgets('stacks report sections with stable spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportPackSectionStack(
              spacing: 20,
              sections: [Text('Summary'), Text('Statements')],
            ),
          ),
        ),
      );

      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Statements'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 20,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders statement cards as one section', (tester) async {
      await tester.binding.setSurfaceSize(const Size(980, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportStatementSection(
              pack: _pack(),
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.byType(FinancialReportStatementCard), findsNWidgets(2));
      expect(find.text('Statement of Financial Position'), findsOneWidget);
      expect(find.text('Statement of Cash Flows'), findsOneWidget);
      expect(find.text('Compare 31 Dec 2025'), findsWidgets);
    });

    testWidgets('pack view composes sections without forced scrolling', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportPackView(
              pack: _pack(),
              isDarkMode: false,
              scrollable: false,
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(
        find.text('Kaysir Advisory Financial Report Pack'),
        findsOneWidget,
      );
      expect(find.text('SAK / IFRS Readiness'), findsOneWidget);
      expect(find.text('Report Exception Register'), findsOneWidget);
      expect(find.text('Statement of Financial Position'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
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
        standardReferences: ['PSAK 1'],
        lines: [
          FinancialReportLine(
            label: 'Cash and bank',
            amount: 12000,
            comparativeAmount: 13000,
          ),
        ],
      ),
      FinancialReportStatement(
        kind: FinancialReportStatementKind.cashFlows,
        title: 'Statement of Cash Flows',
        subtitle: 'For FY 2026',
        standardReferences: ['PSAK 207'],
        lines: [
          FinancialReportLine(
            label: 'Ending cash',
            amount: 12000,
            comparativeAmount: 13000,
          ),
        ],
      ),
    ],
    notes: const [
      FinancialReportDisclosureNote(
        number: '1',
        title: 'Basis of preparation',
        body: 'Prepared under SAK Indonesia.',
        standardReferences: ['PSAK 1'],
      ),
    ],
    complianceItems: const [
      FinancialReportComplianceItem(
        id: 'primary',
        title: 'Primary statements prepared',
        description: 'All primary statements are available.',
        standardReference: 'PSAK 1',
        isSatisfied: true,
      ),
    ],
    metrics: const [
      FinancialReportMetric(
        label: 'Cash',
        amount: 12000,
        helperText: 'Closing balance',
      ),
    ],
  );
}

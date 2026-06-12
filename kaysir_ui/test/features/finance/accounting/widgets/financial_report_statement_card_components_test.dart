import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_statement_card_components.dart';

void main() {
  group('financial report statement card components', () {
    testWidgets('renders statement header metadata and references', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportStatementCardHeader(
              statement: _statement,
              isDarkMode: false,
              lineCount: 2,
              showComparative: true,
              comparativeLabel: 'FY 2025',
            ),
          ),
        ),
      );

      expect(find.text('Statement of Cash Flows'), findsOneWidget);
      expect(find.text('For FY 2026'), findsOneWidget);
      expect(find.text('2 line(s)'), findsOneWidget);
      expect(find.text('Compare FY 2025'), findsOneWidget);
      expect(find.text('PSAK 207'), findsOneWidget);
      expect(
        financialReportStatementStartsExpanded(
          FinancialReportStatementKind.cashFlows,
        ),
        isFalse,
      );
      expect(
        financialReportStatementIcon(FinancialReportStatementKind.cashFlows),
        Icons.waterfall_chart_rounded,
      );
    });
  });
}

const _statement = FinancialReportStatement(
  kind: FinancialReportStatementKind.cashFlows,
  title: 'Statement of Cash Flows',
  subtitle: 'For FY 2026',
  standardReferences: ['PSAK 207'],
  lines: [
    FinancialReportLine(
      label: 'Operating cash flow',
      amount: 12000,
      comparativeAmount: 11000,
    ),
    FinancialReportLine(label: 'Ending cash', amount: 9000),
  ],
);

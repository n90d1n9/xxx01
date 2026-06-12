import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_compliance_panel.dart';

void main() {
  group('FinancialReportCompliancePanel', () {
    testWidgets('summarizes readiness and material exceptions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: FinancialReportCompliancePanel(
                pack: _packWithCompliance(),
                isDarkMode: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('SAK / IFRS Readiness'), findsOneWidget);
      expect(find.text('33% ready'), findsOneWidget);
      expect(find.text('1 of 3 controls'), findsOneWidget);
      expect(find.text('Ready'), findsWidgets);
      expect(find.text('Open'), findsWidgets);
      expect(find.text('Exceptions'), findsOneWidget);
      expect(find.text('Primary statements prepared'), findsOneWidget);
      expect(find.text('Revenue tie-out'), findsOneWidget);
      expect(find.text('Cash flow disclosure'), findsOneWidget);
      expect(find.text('Material'), findsOneWidget);
      expect(
        find.byTooltip(
          'PSAK 72: Revenue mapping does not reconcile to the ledger.\n'
          r'Current variance $9,500.00 | Comparative variance -$4,500.00'
          '\n'
          r'Material exception threshold $5,000.00 (Revenue)',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders an empty readiness state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportCompliancePanel(
              pack: _emptyPack(),
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('0% ready'), findsOneWidget);
      expect(find.text('0 of 0 controls'), findsOneWidget);
      expect(
        find.text('No readiness controls are attached to this report pack.'),
        findsOneWidget,
      );
    });
  });
}

FinancialReportPack _packWithCompliance() {
  return FinancialReportPack(
    entityName: 'Kaysir Advisory',
    frameworkName: 'SAK Indonesia',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'FY 2026',
    asOfLabel: '31 Dec 2026',
    periodStart: DateTime(2026),
    periodEnd: DateTime(2026, 12, 31),
    generatedAt: DateTime(2026, 12, 31, 18),
    statements: const [],
    notes: const [],
    complianceItems: const [
      FinancialReportComplianceItem(
        id: 'primary',
        title: 'Primary statements prepared',
        description: 'All primary statements are available.',
        standardReference: 'PSAK 1',
        isSatisfied: true,
      ),
      FinancialReportComplianceItem(
        id: 'revenue',
        title: 'Revenue tie-out',
        description: 'Revenue mapping does not reconcile to the ledger.',
        standardReference: 'PSAK 72',
        isSatisfied: false,
        variance: 9500,
        comparativeVariance: -4500,
        materialityThreshold: 5000,
        materialityBasis: 'Revenue',
      ),
      FinancialReportComplianceItem(
        id: 'cash-flow',
        title: 'Cash flow disclosure',
        description: 'Cash flow disclosure still needs review.',
        standardReference: 'PSAK 2',
        isSatisfied: false,
      ),
    ],
    metrics: const [],
  );
}

FinancialReportPack _emptyPack() {
  return FinancialReportPack(
    entityName: 'Kaysir Advisory',
    frameworkName: 'SAK Indonesia',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'FY 2026',
    asOfLabel: '31 Dec 2026',
    periodStart: DateTime(2026),
    periodEnd: DateTime(2026, 12, 31),
    generatedAt: DateTime(2026, 12, 31, 18),
    statements: const [],
    notes: const [],
    complianceItems: const [],
    metrics: const [],
  );
}

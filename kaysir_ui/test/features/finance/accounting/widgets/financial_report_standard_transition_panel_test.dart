import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_standard_transition.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';

void main() {
  testWidgets('renders PSAK 118 transition readiness metrics and checks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FinancialReportStandardTransitionPanel(summary: _summary),
          ),
        ),
      ),
    );

    expect(find.text('PSAK 118 Transition Readiness'), findsOneWidget);
    expect(find.text('PSAK 118 / IFRS 18'), findsOneWidget);
    expect(find.text('Effective 2027-01-01'), findsOneWidget);
    expect(find.text('2 ready'), findsOneWidget);
    expect(find.text('1 monitor'), findsOneWidget);
    expect(find.text('1 action'), findsOneWidget);
    expect(find.text('0 overdue'), findsOneWidget);
    expect(find.text('Required profit or loss subtotals'), findsOneWidget);
    expect(
      find.text('UKTM / management performance measure disclosure'),
      findsOneWidget,
    );
    expect(find.textContaining('Finance director'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      find.byType(
        FinancialReportResponsiveWrapGrid<
          FinancialReportStandardTransitionItem
        >,
      ),
      findsOneWidget,
    );
  });
}

final _summary = FinancialReportStandardTransitionSummary(
  currentStandardReference: 'PSAK 201 / IAS 1',
  nextStandardReference: 'PSAK 118 / IFRS 18',
  effectiveDate: DateTime(2027, 1, 1),
  daysUntilEffective: 214,
  items: const [
    FinancialReportStandardTransitionItem(
      kind: FinancialReportStandardTransitionKind.effectiveStandard,
      title: 'PSAK 118 effective-date watch',
      status: FinancialReportStandardTransitionStatus.monitor,
      metric: '214 day(s) remaining',
      owner: 'Reporting lead',
      reference: 'PSAK 118 / IFRS 18 effective 2027-01-01',
      detail: 'Track implementation work before PSAK 118 replaces PSAK 201.',
      evidenceReference: 'SAK Indonesia',
    ),
    FinancialReportStandardTransitionItem(
      kind: FinancialReportStandardTransitionKind.profitLossSubtotals,
      title: 'Required profit or loss subtotals',
      status: FinancialReportStandardTransitionStatus.actionRequired,
      metric: 'Operating mapped',
      owner: 'Reporting accountant',
      reference: 'PSAK 118 / IFRS 18',
      detail: 'Add the PSAK 118 subtotal for profit before financing and tax.',
      evidenceReference: 'Operating profit present',
    ),
    FinancialReportStandardTransitionItem(
      kind: FinancialReportStandardTransitionKind.managementPerformanceMeasures,
      title: 'UKTM / management performance measure disclosure',
      status: FinancialReportStandardTransitionStatus.ready,
      metric: 'Disclosure drafted',
      owner: 'Finance director',
      reference: 'PSAK 118 / IFRS 18',
      detail:
          'Management-defined performance measure disclosure is documented.',
      evidenceReference: 'UKTM note',
    ),
    FinancialReportStandardTransitionItem(
      kind: FinancialReportStandardTransitionKind.cashFlowPresentation,
      title: 'Cash flow presentation impact',
      status: FinancialReportStandardTransitionStatus.ready,
      metric: 'Buckets mapped',
      owner: 'Treasury / Cash accountant',
      reference: 'PSAK 118 / IFRS 18 / PSAK 207',
      detail: 'Operating, investing, and financing buckets are visible.',
      evidenceReference: 'Cash flow statement',
    ),
  ],
  readyCount: 2,
  monitorCount: 1,
  actionRequiredCount: 1,
  overdueCount: 0,
  notApplicableCount: 0,
  readinessRatio: 0.5,
  headline: 'PSAK 118 transition needs implementation work.',
  nextAction:
      'Required profit or loss subtotals: Add the PSAK 118 subtotal for profit before financing and tax.',
);

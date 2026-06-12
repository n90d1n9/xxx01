import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_going_concern_review.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';

void main() {
  testWidgets('renders going-concern review metrics and checks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FinancialReportGoingConcernReviewPanel(summary: _summary),
          ),
        ),
      ),
    );

    expect(find.text('Going Concern Review'), findsOneWidget);
    expect(find.text('PSAK 201 / IAS 1'), findsOneWidget);
    expect(
      find.text('Going-concern conclusion needs management follow-up.'),
      findsOneWidget,
    );
    expect(find.text('1 uncertainty'), findsOneWidget);
    expect(find.text('1 attention'), findsOneWidget);
    expect(find.text('1 watch'), findsOneWidget);
    expect(find.text('0 incomplete'), findsOneWidget);
    expect(find.text('Cash runway and liquidity buffer'), findsOneWidget);
    expect(find.text('Management going-concern conclusion'), findsOneWidget);
    expect(find.textContaining('Finance director'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      find.byType(
        FinancialReportResponsiveWrapGrid<
          FinancialReportGoingConcernReviewItem
        >,
      ),
      findsOneWidget,
    );
  });
}

const _summary = FinancialReportGoingConcernReviewSummary(
  standardReference: 'PSAK 201 / IAS 1',
  items: [
    FinancialReportGoingConcernReviewItem(
      kind: FinancialReportGoingConcernReviewKind.liquidityBuffer,
      title: 'Cash runway and liquidity buffer',
      status: FinancialReportGoingConcernReviewStatus.materialUncertainty,
      metric: '0.5 month(s)',
      owner: 'Treasury / Cash accountant',
      reference: 'PSAK 201 / IAS 1 / PSAK 207',
      detail: 'Cash runway needs management assessment.',
      evidenceReference: 'IDR 100.0M',
    ),
    FinancialReportGoingConcernReviewItem(
      kind: FinancialReportGoingConcernReviewKind.operatingPerformance,
      title: 'Profitability and loss trend',
      status: FinancialReportGoingConcernReviewStatus.attention,
      metric: '-15%',
      owner: 'Reporting accountant',
      reference: 'PSAK 201 / IAS 1',
      detail: 'Current-period loss should be explained.',
      evidenceReference: '-150.0M',
    ),
    FinancialReportGoingConcernReviewItem(
      kind: FinancialReportGoingConcernReviewKind.operatingCashFlow,
      title: 'Operating cash-flow support',
      status: FinancialReportGoingConcernReviewStatus.watch,
      metric: '-50.0M',
      owner: 'Treasury / Cash accountant',
      reference: 'PSAK 207 / PSAK 201 / IAS 1',
      detail: 'Negative operating cash flow should be monitored.',
      evidenceReference: '-50.0M',
    ),
    FinancialReportGoingConcernReviewItem(
      kind: FinancialReportGoingConcernReviewKind.managementAssessment,
      title: 'Management going-concern conclusion',
      status: FinancialReportGoingConcernReviewStatus.satisfactory,
      metric: 'Conclusion captured',
      owner: 'Finance director',
      reference: 'PSAK 201 / IAS 1',
      detail: 'Management assertion and release approval support the basis.',
      evidenceReference: 'GC-APPROVAL-001',
    ),
  ],
  satisfactoryCount: 1,
  watchCount: 1,
  attentionCount: 1,
  materialUncertaintyCount: 1,
  incompleteCount: 0,
  readinessRatio: 0.25,
  conclusion: 'Going-concern conclusion needs management follow-up.',
  nextAction: 'Cash runway and liquidity buffer: Cash runway needs review.',
);

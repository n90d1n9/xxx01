import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_subsequent_event_review.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';

void main() {
  testWidgets('renders subsequent events review metrics and checks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FinancialReportSubsequentEventReviewPanel(summary: _summary),
          ),
        ),
      ),
    );

    expect(find.text('Subsequent Events Review'), findsOneWidget);
    expect(find.text('1/4 checks complete'), findsOneWidget);
    expect(find.text('PSAK 210 / IAS 10'), findsOneWidget);
    expect(find.text('3d review window'), findsOneWidget);
    expect(find.text('1 due soon'), findsOneWidget);
    expect(find.text('1 overdue'), findsOneWidget);
    expect(find.text('1 blocked'), findsOneWidget);
    expect(find.text('Management subsequent-event inquiry'), findsOneWidget);
    expect(find.text('Authorization for issue captured'), findsOneWidget);
    expect(find.textContaining('Finance director'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      find.byType(
        FinancialReportResponsiveWrapGrid<
          FinancialReportSubsequentEventReviewItem
        >,
      ),
      findsOneWidget,
    );
  });
}

final _summary = FinancialReportSubsequentEventReviewSummary(
  periodEnd: DateTime(2026, 1, 31),
  authorizationTargetDate: DateTime(2026, 2, 3),
  reviewWindowDays: 3,
  standardReference: 'PSAK 210 / IAS 10',
  items: [
    FinancialReportSubsequentEventReviewItem(
      kind: FinancialReportSubsequentEventReviewKind.packageLock,
      title: 'Lock report package through review date',
      status: FinancialReportSubsequentEventReviewStatus.complete,
      dueDate: DateTime(2026, 2, 1),
      owner: 'Controller',
      reference: 'Package verified',
      detail: 'The displayed report package matches the closed package.',
      evidenceReference: 'ABCDEF123456',
    ),
    FinancialReportSubsequentEventReviewItem(
      kind: FinancialReportSubsequentEventReviewKind.managementInquiry,
      title: 'Management subsequent-event inquiry',
      status: FinancialReportSubsequentEventReviewStatus.blocked,
      dueDate: DateTime(2026, 2, 2),
      owner: 'Controller',
      reference: 'PSAK 210 / IAS 10',
      detail: 'Subsequent event inquiry needs follow-up.',
      evidenceReference: '',
    ),
    FinancialReportSubsequentEventReviewItem(
      kind: FinancialReportSubsequentEventReviewKind.adjustingEventAssessment,
      title: 'Adjusting event assessment',
      status: FinancialReportSubsequentEventReviewStatus.overdue,
      dueDate: DateTime(2026, 2, 2),
      owner: 'Reporting accountant',
      reference: 'PSAK 210 / IAS 10',
      detail: 'Required disclosure review item is unresolved.',
      evidenceReference: '',
    ),
    FinancialReportSubsequentEventReviewItem(
      kind: FinancialReportSubsequentEventReviewKind.authorizationForIssue,
      title: 'Authorization for issue captured',
      status: FinancialReportSubsequentEventReviewStatus.dueSoon,
      dueDate: DateTime(2026, 2, 3),
      owner: 'Finance director',
      reference: 'PSAK 210 / IAS 10',
      detail: 'Capture authorization date.',
      evidenceReference: '',
    ),
  ],
  completeCount: 1,
  openCount: 0,
  dueSoonCount: 1,
  overdueCount: 1,
  blockedCount: 1,
  completionRatio: 0.25,
  nextAction:
      'Management subsequent-event inquiry: Subsequent event inquiry needs follow-up.',
);

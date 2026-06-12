import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure_release_readiness.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_focus_highlight.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_management_measure_release_checklist.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets('renders UKTM release evidence checklist readiness', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FinancialReportManagementMeasureReleaseChecklistStrip(
            summary: _summary,
          ),
        ),
      ),
    );

    expect(find.text('UKTM Release Evidence'), findsOneWidget);
    expect(find.text('2 action(s)'), findsOneWidget);
    expect(find.text('Audit trail'), findsOneWidget);
    expect(find.text('Approval'), findsOneWidget);
    expect(find.text('Reconciliation'), findsOneWidget);
    expect(find.text('Export evidence'), findsOneWidget);
    expect(find.text('No event'), findsOneWidget);
    expect(find.text('0 variance(s)'), findsOneWidget);
    expect(find.byType(AppStatusPill), findsWidgets);

    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, closeTo(0.5, 0.001));
  });

  testWidgets('highlights a focused release checklist tile', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FinancialReportManagementMeasureReleaseChecklistStrip(
            summary: _summary,
            focusedKind:
                FinancialReportManagementMeasureReleaseCheckKind.exportEvidence,
          ),
        ),
      ),
    );

    final highlights = tester.widgetList<FinancialReportFocusHighlight>(
      find.byType(FinancialReportFocusHighlight),
    );

    expect(highlights.where((highlight) => highlight.active), hasLength(1));
    expect(
      highlights.where((highlight) => !highlight.active),
      hasLength(_summary.items.length - 1),
    );
  });
}

const _summary = FinancialReportManagementMeasureReleaseReadinessSummary(
  items: [
    FinancialReportManagementMeasureReleaseCheckItem(
      kind: FinancialReportManagementMeasureReleaseCheckKind.auditTrail,
      title: 'Audit trail',
      status: FinancialReportManagementMeasureReleaseCheckStatus.actionRequired,
      metric: 'No event',
      detail: 'Create UKTM approval or review audit evidence before archive.',
    ),
    FinancialReportManagementMeasureReleaseCheckItem(
      kind: FinancialReportManagementMeasureReleaseCheckKind.approval,
      title: 'Approval',
      status: FinancialReportManagementMeasureReleaseCheckStatus.ready,
      metric: '1/1 approved',
      detail: 'Every UKTM measure is approved for release.',
    ),
    FinancialReportManagementMeasureReleaseCheckItem(
      kind: FinancialReportManagementMeasureReleaseCheckKind.reconciliation,
      title: 'Reconciliation',
      status: FinancialReportManagementMeasureReleaseCheckStatus.ready,
      metric: '0 variance(s)',
      detail: 'UKTM measures reconcile to SAK subtotal and adjustments.',
    ),
    FinancialReportManagementMeasureReleaseCheckItem(
      kind: FinancialReportManagementMeasureReleaseCheckKind.exportEvidence,
      title: 'Export evidence',
      status: FinancialReportManagementMeasureReleaseCheckStatus.actionRequired,
      metric: 'Blocked',
      detail:
          'Complete audit trail, approval, and reconciliation gates before export/archive.',
    ),
  ],
  readyCount: 2,
  actionRequiredCount: 2,
  readyForExport: false,
  completionRatio: 0.5,
  nextAction:
      'Audit trail: Create UKTM approval or review audit evidence before archive.',
);

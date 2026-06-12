import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure_release_readiness.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_management_measure_release_readiness_service.dart';

void main() {
  group('FinancialReportManagementMeasureReleaseReadinessService', () {
    const service = FinancialReportManagementMeasureReleaseReadinessService();

    test('blocks export readiness until audit evidence is captured', () {
      final summary = service.summarize(
        reconciliations: [_approvedBalancedReconciliation],
        auditEvents: const [],
      );

      expect(summary.readyForExport, isFalse);
      expect(summary.readyCount, 2);
      expect(summary.actionRequiredCount, 2);
      expect(summary.nextAction, startsWith('Audit trail:'));
      expect(
        summary.items.first.status,
        FinancialReportManagementMeasureReleaseCheckStatus.actionRequired,
      );
    });

    test('marks UKTM release evidence ready when all gates pass', () {
      final summary = service.summarize(
        reconciliations: [_approvedBalancedReconciliation],
        auditEvents: [_approvedAuditEvent],
      );

      expect(summary.readyForExport, isTrue);
      expect(summary.readyCount, summary.items.length);
      expect(summary.actionRequiredCount, 0);
      expect(summary.completionRatio, 1);
      expect(
        summary.nextAction,
        'UKTM release evidence is ready for export and archive.',
      );
    });

    test('surfaces reconciliation variance before export readiness', () {
      final summary = service.summarize(
        reconciliations: [_approvedVarianceReconciliation],
        auditEvents: [_approvedAuditEvent],
      );

      final reconciliation = summary.items.firstWhere(
        (item) =>
            item.kind ==
            FinancialReportManagementMeasureReleaseCheckKind.reconciliation,
      );

      expect(summary.readyForExport, isFalse);
      expect(
        reconciliation.status,
        isNot(FinancialReportManagementMeasureReleaseCheckStatus.ready),
      );
      expect(summary.nextAction, startsWith('Reconciliation:'));
    });
  });
}

const _approvedBalancedReconciliation =
    FinancialReportManagementMeasureReconciliation(
      measure: FinancialReportManagementMeasure(
        id: 'uktm-operating-performance',
        label: 'management operating performance',
        owner: 'Controller',
        approvalStatus: FinancialReportManagementMeasureApprovalStatus.approved,
      ),
      subtotalAmount: 3800,
      measureAmount: 3800,
      adjustmentTotal: 0,
    );

const _approvedVarianceReconciliation =
    FinancialReportManagementMeasureReconciliation(
      measure: FinancialReportManagementMeasure(
        id: 'uktm-adjusted',
        label: 'adjusted operating performance',
        owner: 'Controller',
        approvalStatus: FinancialReportManagementMeasureApprovalStatus.approved,
        amountOverride: 4000,
      ),
      subtotalAmount: 3800,
      measureAmount: 4000,
      adjustmentTotal: 0,
    );

final _approvedAuditEvent = FinancialReportManagementMeasureAuditEvent(
  id: 'uktm-audit-1',
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  measureId: 'uktm-operating-performance',
  measureLabel: 'management operating performance',
  action: FinancialReportManagementMeasureAuditAction.approved,
  occurredAt: DateTime(2026, 2, 1, 10),
  actor: 'Controller',
  status: FinancialReportManagementMeasureApprovalStatus.approved,
  note: 'Approved for release.',
);

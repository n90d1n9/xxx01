import '../models/financial_report_management_measure.dart';
import '../models/financial_report_management_measure_release_readiness.dart';
import 'financial_report_management_measure_service.dart';

class FinancialReportManagementMeasureReleaseReadinessService {
  final FinancialReportManagementMeasureService managementMeasureService;

  const FinancialReportManagementMeasureReleaseReadinessService({
    this.managementMeasureService =
        const FinancialReportManagementMeasureService(),
  });

  FinancialReportManagementMeasureReleaseReadinessSummary summarize({
    required List<FinancialReportManagementMeasureReconciliation>
    reconciliations,
    required List<FinancialReportManagementMeasureAuditEvent> auditEvents,
  }) {
    final totalCount = reconciliations.length;
    final auditReady = auditEvents.isNotEmpty;
    final pendingApprovalCount = managementMeasureService.pendingApprovalCount(
      reconciliations,
    );
    final openVarianceCount = managementMeasureService.openVarianceCount(
      reconciliations,
    );
    final approvalReady = totalCount > 0 && pendingApprovalCount == 0;
    final reconciliationReady = totalCount > 0 && openVarianceCount == 0;
    final readyForExport = auditReady && approvalReady && reconciliationReady;

    final items = [
      FinancialReportManagementMeasureReleaseCheckItem(
        kind: FinancialReportManagementMeasureReleaseCheckKind.auditTrail,
        title: 'Audit trail',
        status: _status(auditReady),
        metric: auditReady ? '${auditEvents.length} event(s)' : 'No event',
        detail:
            auditReady
                ? 'UKTM status changes are captured for this period.'
                : 'Create UKTM approval or review audit evidence before archive.',
      ),
      FinancialReportManagementMeasureReleaseCheckItem(
        kind: FinancialReportManagementMeasureReleaseCheckKind.approval,
        title: 'Approval',
        status: _status(approvalReady),
        metric: '${totalCount - pendingApprovalCount}/$totalCount approved',
        detail:
            approvalReady
                ? 'Every UKTM measure is approved for release.'
                : 'Approve $pendingApprovalCount UKTM management measure(s).',
      ),
      FinancialReportManagementMeasureReleaseCheckItem(
        kind: FinancialReportManagementMeasureReleaseCheckKind.reconciliation,
        title: 'Reconciliation',
        status: _status(reconciliationReady),
        metric: '$openVarianceCount variance(s)',
        detail:
            reconciliationReady
                ? 'UKTM measures reconcile to SAK subtotal and adjustments.'
                : 'Resolve $openVarianceCount UKTM reconciliation variance(s).',
      ),
      FinancialReportManagementMeasureReleaseCheckItem(
        kind: FinancialReportManagementMeasureReleaseCheckKind.exportEvidence,
        title: 'Export evidence',
        status: _status(readyForExport),
        metric: readyForExport ? 'Ready' : 'Blocked',
        detail:
            readyForExport
                ? 'UKTM evidence is ready for report pack export and archive.'
                : 'Complete audit trail, approval, and reconciliation gates before export/archive.',
      ),
    ];
    final readyCount = items.where((item) => item.isReady).length;
    final actionRequiredCount = items.length - readyCount;

    return FinancialReportManagementMeasureReleaseReadinessSummary(
      items: List.unmodifiable(items),
      readyCount: readyCount,
      actionRequiredCount: actionRequiredCount,
      readyForExport: readyForExport,
      completionRatio: items.isEmpty ? 0 : readyCount / items.length,
      nextAction: _nextAction(items, readyForExport),
    );
  }

  FinancialReportManagementMeasureReleaseCheckStatus _status(bool ready) {
    return ready
        ? FinancialReportManagementMeasureReleaseCheckStatus.ready
        : FinancialReportManagementMeasureReleaseCheckStatus.actionRequired;
  }

  String _nextAction(
    List<FinancialReportManagementMeasureReleaseCheckItem> items,
    bool readyForExport,
  ) {
    if (readyForExport) {
      return 'UKTM release evidence is ready for export and archive.';
    }
    final blocker = items.firstWhere((item) => !item.isReady);
    return '${blocker.title}: ${blocker.detail}';
  }
}

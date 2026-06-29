import 'audit_pack_findings_models.dart';
import 'payroll_adjustment_models.dart';
import 'payroll_archive_models.dart';
import 'payroll_control_review_models.dart';
import 'payroll_exception_models.dart';
import 'payroll_journal_models.dart';
import 'payroll_liability_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_payslip_models.dart';
import 'payroll_reconciliation_models.dart';
import 'payroll_report_distribution_models.dart';
import 'payroll_run_close_models.dart';
import 'payroll_run_models.dart';

enum PayrollAuditEventType {
  run('Run'),
  adjustment('Adjustment'),
  exception('Exception'),
  reconciliation('Reconciliation'),
  release('Release'),
  compliance('Compliance'),
  distribution('Distribution'),
  finding('Finding'),
  archive('Archive');

  final String label;

  const PayrollAuditEventType(this.label);
}

enum PayrollAuditEventStatus {
  attention('Attention'),
  pending('Pending'),
  recorded('Recorded'),
  complete('Complete');

  final String label;

  const PayrollAuditEventStatus(this.label);
}

class PayrollAuditEvent {
  final String id;
  final String title;
  final String actor;
  final DateTime eventDate;
  final String detail;
  final PayrollAuditEventType type;
  final PayrollAuditEventStatus status;

  const PayrollAuditEvent({
    required this.id,
    required this.title,
    required this.actor,
    required this.eventDate,
    required this.detail,
    required this.type,
    required this.status,
  });

  bool get needsAttention => status == PayrollAuditEventStatus.attention;

  bool get isComplete => status == PayrollAuditEventStatus.complete;
}

class PayrollAuditTrailSummary {
  final String periodLabel;
  final List<PayrollAuditEvent> events;
  final String nextAction;

  const PayrollAuditTrailSummary({
    required this.periodLabel,
    required this.events,
    required this.nextAction,
  });

  factory PayrollAuditTrailSummary.fromRun({
    required DateTime asOfDate,
    required PayrollRunDashboard dashboard,
    required List<PayrollAdjustmentRequest> adjustments,
    required List<PayrollExceptionItem> exceptions,
    required PayrollReconciliationSummary reconciliation,
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollPayslipPackageSummary payslipPackage,
    required PayrollLiabilitySummary liabilities,
    required PayrollJournalPostingSummary journalPosting,
    required PayrollArchivePackageSummary archivePackage,
    required PayrollControlReviewSummary controlReview,
    required PayrollRunClosePlan closePlan,
    required PayrollReportDistributionSummary reportDistribution,
    required Map<String, AuditPackFindingRecord> auditFindingRecords,
  }) {
    final events = <PayrollAuditEvent>[
      PayrollAuditEvent(
        id: 'run-initialized',
        title: 'Payroll run initialized',
        actor: 'Payroll Ops',
        eventDate: DateTime(asOfDate.year, asOfDate.month, 1),
        detail:
            '${dashboard.employeeCount} employees, ${dashboard.status.label.toLowerCase()}',
        type: PayrollAuditEventType.run,
        status: PayrollAuditEventStatus.recorded,
      ),
      for (final adjustment in adjustments)
        PayrollAuditEvent(
          id: adjustment.id,
          title: '${adjustment.type.label} ${adjustment.status.label}',
          actor: 'Payroll Manager',
          eventDate: adjustment.submittedAt,
          detail: '${adjustment.employeeName} - ${adjustment.costCenter}',
          type: PayrollAuditEventType.adjustment,
          status:
              adjustment.isPending
                  ? PayrollAuditEventStatus.pending
                  : PayrollAuditEventStatus.recorded,
        ),
      for (final exception in exceptions)
        PayrollAuditEvent(
          id: exception.id,
          title: exception.title,
          actor: exception.owner,
          eventDate: exception.dueDate,
          detail:
              exception.isOpen
                  ? exception.action
                  : '${exception.employeeName} exception resolved',
          type: PayrollAuditEventType.exception,
          status:
              exception.isOpen
                  ? PayrollAuditEventStatus.attention
                  : PayrollAuditEventStatus.complete,
        ),
      PayrollAuditEvent(
        id: 'reconciliation-signoff',
        title: 'Reconciliation sign-off',
        actor: 'Finance Partner',
        eventDate: paymentBatch.payDate.subtract(const Duration(days: 5)),
        detail:
            reconciliation.isReviewed
                ? 'Funding and variance review signed off'
                : reconciliation.nextAction,
        type: PayrollAuditEventType.reconciliation,
        status:
            reconciliation.isReviewed
                ? PayrollAuditEventStatus.complete
                : reconciliation.canReview
                ? PayrollAuditEventStatus.pending
                : PayrollAuditEventStatus.attention,
      ),
      PayrollAuditEvent(
        id: 'lock-payroll',
        title: 'Payroll lock',
        actor: 'Payroll Manager',
        eventDate: paymentBatch.payDate.subtract(const Duration(days: 1)),
        detail:
            _stepComplete(closePlan, 'lock-payroll')
                ? '${dashboard.periodLabel} locked for payment'
                : 'Lock payroll calculations after reconciliation',
        type: PayrollAuditEventType.run,
        status:
            _stepComplete(closePlan, 'lock-payroll')
                ? PayrollAuditEventStatus.complete
                : PayrollAuditEventStatus.pending,
      ),
      PayrollAuditEvent(
        id: 'payment-release',
        title: 'Payment release',
        actor: 'Finance Ops',
        eventDate: paymentBatch.payDate,
        detail: paymentBatch.nextAction,
        type: PayrollAuditEventType.release,
        status:
            paymentBatch.pendingCount == 0
                ? PayrollAuditEventStatus.complete
                : paymentBatch.canRelease
                ? PayrollAuditEventStatus.pending
                : PayrollAuditEventStatus.attention,
      ),
      PayrollAuditEvent(
        id: 'payslip-publishing',
        title: 'Payslip publishing',
        actor: 'Payroll Ops',
        eventDate: paymentBatch.payDate.add(const Duration(days: 1)),
        detail: payslipPackage.nextAction,
        type: PayrollAuditEventType.release,
        status:
            payslipPackage.pendingCount == 0
                ? PayrollAuditEventStatus.complete
                : payslipPackage.canPublish
                ? PayrollAuditEventStatus.pending
                : PayrollAuditEventStatus.attention,
      ),
      PayrollAuditEvent(
        id: 'liability-remittance',
        title: 'Liability remittance',
        actor: 'Payroll Tax',
        eventDate: liabilities.nextDueLine?.dueDate ?? liabilities.payDate,
        detail: liabilities.nextAction,
        type: PayrollAuditEventType.compliance,
        status:
            liabilities.pendingCount == 0
                ? PayrollAuditEventStatus.complete
                : liabilities.canRemit
                ? PayrollAuditEventStatus.pending
                : PayrollAuditEventStatus.attention,
      ),
      PayrollAuditEvent(
        id: 'journal-posting',
        title: 'Journal posting',
        actor: 'Finance Controller',
        eventDate: paymentBatch.payDate.add(const Duration(days: 2)),
        detail: journalPosting.nextAction,
        type: PayrollAuditEventType.compliance,
        status:
            journalPosting.status == PayrollJournalPostingStatus.posted
                ? PayrollAuditEventStatus.complete
                : journalPosting.canPost
                ? PayrollAuditEventStatus.pending
                : PayrollAuditEventStatus.attention,
      ),
      PayrollAuditEvent(
        id: 'archive-package',
        title: 'Archive package',
        actor: 'Payroll Controller',
        eventDate: paymentBatch.payDate.add(const Duration(days: 5)),
        detail: archivePackage.nextAction,
        type: PayrollAuditEventType.archive,
        status:
            archivePackage.status == PayrollArchivePackageStatus.archived
                ? PayrollAuditEventStatus.complete
                : archivePackage.canArchive
                ? PayrollAuditEventStatus.pending
                : PayrollAuditEventStatus.attention,
      ),
      PayrollAuditEvent(
        id: 'control-review',
        title: 'Control review',
        actor: 'Payroll Controller',
        eventDate: paymentBatch.payDate.add(const Duration(days: 7)),
        detail: controlReview.nextAction,
        type: PayrollAuditEventType.compliance,
        status:
            controlReview.status == PayrollControlReviewStatus.reviewed
                ? PayrollAuditEventStatus.complete
                : controlReview.canReview
                ? PayrollAuditEventStatus.pending
                : PayrollAuditEventStatus.attention,
      ),
      for (final line in reportDistribution.deliveredLines)
        PayrollAuditEvent(
          id: 'distribution-${line.report.id}',
          title: '${line.report.title} delivered',
          actor: line.receipt!.deliveredBy,
          eventDate: line.receipt!.deliveredAt,
          detail: '${line.channel.label} - ${line.receipt!.recipientLabel}',
          type: PayrollAuditEventType.distribution,
          status: PayrollAuditEventStatus.complete,
        ),
      for (final record in auditFindingRecords.values) ...[
        if (record.remediatedAt != null)
          PayrollAuditEvent(
            id: 'finding-remediated-${record.checkpointId}',
            title: 'Audit finding remediated',
            actor: 'Payroll Controller',
            eventDate: record.remediatedAt!,
            detail:
                '${record.checkpointId} - ${record.resolutionNote.isEmpty ? 'Remediation evidence attached.' : record.resolutionNote}',
            type: PayrollAuditEventType.finding,
            status: PayrollAuditEventStatus.recorded,
          ),
        if (record.closedAt != null)
          PayrollAuditEvent(
            id: 'finding-closed-${record.checkpointId}',
            title: 'Audit finding closed',
            actor: 'Payroll Controller',
            eventDate: record.closedAt!,
            detail: '${record.checkpointId} reviewer validation complete',
            type: PayrollAuditEventType.finding,
            status: PayrollAuditEventStatus.complete,
          ),
      ],
      PayrollAuditEvent(
        id: 'close-period',
        title: 'Payroll period close',
        actor: 'Payroll Controller',
        eventDate: paymentBatch.payDate.add(const Duration(days: 8)),
        detail: closePlan.nextAction,
        type: PayrollAuditEventType.run,
        status:
            closePlan.isClosed
                ? PayrollAuditEventStatus.complete
                : PayrollAuditEventStatus.pending,
      ),
    ]..sort((left, right) => right.eventDate.compareTo(left.eventDate));

    final attention =
        events.where((event) => event.needsAttention).toList()
          ..sort((left, right) => left.eventDate.compareTo(right.eventDate));

    return PayrollAuditTrailSummary(
      periodLabel: dashboard.periodLabel,
      events: events,
      nextAction:
          attention.isEmpty
              ? 'Payroll audit trail is current.'
              : attention.first.detail,
    );
  }

  int get attentionCount {
    return events.where((event) => event.needsAttention).length;
  }

  int get completedCount {
    return events.where((event) => event.isComplete).length;
  }

  PayrollAuditEvent? get latestEvent {
    if (events.isEmpty) return null;
    return events.first;
  }
}

bool _stepComplete(PayrollRunClosePlan closePlan, String stepId) {
  return closePlan.steps.any((step) => step.id == stepId && step.isComplete);
}

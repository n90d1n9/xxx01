import 'package:uuid/uuid.dart';

import '../models/financial_report_management_measure.dart';

typedef FinancialReportManagementMeasureAuditIdGenerator = String Function();

class FinancialReportManagementMeasureAuditService {
  final FinancialReportManagementMeasureAuditIdGenerator nextId;

  FinancialReportManagementMeasureAuditService({
    FinancialReportManagementMeasureAuditIdGenerator? nextId,
  }) : nextId = nextId ?? const Uuid().v4;

  FinancialReportManagementMeasureAuditEvent measureSaved({
    required String periodKey,
    required String periodLabel,
    required FinancialReportManagementMeasure measure,
    required String actor,
    DateTime? occurredAt,
  }) {
    return _event(
      periodKey: periodKey,
      periodLabel: periodLabel,
      measure: measure,
      action: FinancialReportManagementMeasureAuditAction.saved,
      actor: actor,
      occurredAt: occurredAt,
      status: measure.approvalStatus,
      note: measure.reviewNote ?? '${measure.label} saved.',
    );
  }

  FinancialReportManagementMeasureAuditEvent statusChanged({
    required String periodKey,
    required String periodLabel,
    required FinancialReportManagementMeasure measure,
    required String actor,
    required String note,
    DateTime? occurredAt,
  }) {
    return _event(
      periodKey: periodKey,
      periodLabel: periodLabel,
      measure: measure,
      action: _actionForStatus(measure.approvalStatus),
      actor: actor,
      occurredAt: occurredAt,
      status: measure.approvalStatus,
      note: note,
    );
  }

  FinancialReportManagementMeasureAuditEvent removed({
    required String periodKey,
    required String periodLabel,
    required FinancialReportManagementMeasure measure,
    required String actor,
    DateTime? occurredAt,
  }) {
    return _event(
      periodKey: periodKey,
      periodLabel: periodLabel,
      measure: measure,
      action: FinancialReportManagementMeasureAuditAction.removed,
      actor: actor,
      occurredAt: occurredAt,
      status: measure.approvalStatus,
      note: '${measure.label} removed from the UKTM register.',
    );
  }

  FinancialReportManagementMeasureAuditEvent reset({
    required String periodKey,
    required String periodLabel,
    required String actor,
    DateTime? occurredAt,
  }) {
    return FinancialReportManagementMeasureAuditEvent(
      id: nextId(),
      periodKey: periodKey,
      periodLabel: periodLabel,
      measureId: 'uktm-register',
      measureLabel: 'UKTM register',
      action: FinancialReportManagementMeasureAuditAction.reset,
      occurredAt: occurredAt ?? DateTime.now(),
      actor: actor,
      note: 'UKTM register reset to the default operating performance measure.',
    );
  }

  List<FinancialReportManagementMeasureAuditEvent> newestFirst(
    Iterable<FinancialReportManagementMeasureAuditEvent> events,
  ) {
    return events.toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  FinancialReportManagementMeasureAuditEvent _event({
    required String periodKey,
    required String periodLabel,
    required FinancialReportManagementMeasure measure,
    required FinancialReportManagementMeasureAuditAction action,
    required String actor,
    DateTime? occurredAt,
    FinancialReportManagementMeasureApprovalStatus? status,
    required String note,
  }) {
    return FinancialReportManagementMeasureAuditEvent(
      id: nextId(),
      periodKey: periodKey,
      periodLabel: periodLabel,
      measureId: measure.id,
      measureLabel: measure.label,
      action: action,
      occurredAt: occurredAt ?? DateTime.now(),
      actor: actor,
      status: status,
      note: note,
    );
  }

  FinancialReportManagementMeasureAuditAction _actionForStatus(
    FinancialReportManagementMeasureApprovalStatus status,
  ) {
    switch (status) {
      case FinancialReportManagementMeasureApprovalStatus.approved:
        return FinancialReportManagementMeasureAuditAction.approved;
      case FinancialReportManagementMeasureApprovalStatus.inReview:
        return FinancialReportManagementMeasureAuditAction.submittedForReview;
      case FinancialReportManagementMeasureApprovalStatus.returned:
        return FinancialReportManagementMeasureAuditAction.returned;
      case FinancialReportManagementMeasureApprovalStatus.draft:
        return FinancialReportManagementMeasureAuditAction.saved;
    }
  }
}

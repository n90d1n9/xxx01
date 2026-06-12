import 'package:uuid/uuid.dart';

import '../models/financial_report_evidence_close_task.dart';

typedef FinancialReportEvidenceTaskAuditIdGenerator = String Function();

class FinancialReportEvidenceTaskAuditService {
  final FinancialReportEvidenceTaskAuditIdGenerator nextId;

  FinancialReportEvidenceTaskAuditService({
    FinancialReportEvidenceTaskAuditIdGenerator? nextId,
  }) : nextId = nextId ?? const Uuid().v4;

  FinancialReportEvidenceTaskAuditEvent evidenceSaved({
    required String periodKey,
    required String periodLabel,
    required FinancialReportEvidenceCloseTask task,
    required FinancialReportEvidenceCloseTaskResolution resolution,
  }) {
    return FinancialReportEvidenceTaskAuditEvent(
      id: nextId(),
      periodKey: periodKey,
      periodLabel: periodLabel,
      taskId: task.id,
      taskTitle: task.title,
      scheduleTitle: task.scheduleTitle,
      action: FinancialReportEvidenceTaskAuditAction.evidenceSaved,
      occurredAt: resolution.resolvedAt,
      actor: resolution.reviewer,
      status: resolution.status,
      note: resolution.note,
      evidenceReference: resolution.evidenceReference,
    );
  }

  List<FinancialReportEvidenceTaskAuditEvent> newestFirst(
    Iterable<FinancialReportEvidenceTaskAuditEvent> events,
  ) {
    return events.toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }
}

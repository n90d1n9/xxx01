import 'package:uuid/uuid.dart';

import '../models/financial_report_release_signoff.dart';

typedef FinancialReportReleaseSignOffAuditIdGenerator = String Function();

class FinancialReportReleaseSignOffAuditService {
  final FinancialReportReleaseSignOffAuditIdGenerator nextId;

  FinancialReportReleaseSignOffAuditService({
    FinancialReportReleaseSignOffAuditIdGenerator? nextId,
  }) : nextId = nextId ?? const Uuid().v4;

  FinancialReportReleaseSignOffAuditEvent resolutionSaved({
    required String periodKey,
    required String periodLabel,
    required FinancialReportReleaseSignOffItem item,
    required FinancialReportReleaseSignOffResolution resolution,
  }) {
    return FinancialReportReleaseSignOffAuditEvent(
      id: nextId(),
      periodKey: periodKey,
      periodLabel: periodLabel,
      requirementId: item.id,
      requirementTitle: item.requirement.title,
      role: item.role,
      action:
          resolution.status == FinancialReportReleaseSignOffStatus.signed
              ? FinancialReportReleaseSignOffAuditAction.signed
              : FinancialReportReleaseSignOffAuditAction.returned,
      occurredAt: resolution.signedAt,
      actor: resolution.signer,
      status: resolution.status,
      note: resolution.note,
      evidenceReference: resolution.evidenceReference,
    );
  }

  FinancialReportReleaseSignOffAuditEvent cleared({
    required String periodKey,
    required String periodLabel,
    required FinancialReportReleaseSignOffItem item,
    required String actor,
    DateTime? occurredAt,
  }) {
    return FinancialReportReleaseSignOffAuditEvent(
      id: nextId(),
      periodKey: periodKey,
      periodLabel: periodLabel,
      requirementId: item.id,
      requirementTitle: item.requirement.title,
      role: item.role,
      action: FinancialReportReleaseSignOffAuditAction.cleared,
      occurredAt: occurredAt ?? DateTime.now(),
      actor: actor,
      note: '${item.requirement.title} sign-off cleared.',
    );
  }

  List<FinancialReportReleaseSignOffAuditEvent> newestFirst(
    Iterable<FinancialReportReleaseSignOffAuditEvent> events,
  ) {
    return events.toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }
}

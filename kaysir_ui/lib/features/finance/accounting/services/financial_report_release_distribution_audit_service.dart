import 'package:uuid/uuid.dart';

import '../models/financial_report_release_distribution.dart';

typedef FinancialReportReleaseDistributionAuditIdGenerator = String Function();

class FinancialReportReleaseDistributionAuditService {
  final FinancialReportReleaseDistributionAuditIdGenerator nextId;

  FinancialReportReleaseDistributionAuditService({
    FinancialReportReleaseDistributionAuditIdGenerator? nextId,
  }) : nextId = nextId ?? const Uuid().v4;

  FinancialReportReleaseDistributionAuditEvent resolutionSaved({
    required String periodKey,
    required String periodLabel,
    required FinancialReportReleaseDistributionItem item,
    required FinancialReportReleaseDistributionResolution resolution,
  }) {
    return FinancialReportReleaseDistributionAuditEvent(
      id: nextId(),
      periodKey: periodKey,
      periodLabel: periodLabel,
      recipientId: item.id,
      recipientName: item.recipient.name,
      channel: item.recipient.channel,
      action: _actionForStatus(resolution.status),
      occurredAt: resolution.updatedAt,
      actor: resolution.owner,
      status: resolution.status,
      note: resolution.note,
      evidenceReference: resolution.evidenceReference,
    );
  }

  FinancialReportReleaseDistributionAuditEvent cleared({
    required String periodKey,
    required String periodLabel,
    required FinancialReportReleaseDistributionItem item,
    required String actor,
    DateTime? occurredAt,
  }) {
    return FinancialReportReleaseDistributionAuditEvent(
      id: nextId(),
      periodKey: periodKey,
      periodLabel: periodLabel,
      recipientId: item.id,
      recipientName: item.recipient.name,
      channel: item.recipient.channel,
      action: FinancialReportReleaseDistributionAuditAction.cleared,
      occurredAt: occurredAt ?? DateTime.now(),
      actor: actor,
      note: '${item.recipient.name} distribution status cleared.',
    );
  }

  List<FinancialReportReleaseDistributionAuditEvent> newestFirst(
    Iterable<FinancialReportReleaseDistributionAuditEvent> events,
  ) {
    return events.toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  FinancialReportReleaseDistributionAuditAction _actionForStatus(
    FinancialReportReleaseDistributionStatus status,
  ) {
    switch (status) {
      case FinancialReportReleaseDistributionStatus.acknowledged:
        return FinancialReportReleaseDistributionAuditAction.acknowledged;
      case FinancialReportReleaseDistributionStatus.exception:
        return FinancialReportReleaseDistributionAuditAction.exception;
      case FinancialReportReleaseDistributionStatus.pending:
      case FinancialReportReleaseDistributionStatus.sent:
        return FinancialReportReleaseDistributionAuditAction.sent;
    }
  }
}

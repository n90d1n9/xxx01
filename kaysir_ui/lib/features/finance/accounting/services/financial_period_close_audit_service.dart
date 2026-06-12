import 'package:uuid/uuid.dart';

import '../models/financial_period_close.dart';
import '../models/financial_period_close_audit.dart';

typedef FinancialPeriodCloseAuditIdGenerator = String Function();

class FinancialPeriodCloseAuditService {
  final FinancialPeriodCloseAuditIdGenerator nextId;

  FinancialPeriodCloseAuditService({
    FinancialPeriodCloseAuditIdGenerator? nextId,
  }) : nextId = nextId ?? const Uuid().v4;

  FinancialPeriodCloseAuditEvent closed(FinancialPeriodCloseRecord record) {
    return FinancialPeriodCloseAuditEvent(
      id: nextId(),
      periodKey: record.periodKey,
      periodLabel: record.periodLabel,
      action: FinancialPeriodCloseAuditAction.closed,
      occurredAt: record.closedAt ?? DateTime.now(),
      actor: record.closedBy ?? 'Unknown',
      reason: null,
      checklistReadinessRatio: record.checklistReadinessRatio,
      blockerCount: record.blockerCount,
      reportPackageHash: record.reportPackageHash,
      reportPackageHashAlgorithm: record.reportPackageHashAlgorithm,
      closingEntryPostingId: record.closingEntryPostingId,
      closingEntryReference: record.closingEntryReference,
      closingEntryPostedAt: record.closingEntryPostedAt,
    );
  }

  FinancialPeriodCloseAuditEvent reopened(FinancialPeriodCloseRecord record) {
    return FinancialPeriodCloseAuditEvent(
      id: nextId(),
      periodKey: record.periodKey,
      periodLabel: record.periodLabel,
      action: FinancialPeriodCloseAuditAction.reopened,
      occurredAt: record.reopenedAt ?? DateTime.now(),
      actor: record.reopenedBy ?? 'Unknown',
      reason: record.reopenReason,
      checklistReadinessRatio: record.checklistReadinessRatio,
      blockerCount: record.blockerCount,
      reportPackageHash: record.reportPackageHash,
      reportPackageHashAlgorithm: record.reportPackageHashAlgorithm,
      closingEntryPostingId: record.closingEntryPostingId,
      closingEntryReference: record.closingEntryReference,
      closingEntryPostedAt: record.closingEntryPostedAt,
    );
  }

  List<FinancialPeriodCloseAuditEvent> newestFirst(
    Iterable<FinancialPeriodCloseAuditEvent> events,
  ) {
    return events.toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }
}

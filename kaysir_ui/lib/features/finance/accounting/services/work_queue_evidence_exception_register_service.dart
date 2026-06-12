import '../models/accounting_workspace_work_queue.dart';
import '../models/work_queue_evidence_exception_register.dart';
import '../models/work_queue_evidence_readiness.dart';

/// Builds the active evidence exception register for accounting work queues.
class AccountingWorkspaceWorkQueueEvidenceExceptionRegisterService {
  const AccountingWorkspaceWorkQueueEvidenceExceptionRegisterService();

  AccountingWorkspaceWorkQueueEvidenceExceptionRegister build({
    required Iterable<AccountingWorkspaceWorkQueue> queues,
    required Map<String, AccountingWorkspaceWorkQueueEvidenceReadiness>
    evidenceReadinessByQueueId,
  }) {
    final exceptions = [
      for (final queue in queues)
        if (evidenceReadinessByQueueId[queue.id] case final readiness?
            when readiness.status !=
                AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready)
          AccountingWorkspaceWorkQueueEvidenceException(
            queueId: queue.id,
            title: queue.title,
            ownerLabel: queue.ownerLabel,
            dueLabel: queue.dueLabel,
            severity: queue.severity,
            slaStatus: queue.slaStatus,
            status: readiness.status,
            coverageLabel: readiness.coverageLabel,
            nextActionLabel: readiness.nextActionLabel,
            pendingReviewCount: readiness.pendingReviewCount,
            reworkEvidenceCount: readiness.reworkEvidenceCount,
            remainingItemCount: readiness.remainingItemCount,
          ),
    ]..sort(_compareEvidenceExceptions);

    return AccountingWorkspaceWorkQueueEvidenceExceptionRegister(
      items: exceptions,
    );
  }
}

int _compareEvidenceExceptions(
  AccountingWorkspaceWorkQueueEvidenceException left,
  AccountingWorkspaceWorkQueueEvidenceException right,
) {
  final priorityComparison = _exceptionPriority(
    right,
  ).compareTo(_exceptionPriority(left));
  if (priorityComparison != 0) return priorityComparison;

  return left.title.compareTo(right.title);
}

int _exceptionPriority(AccountingWorkspaceWorkQueueEvidenceException item) {
  return _statusRank(item.status) * 10000 +
      _severityRank(item.severity) * 1000 +
      _slaRank(item.slaStatus) * 100 +
      item.reworkEvidenceCount * 10 +
      item.pendingReviewCount +
      item.remainingItemCount;
}

int _statusRank(AccountingWorkspaceWorkQueueEvidenceReadinessStatus status) {
  switch (status) {
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework:
      return 4;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing:
      return 3;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded:
      return 2;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.partial:
      return 1;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready:
      return 0;
  }
}

int _severityRank(AccountingWorkspaceWorkQueueSeverity severity) {
  switch (severity) {
    case AccountingWorkspaceWorkQueueSeverity.critical:
      return 3;
    case AccountingWorkspaceWorkQueueSeverity.warning:
      return 2;
    case AccountingWorkspaceWorkQueueSeverity.info:
      return 1;
  }
}

int _slaRank(AccountingWorkspaceWorkQueueSlaStatus status) {
  switch (status) {
    case AccountingWorkspaceWorkQueueSlaStatus.overdue:
      return 3;
    case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
      return 2;
    case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
      return 1;
  }
}

import '../models/accounting_workspace_close_command_center.dart';
import '../models/accounting_workspace_work_queue_close_readiness.dart';
import '../models/accounting_workspace_work_queue_health.dart';
import '../models/accounting_workspace_work_queue_owner_summary.dart';
import '../models/accounting_workspace_work_queue_sla_summary.dart';

class AccountingWorkspaceCloseCommandCenterService {
  const AccountingWorkspaceCloseCommandCenterService();

  AccountingWorkspaceCloseCommandCenter summarize({
    required AccountingWorkspaceWorkQueueHealth health,
    required AccountingWorkspaceWorkQueueSlaSummary slaSummary,
    required AccountingWorkspaceWorkQueueOwnerSummary ownerSummary,
    required AccountingWorkspaceWorkQueueCloseReadiness closeReadiness,
  }) {
    final primaryOwner = ownerSummary.primaryOwner;
    final nextAction = closeReadiness.nextAction;

    return AccountingWorkspaceCloseCommandCenter(
      state: _stateFor(closeReadiness),
      hasQueues: health.hasQueues || closeReadiness.hasQueues,
      decisionLabel: closeReadiness.lockGateLabel,
      readinessLabel: closeReadiness.scoreLabel,
      decisionDetailLabel: _decisionDetailLabel(closeReadiness),
      primaryActionLabel: closeReadiness.actionLabel,
      openValueLabel: '${health.totalItems}',
      openDetailLabel: _openDetailLabel(health),
      evidenceValueLabel: '${closeReadiness.evidenceRequestItems}',
      evidenceDetailLabel: _evidenceDetailLabel(
        slaSummary: slaSummary,
        closeReadiness: closeReadiness,
      ),
      postingValueLabel: '${closeReadiness.postingGateItems}',
      postingDetailLabel: _postingDetailLabel(closeReadiness),
      ownerValueLabel: primaryOwner?.ownerLabel ?? 'No owner',
      ownerDetailLabel: _ownerDetailLabel(primaryOwner),
      nextActionLabel: nextAction?.previewLabel ?? 'No ranked action',
      nextActionQueueId: nextAction?.queueId,
      gateChecks: _gateChecks(
        slaSummary: slaSummary,
        closeReadiness: closeReadiness,
      ),
    );
  }
}

List<AccountingWorkspaceCloseCommandCenterGateCheck> _gateChecks({
  required AccountingWorkspaceWorkQueueSlaSummary slaSummary,
  required AccountingWorkspaceWorkQueueCloseReadiness closeReadiness,
}) {
  return [
    _blockerGate(closeReadiness),
    _evidenceGate(slaSummary: slaSummary, closeReadiness: closeReadiness),
    _postingGate(closeReadiness),
  ];
}

AccountingWorkspaceCloseCommandCenterGateCheck _blockerGate(
  AccountingWorkspaceWorkQueueCloseReadiness readiness,
) {
  if (readiness.hasReleaseBlockers) {
    return AccountingWorkspaceCloseCommandCenterGateCheck(
      id: 'blockers',
      label: 'Blockers',
      status: AccountingWorkspaceCloseCommandCenterGateStatus.blocked,
      statusLabel: 'Blocked',
      detailLabel: '${readiness.releaseBlockerItems} blockers before lock',
    );
  }

  return const AccountingWorkspaceCloseCommandCenterGateCheck(
    id: 'blockers',
    label: 'Blockers',
    status: AccountingWorkspaceCloseCommandCenterGateStatus.clear,
    statusLabel: 'Clear',
    detailLabel: 'No release blockers',
  );
}

AccountingWorkspaceCloseCommandCenterGateCheck _evidenceGate({
  required AccountingWorkspaceWorkQueueSlaSummary slaSummary,
  required AccountingWorkspaceWorkQueueCloseReadiness closeReadiness,
}) {
  if (!closeReadiness.hasEvidenceRequests) {
    return const AccountingWorkspaceCloseCommandCenterGateCheck(
      id: 'evidence',
      label: 'Evidence',
      status: AccountingWorkspaceCloseCommandCenterGateStatus.clear,
      statusLabel: 'Clear',
      detailLabel: 'Evidence clear',
    );
  }
  if (slaSummary.hasOverdueItems) {
    final dayLabel = slaSummary.worstOverdueDays == 1 ? 'day' : 'days';
    return AccountingWorkspaceCloseCommandCenterGateCheck(
      id: 'evidence',
      label: 'Evidence',
      status: AccountingWorkspaceCloseCommandCenterGateStatus.blocked,
      statusLabel: 'Blocked',
      detailLabel: '${slaSummary.worstOverdueDays} $dayLabel max overdue',
    );
  }
  if (slaSummary.hasDueTodayItems) {
    return AccountingWorkspaceCloseCommandCenterGateCheck(
      id: 'evidence',
      label: 'Evidence',
      status: AccountingWorkspaceCloseCommandCenterGateStatus.watch,
      statusLabel: 'Watch',
      detailLabel: '${slaSummary.dueTodayItems} due today',
    );
  }

  return AccountingWorkspaceCloseCommandCenterGateCheck(
    id: 'evidence',
    label: 'Evidence',
    status: AccountingWorkspaceCloseCommandCenterGateStatus.watch,
    statusLabel: 'Watch',
    detailLabel: '${closeReadiness.evidenceRequestItems} owner follow-ups',
  );
}

AccountingWorkspaceCloseCommandCenterGateCheck _postingGate(
  AccountingWorkspaceWorkQueueCloseReadiness readiness,
) {
  if (readiness.hasPostingGates) {
    return AccountingWorkspaceCloseCommandCenterGateCheck(
      id: 'posting',
      label: 'Posting',
      status: AccountingWorkspaceCloseCommandCenterGateStatus.watch,
      statusLabel: 'Review',
      detailLabel: '${readiness.postingGateItems} posting gates before lock',
    );
  }

  return const AccountingWorkspaceCloseCommandCenterGateCheck(
    id: 'posting',
    label: 'Posting',
    status: AccountingWorkspaceCloseCommandCenterGateStatus.clear,
    statusLabel: 'Clear',
    detailLabel: 'No posting gate',
  );
}

AccountingWorkspaceCloseCommandCenterState _stateFor(
  AccountingWorkspaceWorkQueueCloseReadiness readiness,
) {
  if (readiness.hasReleaseBlockers || readiness.readinessScore < 40) {
    return AccountingWorkspaceCloseCommandCenterState.blocked;
  }
  if (readiness.readinessScore >= 90) {
    return AccountingWorkspaceCloseCommandCenterState.ready;
  }
  if (readiness.readinessScore >= 70) {
    return AccountingWorkspaceCloseCommandCenterState.watch;
  }

  return AccountingWorkspaceCloseCommandCenterState.managementReview;
}

String _decisionDetailLabel(
  AccountingWorkspaceWorkQueueCloseReadiness readiness,
) {
  if (!readiness.hasQueues) return 'No active close pressure';
  if (readiness.hasReleaseBlockers) {
    return '${readiness.releaseBlockerItems} blockers before lock';
  }

  return readiness.primaryDriverDetailLabel;
}

String _openDetailLabel(AccountingWorkspaceWorkQueueHealth health) {
  if (!health.hasQueues) return 'No active queues';
  if (health.hasBlockedItems) return '${health.blockedItems} blocked';
  if (health.hasReviewItems) return '${health.reviewItems} in review';

  return '${health.monitorItems} monitoring';
}

String _evidenceDetailLabel({
  required AccountingWorkspaceWorkQueueSlaSummary slaSummary,
  required AccountingWorkspaceWorkQueueCloseReadiness closeReadiness,
}) {
  if (!closeReadiness.hasEvidenceRequests) return 'Evidence clear';
  if (slaSummary.hasOverdueItems) {
    final dayLabel = slaSummary.worstOverdueDays == 1 ? 'day' : 'days';
    return '${slaSummary.worstOverdueDays} $dayLabel max overdue';
  }
  if (slaSummary.hasDueTodayItems) {
    return '${slaSummary.dueTodayItems} due today';
  }

  return '${closeReadiness.evidenceRequestItems} owner follow-ups';
}

String _postingDetailLabel(
  AccountingWorkspaceWorkQueueCloseReadiness readiness,
) {
  if (!readiness.hasPostingGates) return 'No posting gate';

  return 'Review before lock';
}

String _ownerDetailLabel(AccountingWorkspaceWorkQueueOwnerLoad? owner) {
  if (owner == null) return 'No active load';
  if (owner.hasOverdueItems) return '${owner.overdueItems} overdue';
  if (owner.hasDueTodayItems) return '${owner.dueTodayItems} due today';
  if (owner.hasCriticalItems) return '${owner.criticalItems} blocked';

  return '${owner.onTrackItems} on track';
}

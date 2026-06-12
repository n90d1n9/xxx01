import '../models/accounting_workspace_close_command_center.dart';
import '../models/accounting_workspace_period_close_execution.dart';
import '../models/accounting_workspace_work_queue_close_readiness.dart';
import '../models/accounting_workspace_work_queue_owner_summary.dart';

class AccountingWorkspacePeriodCloseExecutionService {
  const AccountingWorkspacePeriodCloseExecutionService();

  AccountingWorkspacePeriodCloseExecution summarize({
    required AccountingWorkspaceCloseCommandCenter commandCenter,
    required AccountingWorkspaceWorkQueueCloseReadiness closeReadiness,
    required AccountingWorkspaceWorkQueueOwnerSummary ownerSummary,
  }) {
    final state = _stateFor(commandCenter.state);
    final firstAttentionGate = _firstAttentionGate(commandCenter.gateChecks);
    final ownerHandoff = _ownerHandoff(ownerSummary.primaryOwner);

    return AccountingWorkspacePeriodCloseExecution(
      state: state,
      hasQueues: commandCenter.hasQueues,
      statusLabel: _statusLabel(state),
      detailLabel: _detailLabel(state, commandCenter),
      progressValue: closeReadiness.readinessScore / 100,
      progressLabel: closeReadiness.scoreLabel,
      primaryActionLabel: _primaryActionLabel(state),
      reviewActionLabel:
          commandCenter.hasNextAction ? 'Review next close gate' : null,
      ownerHandoff: ownerHandoff,
      attentionLabel:
          firstAttentionGate == null
              ? 'No active gate blockers in workspace queues'
              : '${firstAttentionGate.label}: '
                  '${firstAttentionGate.detailLabel}',
      steps: _steps(commandCenter),
    );
  }
}

AccountingWorkspacePeriodCloseExecutionOwnerHandoff? _ownerHandoff(
  AccountingWorkspaceWorkQueueOwnerLoad? owner,
) {
  if (owner == null) return null;

  return AccountingWorkspacePeriodCloseExecutionOwnerHandoff(
    ownerLabel: owner.ownerLabel,
    loadLabel: _ownerLoadLabel(owner),
    riskLabel: _ownerRiskLabel(owner),
    actionLabel: 'Review owner queue',
  );
}

String _ownerLoadLabel(AccountingWorkspaceWorkQueueOwnerLoad owner) {
  final queueLabel = owner.queueCount == 1 ? 'queue' : 'queues';
  final itemLabel = owner.totalItems == 1 ? 'item' : 'items';

  return '${owner.queueCount} $queueLabel · '
      '${owner.totalItems} $itemLabel';
}

String _ownerRiskLabel(AccountingWorkspaceWorkQueueOwnerLoad owner) {
  if (owner.hasCriticalItems) return '${owner.criticalItems} critical';
  if (owner.hasOverdueItems) return '${owner.overdueItems} overdue';
  if (owner.hasDueTodayItems) return '${owner.dueTodayItems} due today';

  return '${owner.onTrackItems} on track';
}

AccountingWorkspacePeriodCloseExecutionState _stateFor(
  AccountingWorkspaceCloseCommandCenterState commandState,
) {
  switch (commandState) {
    case AccountingWorkspaceCloseCommandCenterState.ready:
      return AccountingWorkspacePeriodCloseExecutionState.ready;
    case AccountingWorkspaceCloseCommandCenterState.watch:
      return AccountingWorkspacePeriodCloseExecutionState.watch;
    case AccountingWorkspaceCloseCommandCenterState.managementReview:
      return AccountingWorkspacePeriodCloseExecutionState.review;
    case AccountingWorkspaceCloseCommandCenterState.blocked:
      return AccountingWorkspacePeriodCloseExecutionState.blocked;
  }
}

String _statusLabel(AccountingWorkspacePeriodCloseExecutionState state) {
  switch (state) {
    case AccountingWorkspacePeriodCloseExecutionState.ready:
      return 'Ready for lock workflow';
    case AccountingWorkspacePeriodCloseExecutionState.watch:
      return 'Close watch';
    case AccountingWorkspacePeriodCloseExecutionState.review:
      return 'Management review';
    case AccountingWorkspacePeriodCloseExecutionState.blocked:
      return 'Lock blocked';
  }
}

String _detailLabel(
  AccountingWorkspacePeriodCloseExecutionState state,
  AccountingWorkspaceCloseCommandCenter commandCenter,
) {
  switch (state) {
    case AccountingWorkspacePeriodCloseExecutionState.ready:
      return 'Checklist evidence and posting gates are ready for controller approval.';
    case AccountingWorkspacePeriodCloseExecutionState.watch:
    case AccountingWorkspacePeriodCloseExecutionState.review:
    case AccountingWorkspacePeriodCloseExecutionState.blocked:
      return commandCenter.decisionDetailLabel;
  }
}

String _primaryActionLabel(AccountingWorkspacePeriodCloseExecutionState state) {
  switch (state) {
    case AccountingWorkspacePeriodCloseExecutionState.ready:
      return 'Open lock workflow';
    case AccountingWorkspacePeriodCloseExecutionState.watch:
      return 'Open close workflow';
    case AccountingWorkspacePeriodCloseExecutionState.review:
      return 'Open review workflow';
    case AccountingWorkspacePeriodCloseExecutionState.blocked:
      return 'Open blocker workflow';
  }
}

List<AccountingWorkspacePeriodCloseExecutionStep> _steps(
  AccountingWorkspaceCloseCommandCenter commandCenter,
) {
  final blockers = _gateById(commandCenter.gateChecks, 'blockers');
  final evidence = _gateById(commandCenter.gateChecks, 'evidence');
  final posting = _gateById(commandCenter.gateChecks, 'posting');

  return [
    _gateStep(
      gate: blockers,
      id: 'blockers',
      label: 'Blocker gate',
      clearDetail: 'No release blockers',
    ),
    _gateStep(
      gate: evidence,
      id: 'evidence',
      label: 'Evidence gate',
      clearDetail: 'Evidence follow-ups clear',
    ),
    _gateStep(
      gate: posting,
      id: 'posting',
      label: 'Posting gate',
      clearDetail: 'Posting review clear',
    ),
    AccountingWorkspacePeriodCloseExecutionStep(
      id: 'lock-approval',
      label: 'Lock approval',
      status:
          commandCenter.state ==
                  AccountingWorkspaceCloseCommandCenterState.ready
              ? AccountingWorkspacePeriodCloseExecutionStepStatus.active
              : commandCenter.state ==
                  AccountingWorkspaceCloseCommandCenterState.blocked
              ? AccountingWorkspacePeriodCloseExecutionStepStatus.blocked
              : AccountingWorkspacePeriodCloseExecutionStepStatus.queued,
      detailLabel:
          commandCenter.state ==
                  AccountingWorkspaceCloseCommandCenterState.ready
              ? 'Controller can start final lock approval'
              : commandCenter.decisionDetailLabel,
    ),
  ];
}

AccountingWorkspacePeriodCloseExecutionStep _gateStep({
  required AccountingWorkspaceCloseCommandCenterGateCheck? gate,
  required String id,
  required String label,
  required String clearDetail,
}) {
  if (gate == null) {
    return AccountingWorkspacePeriodCloseExecutionStep(
      id: id,
      label: label,
      status: AccountingWorkspacePeriodCloseExecutionStepStatus.queued,
      detailLabel: 'Waiting for gate data',
    );
  }

  return AccountingWorkspacePeriodCloseExecutionStep(
    id: id,
    label: label,
    status: _stepStatusForGate(gate.status),
    detailLabel:
        gate.status == AccountingWorkspaceCloseCommandCenterGateStatus.clear
            ? clearDetail
            : gate.detailLabel,
  );
}

AccountingWorkspacePeriodCloseExecutionStepStatus _stepStatusForGate(
  AccountingWorkspaceCloseCommandCenterGateStatus status,
) {
  switch (status) {
    case AccountingWorkspaceCloseCommandCenterGateStatus.clear:
      return AccountingWorkspacePeriodCloseExecutionStepStatus.complete;
    case AccountingWorkspaceCloseCommandCenterGateStatus.watch:
      return AccountingWorkspacePeriodCloseExecutionStepStatus.active;
    case AccountingWorkspaceCloseCommandCenterGateStatus.blocked:
      return AccountingWorkspacePeriodCloseExecutionStepStatus.blocked;
  }
}

AccountingWorkspaceCloseCommandCenterGateCheck? _firstAttentionGate(
  Iterable<AccountingWorkspaceCloseCommandCenterGateCheck> gates,
) {
  for (final gate in gates) {
    if (gate.status != AccountingWorkspaceCloseCommandCenterGateStatus.clear) {
      return gate;
    }
  }

  return null;
}

AccountingWorkspaceCloseCommandCenterGateCheck? _gateById(
  Iterable<AccountingWorkspaceCloseCommandCenterGateCheck> gates,
  String id,
) {
  for (final gate in gates) {
    if (gate.id == id) return gate;
  }

  return null;
}

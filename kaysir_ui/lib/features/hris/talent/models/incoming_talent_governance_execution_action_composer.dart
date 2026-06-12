import 'incoming_talent_governance_execution_action.dart';
import 'incoming_talent_governance_execution_track.dart';

/// Builds owner-ready action playbooks from governance execution tracks.
List<IncomingTalentGovernanceExecutionAction>
buildIncomingTalentGovernanceExecutionActions({
  required List<IncomingTalentGovernanceExecutionTrack> tracks,
}) {
  final actions =
      tracks.where((track) => !track.isComplete).map(_actionFromTrack).toList()
        ..sort(_compareActions);

  return actions;
}

IncomingTalentGovernanceExecutionAction _actionFromTrack(
  IncomingTalentGovernanceExecutionTrack track,
) {
  final type = _typeForTrack(track);
  final priority = _priorityForTrack(track);

  return IncomingTalentGovernanceExecutionAction(
    id: 'talent-governance-execution-action:${track.id}',
    trackId: track.id,
    type: type,
    priority: priority,
    title: '${track.ownerName} - ${type.label.toLowerCase()}',
    detail: track.title,
    nextAction: _nextActionFor(track: track, type: type),
    playbook: _playbookFor(type),
    evidenceExpectation: track.evidenceExpectation,
    ownerName: track.ownerName,
    dueDate: track.dueDate,
    progressRatio: track.normalizedProgressRatio,
    signalCount: track.signalCount,
    decisionCount: track.decisionCount,
    readinessTaskCount: track.readinessTaskCount,
    overdue: track.overdue,
  );
}

IncomingTalentGovernanceExecutionActionType _typeForTrack(
  IncomingTalentGovernanceExecutionTrack track,
) {
  if (track.overdue) {
    return IncomingTalentGovernanceExecutionActionType.recoverOverdue;
  }

  return switch (track.status) {
    IncomingTalentGovernanceExecutionStatus.blocked =>
      IncomingTalentGovernanceExecutionActionType.clearBlocker,
    IncomingTalentGovernanceExecutionStatus.awaitingDecision =>
      IncomingTalentGovernanceExecutionActionType.recordDecision,
    IncomingTalentGovernanceExecutionStatus.evidenceRecovery =>
      IncomingTalentGovernanceExecutionActionType.attachEvidence,
    IncomingTalentGovernanceExecutionStatus.ownerConfirmation =>
      IncomingTalentGovernanceExecutionActionType.confirmOwner,
    IncomingTalentGovernanceExecutionStatus.inProgress =>
      IncomingTalentGovernanceExecutionActionType.publishFollowThrough,
    IncomingTalentGovernanceExecutionStatus.completed =>
      IncomingTalentGovernanceExecutionActionType.publishFollowThrough,
  };
}

IncomingTalentGovernanceExecutionActionPriority _priorityForTrack(
  IncomingTalentGovernanceExecutionTrack track,
) {
  if (track.overdue ||
      track.status == IncomingTalentGovernanceExecutionStatus.blocked) {
    return IncomingTalentGovernanceExecutionActionPriority.critical;
  }
  if (track.status ==
          IncomingTalentGovernanceExecutionStatus.awaitingDecision ||
      track.status ==
          IncomingTalentGovernanceExecutionStatus.evidenceRecovery) {
    return IncomingTalentGovernanceExecutionActionPriority.high;
  }
  return IncomingTalentGovernanceExecutionActionPriority.standard;
}

String _nextActionFor({
  required IncomingTalentGovernanceExecutionTrack track,
  required IncomingTalentGovernanceExecutionActionType type,
}) {
  final title = track.title.toLowerCase();

  return switch (type) {
    IncomingTalentGovernanceExecutionActionType.recoverOverdue =>
      'Ask ${track.ownerName} to recover overdue follow-through for $title.',
    IncomingTalentGovernanceExecutionActionType.clearBlocker =>
      'Ask ${track.ownerName} to resolve readiness blockers for $title.',
    IncomingTalentGovernanceExecutionActionType.recordDecision =>
      'Ask ${track.ownerName} to record the leadership decision for $title.',
    IncomingTalentGovernanceExecutionActionType.attachEvidence =>
      'Ask ${track.ownerName} to attach execution evidence for $title.',
    IncomingTalentGovernanceExecutionActionType.confirmOwner =>
      'Confirm ${track.ownerName} as accountable owner for $title.',
    IncomingTalentGovernanceExecutionActionType.publishFollowThrough =>
      'Ask ${track.ownerName} to publish follow-through for $title.',
  };
}

String _playbookFor(IncomingTalentGovernanceExecutionActionType type) {
  return switch (type) {
    IncomingTalentGovernanceExecutionActionType.recoverOverdue =>
      'Reconfirm due date, capture recovery evidence, and mark owner acceptance.',
    IncomingTalentGovernanceExecutionActionType.clearBlocker =>
      'Clear readiness blockers, attach missing evidence, and reopen execution.',
    IncomingTalentGovernanceExecutionActionType.recordDecision =>
      'Capture the decision, document conditions, and assign first follow-up.',
    IncomingTalentGovernanceExecutionActionType.attachEvidence =>
      'Attach evidence, refresh notes, and make the audit trail reviewable.',
    IncomingTalentGovernanceExecutionActionType.confirmOwner =>
      'Confirm the accountable owner, cadence, and escalation contact.',
    IncomingTalentGovernanceExecutionActionType.publishFollowThrough =>
      'Publish execution notes, start owner cadence, and set review checkpoint.',
  };
}

int _compareActions(
  IncomingTalentGovernanceExecutionAction left,
  IncomingTalentGovernanceExecutionAction right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final overdue = _boolRank(left.overdue).compareTo(_boolRank(right.overdue));
  if (overdue != 0) return overdue;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  final signals = right.signalCount.compareTo(left.signalCount);
  if (signals != 0) return signals;

  final decisions = right.decisionCount.compareTo(left.decisionCount);
  if (decisions != 0) return decisions;

  return left.title.compareTo(right.title);
}

int _boolRank(bool value) => value ? 0 : 1;

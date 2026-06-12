import 'incoming_talent_governance_execution_action.dart';
import 'incoming_talent_governance_execution_closure.dart';
import 'incoming_talent_governance_execution_evidence_item.dart';

/// Builds a governance execution evidence register from actions and closures.
List<IncomingTalentGovernanceExecutionEvidenceItem>
buildIncomingTalentGovernanceExecutionEvidenceItems({
  required List<IncomingTalentGovernanceExecutionAction> actions,
  required List<IncomingTalentGovernanceExecutionClosure> closures,
}) {
  final closuresByActionId = {
    for (final closure in closures) closure.actionId: closure,
  };
  final actionIds = actions.map((action) => action.id).toSet();

  final items = [
    for (final action in actions)
      _itemFromAction(action: action, closure: closuresByActionId[action.id]),
    for (final closure in closures)
      if (!actionIds.contains(closure.actionId)) _itemFromClosure(closure),
  ]..sort(_compareItems);

  return items;
}

IncomingTalentGovernanceExecutionEvidenceItem _itemFromAction({
  required IncomingTalentGovernanceExecutionAction action,
  required IncomingTalentGovernanceExecutionClosure? closure,
}) {
  final status =
      closure == null
          ? IncomingTalentGovernanceExecutionEvidenceStatus.missing
          : _statusForClosure(closure);

  return IncomingTalentGovernanceExecutionEvidenceItem(
    id: 'talent-governance-execution-evidence:${action.id}',
    actionId: action.id,
    trackId: action.trackId,
    status: status,
    title: '${action.ownerName} - ${action.type.label.toLowerCase()}',
    evidenceRequirement: action.evidenceExpectation,
    evidenceSummary: closure?.evidenceSummary ?? '',
    ownerConfirmationNote: closure?.ownerConfirmationNote ?? '',
    ownerName: action.ownerName,
    reviewerName: closure?.reviewerName ?? '',
    dueDate: action.dueDate,
    closureDate: closure?.closureDate,
    nextReviewDate: closure?.nextReviewDate,
    residualRiskCount: closure?.residualRiskCount ?? 0,
    signalCount: action.signalCount,
    decisionCount: action.decisionCount,
    readinessRatio: _readinessRatioFor(status),
  );
}

IncomingTalentGovernanceExecutionEvidenceItem _itemFromClosure(
  IncomingTalentGovernanceExecutionClosure closure,
) {
  final status = _statusForClosure(closure);

  return IncomingTalentGovernanceExecutionEvidenceItem(
    id: 'talent-governance-execution-evidence:${closure.actionId}',
    actionId: closure.actionId,
    trackId: closure.trackId,
    status: status,
    title: '${closure.ownerName} - ${closure.actionType.label.toLowerCase()}',
    evidenceRequirement:
        'Retain closure evidence, owner confirmation, and next-review notes.',
    evidenceSummary: closure.evidenceSummary,
    ownerConfirmationNote: closure.ownerConfirmationNote,
    ownerName: closure.ownerName,
    reviewerName: closure.reviewerName,
    dueDate: closure.actionDueDate,
    closureDate: closure.closureDate,
    nextReviewDate: closure.nextReviewDate,
    residualRiskCount: closure.residualRiskCount,
    signalCount: closure.signalCount,
    decisionCount: closure.decisionCount,
    readinessRatio: _readinessRatioFor(status),
  );
}

IncomingTalentGovernanceExecutionEvidenceStatus _statusForClosure(
  IncomingTalentGovernanceExecutionClosure closure,
) {
  return switch (closure.outcome) {
    IncomingTalentGovernanceExecutionClosureOutcome.completed =>
      IncomingTalentGovernanceExecutionEvidenceStatus.accepted,
    IncomingTalentGovernanceExecutionClosureOutcome.monitor =>
      IncomingTalentGovernanceExecutionEvidenceStatus.monitor,
    IncomingTalentGovernanceExecutionClosureOutcome.reopened =>
      IncomingTalentGovernanceExecutionEvidenceStatus.reopened,
    IncomingTalentGovernanceExecutionClosureOutcome.escalated =>
      IncomingTalentGovernanceExecutionEvidenceStatus.escalated,
  };
}

double _readinessRatioFor(
  IncomingTalentGovernanceExecutionEvidenceStatus status,
) {
  return switch (status) {
    IncomingTalentGovernanceExecutionEvidenceStatus.missing => 0.2,
    IncomingTalentGovernanceExecutionEvidenceStatus.escalated => 0.35,
    IncomingTalentGovernanceExecutionEvidenceStatus.reopened => 0.45,
    IncomingTalentGovernanceExecutionEvidenceStatus.monitor => 0.7,
    IncomingTalentGovernanceExecutionEvidenceStatus.accepted => 1,
  };
}

int _compareItems(
  IncomingTalentGovernanceExecutionEvidenceItem left,
  IncomingTalentGovernanceExecutionEvidenceItem right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final residualRisk = right.residualRiskCount.compareTo(
    left.residualRiskCount,
  );
  if (residualRisk != 0) return residualRisk;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  final signals = right.signalCount.compareTo(left.signalCount);
  if (signals != 0) return signals;

  return left.title.compareTo(right.title);
}

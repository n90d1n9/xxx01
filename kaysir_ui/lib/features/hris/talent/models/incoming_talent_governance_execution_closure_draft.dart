import 'incoming_talent_governance_execution_action.dart';
import 'incoming_talent_governance_execution_closure.dart';
import 'incoming_talent_governance_execution_closure_policy.dart';

/// Editable draft for closing a governance execution action.
class IncomingTalentGovernanceExecutionClosureDraft {
  final String actionId;
  final String trackId;
  final String ownerName;
  final String reviewerName;
  final IncomingTalentGovernanceExecutionActionType? actionType;
  final IncomingTalentGovernanceExecutionActionPriority? actionPriority;
  final DateTime? actionDueDate;
  final DateTime? closureDate;
  final IncomingTalentGovernanceExecutionClosureOutcome? outcome;
  final int residualRiskCount;
  final String evidenceSummary;
  final String ownerConfirmationNote;
  final String nextAction;
  final DateTime? nextReviewDate;
  final int signalCount;
  final int decisionCount;
  final DateTime asOfDate;

  const IncomingTalentGovernanceExecutionClosureDraft({
    required this.actionId,
    required this.trackId,
    required this.ownerName,
    required this.reviewerName,
    required this.actionType,
    required this.actionPriority,
    required this.actionDueDate,
    required this.closureDate,
    required this.outcome,
    required this.residualRiskCount,
    required this.evidenceSummary,
    required this.ownerConfirmationNote,
    required this.nextAction,
    required this.nextReviewDate,
    required this.signalCount,
    required this.decisionCount,
    required this.asOfDate,
  });

  factory IncomingTalentGovernanceExecutionClosureDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentGovernanceExecutionClosureDraft(
      actionId: '',
      trackId: '',
      ownerName: '',
      reviewerName: '',
      actionType: null,
      actionPriority: null,
      actionDueDate: null,
      closureDate: null,
      outcome: null,
      residualRiskCount: 0,
      evidenceSummary: '',
      ownerConfirmationNote: '',
      nextAction: '',
      nextReviewDate: null,
      signalCount: 0,
      decisionCount: 0,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentGovernanceExecutionClosureDraft.fromAction({
    required IncomingTalentGovernanceExecutionAction action,
    required DateTime asOfDate,
  }) {
    final defaults =
        IncomingTalentGovernanceExecutionClosureDefaults.fromAction(action);

    return IncomingTalentGovernanceExecutionClosureDraft(
      actionId: action.id,
      trackId: action.trackId,
      ownerName: action.ownerName,
      reviewerName: action.ownerName,
      actionType: action.type,
      actionPriority: action.priority,
      actionDueDate: action.dueDate,
      closureDate: asOfDate,
      outcome: defaults.outcome,
      residualRiskCount: defaults.residualRiskCount,
      evidenceSummary: defaults.evidenceSummary,
      ownerConfirmationNote: defaults.ownerConfirmationNote,
      nextAction: defaults.nextAction,
      nextReviewDate: asOfDate.add(defaults.nextReviewOffset),
      signalCount: action.signalCount,
      decisionCount: action.decisionCount,
      asOfDate: asOfDate,
    );
  }
}

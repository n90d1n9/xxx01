import 'incoming_talent_governance_execution_action.dart';

/// Closure outcome for governance execution follow-through.
enum IncomingTalentGovernanceExecutionClosureOutcome {
  completed('Completed'),
  monitor('Monitor'),
  reopened('Reopened'),
  escalated('Escalated');

  final String label;

  const IncomingTalentGovernanceExecutionClosureOutcome(this.label);
}

/// Completed closure record for a governance execution action.
class IncomingTalentGovernanceExecutionClosure {
  final String id;
  final String actionId;
  final String trackId;
  final String ownerName;
  final String reviewerName;
  final IncomingTalentGovernanceExecutionActionType actionType;
  final IncomingTalentGovernanceExecutionActionPriority actionPriority;
  final DateTime actionDueDate;
  final DateTime closureDate;
  final IncomingTalentGovernanceExecutionClosureOutcome outcome;
  final int residualRiskCount;
  final String evidenceSummary;
  final String ownerConfirmationNote;
  final String nextAction;
  final DateTime nextReviewDate;
  final int signalCount;
  final int decisionCount;
  final DateTime createdAt;

  const IncomingTalentGovernanceExecutionClosure({
    required this.id,
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
    required this.createdAt,
  });

  bool get needsAttention {
    return outcome !=
            IncomingTalentGovernanceExecutionClosureOutcome.completed ||
        residualRiskCount > 0;
  }
}

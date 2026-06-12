import 'incoming_talent_governance_execution_action.dart';
import 'incoming_talent_governance_execution_closure.dart';
import 'incoming_talent_governance_execution_closure_draft.dart';

/// Copy helpers for governance execution closure drafts.
extension IncomingTalentGovernanceExecutionClosureDraftCopy
    on IncomingTalentGovernanceExecutionClosureDraft {
  IncomingTalentGovernanceExecutionClosureDraft copyWith({
    String? actionId,
    String? trackId,
    String? ownerName,
    String? reviewerName,
    IncomingTalentGovernanceExecutionActionType? actionType,
    IncomingTalentGovernanceExecutionActionPriority? actionPriority,
    DateTime? actionDueDate,
    DateTime? closureDate,
    IncomingTalentGovernanceExecutionClosureOutcome? outcome,
    int? residualRiskCount,
    String? evidenceSummary,
    String? ownerConfirmationNote,
    String? nextAction,
    DateTime? nextReviewDate,
    int? signalCount,
    int? decisionCount,
    DateTime? asOfDate,
  }) {
    return IncomingTalentGovernanceExecutionClosureDraft(
      actionId: actionId ?? this.actionId,
      trackId: trackId ?? this.trackId,
      ownerName: ownerName ?? this.ownerName,
      reviewerName: reviewerName ?? this.reviewerName,
      actionType: actionType ?? this.actionType,
      actionPriority: actionPriority ?? this.actionPriority,
      actionDueDate: actionDueDate ?? this.actionDueDate,
      closureDate: closureDate ?? this.closureDate,
      outcome: outcome ?? this.outcome,
      residualRiskCount: residualRiskCount ?? this.residualRiskCount,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      ownerConfirmationNote:
          ownerConfirmationNote ?? this.ownerConfirmationNote,
      nextAction: nextAction ?? this.nextAction,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      signalCount: signalCount ?? this.signalCount,
      decisionCount: decisionCount ?? this.decisionCount,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}

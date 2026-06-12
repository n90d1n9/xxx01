import 'incoming_talent_governance_execution_closure.dart';
import 'incoming_talent_governance_execution_closure_draft.dart';
import 'incoming_talent_governance_execution_closure_policy.dart';

/// Submission helpers for governance execution closure drafts.
extension IncomingTalentGovernanceExecutionClosureDraftSubmission
    on IncomingTalentGovernanceExecutionClosureDraft {
  double get completionRatio {
    final completed =
        [
          actionId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          actionType != null,
          actionPriority != null,
          actionDueDate != null,
          closureDate != null,
          outcome != null,
          validateIncomingTalentGovernanceExecutionClosureResidualRisk(
                residualRiskCount,
              ) ==
              null,
          evidenceSummary.trim().length >= 12,
          ownerConfirmationNote.trim().length >= 12,
          nextAction.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 12;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentGovernanceExecutionClosureRequired(
            actionId,
            'a governance execution action',
          )
          case final error?)
        error,
      if (validateIncomingTalentGovernanceExecutionClosureRequired(
            reviewerName,
            'a closure reviewer',
          )
          case final error?)
        error,
      if (actionType == null) 'Select a governance execution action type',
      if (actionPriority == null) 'Select a governance execution priority',
      if (actionDueDate == null) 'Select governance action due date',
      if (validateIncomingTalentGovernanceExecutionClosureDate(
            closureDate,
            asOfDate,
          )
          case final error?)
        error,
      if (validateIncomingTalentGovernanceExecutionClosureOutcome(outcome)
          case final error?)
        error,
      if (validateIncomingTalentGovernanceExecutionClosureResidualRisk(
            residualRiskCount,
          )
          case final error?)
        error,
      if (validateIncomingTalentGovernanceExecutionClosureLongText(
            evidenceSummary,
            'evidence summary',
          )
          case final error?)
        error,
      if (validateIncomingTalentGovernanceExecutionClosureLongText(
            ownerConfirmationNote,
            'owner confirmation note',
          )
          case final error?)
        error,
      if (validateIncomingTalentGovernanceExecutionClosureLongText(
            nextAction,
            'next action',
          )
          case final error?)
        error,
      if (validateIncomingTalentGovernanceExecutionClosureNextReviewDate(
            closureDate,
            nextReviewDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentGovernanceExecutionClosure toClosure({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentGovernanceExecutionClosure(
      id: id,
      actionId: actionId.trim(),
      trackId: trackId.trim(),
      ownerName: ownerName.trim(),
      reviewerName: reviewerName.trim(),
      actionType: actionType!,
      actionPriority: actionPriority!,
      actionDueDate: actionDueDate!,
      closureDate: closureDate!,
      outcome: outcome!,
      residualRiskCount: residualRiskCount,
      evidenceSummary: evidenceSummary.trim(),
      ownerConfirmationNote: ownerConfirmationNote.trim(),
      nextAction: nextAction.trim(),
      nextReviewDate: nextReviewDate!,
      signalCount: signalCount,
      decisionCount: decisionCount,
      createdAt: createdAt,
    );
  }
}

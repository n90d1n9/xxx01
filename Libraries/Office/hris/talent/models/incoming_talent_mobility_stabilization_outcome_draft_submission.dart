import 'incoming_talent_mobility_stabilization_outcome.dart';
import 'incoming_talent_mobility_stabilization_outcome_draft.dart';

extension IncomingTalentMobilityStabilizationOutcomeDraftSubmission
    on IncomingTalentMobilityStabilizationOutcomeDraft {
  double get completionRatio {
    final completed =
        [
          actionId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          IncomingTalentMobilityStabilizationOutcomeDraft.validateActionStatus(
                actionStatus,
              ) ==
              null,
          outcomeDate != null,
          decision != null,
          residualRisk != null,
          IncomingTalentMobilityStabilizationOutcomeDraft.validateHostConfidenceAfter(
                hostConfidenceAfter,
              ) ==
              null,
          evidenceSummary.trim().length >= 12,
          learningSummary.trim().length >= 12,
          nextCadenceAction.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (IncomingTalentMobilityStabilizationOutcomeDraft.validateRequired(
            actionId,
            'a completed stabilization action',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationOutcomeDraft.validateRequired(
            reviewerName,
            'an outcome reviewer',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationOutcomeDraft.validateActionStatus(
            actionStatus,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationOutcomeDraft.validateOutcomeDate(
            outcomeDate,
            asOfDate,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationOutcomeDraft.validateDecision(
            decision,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationOutcomeDraft.validateResidualRisk(
            residualRisk,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationOutcomeDraft.validateHostConfidenceAfter(
            hostConfidenceAfter,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationOutcomeDraft.validateEvidenceSummary(
            evidenceSummary,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationOutcomeDraft.validateLearningSummary(
            learningSummary,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationOutcomeDraft.validateNextCadenceAction(
            nextCadenceAction,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationOutcomeDraft.validateNextReviewDate(
            outcomeDate,
            nextReviewDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentMobilityStabilizationOutcome toOutcome({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentMobilityStabilizationOutcome(
      id: id,
      actionId: actionId,
      reviewId: reviewId,
      checklistId: checklistId,
      matchId: matchId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      currentRole: currentRole.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      opportunityTitle: opportunityTitle.trim(),
      hostDepartment: hostDepartment.trim(),
      actionType: actionType!,
      actionStatus: actionStatus!,
      actionOwnerName: actionOwnerName.trim(),
      actionSummary: actionSummary.trim(),
      reviewOutcomeBefore: reviewOutcomeBefore!,
      retentionRiskBefore: retentionRiskBefore!,
      hostConfidenceBefore: hostConfidenceBefore,
      reviewerName: reviewerName.trim(),
      outcomeDate: outcomeDate!,
      decision: decision!,
      residualRisk: residualRisk!,
      hostConfidenceAfter: hostConfidenceAfter,
      evidenceSummary: evidenceSummary.trim(),
      learningSummary: learningSummary.trim(),
      nextCadenceAction: nextCadenceAction.trim(),
      nextReviewDate: nextReviewDate!,
      createdAt: createdAt,
    );
  }
}

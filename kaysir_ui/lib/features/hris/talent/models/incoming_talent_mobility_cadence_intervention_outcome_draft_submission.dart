import 'incoming_talent_mobility_cadence_intervention_outcome.dart';
import 'incoming_talent_mobility_cadence_intervention_outcome_draft.dart';

extension IncomingTalentMobilityCadenceInterventionOutcomeDraftSubmission
    on IncomingTalentMobilityCadenceInterventionOutcomeDraft {
  double get completionRatio {
    final completed =
        [
          interventionId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateInterventionStatus(
                interventionStatus,
              ) ==
              null,
          reviewDate != null,
          decision != null,
          sustainability != null,
          residualRiskAfter != null,
          IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateHostConfidenceAfter(
                hostConfidenceAfter,
              ) ==
              null,
          evidenceSummary.trim().length >= 12,
          learningSummary.trim().length >= 12,
          nextCadenceAction.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 12;
  }

  List<String> get validationErrors {
    return [
      if (IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateRequired(
            interventionId,
            'a resolved intervention',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateRequired(
            reviewerName,
            'an outcome reviewer',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateInterventionStatus(
            interventionStatus,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateReviewDate(
            reviewDate,
            asOfDate,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateDecision(
            decision,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateSustainability(
            sustainability,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateResidualRisk(
            residualRiskAfter,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateHostConfidenceAfter(
            hostConfidenceAfter,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateEvidenceSummary(
            evidenceSummary,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateLearningSummary(
            learningSummary,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateNextCadenceAction(
            nextCadenceAction,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionOutcomeDraft.validateNextReviewDate(
            reviewDate,
            nextReviewDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentMobilityCadenceInterventionOutcome toOutcome({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentMobilityCadenceInterventionOutcome(
      id: id,
      interventionId: interventionId,
      checkInId: checkInId,
      outcomeId: outcomeId,
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
      cadenceStatusBefore: cadenceStatusBefore!,
      residualRiskBefore: residualRiskBefore!,
      hostConfidenceBefore: hostConfidenceBefore,
      interventionType: interventionType!,
      priority: priority!,
      interventionStatus: interventionStatus!,
      interventionOwnerName: interventionOwnerName.trim(),
      interventionSummary: interventionSummary.trim(),
      reviewerName: reviewerName.trim(),
      reviewDate: reviewDate!,
      decision: decision!,
      sustainability: sustainability!,
      residualRiskAfter: residualRiskAfter!,
      hostConfidenceAfter: hostConfidenceAfter,
      evidenceSummary: evidenceSummary.trim(),
      learningSummary: learningSummary.trim(),
      nextCadenceAction: nextCadenceAction.trim(),
      nextReviewDate: nextReviewDate!,
      createdAt: createdAt,
    );
  }
}

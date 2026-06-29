import 'incoming_talent_career_path_support_outcome.dart';
import 'incoming_talent_career_path_support_outcome_draft.dart';
import 'incoming_talent_career_path_support_outcome_policy.dart';

extension IncomingTalentCareerPathSupportOutcomeDraftSubmission
    on IncomingTalentCareerPathSupportOutcomeDraft {
  double get completionRatio {
    final completed =
        [
          actionId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          validateIncomingTalentCareerPathSupportOutcomeActionStatus(
                actionStatus,
              ) ==
              null,
          outcomeDate != null,
          decision != null,
          residualRisk != null,
          validateIncomingTalentCareerPathSupportOutcomeVerifiedLevel(
                verifiedLevel,
              ) ==
              null,
          evidenceSummary.trim().length >= 12,
          managerNote.trim().length >= 12,
          nextReviewAction.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentCareerPathSupportOutcomeRequired(
            actionId,
            'a resolved support action',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportOutcomeRequired(
            reviewerName,
            'an outcome reviewer',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportOutcomeActionStatus(
            actionStatus,
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportOutcomeDate(
            outcomeDate,
            asOfDate,
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportOutcomeDecision(decision)
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportOutcomeResidualRisk(
            residualRisk,
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportOutcomeVerifiedLevel(
            verifiedLevel,
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportOutcomeLongText(
            evidenceSummary,
            'evidence summary',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportOutcomeLongText(
            managerNote,
            'manager note',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportOutcomeLongText(
            nextReviewAction,
            'next review action',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportOutcomeNextReviewDate(
            outcomeDate,
            nextReviewDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentCareerPathSupportOutcome toOutcome({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentCareerPathSupportOutcome(
      id: id,
      actionId: actionId,
      reviewId: reviewId,
      careerPathId: careerPathId,
      portfolioId: portfolioId,
      roadmapId: roadmapId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      competencyName: competencyName.trim(),
      actionType: actionType!,
      actionPriority: actionPriority!,
      actionStatus: actionStatus!,
      actionOwnerName: actionOwnerName.trim(),
      actionPlan: actionPlan.trim(),
      successCriteria: successCriteria.trim(),
      sourceDecision: sourceDecision!,
      reviewedLevelBefore: reviewedLevelBefore,
      targetLevel: targetLevel,
      sourceLevelGap: sourceLevelGap,
      reviewerName: reviewerName.trim(),
      outcomeDate: outcomeDate!,
      decision: decision!,
      residualRisk: residualRisk!,
      verifiedLevel: verifiedLevel,
      evidenceSummary: evidenceSummary.trim(),
      managerNote: managerNote.trim(),
      nextReviewAction: nextReviewAction.trim(),
      nextReviewDate: nextReviewDate!,
      createdAt: createdAt,
    );
  }
}

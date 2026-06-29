import 'incoming_talent_mobility_cadence_check_in.dart';
import 'incoming_talent_mobility_cadence_check_in_draft.dart';

extension IncomingTalentMobilityCadenceCheckInDraftSubmission
    on IncomingTalentMobilityCadenceCheckInDraft {
  double get completionRatio {
    final completed =
        [
          outcomeId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          checkInDate != null,
          status != null,
          residualRisk != null,
          IncomingTalentMobilityCadenceCheckInDraft.validateHostConfidence(
                hostConfidenceScore,
              ) ==
              null,
          pulseSummary.trim().length >= 12,
          supportPlan.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 9;
  }

  List<String> get validationErrors {
    return [
      if (IncomingTalentMobilityCadenceCheckInDraft.validateRequired(
            outcomeId,
            'a mobility outcome',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceCheckInDraft.validateRequired(
            reviewerName,
            'a cadence reviewer',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceCheckInDraft.validateCheckInDate(
            checkInDate,
            asOfDate,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceCheckInDraft.validateStatus(status)
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceCheckInDraft.validateResidualRisk(
            residualRisk,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceCheckInDraft.validateHostConfidence(
            hostConfidenceScore,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceCheckInDraft.validatePulseSummary(
            pulseSummary,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceCheckInDraft.validateSupportPlan(
            supportPlan,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceCheckInDraft.validateNextReviewDate(
            checkInDate,
            nextReviewDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentMobilityCadenceCheckIn toCheckIn({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentMobilityCadenceCheckIn(
      id: id,
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
      outcomeDecision: outcomeDecision!,
      previousResidualRisk: previousResidualRisk!,
      previousHostConfidence: previousHostConfidence,
      reviewerName: reviewerName.trim(),
      checkInDate: checkInDate!,
      status: status!,
      residualRisk: residualRisk!,
      hostConfidenceScore: hostConfidenceScore,
      pulseSummary: pulseSummary.trim(),
      supportPlan: supportPlan.trim(),
      nextReviewDate: nextReviewDate!,
      createdAt: createdAt,
    );
  }
}

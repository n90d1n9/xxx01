import 'incoming_talent_promotion_stabilization_follow_up_resolution.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution_draft.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution_policy.dart';

/// Submission helpers for promotion follow-up resolution drafts.
extension IncomingTalentPromotionStabilizationFollowUpResolutionDraftSubmission
    on IncomingTalentPromotionStabilizationFollowUpResolutionDraft {
  double get completionRatio {
    final completed =
        [
          actionId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          validateIncomingTalentPromotionFollowUpResolutionSourceStatus(
                actionStatus,
              ) ==
              null,
          reviewDate != null,
          outcome != null,
          validateIncomingTalentPromotionFollowUpResolutionConfidence(
                confidenceAfter,
              ) ==
              null,
          validateIncomingTalentPromotionFollowUpResolutionResidualRisk(
                residualRiskCount,
              ) ==
              null,
          evidenceSummary.trim().length >= 12,
          managerNote.trim().length >= 12,
          nextAction.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentPromotionFollowUpResolutionRequired(
            actionId,
            'a resolved or escalated follow-up',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionFollowUpResolutionRequired(
            reviewerName,
            'a reviewer',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionFollowUpResolutionSourceStatus(
            actionStatus,
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionFollowUpResolutionDate(
            reviewDate,
            asOfDate,
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionFollowUpResolutionOutcome(outcome)
          case final error?)
        error,
      if (validateIncomingTalentPromotionFollowUpResolutionConfidence(
            confidenceAfter,
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionFollowUpResolutionResidualRisk(
            residualRiskCount,
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionFollowUpResolutionLongText(
            evidenceSummary,
            'evidence summary',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionFollowUpResolutionLongText(
            managerNote,
            'manager note',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionFollowUpResolutionLongText(
            nextAction,
            'next action',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionFollowUpResolutionNextReviewDate(
            reviewDate,
            nextReviewDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentPromotionStabilizationFollowUpResolution toResolution({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentPromotionStabilizationFollowUpResolution(
      id: id,
      actionId: actionId.trim(),
      reviewId: reviewId.trim(),
      implementationId: implementationId.trim(),
      decisionId: decisionId.trim(),
      candidateId: candidateId.trim(),
      candidateName: candidateName.trim(),
      department: department.trim(),
      currentRole: currentRole.trim(),
      newRole: newRole.trim(),
      frameworkLevelCode: frameworkLevelCode.trim(),
      ownerName: ownerName.trim(),
      reviewerName: reviewerName.trim(),
      actionType: actionType!,
      actionPriority: actionPriority!,
      actionStatus: actionStatus!,
      actionDueDate: actionDueDate!,
      reviewDate: reviewDate!,
      outcome: outcome!,
      confidenceBefore: confidenceBefore,
      confidenceAfter: confidenceAfter,
      residualRiskCount: residualRiskCount,
      evidenceSummary: evidenceSummary.trim(),
      managerNote: managerNote.trim(),
      nextAction: nextAction.trim(),
      nextReviewDate: nextReviewDate!,
      createdAt: createdAt,
    );
  }
}

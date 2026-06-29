import 'incoming_talent_promotion_stabilization_follow_up_action.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_draft.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_policy.dart';

/// Submission helpers for promotion stabilization follow-up action drafts.
extension IncomingTalentPromotionStabilizationFollowUpActionDraftSubmission
    on IncomingTalentPromotionStabilizationFollowUpActionDraft {
  double get completionRatio {
    final completed =
        [
          reviewId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          actionType != null,
          priority != null,
          status != null,
          dueDate != null,
          actionPlan.trim().length >= 12,
          successCriteria.trim().length >= 12,
          escalationNote.trim().length >= 12,
          validateIncomingTalentPromotionStabilizationFollowUpResolutionNote(
                status: status,
                resolutionNote: resolutionNote,
              ) ==
              null,
        ].where((item) => item).length;

    return completed / 10;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentPromotionStabilizationFollowUpRequired(
            reviewId,
            'a stabilization review',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationFollowUpRequired(
            ownerName,
            'an owner',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationFollowUpActionType(
            actionType,
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationFollowUpPriority(priority)
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationFollowUpStatus(status)
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationFollowUpDueDate(
            dueDate,
            asOfDate,
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationFollowUpLongText(
            actionPlan,
            'action plan',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationFollowUpLongText(
            successCriteria,
            'success criteria',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationFollowUpLongText(
            escalationNote,
            'escalation note',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationFollowUpResolutionNote(
            status: status,
            resolutionNote: resolutionNote,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentPromotionStabilizationFollowUpAction toAction({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentPromotionStabilizationFollowUpAction(
      id: id,
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
      actionType: actionType!,
      priority: priority!,
      status: status!,
      dueDate: dueDate!,
      actionPlan: actionPlan.trim(),
      successCriteria: successCriteria.trim(),
      escalationNote: escalationNote.trim(),
      resolutionNote: resolutionNote.trim(),
      sourceOutcome: sourceOutcome!,
      sourceReviewStatus: sourceReviewStatus!,
      sourceConfidenceScore: sourceConfidenceScore,
      createdAt: createdAt,
    );
  }
}

import 'incoming_talent_promotion_stabilization_follow_up_action.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_draft.dart';
import 'incoming_talent_promotion_stabilization_review.dart';

/// Copy helpers for promotion stabilization follow-up action drafts.
extension IncomingTalentPromotionStabilizationFollowUpActionDraftCopy
    on IncomingTalentPromotionStabilizationFollowUpActionDraft {
  IncomingTalentPromotionStabilizationFollowUpActionDraft copyWith({
    String? reviewId,
    String? implementationId,
    String? decisionId,
    String? candidateId,
    String? candidateName,
    String? department,
    String? currentRole,
    String? newRole,
    String? frameworkLevelCode,
    String? ownerName,
    IncomingTalentPromotionStabilizationFollowUpActionType? actionType,
    IncomingTalentPromotionStabilizationFollowUpPriority? priority,
    IncomingTalentPromotionStabilizationFollowUpStatus? status,
    DateTime? dueDate,
    String? actionPlan,
    String? successCriteria,
    String? escalationNote,
    String? resolutionNote,
    IncomingTalentPromotionStabilizationOutcome? sourceOutcome,
    IncomingTalentPromotionStabilizationStatus? sourceReviewStatus,
    int? sourceConfidenceScore,
    DateTime? asOfDate,
  }) {
    return IncomingTalentPromotionStabilizationFollowUpActionDraft(
      reviewId: reviewId ?? this.reviewId,
      implementationId: implementationId ?? this.implementationId,
      decisionId: decisionId ?? this.decisionId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      department: department ?? this.department,
      currentRole: currentRole ?? this.currentRole,
      newRole: newRole ?? this.newRole,
      frameworkLevelCode: frameworkLevelCode ?? this.frameworkLevelCode,
      ownerName: ownerName ?? this.ownerName,
      actionType: actionType ?? this.actionType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      actionPlan: actionPlan ?? this.actionPlan,
      successCriteria: successCriteria ?? this.successCriteria,
      escalationNote: escalationNote ?? this.escalationNote,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      sourceOutcome: sourceOutcome ?? this.sourceOutcome,
      sourceReviewStatus: sourceReviewStatus ?? this.sourceReviewStatus,
      sourceConfidenceScore:
          sourceConfidenceScore ?? this.sourceConfidenceScore,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}

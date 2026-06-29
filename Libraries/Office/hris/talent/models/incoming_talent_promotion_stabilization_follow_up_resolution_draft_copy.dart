import 'incoming_talent_promotion_stabilization_follow_up_action.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution_draft.dart';

/// Copy helpers for promotion follow-up resolution drafts.
extension IncomingTalentPromotionStabilizationFollowUpResolutionDraftCopy
    on IncomingTalentPromotionStabilizationFollowUpResolutionDraft {
  IncomingTalentPromotionStabilizationFollowUpResolutionDraft copyWith({
    String? actionId,
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
    String? reviewerName,
    IncomingTalentPromotionStabilizationFollowUpActionType? actionType,
    IncomingTalentPromotionStabilizationFollowUpPriority? actionPriority,
    IncomingTalentPromotionStabilizationFollowUpStatus? actionStatus,
    DateTime? actionDueDate,
    DateTime? reviewDate,
    IncomingTalentPromotionStabilizationFollowUpResolutionOutcome? outcome,
    int? confidenceBefore,
    int? confidenceAfter,
    int? residualRiskCount,
    String? evidenceSummary,
    String? managerNote,
    String? nextAction,
    DateTime? nextReviewDate,
    DateTime? asOfDate,
  }) {
    return IncomingTalentPromotionStabilizationFollowUpResolutionDraft(
      actionId: actionId ?? this.actionId,
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
      reviewerName: reviewerName ?? this.reviewerName,
      actionType: actionType ?? this.actionType,
      actionPriority: actionPriority ?? this.actionPriority,
      actionStatus: actionStatus ?? this.actionStatus,
      actionDueDate: actionDueDate ?? this.actionDueDate,
      reviewDate: reviewDate ?? this.reviewDate,
      outcome: outcome ?? this.outcome,
      confidenceBefore: confidenceBefore ?? this.confidenceBefore,
      confidenceAfter: confidenceAfter ?? this.confidenceAfter,
      residualRiskCount: residualRiskCount ?? this.residualRiskCount,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      managerNote: managerNote ?? this.managerNote,
      nextAction: nextAction ?? this.nextAction,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}

import 'incoming_talent_promotion_decision.dart';
import 'incoming_talent_promotion_implementation.dart';
import 'incoming_talent_promotion_readiness.dart';
import 'incoming_talent_promotion_stabilization_review.dart';
import 'incoming_talent_promotion_stabilization_review_draft.dart';

/// Copy helpers for promotion stabilization review drafts.
extension IncomingTalentPromotionStabilizationReviewDraftCopy
    on IncomingTalentPromotionStabilizationReviewDraft {
  IncomingTalentPromotionStabilizationReviewDraft copyWith({
    String? implementationId,
    String? decisionId,
    String? readinessId,
    String? candidateId,
    String? candidateName,
    String? department,
    String? currentRole,
    String? newRole,
    String? frameworkLevelCode,
    String? ownerName,
    String? reviewerName,
    IncomingTalentPromotionStabilizationOutcome? outcome,
    IncomingTalentPromotionStabilizationStatus? status,
    DateTime? reviewDate,
    DateTime? followUpDate,
    int? confidenceScore,
    String? managerFeedback,
    String? employeeFeedback,
    String? evidenceSummary,
    String? supportPlan,
    IncomingTalentPromotionImplementationAction? sourceAction,
    IncomingTalentPromotionImplementationStatus? sourceImplementationStatus,
    IncomingTalentPromotionDecisionOutcome? sourceOutcome,
    IncomingTalentPromotionReadinessRating? sourceReadinessRating,
    DateTime? asOfDate,
  }) {
    return IncomingTalentPromotionStabilizationReviewDraft(
      implementationId: implementationId ?? this.implementationId,
      decisionId: decisionId ?? this.decisionId,
      readinessId: readinessId ?? this.readinessId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      department: department ?? this.department,
      currentRole: currentRole ?? this.currentRole,
      newRole: newRole ?? this.newRole,
      frameworkLevelCode: frameworkLevelCode ?? this.frameworkLevelCode,
      ownerName: ownerName ?? this.ownerName,
      reviewerName: reviewerName ?? this.reviewerName,
      outcome: outcome ?? this.outcome,
      status: status ?? this.status,
      reviewDate: reviewDate ?? this.reviewDate,
      followUpDate: followUpDate ?? this.followUpDate,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      managerFeedback: managerFeedback ?? this.managerFeedback,
      employeeFeedback: employeeFeedback ?? this.employeeFeedback,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      supportPlan: supportPlan ?? this.supportPlan,
      sourceAction: sourceAction ?? this.sourceAction,
      sourceImplementationStatus:
          sourceImplementationStatus ?? this.sourceImplementationStatus,
      sourceOutcome: sourceOutcome ?? this.sourceOutcome,
      sourceReadinessRating:
          sourceReadinessRating ?? this.sourceReadinessRating,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}

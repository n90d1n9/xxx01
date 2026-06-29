import 'incoming_talent_promotion_stabilization_follow_up_action.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_policy.dart';
import 'incoming_talent_promotion_stabilization_review.dart';

/// Editable draft for resolving a promotion stabilization risk.
class IncomingTalentPromotionStabilizationFollowUpActionDraft {
  final String reviewId;
  final String implementationId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String currentRole;
  final String newRole;
  final String frameworkLevelCode;
  final String ownerName;
  final IncomingTalentPromotionStabilizationFollowUpActionType? actionType;
  final IncomingTalentPromotionStabilizationFollowUpPriority? priority;
  final IncomingTalentPromotionStabilizationFollowUpStatus? status;
  final DateTime? dueDate;
  final String actionPlan;
  final String successCriteria;
  final String escalationNote;
  final String resolutionNote;
  final IncomingTalentPromotionStabilizationOutcome? sourceOutcome;
  final IncomingTalentPromotionStabilizationStatus? sourceReviewStatus;
  final int sourceConfidenceScore;
  final DateTime asOfDate;

  const IncomingTalentPromotionStabilizationFollowUpActionDraft({
    required this.reviewId,
    required this.implementationId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.currentRole,
    required this.newRole,
    required this.frameworkLevelCode,
    required this.ownerName,
    required this.actionType,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.actionPlan,
    required this.successCriteria,
    required this.escalationNote,
    required this.resolutionNote,
    required this.sourceOutcome,
    required this.sourceReviewStatus,
    required this.sourceConfidenceScore,
    required this.asOfDate,
  });

  factory IncomingTalentPromotionStabilizationFollowUpActionDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentPromotionStabilizationFollowUpActionDraft(
      reviewId: '',
      implementationId: '',
      decisionId: '',
      candidateId: '',
      candidateName: '',
      department: '',
      currentRole: '',
      newRole: '',
      frameworkLevelCode: '',
      ownerName: '',
      actionType: null,
      priority: null,
      status: null,
      dueDate: null,
      actionPlan: '',
      successCriteria: '',
      escalationNote: '',
      resolutionNote: '',
      sourceOutcome: null,
      sourceReviewStatus: null,
      sourceConfidenceScore: 0,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentPromotionStabilizationFollowUpActionDraft.fromReview({
    required IncomingTalentPromotionStabilizationReview review,
    required DateTime asOfDate,
  }) {
    final defaults =
        IncomingTalentPromotionStabilizationFollowUpActionDefaults.fromReview(
          review,
        );

    return IncomingTalentPromotionStabilizationFollowUpActionDraft(
      reviewId: review.id,
      implementationId: review.implementationId,
      decisionId: review.decisionId,
      candidateId: review.candidateId,
      candidateName: review.candidateName,
      department: review.department,
      currentRole: review.currentRole,
      newRole: review.newRole,
      frameworkLevelCode: review.frameworkLevelCode,
      ownerName: review.ownerName,
      actionType: defaults.actionType,
      priority: defaults.priority,
      status: defaults.status,
      dueDate: asOfDate.add(defaults.dueOffset),
      actionPlan: defaults.actionPlan,
      successCriteria: defaults.successCriteria,
      escalationNote: defaults.escalationNote,
      resolutionNote: '',
      sourceOutcome: review.outcome,
      sourceReviewStatus: review.status,
      sourceConfidenceScore: review.confidenceScore,
      asOfDate: asOfDate,
    );
  }
}

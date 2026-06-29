import 'incoming_talent_promotion_stabilization_follow_up_action.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution_policy.dart';

/// Editable draft for reviewing a completed promotion follow-up action.
class IncomingTalentPromotionStabilizationFollowUpResolutionDraft {
  final String actionId;
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
  final String reviewerName;
  final IncomingTalentPromotionStabilizationFollowUpActionType? actionType;
  final IncomingTalentPromotionStabilizationFollowUpPriority? actionPriority;
  final IncomingTalentPromotionStabilizationFollowUpStatus? actionStatus;
  final DateTime? actionDueDate;
  final DateTime? reviewDate;
  final IncomingTalentPromotionStabilizationFollowUpResolutionOutcome? outcome;
  final int confidenceBefore;
  final int confidenceAfter;
  final int residualRiskCount;
  final String evidenceSummary;
  final String managerNote;
  final String nextAction;
  final DateTime? nextReviewDate;
  final DateTime asOfDate;

  const IncomingTalentPromotionStabilizationFollowUpResolutionDraft({
    required this.actionId,
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
    required this.reviewerName,
    required this.actionType,
    required this.actionPriority,
    required this.actionStatus,
    required this.actionDueDate,
    required this.reviewDate,
    required this.outcome,
    required this.confidenceBefore,
    required this.confidenceAfter,
    required this.residualRiskCount,
    required this.evidenceSummary,
    required this.managerNote,
    required this.nextAction,
    required this.nextReviewDate,
    required this.asOfDate,
  });

  factory IncomingTalentPromotionStabilizationFollowUpResolutionDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentPromotionStabilizationFollowUpResolutionDraft(
      actionId: '',
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
      reviewerName: '',
      actionType: null,
      actionPriority: null,
      actionStatus: null,
      actionDueDate: null,
      reviewDate: null,
      outcome: null,
      confidenceBefore: 0,
      confidenceAfter: 0,
      residualRiskCount: 0,
      evidenceSummary: '',
      managerNote: '',
      nextAction: '',
      nextReviewDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentPromotionStabilizationFollowUpResolutionDraft.fromAction({
    required IncomingTalentPromotionStabilizationFollowUpAction action,
    required DateTime asOfDate,
  }) {
    final defaults =
        IncomingTalentPromotionStabilizationFollowUpResolutionDefaults.fromAction(
          action,
        );

    return IncomingTalentPromotionStabilizationFollowUpResolutionDraft(
      actionId: action.id,
      reviewId: action.reviewId,
      implementationId: action.implementationId,
      decisionId: action.decisionId,
      candidateId: action.candidateId,
      candidateName: action.candidateName,
      department: action.department,
      currentRole: action.currentRole,
      newRole: action.newRole,
      frameworkLevelCode: action.frameworkLevelCode,
      ownerName: action.ownerName,
      reviewerName: action.ownerName,
      actionType: action.actionType,
      actionPriority: action.priority,
      actionStatus: action.status,
      actionDueDate: action.dueDate,
      reviewDate: asOfDate,
      outcome: defaults.outcome,
      confidenceBefore: action.sourceConfidenceScore,
      confidenceAfter: defaults.confidenceAfter,
      residualRiskCount: defaults.residualRiskCount,
      evidenceSummary: defaults.evidenceSummary,
      managerNote: defaults.managerNote,
      nextAction: defaults.nextAction,
      nextReviewDate: asOfDate.add(defaults.nextReviewOffset),
      asOfDate: asOfDate,
    );
  }
}

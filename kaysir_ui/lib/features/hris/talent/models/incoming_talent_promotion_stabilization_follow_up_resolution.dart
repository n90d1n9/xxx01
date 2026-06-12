import 'incoming_talent_promotion_stabilization_follow_up_action.dart';

/// Resolution outcome for validating whether a promotion follow-up stabilized.
enum IncomingTalentPromotionStabilizationFollowUpResolutionOutcome {
  stabilized('Stabilized'),
  monitor('Monitor'),
  reopenFollowUp('Reopen follow-up'),
  peoplePanelEscalation('People panel escalation');

  final String label;

  const IncomingTalentPromotionStabilizationFollowUpResolutionOutcome(
    this.label,
  );
}

/// HRIS review that closes the loop after a promotion follow-up action.
class IncomingTalentPromotionStabilizationFollowUpResolution {
  final String id;
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
  final IncomingTalentPromotionStabilizationFollowUpActionType actionType;
  final IncomingTalentPromotionStabilizationFollowUpPriority actionPriority;
  final IncomingTalentPromotionStabilizationFollowUpStatus actionStatus;
  final DateTime actionDueDate;
  final DateTime reviewDate;
  final IncomingTalentPromotionStabilizationFollowUpResolutionOutcome outcome;
  final int confidenceBefore;
  final int confidenceAfter;
  final int residualRiskCount;
  final String evidenceSummary;
  final String managerNote;
  final String nextAction;
  final DateTime nextReviewDate;
  final DateTime createdAt;

  const IncomingTalentPromotionStabilizationFollowUpResolution({
    required this.id,
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
    required this.createdAt,
  });

  bool get needsAttention {
    return outcome ==
            IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
                .monitor ||
        outcome ==
            IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
                .reopenFollowUp ||
        outcome ==
            IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
                .peoplePanelEscalation ||
        confidenceAfter <= 3 ||
        residualRiskCount > 0;
  }

  int get confidenceDelta => confidenceAfter - confidenceBefore;

  double get confidenceRatio => confidenceAfter / 5;
}

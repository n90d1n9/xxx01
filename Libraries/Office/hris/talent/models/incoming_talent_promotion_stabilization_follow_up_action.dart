import 'incoming_talent_promotion_stabilization_review.dart';

/// Operational action used to resolve a risky promotion stabilization review.
enum IncomingTalentPromotionStabilizationFollowUpActionType {
  managerCoaching('Manager coaching'),
  compensationConfirmation('Compensation confirmation'),
  trialCheckpoint('Trial checkpoint'),
  roleResetPlan('Role reset plan'),
  peoplePanelEscalation('People panel escalation');

  final String label;

  const IncomingTalentPromotionStabilizationFollowUpActionType(this.label);
}

/// Priority for post-promotion stabilization follow-up work.
enum IncomingTalentPromotionStabilizationFollowUpPriority {
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String label;

  const IncomingTalentPromotionStabilizationFollowUpPriority(this.label);
}

/// Lifecycle state for a promotion stabilization follow-up action.
enum IncomingTalentPromotionStabilizationFollowUpStatus {
  open('Open'),
  inProgress('In progress'),
  resolved('Resolved'),
  escalated('Escalated'),
  cancelled('Cancelled');

  final String label;

  const IncomingTalentPromotionStabilizationFollowUpStatus(this.label);
}

/// HRIS action record for closing promotion stabilization risks.
class IncomingTalentPromotionStabilizationFollowUpAction {
  final String id;
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
  final IncomingTalentPromotionStabilizationFollowUpActionType actionType;
  final IncomingTalentPromotionStabilizationFollowUpPriority priority;
  final IncomingTalentPromotionStabilizationFollowUpStatus status;
  final DateTime dueDate;
  final String actionPlan;
  final String successCriteria;
  final String escalationNote;
  final String resolutionNote;
  final IncomingTalentPromotionStabilizationOutcome sourceOutcome;
  final IncomingTalentPromotionStabilizationStatus sourceReviewStatus;
  final int sourceConfidenceScore;
  final DateTime createdAt;

  const IncomingTalentPromotionStabilizationFollowUpAction({
    required this.id,
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
    required this.createdAt,
  });

  bool get isClosed {
    return status ==
            IncomingTalentPromotionStabilizationFollowUpStatus.resolved ||
        status == IncomingTalentPromotionStabilizationFollowUpStatus.cancelled;
  }

  bool get needsAttention {
    return !isClosed &&
        (status ==
                IncomingTalentPromotionStabilizationFollowUpStatus.escalated ||
            priority ==
                IncomingTalentPromotionStabilizationFollowUpPriority.critical ||
            sourceOutcome !=
                IncomingTalentPromotionStabilizationOutcome.stableInRole ||
            sourceConfidenceScore <= 2);
  }

  double get progressRatio {
    return switch (status) {
      IncomingTalentPromotionStabilizationFollowUpStatus.open => 0.2,
      IncomingTalentPromotionStabilizationFollowUpStatus.inProgress => 0.55,
      IncomingTalentPromotionStabilizationFollowUpStatus.resolved => 1,
      IncomingTalentPromotionStabilizationFollowUpStatus.escalated => 0.35,
      IncomingTalentPromotionStabilizationFollowUpStatus.cancelled => 0,
    };
  }
}

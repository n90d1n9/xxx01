import 'incoming_talent_promotion_decision.dart';
import 'incoming_talent_promotion_implementation.dart';
import 'incoming_talent_promotion_readiness.dart';

/// Business outcome captured after a promotion implementation stabilizes.
enum IncomingTalentPromotionStabilizationOutcome {
  stableInRole('Stable in role'),
  needsManagerSupport('Needs manager support'),
  compensationFollowUp('Compensation follow-up'),
  trialExtended('Trial extended'),
  roleReset('Role reset');

  final String label;

  const IncomingTalentPromotionStabilizationOutcome(this.label);
}

/// Review lifecycle for a post-promotion stabilization checkpoint.
enum IncomingTalentPromotionStabilizationStatus {
  scheduled('Scheduled'),
  reviewed('Reviewed'),
  followUpRequired('Follow-up required'),
  escalated('Escalated'),
  closed('Closed');

  final String label;

  const IncomingTalentPromotionStabilizationStatus(this.label);
}

/// Structured HRIS review for validating post-promotion adoption and support.
class IncomingTalentPromotionStabilizationReview {
  final String id;
  final String implementationId;
  final String decisionId;
  final String readinessId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String currentRole;
  final String newRole;
  final String frameworkLevelCode;
  final String ownerName;
  final String reviewerName;
  final IncomingTalentPromotionStabilizationOutcome outcome;
  final IncomingTalentPromotionStabilizationStatus status;
  final DateTime reviewDate;
  final DateTime? followUpDate;
  final int confidenceScore;
  final String managerFeedback;
  final String employeeFeedback;
  final String evidenceSummary;
  final String supportPlan;
  final IncomingTalentPromotionImplementationAction sourceAction;
  final IncomingTalentPromotionImplementationStatus sourceImplementationStatus;
  final IncomingTalentPromotionDecisionOutcome sourceOutcome;
  final IncomingTalentPromotionReadinessRating sourceReadinessRating;
  final DateTime createdAt;

  const IncomingTalentPromotionStabilizationReview({
    required this.id,
    required this.implementationId,
    required this.decisionId,
    required this.readinessId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.currentRole,
    required this.newRole,
    required this.frameworkLevelCode,
    required this.ownerName,
    required this.reviewerName,
    required this.outcome,
    required this.status,
    required this.reviewDate,
    required this.followUpDate,
    required this.confidenceScore,
    required this.managerFeedback,
    required this.employeeFeedback,
    required this.evidenceSummary,
    required this.supportPlan,
    required this.sourceAction,
    required this.sourceImplementationStatus,
    required this.sourceOutcome,
    required this.sourceReadinessRating,
    required this.createdAt,
  });

  bool get isClosed {
    return status == IncomingTalentPromotionStabilizationStatus.closed;
  }

  bool get needsAttention {
    return status == IncomingTalentPromotionStabilizationStatus.escalated ||
        status == IncomingTalentPromotionStabilizationStatus.followUpRequired ||
        outcome != IncomingTalentPromotionStabilizationOutcome.stableInRole ||
        confidenceScore <= 2;
  }

  double get confidenceRatio {
    return confidenceScore.clamp(1, 5) / 5;
  }

  double get progressRatio {
    return switch (status) {
      IncomingTalentPromotionStabilizationStatus.scheduled => 0.25,
      IncomingTalentPromotionStabilizationStatus.reviewed => 0.65,
      IncomingTalentPromotionStabilizationStatus.followUpRequired => 0.55,
      IncomingTalentPromotionStabilizationStatus.escalated => 0.35,
      IncomingTalentPromotionStabilizationStatus.closed => 1,
    };
  }
}

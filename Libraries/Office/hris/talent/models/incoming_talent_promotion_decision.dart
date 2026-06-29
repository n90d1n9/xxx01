import 'incoming_talent_promotion_readiness.dart';

/// Final panel outcome for a promotion-readiness packet.
enum IncomingTalentPromotionDecisionOutcome {
  promoteNow('Promote now'),
  promoteWithTrial('Promote with trial'),
  deferPromotion('Defer promotion'),
  retainInRole('Retain in role'),
  compensationReview('Compensation review');

  final String label;

  const IncomingTalentPromotionDecisionOutcome(this.label);
}

/// Operational status for implementing a promotion panel decision.
enum IncomingTalentPromotionDecisionStatus {
  draft('Draft'),
  approved('Approved'),
  routed('Routed'),
  implemented('Implemented'),
  deferred('Deferred'),
  closed('Closed');

  final String label;

  const IncomingTalentPromotionDecisionStatus(this.label);
}

/// HR decision packet that turns promotion readiness into an action.
class IncomingTalentPromotionDecision {
  final String id;
  final String readinessId;
  final String careerPathId;
  final String frameworkLevelId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String currentRole;
  final String newRole;
  final String frameworkLevelCode;
  final String ownerName;
  final String approverName;
  final IncomingTalentPromotionDecisionOutcome outcome;
  final IncomingTalentPromotionDecisionStatus status;
  final String compensationBandNote;
  final String implementationNote;
  final String riskControlNote;
  final DateTime effectiveDate;
  final DateTime followUpDate;
  final IncomingTalentPromotionReadinessRating sourceRating;
  final IncomingTalentPromotionReadinessStatus sourceReadinessStatus;
  final DateTime createdAt;

  const IncomingTalentPromotionDecision({
    required this.id,
    required this.readinessId,
    required this.careerPathId,
    required this.frameworkLevelId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.currentRole,
    required this.newRole,
    required this.frameworkLevelCode,
    required this.ownerName,
    required this.approverName,
    required this.outcome,
    required this.status,
    required this.compensationBandNote,
    required this.implementationNote,
    required this.riskControlNote,
    required this.effectiveDate,
    required this.followUpDate,
    required this.sourceRating,
    required this.sourceReadinessStatus,
    required this.createdAt,
  });

  bool get isClosed {
    return status == IncomingTalentPromotionDecisionStatus.implemented ||
        status == IncomingTalentPromotionDecisionStatus.closed;
  }

  bool get needsAttention {
    return status == IncomingTalentPromotionDecisionStatus.draft ||
        status == IncomingTalentPromotionDecisionStatus.routed ||
        status == IncomingTalentPromotionDecisionStatus.deferred ||
        outcome == IncomingTalentPromotionDecisionOutcome.deferPromotion ||
        outcome == IncomingTalentPromotionDecisionOutcome.retainInRole;
  }

  double get implementationProgress {
    return switch (status) {
      IncomingTalentPromotionDecisionStatus.draft => 0.15,
      IncomingTalentPromotionDecisionStatus.approved => 0.45,
      IncomingTalentPromotionDecisionStatus.routed => 0.65,
      IncomingTalentPromotionDecisionStatus.deferred => 0.35,
      IncomingTalentPromotionDecisionStatus.implemented ||
      IncomingTalentPromotionDecisionStatus.closed => 1,
    };
  }
}

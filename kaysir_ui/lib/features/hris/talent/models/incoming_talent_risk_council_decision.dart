import 'incoming_talent_risk_council_queue_item.dart';

/// Decision choices available when the talent risk council resolves queue work.
enum IncomingTalentRiskCouncilDecisionOutcome {
  approveActionPlan('Approve action plan'),
  assignOwner('Assign owner'),
  monitorNextCouncil('Monitor next council'),
  escalatePeopleBoard('Escalate to people board'),
  closeRisk('Close risk');

  final String label;

  const IncomingTalentRiskCouncilDecisionOutcome(this.label);
}

/// Recorded council decision with ownership, follow-up, and attention signals.
class IncomingTalentRiskCouncilDecision {
  final String id;
  final String queueItemId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final IncomingTalentRiskCouncilQueueCategory category;
  final IncomingTalentRiskCouncilQueueSeverity sourceSeverity;
  final IncomingTalentRiskCouncilQueueSource source;
  final String decisionMakerName;
  final String ownerName;
  final DateTime decisionDate;
  final IncomingTalentRiskCouncilDecisionOutcome outcome;
  final String commitmentSummary;
  final String minutesNote;
  final DateTime followUpDate;
  final DateTime createdAt;
  final int signalCount;

  const IncomingTalentRiskCouncilDecision({
    required this.id,
    required this.queueItemId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.category,
    required this.sourceSeverity,
    this.source = IncomingTalentRiskCouncilQueueSource.general,
    required this.decisionMakerName,
    required this.ownerName,
    required this.decisionDate,
    required this.outcome,
    required this.commitmentSummary,
    required this.minutesNote,
    required this.followUpDate,
    required this.createdAt,
    required this.signalCount,
  });

  bool get needsAttention {
    if (outcome == IncomingTalentRiskCouncilDecisionOutcome.closeRisk) {
      return false;
    }

    return outcome ==
            IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil ||
        outcome ==
            IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard ||
        sourceSeverity == IncomingTalentRiskCouncilQueueSeverity.critical;
  }

  /// Whether this decision came from a promotion stabilization resolution review.
  bool get isPromotionResolutionReview {
    return source ==
        IncomingTalentRiskCouncilQueueSource.promotionResolutionReview;
  }

  double get urgencyRatio {
    if (outcome == IncomingTalentRiskCouncilDecisionOutcome.closeRisk) {
      return 0.34;
    }
    if (outcome ==
        IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard) {
      return 1;
    }
    if (sourceSeverity == IncomingTalentRiskCouncilQueueSeverity.critical) {
      return 0.86;
    }
    if (outcome ==
        IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil) {
      return 0.68;
    }
    return 0.54;
  }
}

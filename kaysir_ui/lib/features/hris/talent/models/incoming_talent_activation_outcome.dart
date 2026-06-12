enum IncomingTalentActivationOutcomeDecision {
  stabilized('Stabilized'),
  extendSupport('Extend support'),
  assignDevelopmentTrack('Assign development track'),
  escalateRisk('Escalate risk');

  final String label;

  const IncomingTalentActivationOutcomeDecision(this.label);
}

enum IncomingTalentActivationRetentionRisk {
  low('Low risk'),
  medium('Medium risk'),
  high('High risk');

  final String label;

  const IncomingTalentActivationRetentionRisk(this.label);
}

class IncomingTalentActivationOutcomeReview {
  final String id;
  final String activationPlanId;
  final String handoffId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String reviewerName;
  final DateTime reviewDate;
  final IncomingTalentActivationOutcomeDecision decision;
  final IncomingTalentActivationRetentionRisk retentionRisk;
  final int readinessScore;
  final String nextDevelopmentTrack;
  final String evidenceNote;
  final String decisionNote;
  final DateTime createdAt;

  const IncomingTalentActivationOutcomeReview({
    required this.id,
    required this.activationPlanId,
    required this.handoffId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.reviewerName,
    required this.reviewDate,
    required this.decision,
    required this.retentionRisk,
    required this.readinessScore,
    required this.nextDevelopmentTrack,
    required this.evidenceNote,
    required this.decisionNote,
    required this.createdAt,
  });

  bool get needsAttention {
    return decision != IncomingTalentActivationOutcomeDecision.stabilized ||
        retentionRisk != IncomingTalentActivationRetentionRisk.low;
  }

  double get readinessRatio => readinessScore / 100;
}

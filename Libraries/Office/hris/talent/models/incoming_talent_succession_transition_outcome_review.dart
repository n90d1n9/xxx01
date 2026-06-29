import 'incoming_talent_succession_transition_intervention.dart';
import 'incoming_talent_succession_transition_pulse.dart';

enum IncomingTalentSuccessionTransitionOutcomeDecision {
  stabilized('Stabilized'),
  extendSupport('Extend support'),
  leadershipReview('Leadership review'),
  successionRework('Succession rework');

  final String label;

  const IncomingTalentSuccessionTransitionOutcomeDecision(this.label);
}

enum IncomingTalentSuccessionTransitionOutcomeResidualRisk {
  low('Low'),
  medium('Medium'),
  high('High');

  final String label;

  const IncomingTalentSuccessionTransitionOutcomeResidualRisk(this.label);
}

class IncomingTalentSuccessionTransitionOutcomeReview {
  final String id;
  final String interventionId;
  final String pulseId;
  final String closureId;
  final String resolutionReviewId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String reviewerName;
  final IncomingTalentSuccessionTransitionInterventionType interventionType;
  final IncomingTalentSuccessionTransitionPulseHealth pulseHealth;
  final IncomingTalentSuccessionTransitionRetentionRisk retentionRisk;
  final DateTime reviewDate;
  final IncomingTalentSuccessionTransitionOutcomeDecision decision;
  final IncomingTalentSuccessionTransitionOutcomeResidualRisk residualRisk;
  final int stabilizationScore;
  final String evidenceSummary;
  final String lessonsLearned;
  final String nextTalentAction;
  final DateTime nextReviewDate;
  final DateTime createdAt;

  const IncomingTalentSuccessionTransitionOutcomeReview({
    required this.id,
    required this.interventionId,
    required this.pulseId,
    required this.closureId,
    required this.resolutionReviewId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.reviewerName,
    required this.interventionType,
    required this.pulseHealth,
    required this.retentionRisk,
    required this.reviewDate,
    required this.decision,
    required this.residualRisk,
    required this.stabilizationScore,
    required this.evidenceSummary,
    required this.lessonsLearned,
    required this.nextTalentAction,
    required this.nextReviewDate,
    required this.createdAt,
  });

  bool get needsAttention {
    return decision !=
            IncomingTalentSuccessionTransitionOutcomeDecision.stabilized ||
        residualRisk ==
            IncomingTalentSuccessionTransitionOutcomeResidualRisk.high ||
        stabilizationScore <= 3;
  }

  double get stabilizationRatio => stabilizationScore / 5;
}

import 'incoming_talent_succession_activation_escalation.dart';

enum IncomingTalentSuccessionActivationResolutionOutcome {
  transitionCleared('Transition cleared'),
  monitor('Monitor'),
  reopenEscalation('Reopen escalation'),
  panelReview('Panel review');

  final String label;

  const IncomingTalentSuccessionActivationResolutionOutcome(this.label);
}

enum IncomingTalentSuccessionActivationResidualRisk {
  low('Low'),
  medium('Medium'),
  high('High');

  final String label;

  const IncomingTalentSuccessionActivationResidualRisk(this.label);
}

class IncomingTalentSuccessionActivationResolutionReview {
  final String id;
  final String escalationId;
  final String checkInId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String reviewerName;
  final IncomingTalentSuccessionActivationEscalationPriority escalationPriority;
  final DateTime resolutionDate;
  final IncomingTalentSuccessionActivationResolutionOutcome outcome;
  final IncomingTalentSuccessionActivationResidualRisk residualRisk;
  final int finalConfidenceScore;
  final String evidenceSummary;
  final String sponsorConfirmation;
  final String nextGovernanceStep;
  final DateTime nextReviewDate;
  final DateTime createdAt;

  const IncomingTalentSuccessionActivationResolutionReview({
    required this.id,
    required this.escalationId,
    required this.checkInId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.reviewerName,
    required this.escalationPriority,
    required this.resolutionDate,
    required this.outcome,
    required this.residualRisk,
    required this.finalConfidenceScore,
    required this.evidenceSummary,
    required this.sponsorConfirmation,
    required this.nextGovernanceStep,
    required this.nextReviewDate,
    required this.createdAt,
  });

  bool get needsAttention {
    return outcome ==
            IncomingTalentSuccessionActivationResolutionOutcome
                .reopenEscalation ||
        outcome ==
            IncomingTalentSuccessionActivationResolutionOutcome.panelReview ||
        residualRisk == IncomingTalentSuccessionActivationResidualRisk.high ||
        finalConfidenceScore <= 3;
  }

  double get finalConfidenceRatio => finalConfidenceScore / 5;
}

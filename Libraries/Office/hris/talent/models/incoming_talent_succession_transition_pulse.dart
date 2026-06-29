import 'incoming_talent_succession_activation_closure.dart';

enum IncomingTalentSuccessionTransitionPulseWindow {
  thirtyDay('30-day'),
  sixtyDay('60-day'),
  ninetyDay('90-day');

  final String label;

  const IncomingTalentSuccessionTransitionPulseWindow(this.label);
}

enum IncomingTalentSuccessionTransitionPulseHealth {
  thriving('Thriving'),
  stable('Stable'),
  watch('Watch'),
  intervention('Intervention');

  final String label;

  const IncomingTalentSuccessionTransitionPulseHealth(this.label);
}

enum IncomingTalentSuccessionTransitionRetentionRisk {
  low('Low'),
  medium('Medium'),
  high('High');

  final String label;

  const IncomingTalentSuccessionTransitionRetentionRisk(this.label);
}

class IncomingTalentSuccessionTransitionPulse {
  final String id;
  final String closureId;
  final String resolutionReviewId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String ownerName;
  final IncomingTalentSuccessionActivationClosureType closureType;
  final DateTime effectiveDate;
  final IncomingTalentSuccessionTransitionPulseWindow pulseWindow;
  final DateTime pulseDate;
  final IncomingTalentSuccessionTransitionPulseHealth health;
  final int adoptionScore;
  final int managerConfidenceScore;
  final IncomingTalentSuccessionTransitionRetentionRisk retentionRisk;
  final String outcomeEvidence;
  final String employeeSignal;
  final String managerSignal;
  final String stakeholderSentiment;
  final String nextAction;
  final DateTime nextPulseDate;
  final DateTime createdAt;

  const IncomingTalentSuccessionTransitionPulse({
    required this.id,
    required this.closureId,
    required this.resolutionReviewId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.ownerName,
    required this.closureType,
    required this.effectiveDate,
    required this.pulseWindow,
    required this.pulseDate,
    required this.health,
    required this.adoptionScore,
    required this.managerConfidenceScore,
    required this.retentionRisk,
    required this.outcomeEvidence,
    required this.employeeSignal,
    required this.managerSignal,
    required this.stakeholderSentiment,
    required this.nextAction,
    required this.nextPulseDate,
    required this.createdAt,
  });

  bool get needsAttention {
    return health == IncomingTalentSuccessionTransitionPulseHealth.watch ||
        health == IncomingTalentSuccessionTransitionPulseHealth.intervention ||
        retentionRisk == IncomingTalentSuccessionTransitionRetentionRisk.high ||
        adoptionScore <= 3 ||
        managerConfidenceScore <= 3;
  }

  double get adoptionRatio => adoptionScore / 5;

  double get managerConfidenceRatio => managerConfidenceScore / 5;
}

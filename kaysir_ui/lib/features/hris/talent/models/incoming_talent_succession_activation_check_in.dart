import 'incoming_talent_succession_activation_plan.dart';

enum IncomingTalentSuccessionActivationCheckInTrend {
  accelerating('Accelerating'),
  onTrack('On track'),
  watch('Watch'),
  blocked('Blocked');

  final String label;

  const IncomingTalentSuccessionActivationCheckInTrend(this.label);
}

class IncomingTalentSuccessionActivationCheckIn {
  final String id;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String reviewerName;
  final DateTime checkInDate;
  final IncomingTalentSuccessionActivationCheckInTrend trend;
  final int confidenceScore;
  final String milestoneHealth;
  final String blockerNote;
  final String sponsorAction;
  final String nextStep;
  final DateTime nextCheckInDate;
  final IncomingTalentSuccessionActivationStatus activationStatus;
  final DateTime createdAt;

  const IncomingTalentSuccessionActivationCheckIn({
    required this.id,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.reviewerName,
    required this.checkInDate,
    required this.trend,
    required this.confidenceScore,
    required this.milestoneHealth,
    required this.blockerNote,
    required this.sponsorAction,
    required this.nextStep,
    required this.nextCheckInDate,
    required this.activationStatus,
    required this.createdAt,
  });

  bool get needsAttention {
    return trend == IncomingTalentSuccessionActivationCheckInTrend.watch ||
        trend == IncomingTalentSuccessionActivationCheckInTrend.blocked ||
        confidenceScore <= 3 ||
        activationStatus == IncomingTalentSuccessionActivationStatus.atRisk;
  }

  double get confidenceRatio => confidenceScore / 5;
}

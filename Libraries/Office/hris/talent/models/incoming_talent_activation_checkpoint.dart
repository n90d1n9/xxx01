import 'incoming_talent_activation_plan.dart';

enum IncomingTalentActivationCheckpointHealth {
  onTrack('On track'),
  watch('Watch'),
  blocked('Blocked');

  final String label;

  const IncomingTalentActivationCheckpointHealth(this.label);
}

class IncomingTalentActivationCheckpoint {
  final String id;
  final String activationPlanId;
  final String handoffId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String managerName;
  final String mentorName;
  final int acceptedProgramMilestoneCount;
  final int roleReadyProgramCompletionCount;
  final int programCompletionExtensionCount;
  final String reviewerName;
  final DateTime reviewDate;
  final IncomingTalentActivationCheckpointHealth health;
  final int confidenceScore;
  final String managerFeedback;
  final String blockerNote;
  final String nextStep;
  final DateTime createdAt;

  const IncomingTalentActivationCheckpoint({
    required this.id,
    required this.activationPlanId,
    required this.handoffId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.managerName,
    required this.mentorName,
    this.acceptedProgramMilestoneCount = 0,
    this.roleReadyProgramCompletionCount = 0,
    this.programCompletionExtensionCount = 0,
    required this.reviewerName,
    required this.reviewDate,
    required this.health,
    required this.confidenceScore,
    required this.managerFeedback,
    required this.blockerNote,
    required this.nextStep,
    required this.createdAt,
  });

  bool get needsAttention {
    return health != IncomingTalentActivationCheckpointHealth.onTrack ||
        confidenceScore <= 3 ||
        programCompletionExtensionCount > 0;
  }

  bool get isBlocked {
    return health == IncomingTalentActivationCheckpointHealth.blocked;
  }

  int get developmentEvidenceCount {
    return acceptedProgramMilestoneCount + roleReadyProgramCompletionCount;
  }

  double get confidenceRatio => confidenceScore / 5;
}

IncomingTalentActivationCheckpointHealth defaultCheckpointHealth(
  IncomingTalentActivationPlan plan,
) {
  if (plan.hasProgramExtensionRisk) {
    return IncomingTalentActivationCheckpointHealth.blocked;
  }

  return switch (plan.status) {
    IncomingTalentActivationStatus.completed =>
      IncomingTalentActivationCheckpointHealth.onTrack,
    IncomingTalentActivationStatus.active =>
      IncomingTalentActivationCheckpointHealth.onTrack,
    IncomingTalentActivationStatus.planned =>
      IncomingTalentActivationCheckpointHealth.watch,
    IncomingTalentActivationStatus.blocked =>
      IncomingTalentActivationCheckpointHealth.blocked,
  };
}

int defaultCheckpointConfidence(IncomingTalentActivationPlan plan) {
  if (plan.hasProgramExtensionRisk) return 2;

  return switch (plan.status) {
    IncomingTalentActivationStatus.completed => 5,
    IncomingTalentActivationStatus.active => 4,
    IncomingTalentActivationStatus.planned => 3,
    IncomingTalentActivationStatus.blocked => 2,
  };
}

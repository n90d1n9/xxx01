import 'incoming_talent_succession_candidate.dart';
import 'incoming_talent_succession_panel_decision.dart';

enum IncomingTalentSuccessionActivationStatus {
  planned('Planned'),
  inProgress('In progress'),
  atRisk('At risk'),
  completed('Completed');

  final String label;

  const IncomingTalentSuccessionActivationStatus(this.label);
}

class IncomingTalentSuccessionActivationPlan {
  final String id;
  final String decisionId;
  final String nominationId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String activationOwner;
  final String mentorName;
  final IncomingTalentSuccessionActivationStatus status;
  final IncomingTalentSuccessionPanelOutcome outcome;
  final IncomingTalentSuccessionReadiness readiness;
  final IncomingTalentSuccessionRisk risk;
  final DateTime startDate;
  final DateTime milestoneDate;
  final DateTime firstReviewDate;
  final String transitionGoal;
  final String milestone;
  final String successMetric;
  final String supportPlan;
  final DateTime createdAt;

  const IncomingTalentSuccessionActivationPlan({
    required this.id,
    required this.decisionId,
    required this.nominationId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.activationOwner,
    required this.mentorName,
    required this.status,
    required this.outcome,
    required this.readiness,
    required this.risk,
    required this.startDate,
    required this.milestoneDate,
    required this.firstReviewDate,
    required this.transitionGoal,
    required this.milestone,
    required this.successMetric,
    required this.supportPlan,
    required this.createdAt,
  });

  bool get needsAttention {
    return status == IncomingTalentSuccessionActivationStatus.atRisk ||
        outcome == IncomingTalentSuccessionPanelOutcome.conditionalApproval ||
        risk != IncomingTalentSuccessionRisk.low;
  }

  bool get isCompleted {
    return status == IncomingTalentSuccessionActivationStatus.completed;
  }

  double get transitionProgress {
    return switch (status) {
      IncomingTalentSuccessionActivationStatus.planned => 0.2,
      IncomingTalentSuccessionActivationStatus.inProgress => 0.55,
      IncomingTalentSuccessionActivationStatus.atRisk => 0.35,
      IncomingTalentSuccessionActivationStatus.completed => 1,
    };
  }
}

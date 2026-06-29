import 'incoming_talent_succession_activation_closure.dart';
import 'incoming_talent_succession_transition_pulse.dart';

enum IncomingTalentSuccessionTransitionInterventionType {
  roleClarity('Role clarity'),
  managerAlignment('Manager alignment'),
  stakeholderReset('Stakeholder reset'),
  coaching('Coaching'),
  retentionPlan('Retention plan');

  final String label;

  const IncomingTalentSuccessionTransitionInterventionType(this.label);
}

enum IncomingTalentSuccessionTransitionInterventionStatus {
  planned('Planned'),
  inProgress('In progress'),
  completed('Completed'),
  blocked('Blocked');

  final String label;

  const IncomingTalentSuccessionTransitionInterventionStatus(this.label);
}

class IncomingTalentSuccessionTransitionIntervention {
  final String id;
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
  final String ownerName;
  final IncomingTalentSuccessionActivationClosureType closureType;
  final IncomingTalentSuccessionTransitionPulseWindow pulseWindow;
  final IncomingTalentSuccessionTransitionPulseHealth pulseHealth;
  final IncomingTalentSuccessionTransitionRetentionRisk retentionRisk;
  final IncomingTalentSuccessionTransitionInterventionType interventionType;
  final IncomingTalentSuccessionTransitionInterventionStatus status;
  final DateTime dueDate;
  final String interventionPlan;
  final String sponsorSupport;
  final String successMetric;
  final DateTime createdAt;

  const IncomingTalentSuccessionTransitionIntervention({
    required this.id,
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
    required this.ownerName,
    required this.closureType,
    required this.pulseWindow,
    required this.pulseHealth,
    required this.retentionRisk,
    required this.interventionType,
    required this.status,
    required this.dueDate,
    required this.interventionPlan,
    required this.sponsorSupport,
    required this.successMetric,
    required this.createdAt,
  });

  bool get isOpen {
    return status !=
        IncomingTalentSuccessionTransitionInterventionStatus.completed;
  }

  bool get needsAttention {
    return isOpen ||
        status == IncomingTalentSuccessionTransitionInterventionStatus.blocked;
  }

  int daysUntilDue(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(start).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    final days = daysUntilDue(asOfDate);
    return isOpen && days >= 0 && days <= 7;
  }

  bool isOverdue(DateTime asOfDate) {
    return isOpen && daysUntilDue(asOfDate) < 0;
  }

  IncomingTalentSuccessionTransitionIntervention copyWith({
    IncomingTalentSuccessionTransitionInterventionStatus? status,
  }) {
    return IncomingTalentSuccessionTransitionIntervention(
      id: id,
      pulseId: pulseId,
      closureId: closureId,
      resolutionReviewId: resolutionReviewId,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      targetRole: targetRole,
      ownerName: ownerName,
      closureType: closureType,
      pulseWindow: pulseWindow,
      pulseHealth: pulseHealth,
      retentionRisk: retentionRisk,
      interventionType: interventionType,
      status: status ?? this.status,
      dueDate: dueDate,
      interventionPlan: interventionPlan,
      sponsorSupport: sponsorSupport,
      successMetric: successMetric,
      createdAt: createdAt,
    );
  }
}

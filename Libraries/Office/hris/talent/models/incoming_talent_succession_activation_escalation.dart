import 'incoming_talent_succession_activation_check_in.dart';

enum IncomingTalentSuccessionActivationEscalationPriority {
  standard('Standard'),
  urgent('Urgent'),
  executive('Executive');

  final String label;

  const IncomingTalentSuccessionActivationEscalationPriority(this.label);
}

enum IncomingTalentSuccessionActivationEscalationStatus {
  opened('Opened'),
  inProgress('In progress'),
  resolved('Resolved'),
  blocked('Blocked');

  final String label;

  const IncomingTalentSuccessionActivationEscalationStatus(this.label);
}

class IncomingTalentSuccessionActivationEscalation {
  final String id;
  final String checkInId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String ownerName;
  final IncomingTalentSuccessionActivationCheckInTrend checkInTrend;
  final int confidenceScore;
  final IncomingTalentSuccessionActivationEscalationPriority priority;
  final IncomingTalentSuccessionActivationEscalationStatus status;
  final DateTime dueDate;
  final String escalationReason;
  final String decisionNeeded;
  final String sponsorCommitment;
  final String successCriteria;
  final DateTime createdAt;

  const IncomingTalentSuccessionActivationEscalation({
    required this.id,
    required this.checkInId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.ownerName,
    required this.checkInTrend,
    required this.confidenceScore,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.escalationReason,
    required this.decisionNeeded,
    required this.sponsorCommitment,
    required this.successCriteria,
    required this.createdAt,
  });

  bool get isOpen {
    return status !=
        IncomingTalentSuccessionActivationEscalationStatus.resolved;
  }

  bool get needsAttention {
    return isOpen &&
        (priority !=
                IncomingTalentSuccessionActivationEscalationPriority.standard ||
            status ==
                IncomingTalentSuccessionActivationEscalationStatus.blocked);
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

  IncomingTalentSuccessionActivationEscalation copyWith({
    IncomingTalentSuccessionActivationEscalationStatus? status,
  }) {
    return IncomingTalentSuccessionActivationEscalation(
      id: id,
      checkInId: checkInId,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      targetRole: targetRole,
      ownerName: ownerName,
      checkInTrend: checkInTrend,
      confidenceScore: confidenceScore,
      priority: priority,
      status: status ?? this.status,
      dueDate: dueDate,
      escalationReason: escalationReason,
      decisionNeeded: decisionNeeded,
      sponsorCommitment: sponsorCommitment,
      successCriteria: successCriteria,
      createdAt: createdAt,
    );
  }
}

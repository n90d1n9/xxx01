import 'incoming_talent_succession_bench_check_in.dart';
import 'incoming_talent_succession_bench_replenishment.dart';

enum IncomingTalentSuccessionBenchActionType {
  sourcing('Sourcing'),
  development('Development'),
  leadership('Leadership'),
  mobility('Mobility'),
  externalSearch('External search');

  final String label;

  const IncomingTalentSuccessionBenchActionType(this.label);
}

enum IncomingTalentSuccessionBenchActionStatus {
  planned('Planned'),
  inProgress('In progress'),
  resolved('Resolved'),
  blocked('Blocked');

  final String label;

  const IncomingTalentSuccessionBenchActionStatus(this.label);
}

class IncomingTalentSuccessionBenchAction {
  final String id;
  final String checkInId;
  final String benchReplenishmentId;
  final String outcomeReviewId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String ownerName;
  final IncomingTalentSuccessionBenchReplenishmentPriority priority;
  final IncomingTalentSuccessionBenchCheckInHealth checkInHealth;
  final IncomingTalentSuccessionBenchActionType actionType;
  final IncomingTalentSuccessionBenchActionStatus status;
  final DateTime dueDate;
  final String actionPlan;
  final String escalationPath;
  final String resolutionEvidence;
  final DateTime createdAt;

  const IncomingTalentSuccessionBenchAction({
    required this.id,
    required this.checkInId,
    required this.benchReplenishmentId,
    required this.outcomeReviewId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.ownerName,
    required this.priority,
    required this.checkInHealth,
    required this.actionType,
    required this.status,
    required this.dueDate,
    required this.actionPlan,
    required this.escalationPath,
    required this.resolutionEvidence,
    required this.createdAt,
  });

  bool get isOpen {
    return status != IncomingTalentSuccessionBenchActionStatus.resolved;
  }

  bool get needsAttention {
    return isOpen ||
        status == IncomingTalentSuccessionBenchActionStatus.blocked;
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

  IncomingTalentSuccessionBenchAction copyWith({
    IncomingTalentSuccessionBenchActionStatus? status,
  }) {
    return IncomingTalentSuccessionBenchAction(
      id: id,
      checkInId: checkInId,
      benchReplenishmentId: benchReplenishmentId,
      outcomeReviewId: outcomeReviewId,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      targetRole: targetRole,
      ownerName: ownerName,
      priority: priority,
      checkInHealth: checkInHealth,
      actionType: actionType,
      status: status ?? this.status,
      dueDate: dueDate,
      actionPlan: actionPlan,
      escalationPath: escalationPath,
      resolutionEvidence: resolutionEvidence,
      createdAt: createdAt,
    );
  }
}

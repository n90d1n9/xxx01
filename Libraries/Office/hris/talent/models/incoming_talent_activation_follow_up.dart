enum IncomingTalentActivationFollowUpType {
  coaching('Coaching'),
  mentorCapacity('Mentor capacity'),
  managerAlignment('Manager alignment'),
  learningAdjustment('Learning adjustment'),
  accessBlocker('Access blocker');

  final String label;

  const IncomingTalentActivationFollowUpType(this.label);
}

enum IncomingTalentActivationFollowUpStatus {
  planned('Planned'),
  inProgress('In progress'),
  completed('Completed'),
  blocked('Blocked');

  final String label;

  const IncomingTalentActivationFollowUpStatus(this.label);
}

class IncomingTalentActivationFollowUpAction {
  final String id;
  final String checkpointId;
  final String activationPlanId;
  final String handoffId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String ownerName;
  final int acceptedProgramMilestoneCount;
  final int roleReadyProgramCompletionCount;
  final int programCompletionExtensionCount;
  final IncomingTalentActivationFollowUpType actionType;
  final IncomingTalentActivationFollowUpStatus status;
  final DateTime dueDate;
  final String action;
  final String successCriteria;
  final DateTime createdAt;

  const IncomingTalentActivationFollowUpAction({
    required this.id,
    required this.checkpointId,
    required this.activationPlanId,
    required this.handoffId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.ownerName,
    this.acceptedProgramMilestoneCount = 0,
    this.roleReadyProgramCompletionCount = 0,
    this.programCompletionExtensionCount = 0,
    required this.actionType,
    required this.status,
    required this.dueDate,
    required this.action,
    required this.successCriteria,
    required this.createdAt,
  });

  bool get isOpen => status != IncomingTalentActivationFollowUpStatus.completed;

  bool get needsAttention => isOpen || programCompletionExtensionCount > 0;

  int get developmentEvidenceCount {
    return acceptedProgramMilestoneCount + roleReadyProgramCompletionCount;
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

  IncomingTalentActivationFollowUpAction copyWith({
    IncomingTalentActivationFollowUpStatus? status,
    int? acceptedProgramMilestoneCount,
    int? roleReadyProgramCompletionCount,
    int? programCompletionExtensionCount,
  }) {
    return IncomingTalentActivationFollowUpAction(
      id: id,
      checkpointId: checkpointId,
      activationPlanId: activationPlanId,
      handoffId: handoffId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      ownerName: ownerName,
      acceptedProgramMilestoneCount:
          acceptedProgramMilestoneCount ?? this.acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount:
          roleReadyProgramCompletionCount ??
          this.roleReadyProgramCompletionCount,
      programCompletionExtensionCount:
          programCompletionExtensionCount ??
          this.programCompletionExtensionCount,
      actionType: actionType,
      status: status ?? this.status,
      dueDate: dueDate,
      action: action,
      successCriteria: successCriteria,
      createdAt: createdAt,
    );
  }
}

enum IncomingTalentActivationStatus {
  planned('Planned'),
  active('Active'),
  completed('Completed'),
  blocked('Blocked');

  final String label;

  const IncomingTalentActivationStatus(this.label);
}

class IncomingTalentActivationPlan {
  final String id;
  final String handoffId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String managerName;
  final int acceptedProgramMilestoneCount;
  final int roleReadyProgramCompletionCount;
  final int programCompletionExtensionCount;
  final String mentorName;
  final String learningPlanTitle;
  final String activationOwner;
  final DateTime kickoffDate;
  final DateTime firstCheckpointDate;
  final String successMeasure;
  final String notes;
  final IncomingTalentActivationStatus status;
  final DateTime createdAt;

  const IncomingTalentActivationPlan({
    required this.id,
    required this.handoffId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.managerName,
    this.acceptedProgramMilestoneCount = 0,
    this.roleReadyProgramCompletionCount = 0,
    this.programCompletionExtensionCount = 0,
    required this.mentorName,
    required this.learningPlanTitle,
    required this.activationOwner,
    required this.kickoffDate,
    required this.firstCheckpointDate,
    required this.successMeasure,
    required this.notes,
    required this.status,
    required this.createdAt,
  });

  bool get isOpen => status != IncomingTalentActivationStatus.completed;

  bool get needsAttention => status != IncomingTalentActivationStatus.completed;

  int get developmentEvidenceCount {
    return acceptedProgramMilestoneCount + roleReadyProgramCompletionCount;
  }

  bool get hasProgramExtensionRisk => programCompletionExtensionCount > 0;

  double get progress {
    return switch (status) {
      IncomingTalentActivationStatus.planned => 0.25,
      IncomingTalentActivationStatus.active => 0.65,
      IncomingTalentActivationStatus.blocked => 0.35,
      IncomingTalentActivationStatus.completed => 1,
    };
  }

  int daysUntilKickoff(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final kickoff = DateTime(
      kickoffDate.year,
      kickoffDate.month,
      kickoffDate.day,
    );
    return kickoff.difference(start).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    final days = daysUntilKickoff(asOfDate);
    return isOpen && days >= 0 && days <= 7;
  }

  bool isOverdue(DateTime asOfDate) {
    return status == IncomingTalentActivationStatus.planned &&
        daysUntilKickoff(asOfDate) < 0;
  }

  IncomingTalentActivationPlan copyWith({
    IncomingTalentActivationStatus? status,
    int? acceptedProgramMilestoneCount,
    int? roleReadyProgramCompletionCount,
    int? programCompletionExtensionCount,
  }) {
    return IncomingTalentActivationPlan(
      id: id,
      handoffId: handoffId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      managerName: managerName,
      acceptedProgramMilestoneCount:
          acceptedProgramMilestoneCount ?? this.acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount:
          roleReadyProgramCompletionCount ??
          this.roleReadyProgramCompletionCount,
      programCompletionExtensionCount:
          programCompletionExtensionCount ??
          this.programCompletionExtensionCount,
      mentorName: mentorName,
      learningPlanTitle: learningPlanTitle,
      activationOwner: activationOwner,
      kickoffDate: kickoffDate,
      firstCheckpointDate: firstCheckpointDate,
      successMeasure: successMeasure,
      notes: notes,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

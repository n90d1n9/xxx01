enum CandidateDevelopmentObjectiveStatus {
  planned('Planned'),
  active('Active'),
  completed('Completed');

  final String label;

  const CandidateDevelopmentObjectiveStatus(this.label);
}

class CandidateDevelopmentObjective {
  final String id;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String objectiveTitle;
  final String skillFocus;
  final String ownerName;
  final String mentorName;
  final String successMeasure;
  final DateTime startDate;
  final DateTime dueDate;
  final CandidateDevelopmentObjectiveStatus status;
  final DateTime createdAt;

  const CandidateDevelopmentObjective({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.objectiveTitle,
    required this.skillFocus,
    required this.ownerName,
    required this.mentorName,
    required this.successMeasure,
    required this.startDate,
    required this.dueDate,
    required this.status,
    required this.createdAt,
  });

  bool get isOpen => status != CandidateDevelopmentObjectiveStatus.completed;

  int daysUntilDue(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(start).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    return isOpen && daysUntilDue(asOfDate) <= 14;
  }

  CandidateDevelopmentObjective copyWith({
    CandidateDevelopmentObjectiveStatus? status,
  }) {
    return CandidateDevelopmentObjective(
      id: id,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      objectiveTitle: objectiveTitle,
      skillFocus: skillFocus,
      ownerName: ownerName,
      mentorName: mentorName,
      successMeasure: successMeasure,
      startDate: startDate,
      dueDate: dueDate,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

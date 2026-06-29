enum CandidateDevelopmentInterventionType {
  coaching('Coaching'),
  unblock('Unblock'),
  escalation('Escalation'),
  timelineReview('Timeline review');

  final String label;

  const CandidateDevelopmentInterventionType(this.label);
}

enum CandidateDevelopmentInterventionStatus {
  open('Open'),
  inProgress('In progress'),
  resolved('Resolved');

  final String label;

  const CandidateDevelopmentInterventionStatus(this.label);
}

class CandidateDevelopmentIntervention {
  final String id;
  final String checkInId;
  final String objectiveId;
  final String candidateName;
  final String role;
  final String department;
  final String objectiveTitle;
  final String ownerName;
  final CandidateDevelopmentInterventionType type;
  final String actionNote;
  final bool escalationRequired;
  final DateTime dueDate;
  final CandidateDevelopmentInterventionStatus status;
  final DateTime createdAt;

  const CandidateDevelopmentIntervention({
    required this.id,
    required this.checkInId,
    required this.objectiveId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.objectiveTitle,
    required this.ownerName,
    required this.type,
    required this.actionNote,
    required this.escalationRequired,
    required this.dueDate,
    required this.status,
    required this.createdAt,
  });

  bool get isOpen => status != CandidateDevelopmentInterventionStatus.resolved;

  int daysUntilDue(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(start).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    return isOpen && daysUntilDue(asOfDate) <= 7;
  }

  CandidateDevelopmentIntervention copyWith({
    CandidateDevelopmentInterventionStatus? status,
  }) {
    return CandidateDevelopmentIntervention(
      id: id,
      checkInId: checkInId,
      objectiveId: objectiveId,
      candidateName: candidateName,
      role: role,
      department: department,
      objectiveTitle: objectiveTitle,
      ownerName: ownerName,
      type: type,
      actionNote: actionNote,
      escalationRequired: escalationRequired,
      dueDate: dueDate,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

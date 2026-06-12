enum CandidateTalentHandoffChecklistCategory {
  paperwork('Paperwork'),
  payroll('Payroll'),
  access('Access'),
  managerKickoff('Manager kickoff'),
  mentor('Mentor'),
  learning('Learning');

  final String label;

  const CandidateTalentHandoffChecklistCategory(this.label);
}

enum CandidateTalentHandoffChecklistStatus {
  open('Open'),
  inProgress('In progress'),
  completed('Completed'),
  blocked('Blocked');

  final String label;

  const CandidateTalentHandoffChecklistStatus(this.label);
}

class CandidateTalentHandoffChecklistItem {
  final String id;
  final String handoffId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final CandidateTalentHandoffChecklistCategory category;
  final CandidateTalentHandoffChecklistStatus status;
  final String title;
  final String ownerName;
  final DateTime dueDate;
  final String detail;
  final bool requiredBeforeStart;
  final DateTime createdAt;

  const CandidateTalentHandoffChecklistItem({
    required this.id,
    required this.handoffId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.category,
    required this.status,
    required this.title,
    required this.ownerName,
    required this.dueDate,
    required this.detail,
    required this.requiredBeforeStart,
    required this.createdAt,
  });

  bool get isOpen => status != CandidateTalentHandoffChecklistStatus.completed;

  int daysUntilDue(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(start).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    return isOpen && daysUntilDue(asOfDate) <= 7;
  }

  bool isOverdue(DateTime asOfDate) {
    return isOpen && daysUntilDue(asOfDate) < 0;
  }

  CandidateTalentHandoffChecklistItem copyWith({
    CandidateTalentHandoffChecklistStatus? status,
  }) {
    return CandidateTalentHandoffChecklistItem(
      id: id,
      handoffId: handoffId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      category: category,
      status: status ?? this.status,
      title: title,
      ownerName: ownerName,
      dueDate: dueDate,
      detail: detail,
      requiredBeforeStart: requiredBeforeStart,
      createdAt: createdAt,
    );
  }
}

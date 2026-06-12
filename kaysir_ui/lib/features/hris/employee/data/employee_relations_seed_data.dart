import '../models/employee_directory_models.dart';
import '../models/employee_relations_models.dart';

EmployeeRelationsProfile buildEmployeeRelationsProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeRelationsProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    events: _eventsFor(member, today),
  );
}

EmployeeRelationsEventDraft buildEmployeeRelationsEventDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeRelationsEventDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    type: EmployeeRelationsEventType.recognition,
    title: 'Recognize employee impact',
    owner: member.manager,
    occurredAt: today,
    followUpDate: today.add(const Duration(days: 7)),
    severity: EmployeeRelationsSeverity.low,
    visibility: EmployeeRelationsVisibility.managerOnly,
    summary: '',
  );
}

List<EmployeeRelationsEvent> _eventsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeRelationsEvent(
        id: 'ERL-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeRelationsEventType.performanceImprovement,
        title: 'Performance improvement plan checkpoint',
        owner: member.manager,
        occurredAt: today.subtract(const Duration(days: 14)),
        followUpDate: today.subtract(const Duration(days: 1)),
        severity: EmployeeRelationsSeverity.high,
        status: EmployeeRelationsStatus.followUpDue,
        visibility: EmployeeRelationsVisibility.confidential,
        summary:
            'PIP checkpoint is overdue and needs documented manager follow-up.',
      ),
      EmployeeRelationsEvent(
        id: 'ERL-${member.id}-002',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeRelationsEventType.coaching,
        title: 'Coaching on roadmap commitments',
        owner: 'People Partner',
        occurredAt: today.subtract(const Duration(days: 22)),
        followUpDate: today.add(const Duration(days: 4)),
        severity: EmployeeRelationsSeverity.medium,
        status: EmployeeRelationsStatus.inProgress,
        visibility: EmployeeRelationsVisibility.managerOnly,
        summary:
            'Manager and people partner aligned weekly coaching checkpoints.',
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeeRelationsEvent(
        id: 'ERL-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeRelationsEventType.commendation,
        title: 'Leadership commendation',
        owner: 'People Leadership',
        occurredAt: today.subtract(const Duration(days: 21)),
        followUpDate: null,
        severity: EmployeeRelationsSeverity.low,
        status: EmployeeRelationsStatus.documented,
        visibility: EmployeeRelationsVisibility.team,
        summary:
            'Recognized for raising execution quality and mentoring peers.',
      ),
      EmployeeRelationsEvent(
        id: 'ERL-${member.id}-002',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeRelationsEventType.recognition,
        title: 'Customer impact recognition',
        owner: member.manager,
        occurredAt: today.subtract(const Duration(days: 40)),
        followUpDate: null,
        severity: EmployeeRelationsSeverity.low,
        status: EmployeeRelationsStatus.documented,
        visibility: EmployeeRelationsVisibility.team,
        summary:
            'Customer feedback highlighted clarity and ownership during launch.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeRelationsEvent(
        id: 'ERL-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeRelationsEventType.coaching,
        title: 'Onboarding expectation coaching',
        owner: member.manager,
        occurredAt: today.subtract(const Duration(days: 3)),
        followUpDate: today.add(const Duration(days: 5)),
        severity: EmployeeRelationsSeverity.low,
        status: EmployeeRelationsStatus.inProgress,
        visibility: EmployeeRelationsVisibility.managerOnly,
        summary:
            'Clarified first-month expectations and support cadence with manager.',
      ),
    ];
  }

  return [
    EmployeeRelationsEvent(
      id: 'ERL-${member.id}-001',
      employeeId: member.id,
      employeeName: member.name,
      type: EmployeeRelationsEventType.recognition,
      title: '${member.department} contribution recognized',
      owner: member.manager,
      occurredAt: today.subtract(const Duration(days: 16)),
      followUpDate: null,
      severity: EmployeeRelationsSeverity.low,
      status: EmployeeRelationsStatus.documented,
      visibility: EmployeeRelationsVisibility.team,
      summary:
          'Manager documented a positive contribution to team delivery quality.',
    ),
  ];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

import '../models/employee_directory_models.dart';
import '../models/employee_timeline_models.dart';

EmployeeTimelineProfile buildEmployeeTimelineProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeTimelineProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    entries: _entriesFor(member, today),
  );
}

EmployeeTimelineDraft buildEmployeeTimelineDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeTimelineDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    type: EmployeeTimelineEventType.note,
    title: 'Timeline note',
    detail: '',
    owner: member.manager,
    occurredAt: today,
    dueAt: today.add(const Duration(days: 7)),
    priority: EmployeeTimelinePriority.followUp,
    pinned: false,
  );
}

List<EmployeeTimelineEntry> _entriesFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  final entries = <EmployeeTimelineEntry>[
    EmployeeTimelineEntry(
      id: 'ETL-${member.id}-HIRE',
      employeeId: member.id,
      employeeName: member.name,
      type: EmployeeTimelineEventType.hire,
      title: 'Joined ${member.department}',
      detail: '${member.position} started in ${member.location}.',
      owner: 'People Operations',
      occurredAt: _dateOnly(member.joiningDate),
      dueAt: null,
      priority: EmployeeTimelinePriority.milestone,
      status: EmployeeTimelineStatus.completed,
      pinned: true,
    ),
  ];

  if (member.status == EmployeeDirectoryStatus.watchlist) {
    entries.addAll([
      EmployeeTimelineEntry(
        id: 'ETL-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeTimelineEventType.security,
        title: 'Privileged access review follow-up',
        detail: 'Admin and finance access need manager decision.',
        owner: 'IT Security',
        occurredAt: today.subtract(const Duration(days: 5)),
        dueAt: today.subtract(const Duration(days: 1)),
        priority: EmployeeTimelinePriority.risk,
        status: EmployeeTimelineStatus.open,
        pinned: true,
      ),
      EmployeeTimelineEntry(
        id: 'ETL-${member.id}-002',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeTimelineEventType.growth,
        title: 'Performance checkpoint',
        detail: 'Follow up on product delivery goals and manager feedback.',
        owner: member.manager,
        occurredAt: today.subtract(const Duration(days: 2)),
        dueAt: today.add(const Duration(days: 2)),
        priority: EmployeeTimelinePriority.followUp,
        status: EmployeeTimelineStatus.open,
        pinned: false,
      ),
    ]);
  } else if (member.status == EmployeeDirectoryStatus.onboarding) {
    entries.addAll([
      EmployeeTimelineEntry(
        id: 'ETL-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeTimelineEventType.work,
        title: 'First-week onboarding check',
        detail: 'Confirm manager intro, equipment, and HRIS access.',
        owner: member.manager,
        occurredAt: today,
        dueAt: today,
        priority: EmployeeTimelinePriority.followUp,
        status: EmployeeTimelineStatus.open,
        pinned: true,
      ),
      EmployeeTimelineEntry(
        id: 'ETL-${member.id}-002',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeTimelineEventType.pay,
        title: 'Payroll readiness follow-up',
        detail: 'Collect bank and tax profile before first payroll.',
        owner: 'Payroll Operations',
        occurredAt: today,
        dueAt: today.add(const Duration(days: 3)),
        priority: EmployeeTimelinePriority.followUp,
        status: EmployeeTimelineStatus.open,
        pinned: false,
      ),
    ]);
  } else if (member.isHighPerformer) {
    entries.add(
      EmployeeTimelineEntry(
        id: 'ETL-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeTimelineEventType.growth,
        title: 'High performer calibration',
        detail: 'Recognized in talent calibration and growth planning.',
        owner: member.manager,
        occurredAt: today.subtract(const Duration(days: 14)),
        dueAt: null,
        priority: EmployeeTimelinePriority.milestone,
        status: EmployeeTimelineStatus.completed,
        pinned: true,
      ),
    );
  }

  return entries;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

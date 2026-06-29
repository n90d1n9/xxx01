import '../models/employee_directory_models.dart';
import '../models/employee_timekeeping_models.dart';

EmployeeTimekeepingProfile buildEmployeeTimekeepingProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  return EmployeeTimekeepingProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    periodStart: today.subtract(Duration(days: today.weekday - 1)),
    periodEnd: today
        .subtract(Duration(days: today.weekday - 1))
        .add(const Duration(days: 6)),
    payrollCutoffDate: today.add(const Duration(days: 2)),
    entries: _entriesFor(member, today),
    exceptions: _exceptionsFor(member, today),
  );
}

EmployeeTimekeepingExceptionDraft buildEmployeeTimekeepingExceptionDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final watchlist = member.status == EmployeeDirectoryStatus.watchlist;
  return EmployeeTimekeepingExceptionDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    type:
        watchlist
            ? EmployeeTimekeepingExceptionType.missingClockOut
            : EmployeeTimekeepingExceptionType.overtime,
    workDate: _dateOnly(asOfDate).subtract(const Duration(days: 1)),
    severity:
        watchlist
            ? EmployeeTimekeepingExceptionSeverity.high
            : EmployeeTimekeepingExceptionSeverity.medium,
    owner: member.manager,
    minutesImpact: watchlist ? 90 : 45,
    payrollImpact: watchlist,
    note: '',
  );
}

List<EmployeeTimesheetEntry> _entriesFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.id == '4') {
    return [
      EmployeeTimesheetEntry(
        id: '${member.id}-time-entry-1',
        employeeId: member.id,
        workDate: today.subtract(const Duration(days: 1)),
        scheduledHours: 8,
        regularHours: 7.5,
        overtimeHours: 1.5,
        breakMinutes: 30,
        status: EmployeeTimesheetEntryStatus.submitted,
        approvedBy: '',
        note: 'Roadmap recovery support work submitted for review.',
      ),
      EmployeeTimesheetEntry(
        id: '${member.id}-time-entry-2',
        employeeId: member.id,
        workDate: today.subtract(const Duration(days: 2)),
        scheduledHours: 8,
        regularHours: 8,
        overtimeHours: 2,
        breakMinutes: 20,
        status: EmployeeTimesheetEntryStatus.approved,
        approvedBy: member.manager,
        note: 'Approved product incident follow-up overtime.',
      ),
      EmployeeTimesheetEntry(
        id: '${member.id}-time-entry-3',
        employeeId: member.id,
        workDate: today.subtract(const Duration(days: 3)),
        scheduledHours: 8,
        regularHours: 6.75,
        overtimeHours: 0,
        breakMinutes: 45,
        status: EmployeeTimesheetEntryStatus.rejected,
        approvedBy: '',
        note: 'Rejected pending missing clock-out correction.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeTimesheetEntry(
        id: '${member.id}-time-entry-1',
        employeeId: member.id,
        workDate: today.subtract(const Duration(days: 1)),
        scheduledHours: 8,
        regularHours: 8,
        overtimeHours: 0,
        breakMinutes: 60,
        status: EmployeeTimesheetEntryStatus.submitted,
        approvedBy: '',
        note: 'First-cycle onboarding timesheet submitted.',
      ),
      EmployeeTimesheetEntry(
        id: '${member.id}-time-entry-2',
        employeeId: member.id,
        workDate: today.subtract(const Duration(days: 2)),
        scheduledHours: 8,
        regularHours: 8,
        overtimeHours: 0,
        breakMinutes: 60,
        status: EmployeeTimesheetEntryStatus.approved,
        approvedBy: member.manager,
        note: 'Manager approved onboarding shift.',
      ),
    ];
  }

  return [
    EmployeeTimesheetEntry(
      id: '${member.id}-time-entry-1',
      employeeId: member.id,
      workDate: today.subtract(const Duration(days: 1)),
      scheduledHours: 8,
      regularHours: 8,
      overtimeHours: member.isHighPerformer ? 1 : 0,
      breakMinutes: 60,
      status: EmployeeTimesheetEntryStatus.payrollReady,
      approvedBy: member.manager,
      note: 'Timesheet entry cleared for payroll.',
    ),
    EmployeeTimesheetEntry(
      id: '${member.id}-time-entry-2',
      employeeId: member.id,
      workDate: today.subtract(const Duration(days: 2)),
      scheduledHours: 8,
      regularHours: 8,
      overtimeHours: 0,
      breakMinutes: 60,
      status: EmployeeTimesheetEntryStatus.payrollReady,
      approvedBy: member.manager,
      note: 'Standard workday cleared for payroll.',
    ),
  ];
}

List<EmployeeTimekeepingException> _exceptionsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.id == '4') {
    return [
      EmployeeTimekeepingException(
        id: '${member.id}-time-exception-missing-clock',
        employeeId: member.id,
        type: EmployeeTimekeepingExceptionType.missingClockOut,
        workDate: today.subtract(const Duration(days: 3)),
        severity: EmployeeTimekeepingExceptionSeverity.critical,
        status: EmployeeTimekeepingExceptionStatus.open,
        owner: member.manager,
        minutesImpact: 75,
        payrollImpact: true,
        note: 'Missing clock-out blocks payroll validation for Friday.',
      ),
      EmployeeTimekeepingException(
        id: '${member.id}-time-exception-overtime',
        employeeId: member.id,
        type: EmployeeTimekeepingExceptionType.overtime,
        workDate: today.subtract(const Duration(days: 2)),
        severity: EmployeeTimekeepingExceptionSeverity.high,
        status: EmployeeTimekeepingExceptionStatus.inReview,
        owner: 'Payroll Operations',
        minutesImpact: 120,
        payrollImpact: true,
        note: 'Overtime requires approval evidence from roadmap recovery work.',
      ),
      EmployeeTimekeepingException(
        id: '${member.id}-time-exception-late',
        employeeId: member.id,
        type: EmployeeTimekeepingExceptionType.lateArrival,
        workDate: today.subtract(const Duration(days: 5)),
        severity: EmployeeTimekeepingExceptionSeverity.low,
        status: EmployeeTimekeepingExceptionStatus.resolved,
        owner: member.manager,
        minutesImpact: 18,
        payrollImpact: false,
        note: 'Late arrival was reconciled with flexible schedule note.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeTimekeepingException(
        id: '${member.id}-time-exception-break',
        employeeId: member.id,
        type: EmployeeTimekeepingExceptionType.breakViolation,
        workDate: today.subtract(const Duration(days: 1)),
        severity: EmployeeTimekeepingExceptionSeverity.medium,
        status: EmployeeTimekeepingExceptionStatus.open,
        owner: member.manager,
        minutesImpact: 20,
        payrollImpact: false,
        note: 'Break policy coaching needed during onboarding period.',
      ),
    ];
  }

  return const [];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

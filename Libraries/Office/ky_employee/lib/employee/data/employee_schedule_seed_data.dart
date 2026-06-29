import '../models/employee_directory_models.dart';
import '../models/employee_schedule_models.dart';

EmployeeScheduleProfile buildEmployeeScheduleProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeScheduleProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    assignment: _assignmentFor(member),
    attendanceSignals: _signalsFor(member, today),
    adjustments: _adjustmentsFor(member, today),
  );
}

EmployeeScheduleAdjustmentDraft buildEmployeeScheduleAdjustmentDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  final assignment = _assignmentFor(member);

  return EmployeeScheduleAdjustmentDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    type: EmployeeScheduleAdjustmentType.shiftChange,
    targetDate: today.add(const Duration(days: 7)),
    startTimeLabel: assignment.startTimeLabel,
    endTimeLabel: assignment.endTimeLabel,
    location: assignment.location,
    reason: '',
  );
}

EmployeeScheduleAssignment _assignmentFor(EmployeeDirectoryMember member) {
  final pattern =
      member.status == EmployeeDirectoryStatus.watchlist
          ? EmployeeSchedulePattern.flexible
          : member.location == 'Singapore'
          ? EmployeeSchedulePattern.compressed
          : EmployeeSchedulePattern.standard;
  final workDays =
      pattern == EmployeeSchedulePattern.compressed
          ? ['Mon', 'Tue', 'Wed', 'Thu']
          : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final weeklyHours =
      pattern == EmployeeSchedulePattern.compressed ? 36.0 : 40.0;
  final startTime =
      pattern == EmployeeSchedulePattern.flexible
          ? '10:00'
          : pattern == EmployeeSchedulePattern.compressed
          ? '08:00'
          : '09:00';
  final endTime =
      pattern == EmployeeSchedulePattern.compressed ? '18:00' : '17:00';

  return EmployeeScheduleAssignment(
    employeeId: member.id,
    pattern: pattern,
    workDays: workDays,
    startTimeLabel: startTime,
    endTimeLabel: endTime,
    location: member.location,
    timezone: _timezoneFor(member.location),
    weeklyHours: weeklyHours,
    effectiveFrom: _dateOnly(member.joiningDate),
  );
}

List<EmployeeAttendanceSignal> _signalsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeAttendanceSignal(
        id: 'EAS-${member.id}-001',
        employeeId: member.id,
        date: today.subtract(const Duration(days: 1)),
        type: EmployeeAttendanceSignalType.absence,
        severity: EmployeeAttendanceSignalSeverity.high,
        minutesVariance: 480,
        note: 'Unexcused absence requires manager and HR follow-up.',
        resolved: false,
      ),
      EmployeeAttendanceSignal(
        id: 'EAS-${member.id}-002',
        employeeId: member.id,
        date: today.subtract(const Duration(days: 3)),
        type: EmployeeAttendanceSignalType.lateArrival,
        severity: EmployeeAttendanceSignalSeverity.medium,
        minutesVariance: 42,
        note: 'Late arrival trend on flexible schedule needs coaching.',
        resolved: false,
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeAttendanceSignal(
        id: 'EAS-${member.id}-001',
        employeeId: member.id,
        date: today.subtract(const Duration(days: 2)),
        type: EmployeeAttendanceSignalType.missedClockOut,
        severity: EmployeeAttendanceSignalSeverity.medium,
        minutesVariance: 0,
        note: 'First-week missed clock-out needs timekeeping correction.',
        resolved: false,
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeeAttendanceSignal(
        id: 'EAS-${member.id}-001',
        employeeId: member.id,
        date: today.subtract(const Duration(days: 5)),
        type: EmployeeAttendanceSignalType.overtimeDrift,
        severity: EmployeeAttendanceSignalSeverity.low,
        minutesVariance: 68,
        note: 'Overtime reviewed with manager and marked as expected.',
        resolved: true,
      ),
    ];
  }

  return const [];
}

List<EmployeeScheduleAdjustmentRequest> _adjustmentsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeScheduleAdjustmentRequest(
        id: 'ESA-${member.id}-001',
        employeeId: member.id,
        type: EmployeeScheduleAdjustmentType.locationChange,
        targetDate: today.add(const Duration(days: 1)),
        startTimeLabel: '09:00',
        endTimeLabel: '17:00',
        location: 'Jakarta',
        reason: 'Onboarding buddy support requires temporary site coverage.',
        status: EmployeeScheduleAdjustmentStatus.pending,
        createdAt: today,
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeeScheduleAdjustmentRequest(
        id: 'ESA-${member.id}-001',
        employeeId: member.id,
        type: EmployeeScheduleAdjustmentType.remoteDay,
        targetDate: today.add(const Duration(days: 2)),
        startTimeLabel: '09:00',
        endTimeLabel: '17:00',
        location: 'Remote',
        reason: 'Approved remote focus day for project delivery.',
        status: EmployeeScheduleAdjustmentStatus.approved,
        createdAt: today.subtract(const Duration(days: 1)),
      ),
    ];
  }

  return const [];
}

String _timezoneFor(String location) {
  return switch (location) {
    'Singapore' => 'SGT',
    'Bandung' || 'Jakarta' || 'Surabaya' => 'WIB',
    _ => 'Local',
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

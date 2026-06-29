import 'package:flutter/material.dart';

import '../../models/employee_timekeeping_models.dart';

Color employeeTimesheetEntryStatusColor(EmployeeTimesheetEntryStatus status) {
  return switch (status) {
    EmployeeTimesheetEntryStatus.draft => const Color(0xFF64748B),
    EmployeeTimesheetEntryStatus.submitted => const Color(0xFFB45309),
    EmployeeTimesheetEntryStatus.approved => const Color(0xFF2563EB),
    EmployeeTimesheetEntryStatus.payrollReady => const Color(0xFF15803D),
    EmployeeTimesheetEntryStatus.rejected => const Color(0xFFB91C1C),
  };
}

Color employeeTimekeepingExceptionSeverityColor(
  EmployeeTimekeepingExceptionSeverity severity,
) {
  return switch (severity) {
    EmployeeTimekeepingExceptionSeverity.critical => const Color(0xFFB91C1C),
    EmployeeTimekeepingExceptionSeverity.high => const Color(0xFFC2410C),
    EmployeeTimekeepingExceptionSeverity.medium => const Color(0xFFB45309),
    EmployeeTimekeepingExceptionSeverity.low => const Color(0xFF64748B),
  };
}

Color employeeTimekeepingExceptionStatusColor(
  EmployeeTimekeepingExceptionStatus status,
) {
  return switch (status) {
    EmployeeTimekeepingExceptionStatus.open => const Color(0xFFB45309),
    EmployeeTimekeepingExceptionStatus.inReview => const Color(0xFF2563EB),
    EmployeeTimekeepingExceptionStatus.resolved => const Color(0xFF15803D),
    EmployeeTimekeepingExceptionStatus.waived => const Color(0xFF6B7280),
  };
}

IconData employeeTimekeepingExceptionTypeIcon(
  EmployeeTimekeepingExceptionType type,
) {
  return switch (type) {
    EmployeeTimekeepingExceptionType.lateArrival => Icons.alarm_on_outlined,
    EmployeeTimekeepingExceptionType.missingClockOut => Icons.logout_outlined,
    EmployeeTimekeepingExceptionType.overtime => Icons.more_time_outlined,
    EmployeeTimekeepingExceptionType.breakViolation => Icons.coffee_outlined,
    EmployeeTimekeepingExceptionType.absence => Icons.event_busy_outlined,
  };
}

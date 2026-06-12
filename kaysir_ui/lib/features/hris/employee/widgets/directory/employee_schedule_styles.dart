import 'package:flutter/material.dart';

import '../../models/employee_schedule_models.dart';

Color employeeAttendanceSeverityColor(
  EmployeeAttendanceSignalSeverity severity,
) {
  return switch (severity) {
    EmployeeAttendanceSignalSeverity.low => const Color(0xFF2563EB),
    EmployeeAttendanceSignalSeverity.medium => const Color(0xFFB45309),
    EmployeeAttendanceSignalSeverity.high => const Color(0xFFB91C1C),
  };
}

Color employeeScheduleAdjustmentStatusColor(
  EmployeeScheduleAdjustmentStatus status,
) {
  return switch (status) {
    EmployeeScheduleAdjustmentStatus.pending => const Color(0xFFB45309),
    EmployeeScheduleAdjustmentStatus.approved => const Color(0xFF2563EB),
    EmployeeScheduleAdjustmentStatus.applied => const Color(0xFF15803D),
  };
}

IconData employeeSchedulePatternIcon(EmployeeSchedulePattern pattern) {
  return switch (pattern) {
    EmployeeSchedulePattern.standard => Icons.calendar_view_week_outlined,
    EmployeeSchedulePattern.flexible => Icons.tune_outlined,
    EmployeeSchedulePattern.rotating => Icons.sync_outlined,
    EmployeeSchedulePattern.compressed => Icons.compress_outlined,
  };
}

IconData employeeScheduleAdjustmentTypeIcon(
  EmployeeScheduleAdjustmentType type,
) {
  return switch (type) {
    EmployeeScheduleAdjustmentType.shiftChange => Icons.schedule_outlined,
    EmployeeScheduleAdjustmentType.locationChange => Icons.place_outlined,
    EmployeeScheduleAdjustmentType.overtime => Icons.more_time_outlined,
    EmployeeScheduleAdjustmentType.remoteDay => Icons.language_outlined,
  };
}

IconData employeeAttendanceSignalTypeIcon(EmployeeAttendanceSignalType type) {
  return switch (type) {
    EmployeeAttendanceSignalType.lateArrival => Icons.timer_off_outlined,
    EmployeeAttendanceSignalType.absence => Icons.event_busy_outlined,
    EmployeeAttendanceSignalType.missedClockOut => Icons.logout_outlined,
    EmployeeAttendanceSignalType.overtimeDrift => Icons.av_timer_outlined,
  };
}

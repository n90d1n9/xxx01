import 'package:flutter/material.dart';

import '../../models/employee_timeline_models.dart';

Color employeeTimelinePriorityColor(EmployeeTimelinePriority priority) {
  return switch (priority) {
    EmployeeTimelinePriority.info => const Color(0xFF2563EB),
    EmployeeTimelinePriority.milestone => const Color(0xFF15803D),
    EmployeeTimelinePriority.followUp => const Color(0xFFB45309),
    EmployeeTimelinePriority.risk => const Color(0xFFB91C1C),
  };
}

Color employeeTimelineStatusColor(EmployeeTimelineStatus status) {
  return switch (status) {
    EmployeeTimelineStatus.open => const Color(0xFFB45309),
    EmployeeTimelineStatus.completed => const Color(0xFF15803D),
    EmployeeTimelineStatus.resolved => const Color(0xFF6B7280),
  };
}

IconData employeeTimelineTypeIcon(EmployeeTimelineEventType type) {
  return switch (type) {
    EmployeeTimelineEventType.hire => Icons.person_add_alt_outlined,
    EmployeeTimelineEventType.record => Icons.folder_copy_outlined,
    EmployeeTimelineEventType.work => Icons.work_history_outlined,
    EmployeeTimelineEventType.growth => Icons.insights_outlined,
    EmployeeTimelineEventType.pay => Icons.payments_outlined,
    EmployeeTimelineEventType.security => Icons.security_outlined,
    EmployeeTimelineEventType.note => Icons.sticky_note_2_outlined,
  };
}

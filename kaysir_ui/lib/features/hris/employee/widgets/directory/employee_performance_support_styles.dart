import 'package:flutter/material.dart';

import '../../models/employee_performance_support_models.dart';

Color employeePerformanceSupportStatusColor(
  EmployeePerformanceSupportStatus status,
) {
  return switch (status) {
    EmployeePerformanceSupportStatus.draft => const Color(0xFF6B7280),
    EmployeePerformanceSupportStatus.active => const Color(0xFF2563EB),
    EmployeePerformanceSupportStatus.reviewDue => const Color(0xFFB45309),
    EmployeePerformanceSupportStatus.completed => const Color(0xFF15803D),
    EmployeePerformanceSupportStatus.escalated => const Color(0xFFB91C1C),
  };
}

IconData employeePerformanceSupportStatusIcon(
  EmployeePerformanceSupportStatus status,
) {
  return switch (status) {
    EmployeePerformanceSupportStatus.draft => Icons.edit_note_outlined,
    EmployeePerformanceSupportStatus.active => Icons.play_circle_outline,
    EmployeePerformanceSupportStatus.reviewDue => Icons.fact_check_outlined,
    EmployeePerformanceSupportStatus.completed => Icons.verified_outlined,
    EmployeePerformanceSupportStatus.escalated => Icons.report_problem_outlined,
  };
}

Color employeePerformanceMilestoneStatusColor(
  EmployeePerformanceMilestoneStatus status,
) {
  return switch (status) {
    EmployeePerformanceMilestoneStatus.open => const Color(0xFF2563EB),
    EmployeePerformanceMilestoneStatus.inProgress => const Color(0xFF7C3AED),
    EmployeePerformanceMilestoneStatus.blocked => const Color(0xFFB91C1C),
    EmployeePerformanceMilestoneStatus.completed => const Color(0xFF15803D),
    EmployeePerformanceMilestoneStatus.waived => const Color(0xFF6B7280),
  };
}

IconData employeePerformanceMilestoneStatusIcon(
  EmployeePerformanceMilestoneStatus status,
) {
  return switch (status) {
    EmployeePerformanceMilestoneStatus.open => Icons.radio_button_unchecked,
    EmployeePerformanceMilestoneStatus.inProgress =>
      Icons.pending_actions_outlined,
    EmployeePerformanceMilestoneStatus.blocked => Icons.report_problem_outlined,
    EmployeePerformanceMilestoneStatus.completed => Icons.check_circle_outline,
    EmployeePerformanceMilestoneStatus.waived =>
      Icons.do_not_disturb_on_outlined,
  };
}

Color employeePerformanceSupportRiskColor(EmployeePerformanceSupportRisk risk) {
  return switch (risk) {
    EmployeePerformanceSupportRisk.critical => const Color(0xFF991B1B),
    EmployeePerformanceSupportRisk.high => const Color(0xFFB45309),
    EmployeePerformanceSupportRisk.medium => const Color(0xFF2563EB),
    EmployeePerformanceSupportRisk.low => const Color(0xFF15803D),
  };
}

IconData employeePerformanceMilestoneTypeIcon(
  EmployeePerformanceMilestoneType type,
) {
  return switch (type) {
    EmployeePerformanceMilestoneType.coaching =>
      Icons.record_voice_over_outlined,
    EmployeePerformanceMilestoneType.deliverable =>
      Icons.assignment_turned_in_outlined,
    EmployeePerformanceMilestoneType.behavior => Icons.groups_outlined,
    EmployeePerformanceMilestoneType.training => Icons.school_outlined,
    EmployeePerformanceMilestoneType.review => Icons.fact_check_outlined,
  };
}

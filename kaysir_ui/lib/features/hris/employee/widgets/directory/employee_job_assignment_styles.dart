import 'package:flutter/material.dart';

import '../../models/employee_job_assignment_models.dart';

Color employeeJobAssignmentStatusColor(EmployeeJobAssignmentStatus status) {
  return switch (status) {
    EmployeeJobAssignmentStatus.active => const Color(0xFF15803D),
    EmployeeJobAssignmentStatus.scheduled => const Color(0xFF2563EB),
    EmployeeJobAssignmentStatus.pendingApproval => const Color(0xFFB45309),
    EmployeeJobAssignmentStatus.completed => const Color(0xFF6B7280),
  };
}

IconData employeeJobAssignmentStatusIcon(EmployeeJobAssignmentStatus status) {
  return switch (status) {
    EmployeeJobAssignmentStatus.active => Icons.verified_user_outlined,
    EmployeeJobAssignmentStatus.scheduled => Icons.event_available_outlined,
    EmployeeJobAssignmentStatus.pendingApproval => Icons.rate_review_outlined,
    EmployeeJobAssignmentStatus.completed => Icons.history_outlined,
  };
}

IconData employeeJobAssignmentTypeIcon(EmployeeJobAssignmentType type) {
  return switch (type) {
    EmployeeJobAssignmentType.primary => Icons.badge_outlined,
    EmployeeJobAssignmentType.acting => Icons.work_history_outlined,
    EmployeeJobAssignmentType.secondment => Icons.swap_calls_outlined,
    EmployeeJobAssignmentType.probation => Icons.assignment_late_outlined,
  };
}

IconData employeeWorkArrangementIcon(EmployeeWorkArrangement arrangement) {
  return switch (arrangement) {
    EmployeeWorkArrangement.onsite => Icons.business_center_outlined,
    EmployeeWorkArrangement.hybrid => Icons.hub_outlined,
    EmployeeWorkArrangement.remote => Icons.language_outlined,
  };
}

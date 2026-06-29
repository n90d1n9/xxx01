import 'package:flutter/material.dart';

import '../../models/employee_lifecycle_task_models.dart';

Color employeeLifecycleTaskStatusColor(EmployeeLifecycleTaskStatus status) {
  return switch (status) {
    EmployeeLifecycleTaskStatus.open => const Color(0xFF2563EB),
    EmployeeLifecycleTaskStatus.inProgress => const Color(0xFFB45309),
    EmployeeLifecycleTaskStatus.blocked => const Color(0xFFB91C1C),
    EmployeeLifecycleTaskStatus.done => const Color(0xFF15803D),
  };
}

IconData employeeLifecycleTaskStatusIcon(EmployeeLifecycleTaskStatus status) {
  return switch (status) {
    EmployeeLifecycleTaskStatus.open => Icons.radio_button_unchecked,
    EmployeeLifecycleTaskStatus.inProgress => Icons.pending_actions_outlined,
    EmployeeLifecycleTaskStatus.blocked => Icons.report_outlined,
    EmployeeLifecycleTaskStatus.done => Icons.check_circle_outline,
  };
}

Color employeeLifecycleTaskPriorityColor(
  EmployeeLifecycleTaskPriority priority,
) {
  return switch (priority) {
    EmployeeLifecycleTaskPriority.high => const Color(0xFFB91C1C),
    EmployeeLifecycleTaskPriority.medium => const Color(0xFFB45309),
    EmployeeLifecycleTaskPriority.low => const Color(0xFF15803D),
  };
}

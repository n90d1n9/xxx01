import 'package:flutter/material.dart';

import '../../models/employee_action_workflow_models.dart';

Color employeeActionTaskStatusColor(EmployeeActionTaskStatus status) {
  return switch (status) {
    EmployeeActionTaskStatus.open => const Color(0xFF2563EB),
    EmployeeActionTaskStatus.inProgress => const Color(0xFF7C3AED),
    EmployeeActionTaskStatus.waiting => const Color(0xFFB45309),
    EmployeeActionTaskStatus.completed => const Color(0xFF15803D),
    EmployeeActionTaskStatus.cancelled => const Color(0xFF64748B),
  };
}

IconData employeeActionTaskStatusIcon(EmployeeActionTaskStatus status) {
  return switch (status) {
    EmployeeActionTaskStatus.open => Icons.radio_button_unchecked_outlined,
    EmployeeActionTaskStatus.inProgress => Icons.play_circle_outline,
    EmployeeActionTaskStatus.waiting => Icons.hourglass_top_outlined,
    EmployeeActionTaskStatus.completed => Icons.check_circle_outline,
    EmployeeActionTaskStatus.cancelled => Icons.cancel_outlined,
  };
}

import 'package:flutter/material.dart';

import '../../models/employee_action_activity_models.dart';

Color employeeActionActivityTypeColor(EmployeeActionActivityType type) {
  return switch (type) {
    EmployeeActionActivityType.note => const Color(0xFF2563EB),
    EmployeeActionActivityType.blocker => const Color(0xFFB91C1C),
    EmployeeActionActivityType.decision => const Color(0xFF15803D),
    EmployeeActionActivityType.escalation => const Color(0xFFD97706),
    EmployeeActionActivityType.system => const Color(0xFF64748B),
  };
}

IconData employeeActionActivityTypeIcon(EmployeeActionActivityType type) {
  return switch (type) {
    EmployeeActionActivityType.note => Icons.notes_outlined,
    EmployeeActionActivityType.blocker => Icons.report_problem_outlined,
    EmployeeActionActivityType.decision => Icons.rule_outlined,
    EmployeeActionActivityType.escalation => Icons.priority_high_outlined,
    EmployeeActionActivityType.system => Icons.settings_suggest_outlined,
  };
}

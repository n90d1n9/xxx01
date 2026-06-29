import 'package:flutter/material.dart';

import '../../models/employee_action_sla_models.dart';

Color employeeActionSlaStateColor(EmployeeActionSlaState state) {
  return switch (state) {
    EmployeeActionSlaState.overdue => const Color(0xFFB91C1C),
    EmployeeActionSlaState.dueToday => const Color(0xFFD97706),
    EmployeeActionSlaState.dueSoon => const Color(0xFF2563EB),
    EmployeeActionSlaState.onTrack => const Color(0xFF15803D),
    EmployeeActionSlaState.closed => const Color(0xFF64748B),
  };
}

Color employeeActionEscalationColor(EmployeeActionEscalationLevel escalation) {
  return switch (escalation) {
    EmployeeActionEscalationLevel.leadership => const Color(0xFFB91C1C),
    EmployeeActionEscalationLevel.manager => const Color(0xFFD97706),
    EmployeeActionEscalationLevel.watch => const Color(0xFF2563EB),
    EmployeeActionEscalationLevel.none => const Color(0xFF64748B),
  };
}

IconData employeeActionSlaStateIcon(EmployeeActionSlaState state) {
  return switch (state) {
    EmployeeActionSlaState.overdue => Icons.warning_amber_outlined,
    EmployeeActionSlaState.dueToday => Icons.today_outlined,
    EmployeeActionSlaState.dueSoon => Icons.upcoming_outlined,
    EmployeeActionSlaState.onTrack => Icons.check_circle_outline,
    EmployeeActionSlaState.closed => Icons.task_alt_outlined,
  };
}

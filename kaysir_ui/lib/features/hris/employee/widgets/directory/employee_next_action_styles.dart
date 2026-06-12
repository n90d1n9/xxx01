import 'package:flutter/material.dart';

import '../../models/employee_next_action_models.dart';

Color employeeNextActionPriorityColor(EmployeeNextActionPriority priority) {
  return switch (priority) {
    EmployeeNextActionPriority.critical => const Color(0xFFDC2626),
    EmployeeNextActionPriority.high => const Color(0xFFD97706),
    EmployeeNextActionPriority.medium => const Color(0xFF2563EB),
    EmployeeNextActionPriority.low => const Color(0xFF15803D),
  };
}

Color employeeNextActionStatusColor(EmployeeNextActionStatus status) {
  return switch (status) {
    EmployeeNextActionStatus.blocked => const Color(0xFFB91C1C),
    EmployeeNextActionStatus.dueSoon => const Color(0xFFB45309),
    EmployeeNextActionStatus.open => const Color(0xFF2563EB),
    EmployeeNextActionStatus.ready => const Color(0xFF15803D),
  };
}

IconData employeeNextActionAreaIcon(EmployeeNextActionArea area) {
  return switch (area) {
    EmployeeNextActionArea.profile => Icons.manage_accounts_outlined,
    EmployeeNextActionArea.records => Icons.folder_copy_outlined,
    EmployeeNextActionArea.work => Icons.work_history_outlined,
    EmployeeNextActionArea.growth => Icons.insights_outlined,
    EmployeeNextActionArea.pay => Icons.payments_outlined,
    EmployeeNextActionArea.security => Icons.admin_panel_settings_outlined,
  };
}

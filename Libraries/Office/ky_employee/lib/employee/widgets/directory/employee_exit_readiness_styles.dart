import 'package:flutter/material.dart';

import '../../models/employee_exit_readiness_models.dart';

Color employeeExitStatusColor(EmployeeExitClearanceStatus status) {
  return switch (status) {
    EmployeeExitClearanceStatus.blocked => const Color(0xFFB91C1C),
    EmployeeExitClearanceStatus.open => const Color(0xFFB45309),
    EmployeeExitClearanceStatus.inProgress => const Color(0xFF1D4ED8),
    EmployeeExitClearanceStatus.waived => const Color(0xFF6B7280),
    EmployeeExitClearanceStatus.complete => const Color(0xFF15803D),
  };
}

IconData employeeExitStatusIcon(EmployeeExitClearanceStatus status) {
  return switch (status) {
    EmployeeExitClearanceStatus.blocked => Icons.report_problem_outlined,
    EmployeeExitClearanceStatus.open => Icons.radio_button_unchecked_outlined,
    EmployeeExitClearanceStatus.inProgress => Icons.pending_actions_outlined,
    EmployeeExitClearanceStatus.waived => Icons.do_not_disturb_on_outlined,
    EmployeeExitClearanceStatus.complete => Icons.check_circle_outline,
  };
}

Color employeeExitRiskColor(EmployeeExitRisk risk) {
  return switch (risk) {
    EmployeeExitRisk.critical => const Color(0xFF991B1B),
    EmployeeExitRisk.high => const Color(0xFFB45309),
    EmployeeExitRisk.medium => const Color(0xFF1D4ED8),
    EmployeeExitRisk.low => const Color(0xFF15803D),
  };
}

IconData employeeExitCategoryIcon(EmployeeExitClearanceCategory category) {
  return switch (category) {
    EmployeeExitClearanceCategory.knowledgeTransfer => Icons.handshake_outlined,
    EmployeeExitClearanceCategory.access => Icons.admin_panel_settings_outlined,
    EmployeeExitClearanceCategory.assets => Icons.devices_other_outlined,
    EmployeeExitClearanceCategory.payroll => Icons.payments_outlined,
    EmployeeExitClearanceCategory.documents => Icons.description_outlined,
    EmployeeExitClearanceCategory.compliance => Icons.gavel_outlined,
  };
}

import 'package:flutter/material.dart';

import '../../models/employee_manager_change_readiness_models.dart';

Color employeeManagerChangeStatusColor(
  EmployeeManagerChangeChecklistStatus status,
) {
  return switch (status) {
    EmployeeManagerChangeChecklistStatus.ready => const Color(0xFF15803D),
    EmployeeManagerChangeChecklistStatus.actionRequired => const Color(
      0xFFB45309,
    ),
    EmployeeManagerChangeChecklistStatus.blocked => const Color(0xFFB91C1C),
    EmployeeManagerChangeChecklistStatus.waived => const Color(0xFF6B7280),
  };
}

IconData employeeManagerChangeStatusIcon(
  EmployeeManagerChangeChecklistStatus status,
) {
  return switch (status) {
    EmployeeManagerChangeChecklistStatus.ready => Icons.check_circle_outline,
    EmployeeManagerChangeChecklistStatus.actionRequired =>
      Icons.pending_actions_outlined,
    EmployeeManagerChangeChecklistStatus.blocked =>
      Icons.report_problem_outlined,
    EmployeeManagerChangeChecklistStatus.waived =>
      Icons.do_not_disturb_on_outlined,
  };
}

Color employeeManagerChangeRiskColor(EmployeeManagerChangeRisk risk) {
  return switch (risk) {
    EmployeeManagerChangeRisk.high => const Color(0xFFB91C1C),
    EmployeeManagerChangeRisk.medium => const Color(0xFF1D4ED8),
    EmployeeManagerChangeRisk.low => const Color(0xFF15803D),
  };
}

IconData employeeManagerChangeChecklistIcon(
  EmployeeManagerChangeChecklistType type,
) {
  return switch (type) {
    EmployeeManagerChangeChecklistType.outgoingHandoff =>
      Icons.assignment_return_outlined,
    EmployeeManagerChangeChecklistType.incomingAcknowledgement =>
      Icons.how_to_reg_outlined,
    EmployeeManagerChangeChecklistType.directReportImpact =>
      Icons.groups_2_outlined,
    EmployeeManagerChangeChecklistType.approvalCoverage =>
      Icons.verified_user_outlined,
    EmployeeManagerChangeChecklistType.accessOwnership =>
      Icons.admin_panel_settings_outlined,
    EmployeeManagerChangeChecklistType.performanceOwnership =>
      Icons.insights_outlined,
  };
}

IconData employeeManagerChangeTypeIcon(EmployeeManagerChangeType type) {
  return switch (type) {
    EmployeeManagerChangeType.directManager =>
      Icons.supervisor_account_outlined,
    EmployeeManagerChangeType.matrixManager => Icons.account_tree_outlined,
    EmployeeManagerChangeType.interimManager => Icons.manage_accounts_outlined,
    EmployeeManagerChangeType.skipLevelSponsor => Icons.escalator_warning,
  };
}

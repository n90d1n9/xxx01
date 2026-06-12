import 'package:flutter/material.dart';

import '../../models/employee_mobility_readiness_models.dart';

Color employeeMobilityGateStatusColor(EmployeeMobilityGateStatus status) {
  return switch (status) {
    EmployeeMobilityGateStatus.ready => const Color(0xFF15803D),
    EmployeeMobilityGateStatus.actionRequired => const Color(0xFFB45309),
    EmployeeMobilityGateStatus.blocked => const Color(0xFFB91C1C),
    EmployeeMobilityGateStatus.waived => const Color(0xFF6B7280),
  };
}

IconData employeeMobilityGateStatusIcon(EmployeeMobilityGateStatus status) {
  return switch (status) {
    EmployeeMobilityGateStatus.ready => Icons.check_circle_outline,
    EmployeeMobilityGateStatus.actionRequired => Icons.pending_actions_outlined,
    EmployeeMobilityGateStatus.blocked => Icons.report_problem_outlined,
    EmployeeMobilityGateStatus.waived => Icons.do_not_disturb_on_outlined,
  };
}

Color employeeMobilityGateRiskColor(EmployeeMobilityGateRisk risk) {
  return switch (risk) {
    EmployeeMobilityGateRisk.critical => const Color(0xFF991B1B),
    EmployeeMobilityGateRisk.high => const Color(0xFFB45309),
    EmployeeMobilityGateRisk.medium => const Color(0xFF1D4ED8),
    EmployeeMobilityGateRisk.low => const Color(0xFF15803D),
  };
}

IconData employeeMobilityGateTypeIcon(EmployeeMobilityGateType type) {
  return switch (type) {
    EmployeeMobilityGateType.managerAlignment =>
      Icons.supervisor_account_outlined,
    EmployeeMobilityGateType.compensation => Icons.payments_outlined,
    EmployeeMobilityGateType.access => Icons.admin_panel_settings_outlined,
    EmployeeMobilityGateType.handover => Icons.handshake_outlined,
    EmployeeMobilityGateType.location => Icons.location_on_outlined,
    EmployeeMobilityGateType.startDate => Icons.event_available_outlined,
  };
}

IconData employeeMobilityMoveTypeIcon(EmployeeMobilityMoveType type) {
  return switch (type) {
    EmployeeMobilityMoveType.promotion => Icons.trending_up_outlined,
    EmployeeMobilityMoveType.lateralTransfer => Icons.swap_horiz_outlined,
    EmployeeMobilityMoveType.managerChange => Icons.manage_accounts_outlined,
    EmployeeMobilityMoveType.relocation => Icons.map_outlined,
    EmployeeMobilityMoveType.projectAssignment => Icons.assignment_outlined,
  };
}

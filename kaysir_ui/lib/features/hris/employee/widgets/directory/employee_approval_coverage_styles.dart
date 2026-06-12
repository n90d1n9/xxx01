import 'package:flutter/material.dart';

import '../../models/employee_approval_coverage_models.dart';

Color employeeApprovalCoverageStatusColor(
  EmployeeApprovalCoverageStatus status,
) {
  return switch (status) {
    EmployeeApprovalCoverageStatus.active => const Color(0xFF15803D),
    EmployeeApprovalCoverageStatus.pending => const Color(0xFFB45309),
    EmployeeApprovalCoverageStatus.blocked => const Color(0xFFB91C1C),
    EmployeeApprovalCoverageStatus.expired => const Color(0xFF6B7280),
  };
}

IconData employeeApprovalCoverageStatusIcon(
  EmployeeApprovalCoverageStatus status,
) {
  return switch (status) {
    EmployeeApprovalCoverageStatus.active => Icons.verified_user_outlined,
    EmployeeApprovalCoverageStatus.pending => Icons.pending_actions_outlined,
    EmployeeApprovalCoverageStatus.blocked => Icons.report_problem_outlined,
    EmployeeApprovalCoverageStatus.expired => Icons.event_busy_outlined,
  };
}

Color employeeApprovalCoverageRiskColor(EmployeeApprovalCoverageRisk risk) {
  return switch (risk) {
    EmployeeApprovalCoverageRisk.high => const Color(0xFFB91C1C),
    EmployeeApprovalCoverageRisk.medium => const Color(0xFF1D4ED8),
    EmployeeApprovalCoverageRisk.low => const Color(0xFF15803D),
  };
}

IconData employeeApprovalCoverageAreaIcon(EmployeeApprovalCoverageArea area) {
  return switch (area) {
    EmployeeApprovalCoverageArea.timeOff => Icons.event_available_outlined,
    EmployeeApprovalCoverageArea.expense => Icons.receipt_long_outlined,
    EmployeeApprovalCoverageArea.payroll => Icons.payments_outlined,
    EmployeeApprovalCoverageArea.access => Icons.admin_panel_settings_outlined,
    EmployeeApprovalCoverageArea.documents => Icons.description_outlined,
    EmployeeApprovalCoverageArea.performance => Icons.insights_outlined,
  };
}

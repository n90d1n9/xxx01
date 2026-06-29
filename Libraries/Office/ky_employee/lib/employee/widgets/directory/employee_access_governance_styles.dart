import 'package:flutter/material.dart';

import '../../models/employee_access_governance_models.dart';

Color employeeAccessGovernanceStatusColor(
  EmployeeAccessGovernanceStatus status,
) {
  return switch (status) {
    EmployeeAccessGovernanceStatus.dueReview => const Color(0xFF2563EB),
    EmployeeAccessGovernanceStatus.approved => const Color(0xFF15803D),
    EmployeeAccessGovernanceStatus.revokeRequested => const Color(0xFFB45309),
    EmployeeAccessGovernanceStatus.revoked => const Color(0xFF6B7280),
    EmployeeAccessGovernanceStatus.exception => const Color(0xFFB91C1C),
  };
}

Color employeeAccessGovernanceRiskColor(EmployeeAccessGovernanceRisk risk) {
  return switch (risk) {
    EmployeeAccessGovernanceRisk.standard => const Color(0xFF2563EB),
    EmployeeAccessGovernanceRisk.staleAccess => const Color(0xFFB45309),
    EmployeeAccessGovernanceRisk.privilegedAccess => const Color(0xFF7C3AED),
    EmployeeAccessGovernanceRisk.separationOfDuties => const Color(0xFFB91C1C),
    EmployeeAccessGovernanceRisk.externalAccess => const Color(0xFF0891B2),
    EmployeeAccessGovernanceRisk.orphanedAccount => const Color(0xFFB91C1C),
  };
}

IconData employeeAccessGovernanceScopeIcon(
  EmployeeAccessGovernanceScope scope,
) {
  return switch (scope) {
    EmployeeAccessGovernanceScope.productivity => Icons.apps_outlined,
    EmployeeAccessGovernanceScope.engineering => Icons.code_outlined,
    EmployeeAccessGovernanceScope.finance => Icons.account_balance_outlined,
    EmployeeAccessGovernanceScope.hris => Icons.badge_outlined,
    EmployeeAccessGovernanceScope.admin => Icons.admin_panel_settings_outlined,
  };
}

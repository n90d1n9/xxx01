import 'package:flutter/material.dart';

import '../../models/employee_data_correction_governance_models.dart';

Color employeeDataCorrectionGovernanceStatusColor(
  EmployeeDataCorrectionGovernanceStatus status,
) {
  return switch (status) {
    EmployeeDataCorrectionGovernanceStatus.passed => const Color(0xFF15803D),
    EmployeeDataCorrectionGovernanceStatus.warning => const Color(0xFFB45309),
    EmployeeDataCorrectionGovernanceStatus.blocked => const Color(0xFFB91C1C),
    EmployeeDataCorrectionGovernanceStatus.waived => const Color(0xFF6B7280),
  };
}

IconData employeeDataCorrectionGovernanceRuleIcon(
  EmployeeDataCorrectionGovernanceRuleType type,
) {
  return switch (type) {
    EmployeeDataCorrectionGovernanceRuleType.reviewerSeparation =>
      Icons.people_alt_outlined,
    EmployeeDataCorrectionGovernanceRuleType.evidence =>
      Icons.fact_check_outlined,
    EmployeeDataCorrectionGovernanceRuleType.severityGate =>
      Icons.admin_panel_settings_outlined,
    EmployeeDataCorrectionGovernanceRuleType.sla => Icons.timer_outlined,
    EmployeeDataCorrectionGovernanceRuleType.valueChange =>
      Icons.compare_arrows_outlined,
  };
}

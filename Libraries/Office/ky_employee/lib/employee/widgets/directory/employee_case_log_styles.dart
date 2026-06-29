import 'package:flutter/material.dart';

import '../../models/employee_case_log_models.dart';

Color employeeHrCaseStatusColor(EmployeeHrCaseStatus status) {
  return switch (status) {
    EmployeeHrCaseStatus.open => const Color(0xFF2563EB),
    EmployeeHrCaseStatus.inProgress => const Color(0xFFB45309),
    EmployeeHrCaseStatus.pendingEmployee => const Color(0xFF7C3AED),
    EmployeeHrCaseStatus.resolved => const Color(0xFF15803D),
    EmployeeHrCaseStatus.archived => const Color(0xFF6B7280),
  };
}

Color employeeHrCasePriorityColor(EmployeeHrCasePriority priority) {
  return switch (priority) {
    EmployeeHrCasePriority.low => const Color(0xFF6B7280),
    EmployeeHrCasePriority.medium => const Color(0xFF2563EB),
    EmployeeHrCasePriority.high => const Color(0xFFB45309),
    EmployeeHrCasePriority.critical => const Color(0xFFB91C1C),
  };
}

IconData employeeHrCaseTypeIcon(EmployeeHrCaseType type) {
  return switch (type) {
    EmployeeHrCaseType.inquiry => Icons.help_outline,
    EmployeeHrCaseType.employeeRelations => Icons.groups_2_outlined,
    EmployeeHrCaseType.performance => Icons.insights_outlined,
    EmployeeHrCaseType.accommodation => Icons.accessible_forward_outlined,
    EmployeeHrCaseType.payroll => Icons.payments_outlined,
    EmployeeHrCaseType.benefits => Icons.health_and_safety_outlined,
    EmployeeHrCaseType.documents => Icons.description_outlined,
    EmployeeHrCaseType.onboarding => Icons.rocket_launch_outlined,
    EmployeeHrCaseType.grievance => Icons.gavel_outlined,
    EmployeeHrCaseType.policy => Icons.policy_outlined,
  };
}

IconData employeeHrCaseConfidentialityIcon(
  EmployeeHrCaseConfidentiality confidentiality,
) {
  return switch (confidentiality) {
    EmployeeHrCaseConfidentiality.standard => Icons.lock_open_outlined,
    EmployeeHrCaseConfidentiality.sensitive => Icons.lock_outline,
    EmployeeHrCaseConfidentiality.restricted => Icons.enhanced_encryption,
  };
}

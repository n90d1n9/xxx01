import 'package:flutter/material.dart';

import '../../models/employee_profile_completeness_models.dart';

Color employeeProfileCompletenessStatusColor(
  EmployeeProfileCompletenessStatus status,
) {
  return switch (status) {
    EmployeeProfileCompletenessStatus.complete => const Color(0xFF15803D),
    EmployeeProfileCompletenessStatus.inProgress => const Color(0xFF2563EB),
    EmployeeProfileCompletenessStatus.actionRequired => const Color(0xFFB45309),
    EmployeeProfileCompletenessStatus.missing => const Color(0xFFB91C1C),
  };
}

IconData employeeProfileCompletenessAreaIcon(
  EmployeeProfileCompletenessArea area,
) {
  return switch (area) {
    EmployeeProfileCompletenessArea.personalRecords =>
      Icons.contact_page_outlined,
    EmployeeProfileCompletenessArea.documentVault =>
      Icons.folder_special_outlined,
    EmployeeProfileCompletenessArea.workAuthorization =>
      Icons.assignment_ind_outlined,
    EmployeeProfileCompletenessArea.jobAssignment => Icons.work_outline,
    EmployeeProfileCompletenessArea.payroll =>
      Icons.account_balance_wallet_outlined,
    EmployeeProfileCompletenessArea.benefits =>
      Icons.health_and_safety_outlined,
    EmployeeProfileCompletenessArea.reporting => Icons.account_tree_outlined,
    EmployeeProfileCompletenessArea.schedule => Icons.schedule_outlined,
    EmployeeProfileCompletenessArea.assetsAccess =>
      Icons.devices_other_outlined,
    EmployeeProfileCompletenessArea.compliance => Icons.fact_check_outlined,
  };
}

String employeeProfileCompletenessScoreLabel(int score) {
  if (score >= 95) return 'Complete';
  if (score >= 80) return 'Strong';
  if (score >= 65) return 'Needs review';
  return 'Action needed';
}

Color employeeProfileCompletenessScoreColor(int score) {
  if (score >= 95) return const Color(0xFF15803D);
  if (score >= 80) return const Color(0xFF2563EB);
  if (score >= 65) return const Color(0xFFB45309);
  return const Color(0xFFB91C1C);
}

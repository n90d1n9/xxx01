import 'package:flutter/material.dart';

import '../../models/employee_data_quality_models.dart';

Color employeeDataQualitySeverityColor(EmployeeDataQualitySeverity severity) {
  return switch (severity) {
    EmployeeDataQualitySeverity.low => const Color(0xFF6B7280),
    EmployeeDataQualitySeverity.medium => const Color(0xFF2563EB),
    EmployeeDataQualitySeverity.high => const Color(0xFFB45309),
    EmployeeDataQualitySeverity.critical => const Color(0xFFB91C1C),
  };
}

Color employeeDataQualityStatusColor(EmployeeDataQualityStatus status) {
  return switch (status) {
    EmployeeDataQualityStatus.open => const Color(0xFF2563EB),
    EmployeeDataQualityStatus.reviewed => const Color(0xFF7C3AED),
    EmployeeDataQualityStatus.resolved => const Color(0xFF15803D),
    EmployeeDataQualityStatus.waived => const Color(0xFF6B7280),
  };
}

IconData employeeDataQualityTypeIcon(EmployeeDataQualityIssueType type) {
  return switch (type) {
    EmployeeDataQualityIssueType.missingData => Icons.report_outlined,
    EmployeeDataQualityIssueType.staleData => Icons.update_disabled_outlined,
    EmployeeDataQualityIssueType.inconsistentData =>
      Icons.sync_problem_outlined,
    EmployeeDataQualityIssueType.duplicateRisk => Icons.content_copy_outlined,
    EmployeeDataQualityIssueType.governance => Icons.verified_user_outlined,
    EmployeeDataQualityIssueType.manual => Icons.fact_check_outlined,
  };
}

String employeeDataQualityScoreLabel(int score) {
  if (score >= 90) return 'Clean';
  if (score >= 75) return 'Watch';
  if (score >= 55) return 'Needs cleanup';
  return 'At risk';
}

Color employeeDataQualityScoreColor(int score) {
  if (score >= 90) return const Color(0xFF15803D);
  if (score >= 75) return const Color(0xFF2563EB);
  if (score >= 55) return const Color(0xFFB45309);
  return const Color(0xFFB91C1C);
}

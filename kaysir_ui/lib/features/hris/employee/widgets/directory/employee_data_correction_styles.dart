import 'package:flutter/material.dart';

import '../../models/employee_data_correction_models.dart';
import '../../models/employee_data_quality_models.dart';
import 'employee_data_quality_styles.dart';

Color employeeDataCorrectionStatusColor(EmployeeDataCorrectionStatus status) {
  return switch (status) {
    EmployeeDataCorrectionStatus.submitted => const Color(0xFF2563EB),
    EmployeeDataCorrectionStatus.inReview => const Color(0xFF7C3AED),
    EmployeeDataCorrectionStatus.approved => const Color(0xFFB45309),
    EmployeeDataCorrectionStatus.applied => const Color(0xFF15803D),
    EmployeeDataCorrectionStatus.rejected => const Color(0xFFB91C1C),
    EmployeeDataCorrectionStatus.cancelled => const Color(0xFF6B7280),
  };
}

Color employeeDataCorrectionSeverityColor(
  EmployeeDataQualitySeverity severity,
) {
  return employeeDataQualitySeverityColor(severity);
}

IconData employeeDataCorrectionStatusIcon(EmployeeDataCorrectionStatus status) {
  return switch (status) {
    EmployeeDataCorrectionStatus.submitted => Icons.outbox_outlined,
    EmployeeDataCorrectionStatus.inReview => Icons.rate_review_outlined,
    EmployeeDataCorrectionStatus.approved => Icons.verified_outlined,
    EmployeeDataCorrectionStatus.applied => Icons.task_alt_outlined,
    EmployeeDataCorrectionStatus.rejected => Icons.cancel_outlined,
    EmployeeDataCorrectionStatus.cancelled => Icons.do_not_disturb_on_outlined,
  };
}

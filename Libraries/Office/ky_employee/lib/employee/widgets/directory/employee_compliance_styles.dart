import 'package:flutter/material.dart';

import '../../models/employee_compliance_models.dart';

Color employeeComplianceDocumentStatusColor(
  EmployeeComplianceDocumentStatus status,
) {
  return switch (status) {
    EmployeeComplianceDocumentStatus.pending => const Color(0xFF2563EB),
    EmployeeComplianceDocumentStatus.verified => const Color(0xFF15803D),
    EmployeeComplianceDocumentStatus.rejected => const Color(0xFFB91C1C),
    EmployeeComplianceDocumentStatus.expired => const Color(0xFFB91C1C),
    EmployeeComplianceDocumentStatus.waived => const Color(0xFF6B7280),
  };
}

IconData employeeComplianceDocumentTypeIcon(
  EmployeeComplianceDocumentType type,
) {
  return switch (type) {
    EmployeeComplianceDocumentType.identity => Icons.badge_outlined,
    EmployeeComplianceDocumentType.agreement => Icons.description_outlined,
    EmployeeComplianceDocumentType.tax => Icons.receipt_long_outlined,
    EmployeeComplianceDocumentType.policy => Icons.rule_folder_outlined,
    EmployeeComplianceDocumentType.workPermit => Icons.public_outlined,
    EmployeeComplianceDocumentType.performance => Icons.insights_outlined,
    EmployeeComplianceDocumentType.certification =>
      Icons.workspace_premium_outlined,
  };
}

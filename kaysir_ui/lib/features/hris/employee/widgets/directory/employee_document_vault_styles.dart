import 'package:flutter/material.dart';

import '../../models/employee_document_vault_models.dart';

Color employeeDocumentVaultStatusColor(EmployeeDocumentVaultStatus status) {
  return switch (status) {
    EmployeeDocumentVaultStatus.verified => const Color(0xFF15803D),
    EmployeeDocumentVaultStatus.pendingReview => const Color(0xFF2563EB),
    EmployeeDocumentVaultStatus.needsUpload => const Color(0xFFB45309),
    EmployeeDocumentVaultStatus.expiringSoon => const Color(0xFFB45309),
    EmployeeDocumentVaultStatus.expired => const Color(0xFFB91C1C),
    EmployeeDocumentVaultStatus.rejected => const Color(0xFFB91C1C),
    EmployeeDocumentVaultStatus.archived => const Color(0xFF64748B),
  };
}

Color employeeDocumentVaultAccessColor(EmployeeDocumentVaultAccess access) {
  return switch (access) {
    EmployeeDocumentVaultAccess.employeeVisible => const Color(0xFF15803D),
    EmployeeDocumentVaultAccess.hrOnly => const Color(0xFF2563EB),
    EmployeeDocumentVaultAccess.restricted => const Color(0xFF7C3AED),
  };
}

IconData employeeDocumentVaultCategoryIcon(
  EmployeeDocumentVaultCategory category,
) {
  return switch (category) {
    EmployeeDocumentVaultCategory.identity => Icons.badge_outlined,
    EmployeeDocumentVaultCategory.contract => Icons.assignment_outlined,
    EmployeeDocumentVaultCategory.payrollTax => Icons.receipt_long_outlined,
    EmployeeDocumentVaultCategory.compliance => Icons.fact_check_outlined,
    EmployeeDocumentVaultCategory.workAuthorization =>
      Icons.assignment_ind_outlined,
    EmployeeDocumentVaultCategory.benefits => Icons.health_and_safety_outlined,
    EmployeeDocumentVaultCategory.training => Icons.school_outlined,
    EmployeeDocumentVaultCategory.custom => Icons.folder_copy_outlined,
  };
}

IconData employeeDocumentVaultStatusIcon(EmployeeDocumentVaultStatus status) {
  return switch (status) {
    EmployeeDocumentVaultStatus.verified => Icons.verified_outlined,
    EmployeeDocumentVaultStatus.pendingReview => Icons.rate_review_outlined,
    EmployeeDocumentVaultStatus.needsUpload => Icons.upload_file_outlined,
    EmployeeDocumentVaultStatus.expiringSoon => Icons.event_busy_outlined,
    EmployeeDocumentVaultStatus.expired => Icons.report_problem_outlined,
    EmployeeDocumentVaultStatus.rejected => Icons.cancel_outlined,
    EmployeeDocumentVaultStatus.archived => Icons.archive_outlined,
  };
}

IconData employeeDocumentVaultAccessIcon(EmployeeDocumentVaultAccess access) {
  return switch (access) {
    EmployeeDocumentVaultAccess.employeeVisible => Icons.visibility_outlined,
    EmployeeDocumentVaultAccess.hrOnly => Icons.lock_outline,
    EmployeeDocumentVaultAccess.restricted =>
      Icons.admin_panel_settings_outlined,
  };
}

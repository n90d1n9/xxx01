import 'package:flutter/material.dart';

import '../../models/employee_audit_trail_models.dart';

Color employeeAuditTrailSeverityColor(EmployeeAuditTrailSeverity severity) {
  return switch (severity) {
    EmployeeAuditTrailSeverity.info => const Color(0xFF64748B),
    EmployeeAuditTrailSeverity.notice => const Color(0xFF2563EB),
    EmployeeAuditTrailSeverity.warning => const Color(0xFFB45309),
    EmployeeAuditTrailSeverity.critical => const Color(0xFFB91C1C),
  };
}

Color employeeAuditTrailReviewStatusColor(
  EmployeeAuditTrailReviewStatus status,
) {
  return switch (status) {
    EmployeeAuditTrailReviewStatus.logged => const Color(0xFF64748B),
    EmployeeAuditTrailReviewStatus.reviewRequired => const Color(0xFFB45309),
    EmployeeAuditTrailReviewStatus.reviewed => const Color(0xFF15803D),
    EmployeeAuditTrailReviewStatus.escalated => const Color(0xFFB91C1C),
    EmployeeAuditTrailReviewStatus.archived => const Color(0xFF64748B),
  };
}

IconData employeeAuditTrailSourceIcon(EmployeeAuditTrailSource source) {
  return switch (source) {
    EmployeeAuditTrailSource.profile => Icons.manage_accounts_outlined,
    EmployeeAuditTrailSource.records => Icons.folder_copy_outlined,
    EmployeeAuditTrailSource.work => Icons.work_history_outlined,
    EmployeeAuditTrailSource.growth => Icons.insights_outlined,
    EmployeeAuditTrailSource.pay => Icons.payments_outlined,
    EmployeeAuditTrailSource.security => Icons.admin_panel_settings_outlined,
    EmployeeAuditTrailSource.system => Icons.memory_outlined,
  };
}

IconData employeeAuditTrailActionIcon(EmployeeAuditTrailActionType actionType) {
  return switch (actionType) {
    EmployeeAuditTrailActionType.created => Icons.add_circle_outline,
    EmployeeAuditTrailActionType.updated => Icons.edit_outlined,
    EmployeeAuditTrailActionType.verified => Icons.verified_outlined,
    EmployeeAuditTrailActionType.approved => Icons.check_circle_outline,
    EmployeeAuditTrailActionType.rejected => Icons.cancel_outlined,
    EmployeeAuditTrailActionType.escalated => Icons.priority_high_outlined,
    EmployeeAuditTrailActionType.archived => Icons.archive_outlined,
    EmployeeAuditTrailActionType.note => Icons.notes_outlined,
  };
}

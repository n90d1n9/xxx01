import 'package:flutter/material.dart';

import '../../models/employee_management_models.dart';

Color employeeManagementHealthColor(EmployeeManagementHealth health) {
  return switch (health) {
    EmployeeManagementHealth.healthy => const Color(0xFF15803D),
    EmployeeManagementHealth.review => const Color(0xFFB45309),
    EmployeeManagementHealth.actionRequired => const Color(0xFFB91C1C),
  };
}

Color employeeLifecycleEventColor(EmployeeLifecycleEventType type) {
  return switch (type) {
    EmployeeLifecycleEventType.hire => const Color(0xFF2563EB),
    EmployeeLifecycleEventType.roleChange => const Color(0xFF0F766E),
    EmployeeLifecycleEventType.performance => const Color(0xFF7C3AED),
    EmployeeLifecycleEventType.compliance => const Color(0xFFB45309),
    EmployeeLifecycleEventType.onboarding => const Color(0xFF0891B2),
  };
}

Color employeeRecordStatusColor(EmployeeRecordItemStatus status) {
  return switch (status) {
    EmployeeRecordItemStatus.complete => const Color(0xFF15803D),
    EmployeeRecordItemStatus.pending => const Color(0xFFB45309),
    EmployeeRecordItemStatus.overdue => const Color(0xFFB91C1C),
    EmployeeRecordItemStatus.missing => const Color(0xFFB91C1C),
    EmployeeRecordItemStatus.active => const Color(0xFF2563EB),
    EmployeeRecordItemStatus.provisioning => const Color(0xFF7C3AED),
  };
}

IconData employeeRecordStatusIcon(EmployeeRecordItemStatus status) {
  return switch (status) {
    EmployeeRecordItemStatus.complete => Icons.verified_outlined,
    EmployeeRecordItemStatus.pending => Icons.schedule_outlined,
    EmployeeRecordItemStatus.overdue => Icons.error_outline,
    EmployeeRecordItemStatus.missing => Icons.report_outlined,
    EmployeeRecordItemStatus.active => Icons.check_circle_outline,
    EmployeeRecordItemStatus.provisioning => Icons.pending_actions_outlined,
  };
}

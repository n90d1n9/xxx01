import 'package:flutter/material.dart';

import '../../models/employee_job_history_models.dart';

Color employeeJobHistoryStatusColor(EmployeeJobHistoryStatus status) {
  return switch (status) {
    EmployeeJobHistoryStatus.effective => const Color(0xFF15803D),
    EmployeeJobHistoryStatus.scheduled => const Color(0xFF1D4ED8),
    EmployeeJobHistoryStatus.pendingEvidence => const Color(0xFFB45309),
    EmployeeJobHistoryStatus.reversed => const Color(0xFF6B7280),
  };
}

IconData employeeJobHistoryStatusIcon(EmployeeJobHistoryStatus status) {
  return switch (status) {
    EmployeeJobHistoryStatus.effective => Icons.check_circle_outline,
    EmployeeJobHistoryStatus.scheduled => Icons.event_available_outlined,
    EmployeeJobHistoryStatus.pendingEvidence => Icons.fact_check_outlined,
    EmployeeJobHistoryStatus.reversed => Icons.undo_outlined,
  };
}

IconData employeeJobHistoryTypeIcon(EmployeeJobHistoryEventType type) {
  return switch (type) {
    EmployeeJobHistoryEventType.hire => Icons.person_add_alt_outlined,
    EmployeeJobHistoryEventType.promotion => Icons.trending_up_outlined,
    EmployeeJobHistoryEventType.transfer => Icons.compare_arrows_outlined,
    EmployeeJobHistoryEventType.managerChange => Icons.manage_accounts_outlined,
    EmployeeJobHistoryEventType.departmentChange => Icons.apartment_outlined,
    EmployeeJobHistoryEventType.contractChange => Icons.description_outlined,
    EmployeeJobHistoryEventType.compensationChange => Icons.payments_outlined,
    EmployeeJobHistoryEventType.locationChange => Icons.place_outlined,
  };
}

IconData employeeJobHistorySourceIcon(EmployeeJobHistorySource source) {
  return switch (source) {
    EmployeeJobHistorySource.employeeRecordAction => Icons.edit_note_outlined,
    EmployeeJobHistorySource.jobAssignment => Icons.badge_outlined,
    EmployeeJobHistorySource.managerChange => Icons.supervisor_account_outlined,
    EmployeeJobHistorySource.contractLifecycle => Icons.assignment_outlined,
    EmployeeJobHistorySource.payroll => Icons.account_balance_wallet_outlined,
    EmployeeJobHistorySource.manualCorrection => Icons.build_circle_outlined,
  };
}

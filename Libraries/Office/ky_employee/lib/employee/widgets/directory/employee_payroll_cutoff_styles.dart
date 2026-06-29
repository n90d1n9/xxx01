import 'package:flutter/material.dart';

import '../../models/employee_payroll_cutoff_models.dart';

Color employeePayrollCutoffSeverityColor(
  EmployeePayrollCutoffItemSeverity severity,
) {
  return switch (severity) {
    EmployeePayrollCutoffItemSeverity.blocker => const Color(0xFFB91C1C),
    EmployeePayrollCutoffItemSeverity.high => const Color(0xFFC2410C),
    EmployeePayrollCutoffItemSeverity.medium => const Color(0xFFB45309),
    EmployeePayrollCutoffItemSeverity.low => const Color(0xFF64748B),
  };
}

Color employeePayrollCutoffStatusColor(EmployeePayrollCutoffItemStatus status) {
  return switch (status) {
    EmployeePayrollCutoffItemStatus.open => const Color(0xFFB45309),
    EmployeePayrollCutoffItemStatus.inReview => const Color(0xFF2563EB),
    EmployeePayrollCutoffItemStatus.resolved => const Color(0xFF15803D),
    EmployeePayrollCutoffItemStatus.waived => const Color(0xFF6B7280),
  };
}

Color employeePayrollCutoffStageColor(EmployeePayrollCutoffStage stage) {
  return switch (stage) {
    EmployeePayrollCutoffStage.collectingInputs => const Color(0xFF64748B),
    EmployeePayrollCutoffStage.resolvingExceptions => const Color(0xFFB91C1C),
    EmployeePayrollCutoffStage.managerReview => const Color(0xFFB45309),
    EmployeePayrollCutoffStage.readyForPayroll => const Color(0xFF2563EB),
    EmployeePayrollCutoffStage.signedOff => const Color(0xFF15803D),
  };
}

IconData employeePayrollCutoffSourceIcon(
  EmployeePayrollCutoffItemSource source,
) {
  return switch (source) {
    EmployeePayrollCutoffItemSource.payrollProfile =>
      Icons.account_balance_wallet_outlined,
    EmployeePayrollCutoffItemSource.timekeeping => Icons.timer_outlined,
    EmployeePayrollCutoffItemSource.leave => Icons.event_busy_outlined,
    EmployeePayrollCutoffItemSource.schedule => Icons.event_available_outlined,
  };
}

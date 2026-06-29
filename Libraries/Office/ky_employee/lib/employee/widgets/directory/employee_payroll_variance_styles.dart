import 'package:flutter/material.dart';

import '../../models/employee_payroll_variance_models.dart';

Color employeePayrollVarianceSeverityColor(
  EmployeePayrollVarianceSeverity severity,
) {
  return switch (severity) {
    EmployeePayrollVarianceSeverity.blocker => const Color(0xFFB91C1C),
    EmployeePayrollVarianceSeverity.high => const Color(0xFFC2410C),
    EmployeePayrollVarianceSeverity.medium => const Color(0xFFB45309),
    EmployeePayrollVarianceSeverity.low => const Color(0xFF64748B),
  };
}

Color employeePayrollVarianceStatusColor(EmployeePayrollVarianceStatus status) {
  return switch (status) {
    EmployeePayrollVarianceStatus.open => const Color(0xFFB45309),
    EmployeePayrollVarianceStatus.reviewed => const Color(0xFF2563EB),
    EmployeePayrollVarianceStatus.approved => const Color(0xFF15803D),
    EmployeePayrollVarianceStatus.excluded => const Color(0xFF6B7280),
  };
}

IconData employeePayrollVarianceSourceIcon(
  EmployeePayrollVarianceSource source,
) {
  return switch (source) {
    EmployeePayrollVarianceSource.overtime => Icons.more_time_outlined,
    EmployeePayrollVarianceSource.reimbursement => Icons.receipt_long_outlined,
    EmployeePayrollVarianceSource.compensationChange =>
      Icons.trending_up_outlined,
    EmployeePayrollVarianceSource.leave => Icons.event_busy_outlined,
    EmployeePayrollVarianceSource.payrollProfile =>
      Icons.account_balance_wallet_outlined,
    EmployeePayrollVarianceSource.payrollCutoff => Icons.fact_check_outlined,
    EmployeePayrollVarianceSource.manualAdjustment => Icons.tune_outlined,
  };
}

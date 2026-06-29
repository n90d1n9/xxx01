import 'package:flutter/material.dart';

import '../../models/employee_payroll_run_models.dart';

Color employeePayrollRunStatusColor(EmployeePayrollRunStatus status) {
  return switch (status) {
    EmployeePayrollRunStatus.blocked => const Color(0xFFB91C1C),
    EmployeePayrollRunStatus.draft => const Color(0xFFB45309),
    EmployeePayrollRunStatus.ready => const Color(0xFF2563EB),
    EmployeePayrollRunStatus.exported => const Color(0xFF15803D),
  };
}

Color employeePayrollRunLineStatusColor(EmployeePayrollRunLineStatus status) {
  return switch (status) {
    EmployeePayrollRunLineStatus.included => const Color(0xFF15803D),
    EmployeePayrollRunLineStatus.pending => const Color(0xFFB45309),
    EmployeePayrollRunLineStatus.excluded => const Color(0xFF6B7280),
    EmployeePayrollRunLineStatus.hold => const Color(0xFFB91C1C),
  };
}

IconData employeePayrollRunLineTypeIcon(EmployeePayrollRunLineType type) {
  return switch (type) {
    EmployeePayrollRunLineType.basePay => Icons.payments_outlined,
    EmployeePayrollRunLineType.earning => Icons.trending_up_outlined,
    EmployeePayrollRunLineType.reimbursement => Icons.receipt_long_outlined,
    EmployeePayrollRunLineType.deduction => Icons.remove_circle_outline,
    EmployeePayrollRunLineType.tax => Icons.account_balance_outlined,
    EmployeePayrollRunLineType.employerCost => Icons.business_center_outlined,
    EmployeePayrollRunLineType.hold => Icons.block_outlined,
  };
}

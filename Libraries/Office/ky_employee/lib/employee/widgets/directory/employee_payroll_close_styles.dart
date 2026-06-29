import 'package:flutter/material.dart';

import '../../models/employee_payroll_close_models.dart';

Color employeePayrollCloseStatusColor(EmployeePayrollCloseStatus status) {
  return switch (status) {
    EmployeePayrollCloseStatus.blocked => const Color(0xFFB91C1C),
    EmployeePayrollCloseStatus.ready => const Color(0xFF2563EB),
    EmployeePayrollCloseStatus.posted => const Color(0xFF7C3AED),
    EmployeePayrollCloseStatus.closed => const Color(0xFF15803D),
  };
}

Color employeePayrollJournalLineStatusColor(
  EmployeePayrollJournalLineStatus status,
) {
  return switch (status) {
    EmployeePayrollJournalLineStatus.blocked => const Color(0xFFB91C1C),
    EmployeePayrollJournalLineStatus.draft => const Color(0xFF2563EB),
    EmployeePayrollJournalLineStatus.posted => const Color(0xFF15803D),
  };
}

IconData employeePayrollJournalLineTypeIcon(
  EmployeePayrollJournalLineType type,
) {
  return switch (type) {
    EmployeePayrollJournalLineType.compensationExpense =>
      Icons.groups_2_outlined,
    EmployeePayrollJournalLineType.reimbursementExpense =>
      Icons.receipt_long_outlined,
    EmployeePayrollJournalLineType.taxPayable => Icons.request_quote_outlined,
    EmployeePayrollJournalLineType.employerContributionExpense =>
      Icons.health_and_safety_outlined,
    EmployeePayrollJournalLineType.employerContributionPayable =>
      Icons.account_balance_outlined,
    EmployeePayrollJournalLineType.cashClearing =>
      Icons.account_balance_wallet_outlined,
  };
}

import 'package:flutter/material.dart';

import '../../models/employee_reimbursement_models.dart';

Color employeeExpenseClaimStatusColor(EmployeeExpenseClaimStatus status) {
  return switch (status) {
    EmployeeExpenseClaimStatus.submitted => const Color(0xFF2563EB),
    EmployeeExpenseClaimStatus.approved => const Color(0xFFB45309),
    EmployeeExpenseClaimStatus.reimbursed => const Color(0xFF15803D),
    EmployeeExpenseClaimStatus.rejected => const Color(0xFFB91C1C),
  };
}

Color employeeExpenseReceiptStatusColor(EmployeeExpenseReceiptStatus status) {
  return switch (status) {
    EmployeeExpenseReceiptStatus.attached => const Color(0xFF15803D),
    EmployeeExpenseReceiptStatus.missing => const Color(0xFFB45309),
    EmployeeExpenseReceiptStatus.flagged => const Color(0xFFB91C1C),
  };
}

IconData employeeExpenseCategoryIcon(EmployeeExpenseCategory category) {
  return switch (category) {
    EmployeeExpenseCategory.travel => Icons.flight_takeoff_outlined,
    EmployeeExpenseCategory.meal => Icons.restaurant_outlined,
    EmployeeExpenseCategory.learning => Icons.school_outlined,
    EmployeeExpenseCategory.equipment => Icons.devices_outlined,
    EmployeeExpenseCategory.wellness => Icons.spa_outlined,
    EmployeeExpenseCategory.other => Icons.receipt_long_outlined,
  };
}

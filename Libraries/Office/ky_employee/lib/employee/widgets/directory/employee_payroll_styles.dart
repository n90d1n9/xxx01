import 'package:flutter/material.dart';

import '../../models/employee_payroll_models.dart';

Color employeeBankVerificationStatusColor(
  EmployeeBankVerificationStatus status,
) {
  return switch (status) {
    EmployeeBankVerificationStatus.verified => const Color(0xFF15803D),
    EmployeeBankVerificationStatus.pending => const Color(0xFFB45309),
    EmployeeBankVerificationStatus.failed => const Color(0xFFB91C1C),
    EmployeeBankVerificationStatus.missing => const Color(0xFFB91C1C),
  };
}

Color employeeTaxFormStatusColor(EmployeeTaxFormStatus status) {
  return switch (status) {
    EmployeeTaxFormStatus.current => const Color(0xFF15803D),
    EmployeeTaxFormStatus.expiring => const Color(0xFFB45309),
    EmployeeTaxFormStatus.missing => const Color(0xFFB91C1C),
    EmployeeTaxFormStatus.rejected => const Color(0xFFB91C1C),
  };
}

Color employeePayrollChangeStatusColor(EmployeePayrollChangeStatus status) {
  return switch (status) {
    EmployeePayrollChangeStatus.submitted => const Color(0xFF2563EB),
    EmployeePayrollChangeStatus.approved => const Color(0xFFB45309),
    EmployeePayrollChangeStatus.applied => const Color(0xFF15803D),
    EmployeePayrollChangeStatus.rejected => const Color(0xFFB91C1C),
  };
}

IconData employeePayrollChangeTypeIcon(EmployeePayrollChangeType type) {
  return switch (type) {
    EmployeePayrollChangeType.bankAccount => Icons.account_balance_outlined,
    EmployeePayrollChangeType.taxWithholding => Icons.receipt_long_outlined,
    EmployeePayrollChangeType.paySchedule => Icons.event_available_outlined,
    EmployeePayrollChangeType.paymentMethod => Icons.payments_outlined,
  };
}

IconData employeePaymentMethodIcon(EmployeePaymentMethod method) {
  return switch (method) {
    EmployeePaymentMethod.directDeposit =>
      Icons.account_balance_wallet_outlined,
    EmployeePaymentMethod.bankTransfer => Icons.sync_alt_outlined,
    EmployeePaymentMethod.manual => Icons.edit_note_outlined,
  };
}

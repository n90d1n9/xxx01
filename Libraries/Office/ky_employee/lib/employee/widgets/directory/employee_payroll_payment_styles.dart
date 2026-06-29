import 'package:flutter/material.dart';

import '../../models/employee_payroll_payment_models.dart';

Color employeePayrollPaymentStatusColor(EmployeePayrollPaymentStatus status) {
  return switch (status) {
    EmployeePayrollPaymentStatus.blocked => const Color(0xFFB91C1C),
    EmployeePayrollPaymentStatus.ready => const Color(0xFF2563EB),
    EmployeePayrollPaymentStatus.scheduled => const Color(0xFF7C3AED),
    EmployeePayrollPaymentStatus.paid => const Color(0xFF15803D),
    EmployeePayrollPaymentStatus.held => const Color(0xFFB45309),
  };
}

Color employeePayrollPaymentInstructionStatusColor(
  EmployeePayrollPaymentInstructionStatus status,
) {
  return switch (status) {
    EmployeePayrollPaymentInstructionStatus.blocked => const Color(0xFFB91C1C),
    EmployeePayrollPaymentInstructionStatus.ready => const Color(0xFF2563EB),
    EmployeePayrollPaymentInstructionStatus.scheduled => const Color(
      0xFF7C3AED,
    ),
    EmployeePayrollPaymentInstructionStatus.paid => const Color(0xFF15803D),
    EmployeePayrollPaymentInstructionStatus.held => const Color(0xFFB45309),
  };
}

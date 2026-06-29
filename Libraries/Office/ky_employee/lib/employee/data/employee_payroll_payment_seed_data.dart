import '../models/employee_payroll_models.dart';
import '../models/employee_payroll_payment_models.dart';
import '../models/employee_payroll_run_models.dart';

EmployeePayrollPaymentProfile buildEmployeePayrollPaymentProfile({
  required EmployeePayrollRunProfile payrollRun,
  required EmployeePayrollProfile payroll,
}) {
  final status = _statusFor(payrollRun: payrollRun, payroll: payroll);

  return EmployeePayrollPaymentProfile(
    employeeId: payrollRun.employeeId,
    employeeName: payrollRun.employeeName,
    asOfDate: payrollRun.asOfDate,
    payDate: payrollRun.payDate,
    currencyCode: payrollRun.currencyCode,
    status: status,
    runStatus: payrollRun.status,
    paymentMethod: payroll.schedule.paymentMethod,
    bankVerificationStatus: payroll.bankAccount.verificationStatus,
    exportBatchId: payrollRun.exportBatchId,
    netPay: payrollRun.netPay,
    bankName: payroll.bankAccount.bankName,
    maskedAccount: payroll.bankAccount.maskedAccount,
    routingCode: payroll.bankAccount.routingCode,
    instructions: buildEmployeePayrollPaymentInstructions(
      payrollRun: payrollRun,
      payroll: payroll,
      status: status,
    ),
    paymentOwner: '',
    paymentNote: '',
    paymentReference: '',
    scheduledFor: null,
    paidAt: null,
  );
}

EmployeePayrollPaymentDraft buildEmployeePayrollPaymentDraft({
  required EmployeePayrollRunProfile payrollRun,
}) {
  return EmployeePayrollPaymentDraft(
    employeeId: payrollRun.employeeId,
    employeeName: payrollRun.employeeName,
    asOfDate: payrollRun.asOfDate,
    owner:
        payrollRun.reviewer.trim().isEmpty
            ? 'Payroll Operations'
            : payrollRun.reviewer,
    note: '',
    reference: _defaultPaymentReference(payrollRun),
    scheduledFor: payrollRun.payDate,
  );
}

List<EmployeePayrollPaymentInstruction>
buildEmployeePayrollPaymentInstructions({
  required EmployeePayrollRunProfile payrollRun,
  required EmployeePayrollProfile payroll,
  required EmployeePayrollPaymentStatus status,
}) {
  return [
    EmployeePayrollPaymentInstruction(
      id: 'payment-net-pay',
      method: payroll.schedule.paymentMethod,
      status: _instructionStatusFor(status),
      title: 'Net pay disbursement',
      detail: _detailFor(
        status: status,
        method: payroll.schedule.paymentMethod,
        bankName: payroll.bankAccount.bankName,
        maskedAccount: payroll.bankAccount.maskedAccount,
      ),
      amount: payrollRun.netPay,
      currencyCode: payrollRun.currencyCode,
      bankName: payroll.bankAccount.bankName,
      maskedAccount: payroll.bankAccount.maskedAccount,
      routingCode: payroll.bankAccount.routingCode,
      sortOrder: 10,
    ),
  ];
}

EmployeePayrollPaymentStatus _statusFor({
  required EmployeePayrollRunProfile payrollRun,
  required EmployeePayrollProfile payroll,
}) {
  if (payrollRun.status != EmployeePayrollRunStatus.exported) {
    return EmployeePayrollPaymentStatus.blocked;
  }
  if (payrollRun.netPay <= 0) {
    return EmployeePayrollPaymentStatus.blocked;
  }
  if (payroll.schedule.paymentMethod != EmployeePaymentMethod.manual &&
      payroll.bankAccount.verificationStatus !=
          EmployeeBankVerificationStatus.verified) {
    return EmployeePayrollPaymentStatus.blocked;
  }
  return EmployeePayrollPaymentStatus.ready;
}

EmployeePayrollPaymentInstructionStatus _instructionStatusFor(
  EmployeePayrollPaymentStatus status,
) {
  return switch (status) {
    EmployeePayrollPaymentStatus.blocked =>
      EmployeePayrollPaymentInstructionStatus.blocked,
    EmployeePayrollPaymentStatus.ready =>
      EmployeePayrollPaymentInstructionStatus.ready,
    EmployeePayrollPaymentStatus.scheduled =>
      EmployeePayrollPaymentInstructionStatus.scheduled,
    EmployeePayrollPaymentStatus.paid =>
      EmployeePayrollPaymentInstructionStatus.paid,
    EmployeePayrollPaymentStatus.held =>
      EmployeePayrollPaymentInstructionStatus.held,
  };
}

String _detailFor({
  required EmployeePayrollPaymentStatus status,
  required EmployeePaymentMethod method,
  required String bankName,
  required String maskedAccount,
}) {
  return switch (status) {
    EmployeePayrollPaymentStatus.blocked =>
      'Payment instruction is blocked until payroll export and account checks clear.',
    EmployeePayrollPaymentStatus.ready =>
      '${method.label} to $bankName $maskedAccount is ready to schedule.',
    EmployeePayrollPaymentStatus.scheduled =>
      '${method.label} to $bankName $maskedAccount has been scheduled.',
    EmployeePayrollPaymentStatus.paid =>
      '${method.label} to $bankName $maskedAccount has settled.',
    EmployeePayrollPaymentStatus.held =>
      '${method.label} is on hold for payroll operations review.',
  };
}

String _defaultPaymentReference(EmployeePayrollRunProfile payrollRun) {
  final payDate = payrollRun.payDate;
  return 'PAYMENT-${payDate.year}${payDate.month.toString().padLeft(2, '0')}';
}

import '../models/employee_payslip_delivery_models.dart';
import '../models/employee_payroll_close_models.dart';
import '../models/employee_payroll_payment_models.dart';
import '../models/employee_payroll_run_models.dart';

EmployeePayrollCloseProfile buildEmployeePayrollCloseProfile({
  required EmployeePayrollRunProfile payrollRun,
  required EmployeePayrollPaymentProfile payment,
  required EmployeePayslipDeliveryProfile payslipDelivery,
}) {
  final status = _statusFor(
    payrollRun: payrollRun,
    payment: payment,
    payslipDelivery: payslipDelivery,
  );

  return EmployeePayrollCloseProfile(
    employeeId: payrollRun.employeeId,
    employeeName: payrollRun.employeeName,
    asOfDate: payrollRun.asOfDate,
    periodStart: payrollRun.periodStart,
    periodEnd: payrollRun.periodEnd,
    payDate: payrollRun.payDate,
    currencyCode: payrollRun.currencyCode,
    status: status,
    runStatus: payrollRun.status,
    paymentStatus: payment.status,
    payslipStatus: payslipDelivery.status,
    exportBatchId: payrollRun.exportBatchId,
    paymentReference: payment.paymentReference,
    journalBatchId: '',
    closeOwner: '',
    closeNote: '',
    journalLines: buildEmployeePayrollJournalLines(
      payrollRun: payrollRun,
      status: _journalLineStatusFor(status),
    ),
    postedAt: null,
    closedAt: null,
  );
}

EmployeePayrollCloseDraft buildEmployeePayrollCloseDraft({
  required EmployeePayrollRunProfile payrollRun,
}) {
  return EmployeePayrollCloseDraft(
    employeeId: payrollRun.employeeId,
    employeeName: payrollRun.employeeName,
    asOfDate: payrollRun.asOfDate,
    owner:
        payrollRun.reviewer.trim().isEmpty
            ? 'Payroll Accounting'
            : payrollRun.reviewer,
    journalBatchId: _defaultJournalBatchId(payrollRun),
    note: '',
  );
}

List<EmployeePayrollJournalLine> buildEmployeePayrollJournalLines({
  required EmployeePayrollRunProfile payrollRun,
  required EmployeePayrollJournalLineStatus status,
}) {
  final lines = <EmployeePayrollJournalLine>[
    EmployeePayrollJournalLine(
      id: 'journal-compensation-expense',
      type: EmployeePayrollJournalLineType.compensationExpense,
      status: status,
      accountCode: '6100',
      accountName: 'Payroll compensation expense',
      detail: 'Gross earnings for ${payrollRun.employeeName}.',
      debitAmount: payrollRun.grossEarnings,
      creditAmount: 0,
      currencyCode: payrollRun.currencyCode,
      sortOrder: 10,
    ),
  ];

  if (payrollRun.reimbursements > 0) {
    lines.add(
      EmployeePayrollJournalLine(
        id: 'journal-reimbursement-expense',
        type: EmployeePayrollJournalLineType.reimbursementExpense,
        status: status,
        accountCode: '6120',
        accountName: 'Employee reimbursement expense',
        detail: 'Approved reimbursable payroll items.',
        debitAmount: payrollRun.reimbursements,
        creditAmount: 0,
        currencyCode: payrollRun.currencyCode,
        sortOrder: 20,
      ),
    );
  }

  if (payrollRun.employerCost > 0) {
    lines.add(
      EmployeePayrollJournalLine(
        id: 'journal-employer-contribution-expense',
        type: EmployeePayrollJournalLineType.employerContributionExpense,
        status: status,
        accountCode: '6130',
        accountName: 'Employer contribution expense',
        detail: 'Employer-side contribution estimate for payroll close.',
        debitAmount: payrollRun.employerCost,
        creditAmount: 0,
        currencyCode: payrollRun.currencyCode,
        sortOrder: 30,
      ),
    );
  }

  if (payrollRun.deductions > 0) {
    lines.add(
      EmployeePayrollJournalLine(
        id: 'journal-tax-deductions-payable',
        type: EmployeePayrollJournalLineType.taxPayable,
        status: status,
        accountCode: '2200',
        accountName: 'Payroll tax and deductions payable',
        detail: 'Employee withholding and deduction liabilities.',
        debitAmount: 0,
        creditAmount: payrollRun.deductions,
        currencyCode: payrollRun.currencyCode,
        sortOrder: 70,
      ),
    );
  }

  if (payrollRun.employerCost > 0) {
    lines.add(
      EmployeePayrollJournalLine(
        id: 'journal-employer-contribution-payable',
        type: EmployeePayrollJournalLineType.employerContributionPayable,
        status: status,
        accountCode: '2210',
        accountName: 'Employer contribution payable',
        detail: 'Employer contribution liability for payroll close.',
        debitAmount: 0,
        creditAmount: payrollRun.employerCost,
        currencyCode: payrollRun.currencyCode,
        sortOrder: 80,
      ),
    );
  }

  lines.add(
    EmployeePayrollJournalLine(
      id: 'journal-cash-clearing',
      type: EmployeePayrollJournalLineType.cashClearing,
      status: status,
      accountCode: '1015',
      accountName: 'Payroll cash clearing',
      detail: 'Net pay disbursement clearing entry.',
      debitAmount: 0,
      creditAmount: payrollRun.netPay,
      currencyCode: payrollRun.currencyCode,
      sortOrder: 90,
    ),
  );

  return lines;
}

EmployeePayrollCloseStatus _statusFor({
  required EmployeePayrollRunProfile payrollRun,
  required EmployeePayrollPaymentProfile payment,
  required EmployeePayslipDeliveryProfile payslipDelivery,
}) {
  if (payrollRun.status != EmployeePayrollRunStatus.exported) {
    return EmployeePayrollCloseStatus.blocked;
  }
  if (payment.status != EmployeePayrollPaymentStatus.paid) {
    return EmployeePayrollCloseStatus.blocked;
  }
  if (payslipDelivery.status != EmployeePayslipDeliveryStatus.published) {
    return EmployeePayrollCloseStatus.blocked;
  }
  return EmployeePayrollCloseStatus.ready;
}

EmployeePayrollJournalLineStatus _journalLineStatusFor(
  EmployeePayrollCloseStatus status,
) {
  return switch (status) {
    EmployeePayrollCloseStatus.blocked =>
      EmployeePayrollJournalLineStatus.blocked,
    EmployeePayrollCloseStatus.ready => EmployeePayrollJournalLineStatus.draft,
    EmployeePayrollCloseStatus.posted || EmployeePayrollCloseStatus.closed =>
      EmployeePayrollJournalLineStatus.posted,
  };
}

String _defaultJournalBatchId(EmployeePayrollRunProfile payrollRun) {
  final payDate = payrollRun.payDate;
  return 'JRN-${payDate.year}${payDate.month.toString().padLeft(2, '0')}';
}

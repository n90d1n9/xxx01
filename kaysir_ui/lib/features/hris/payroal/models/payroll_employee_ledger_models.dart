import '../../employee/models/employee.dart';
import 'payroll_attendance_bridge_models.dart';
import 'payroll_deduction_authorization_models.dart';
import 'payroll_detail.dart';
import 'payroll_input_change_models.dart';
import 'payroll_loan_repayment_models.dart';
import 'payroll_off_cycle_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_payslip_models.dart';
import 'payroll_period_models.dart';

enum PayrollEmployeeLedgerEntryType {
  regularPayroll('Regular payroll'),
  inputChange('Input change'),
  attendance('Attendance'),
  loanRepayment('Loan repayment'),
  deductionAuthorization('Deduction authorization'),
  offCycle('Off-cycle'),
  payment('Payment'),
  payslip('Payslip');

  final String label;

  const PayrollEmployeeLedgerEntryType(this.label);
}

enum PayrollEmployeeLedgerStatus {
  pending('Pending'),
  blocked('Blocked'),
  approved('Approved'),
  applied('Applied'),
  released('Released'),
  published('Published');

  final String label;

  const PayrollEmployeeLedgerStatus(this.label);
}

class PayrollEmployeeLedgerEntry {
  final String id;
  final PayrollEmployeeLedgerEntryType type;
  final PayrollEmployeeLedgerStatus status;
  final DateTime eventDate;
  final String title;
  final String detail;
  final String sourceLabel;
  final double amount;

  const PayrollEmployeeLedgerEntry({
    required this.id,
    required this.type,
    required this.status,
    required this.eventDate,
    required this.title,
    required this.detail,
    required this.sourceLabel,
    required this.amount,
  });

  bool get isDebit => amount < 0;

  bool get needsAttention =>
      status == PayrollEmployeeLedgerStatus.blocked ||
      status == PayrollEmployeeLedgerStatus.pending;
}

class PayrollEmployeeLedgerSummary {
  final Employee? employee;
  final String periodLabel;
  final List<PayrollEmployeeLedgerEntry> entries;

  const PayrollEmployeeLedgerSummary({
    required this.employee,
    required this.periodLabel,
    required this.entries,
  });

  factory PayrollEmployeeLedgerSummary.fromRun({
    required Employee? employee,
    required PayrollRunPeriod period,
    required PayrollDetails? details,
    required bool isPaid,
    required PayrollInputChangeSummary inputChanges,
    required PayrollAttendanceBridgeSummary attendanceBridge,
    required PayrollLoanRepaymentSummary loanRepayments,
    required PayrollDeductionAuthorizationSummary deductionAuthorizations,
    required PayrollOffCycleRunSummary offCycleRuns,
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollPayslipPackageSummary payslipPackage,
  }) {
    if (employee == null) {
      return PayrollEmployeeLedgerSummary(
        employee: null,
        periodLabel: period.label,
        entries: const [],
      );
    }

    final entries = <PayrollEmployeeLedgerEntry>[
      PayrollEmployeeLedgerEntry(
        id: 'regular-${employee.id}',
        type: PayrollEmployeeLedgerEntryType.regularPayroll,
        status:
            isPaid
                ? PayrollEmployeeLedgerStatus.released
                : PayrollEmployeeLedgerStatus.pending,
        eventDate: period.payDate,
        title: 'Regular payroll',
        detail: isPaid ? 'Net pay released' : 'Awaiting payment release',
        sourceLabel: period.label,
        amount: details?.netSalary ?? 0,
      ),
      ...inputChanges.lines
          .where((line) => line.request.employeeId == employee.id)
          .map((line) {
            return PayrollEmployeeLedgerEntry(
              id: line.id,
              type: PayrollEmployeeLedgerEntryType.inputChange,
              status: _inputStatus(line.status),
              eventDate: line.request.effectiveDate,
              title: line.request.type.label,
              detail: line.nextAction,
              sourceLabel: line.request.sourceLabel,
              amount: line.payrollImpact,
            );
          }),
      ...attendanceBridge.lines
          .where((line) => line.signal.employeeId == employee.id)
          .map((line) {
            return PayrollEmployeeLedgerEntry(
              id: line.id,
              type: PayrollEmployeeLedgerEntryType.attendance,
              status: _attendanceStatus(line.status),
              eventDate: line.signal.workDate,
              title: line.signal.type.label,
              detail: line.nextAction,
              sourceLabel: line.signal.sourceLabel,
              amount: line.amount,
            );
          }),
      ...loanRepayments.lines
          .where((line) => line.account.employeeId == employee.id)
          .map((line) {
            return PayrollEmployeeLedgerEntry(
              id: line.id,
              type: PayrollEmployeeLedgerEntryType.loanRepayment,
              status: _loanStatus(line.status),
              eventDate: period.payDate,
              title: line.account.type.label,
              detail: line.nextAction,
              sourceLabel: 'Loan repayment',
              amount: -line.repaymentAmount,
            );
          }),
      ...deductionAuthorizations.lines
          .where((line) => line.employeeId == employee.id)
          .map((line) {
            return PayrollEmployeeLedgerEntry(
              id: line.id,
              type: PayrollEmployeeLedgerEntryType.deductionAuthorization,
              status: _deductionStatus(line.status),
              eventDate: period.asOfDate,
              title: line.label,
              detail: line.nextAction,
              sourceLabel: line.type.label,
              amount: -line.amount,
            );
          }),
      ...offCycleRuns.requests
          .where((request) => request.employeeId == employee.id)
          .map((request) {
            return PayrollEmployeeLedgerEntry(
              id: request.id,
              type: PayrollEmployeeLedgerEntryType.offCycle,
              status: _offCycleStatus(request.status),
              eventDate: request.payDate,
              title: request.type.label,
              detail: request.reason,
              sourceLabel: request.evidenceReference,
              amount: request.netAmount,
            );
          }),
      ...paymentBatch.lines.where((line) => line.employeeId == employee.id).map(
        (line) {
          return PayrollEmployeeLedgerEntry(
            id: line.referenceCode,
            type: PayrollEmployeeLedgerEntryType.payment,
            status:
                line.isPaid
                    ? PayrollEmployeeLedgerStatus.released
                    : line.hasBlockers
                    ? PayrollEmployeeLedgerStatus.blocked
                    : PayrollEmployeeLedgerStatus.pending,
            eventDate: paymentBatch.payDate,
            title: 'Payment release',
            detail: line.statusLabel,
            sourceLabel: line.fundingSource,
            amount: line.netAmount,
          );
        },
      ),
      ...payslipPackage.lines
          .where((line) => line.employeeId == employee.id)
          .map((line) {
            return PayrollEmployeeLedgerEntry(
              id: line.statementId,
              type: PayrollEmployeeLedgerEntryType.payslip,
              status:
                  line.isPublished
                      ? PayrollEmployeeLedgerStatus.published
                      : line.hasBlockers
                      ? PayrollEmployeeLedgerStatus.blocked
                      : PayrollEmployeeLedgerStatus.pending,
              eventDate: payslipPackage.payDate,
              title: 'Payslip statement',
              detail: line.statusLabel,
              sourceLabel: line.channel.label,
              amount: line.netAmount,
            );
          }),
    ]..sort((left, right) {
      final dateOrder = right.eventDate.compareTo(left.eventDate);
      if (dateOrder != 0) return dateOrder;
      return left.title.compareTo(right.title);
    });

    return PayrollEmployeeLedgerSummary(
      employee: employee,
      periodLabel: period.label,
      entries: entries,
    );
  }

  int get attentionCount =>
      entries.where((entry) => entry.needsAttention).length;

  double get grossMovement {
    return entries.fold(0, (total, entry) => total + entry.amount);
  }

  double get credits {
    return entries
        .where((entry) => entry.amount > 0)
        .fold(0, (total, entry) => total + entry.amount);
  }

  double get debits {
    return entries
        .where((entry) => entry.amount < 0)
        .fold(0, (total, entry) => total + entry.amount.abs());
  }

  String get nextAction {
    if (employee == null) return 'Select an employee to review payroll ledger.';
    if (attentionCount > 0) {
      return 'Review $attentionCount ledger items needing payroll attention.';
    }
    return '${employee!.name} payroll ledger is clear for this period.';
  }
}

PayrollEmployeeLedgerStatus _inputStatus(PayrollInputChangeStatus status) {
  return switch (status) {
    PayrollInputChangeStatus.blocked => PayrollEmployeeLedgerStatus.blocked,
    PayrollInputChangeStatus.pending => PayrollEmployeeLedgerStatus.pending,
    PayrollInputChangeStatus.approved => PayrollEmployeeLedgerStatus.approved,
    PayrollInputChangeStatus.applied => PayrollEmployeeLedgerStatus.applied,
  };
}

PayrollEmployeeLedgerStatus _attendanceStatus(
  PayrollAttendanceBridgeStatus status,
) {
  return switch (status) {
    PayrollAttendanceBridgeStatus.blocked =>
      PayrollEmployeeLedgerStatus.blocked,
    PayrollAttendanceBridgeStatus.pending =>
      PayrollEmployeeLedgerStatus.pending,
    PayrollAttendanceBridgeStatus.approved =>
      PayrollEmployeeLedgerStatus.approved,
    PayrollAttendanceBridgeStatus.applied =>
      PayrollEmployeeLedgerStatus.applied,
  };
}

PayrollEmployeeLedgerStatus _loanStatus(PayrollLoanRepaymentStatus status) {
  return switch (status) {
    PayrollLoanRepaymentStatus.blocked => PayrollEmployeeLedgerStatus.blocked,
    PayrollLoanRepaymentStatus.ready => PayrollEmployeeLedgerStatus.pending,
    PayrollLoanRepaymentStatus.applied => PayrollEmployeeLedgerStatus.applied,
    PayrollLoanRepaymentStatus.paused => PayrollEmployeeLedgerStatus.pending,
  };
}

PayrollEmployeeLedgerStatus _deductionStatus(
  PayrollDeductionAuthorizationStatus status,
) {
  return switch (status) {
    PayrollDeductionAuthorizationStatus.blocked =>
      PayrollEmployeeLedgerStatus.blocked,
    PayrollDeductionAuthorizationStatus.pending =>
      PayrollEmployeeLedgerStatus.pending,
    PayrollDeductionAuthorizationStatus.approved =>
      PayrollEmployeeLedgerStatus.approved,
  };
}

PayrollEmployeeLedgerStatus _offCycleStatus(PayrollOffCycleRunStatus status) {
  return switch (status) {
    PayrollOffCycleRunStatus.submitted => PayrollEmployeeLedgerStatus.pending,
    PayrollOffCycleRunStatus.approved => PayrollEmployeeLedgerStatus.approved,
    PayrollOffCycleRunStatus.rejected => PayrollEmployeeLedgerStatus.blocked,
    PayrollOffCycleRunStatus.released => PayrollEmployeeLedgerStatus.released,
  };
}

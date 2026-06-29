import '../../employee/models/employee.dart';

enum PayrollLoanType {
  salaryAdvance('Salary advance'),
  employeeLoan('Employee loan'),
  emergencyAdvance('Emergency advance');

  final String label;

  const PayrollLoanType(this.label);
}

enum PayrollLoanRepaymentStatus {
  blocked('Blocked'),
  ready('Ready'),
  applied('Applied'),
  paused('Paused');

  final String label;

  const PayrollLoanRepaymentStatus(this.label);
}

class PayrollLoanAccount {
  final String id;
  final int employeeId;
  final PayrollLoanType type;
  final double principalAmount;
  final double outstandingBalance;
  final double scheduledInstallment;
  final double deductionCapRatio;
  final int remainingInstallments;
  final bool isPaused;
  final bool hasSignedAgreement;
  final bool hasFinanceApproval;

  const PayrollLoanAccount({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.principalAmount,
    required this.outstandingBalance,
    required this.scheduledInstallment,
    required this.deductionCapRatio,
    required this.remainingInstallments,
    required this.isPaused,
    required this.hasSignedAgreement,
    required this.hasFinanceApproval,
  });
}

class PayrollLoanRepaymentLine {
  final PayrollLoanAccount account;
  final Employee? employee;
  final bool isApplied;

  const PayrollLoanRepaymentLine({
    required this.account,
    required this.employee,
    required this.isApplied,
  });

  String get id => account.id;

  String get employeeName => employee?.name ?? 'Unknown employee';

  String get position => employee?.position ?? 'Employee';

  double get salary => employee?.salary ?? 0;

  double get capAmount => salary * account.deductionCapRatio;

  double get repaymentAmount {
    final baseAmount =
        account.scheduledInstallment > account.outstandingBalance
            ? account.outstandingBalance
            : account.scheduledInstallment;
    return baseAmount > capAmount && capAmount > 0 ? capAmount : baseAmount;
  }

  double get projectedBalance {
    final balance = account.outstandingBalance - repaymentAmount;
    return balance < 0 ? 0 : balance;
  }

  List<String> get blockers {
    return [
      if (employee == null) 'Employee is unavailable',
      if (salary <= 0) 'Missing employee salary',
      if (account.outstandingBalance <= 0) 'Loan balance is already settled',
      if (account.scheduledInstallment <= 0) 'Missing repayment installment',
      if (account.deductionCapRatio <= 0) 'Missing deduction cap',
      if (!account.hasSignedAgreement) 'Missing signed agreement',
      if (!account.hasFinanceApproval) 'Missing finance approval',
    ];
  }

  bool get hasBlockers => blockers.isNotEmpty;

  bool get isCapped =>
      account.scheduledInstallment > capAmount && capAmount > 0;

  PayrollLoanRepaymentStatus get status {
    if (account.isPaused) return PayrollLoanRepaymentStatus.paused;
    if (hasBlockers) return PayrollLoanRepaymentStatus.blocked;
    if (isApplied) return PayrollLoanRepaymentStatus.applied;
    return PayrollLoanRepaymentStatus.ready;
  }

  bool get canApply => status == PayrollLoanRepaymentStatus.ready;

  String get nextAction {
    if (account.isPaused) return 'Repayment is paused for this payroll run.';
    if (hasBlockers) return blockers.first;
    if (isApplied) return 'Repayment deduction is applied to payroll.';
    if (isCapped) return 'Apply capped repayment deduction.';
    return 'Apply scheduled repayment deduction.';
  }
}

class PayrollLoanRepaymentSummary {
  final List<PayrollLoanRepaymentLine> lines;
  final int? selectedEmployeeId;

  const PayrollLoanRepaymentSummary({
    required this.lines,
    required this.selectedEmployeeId,
  });

  factory PayrollLoanRepaymentSummary.fromAccounts({
    required List<PayrollLoanAccount> accounts,
    required List<Employee> employees,
    required Set<String> appliedLoanIds,
    required int? selectedEmployeeId,
  }) {
    return PayrollLoanRepaymentSummary(
      selectedEmployeeId: selectedEmployeeId,
      lines:
          accounts
              .map(
                (account) => PayrollLoanRepaymentLine(
                  account: account,
                  employee: _findEmployee(employees, account.employeeId),
                  isApplied: appliedLoanIds.contains(account.id),
                ),
              )
              .toList(),
    );
  }

  List<PayrollLoanRepaymentLine> get visibleLines {
    if (selectedEmployeeId == null) return lines;
    return lines
        .where((line) => line.account.employeeId == selectedEmployeeId)
        .toList();
  }

  int get blockedCount => _count(PayrollLoanRepaymentStatus.blocked);

  int get readyCount => _count(PayrollLoanRepaymentStatus.ready);

  int get appliedCount => _count(PayrollLoanRepaymentStatus.applied);

  int get pausedCount => _count(PayrollLoanRepaymentStatus.paused);

  double get outstandingBalance =>
      lines.fold(0, (total, line) => total + line.account.outstandingBalance);

  double get scheduledRepayment =>
      lines.fold(0, (total, line) => total + line.repaymentAmount);

  double get appliedRepayment => lines
      .where((line) => line.status == PayrollLoanRepaymentStatus.applied)
      .fold(0, (total, line) => total + line.repaymentAmount);

  double get readinessRate {
    if (lines.isEmpty) return 0;
    return (readyCount + appliedCount) / lines.length;
  }

  bool get canApply => lines.any((line) => line.canApply);

  PayrollLoanRepaymentStatus get status {
    if (blockedCount > 0) return PayrollLoanRepaymentStatus.blocked;
    if (readyCount > 0) return PayrollLoanRepaymentStatus.ready;
    if (appliedCount > 0) return PayrollLoanRepaymentStatus.applied;
    return PayrollLoanRepaymentStatus.paused;
  }

  String get nextAction {
    if (blockedCount > 0) {
      return 'Resolve $blockedCount loan repayment blockers.';
    }
    if (readyCount > 0) {
      return 'Apply $readyCount loan repayments to payroll.';
    }
    if (appliedCount > 0) {
      return 'Loan repayments are applied for this payroll run.';
    }
    return 'All loan repayments are paused for this payroll run.';
  }

  int _count(PayrollLoanRepaymentStatus target) {
    return lines.where((line) => line.status == target).length;
  }

  static Employee? _findEmployee(List<Employee> employees, int employeeId) {
    for (final employee in employees) {
      if (employee.id == employeeId) return employee;
    }
    return null;
  }
}

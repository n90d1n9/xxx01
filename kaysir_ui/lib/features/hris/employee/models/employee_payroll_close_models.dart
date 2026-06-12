import 'employee_payslip_delivery_models.dart';
import 'employee_payroll_payment_models.dart';
import 'employee_payroll_run_models.dart';

enum EmployeePayrollCloseStatus {
  blocked('Blocked'),
  ready('Ready'),
  posted('Posted'),
  closed('Closed');

  final String label;

  const EmployeePayrollCloseStatus(this.label);
}

enum EmployeePayrollJournalLineType {
  compensationExpense('Compensation expense'),
  reimbursementExpense('Reimbursement expense'),
  taxPayable('Tax and deduction payable'),
  employerContributionExpense('Employer contribution expense'),
  employerContributionPayable('Employer contribution payable'),
  cashClearing('Cash clearing');

  final String label;

  const EmployeePayrollJournalLineType(this.label);
}

enum EmployeePayrollJournalLineStatus {
  blocked('Blocked'),
  draft('Draft'),
  posted('Posted');

  final String label;

  const EmployeePayrollJournalLineStatus(this.label);
}

class EmployeePayrollJournalLine {
  final String id;
  final EmployeePayrollJournalLineType type;
  final EmployeePayrollJournalLineStatus status;
  final String accountCode;
  final String accountName;
  final String detail;
  final double debitAmount;
  final double creditAmount;
  final String currencyCode;
  final int sortOrder;

  const EmployeePayrollJournalLine({
    required this.id,
    required this.type,
    required this.status,
    required this.accountCode,
    required this.accountName,
    required this.detail,
    required this.debitAmount,
    required this.creditAmount,
    required this.currencyCode,
    required this.sortOrder,
  });

  bool get isDebit => debitAmount > 0;

  double get amount => isDebit ? debitAmount : creditAmount;

  EmployeePayrollJournalLine copyWith({
    EmployeePayrollJournalLineStatus? status,
  }) {
    return EmployeePayrollJournalLine(
      id: id,
      type: type,
      status: status ?? this.status,
      accountCode: accountCode,
      accountName: accountName,
      detail: detail,
      debitAmount: debitAmount,
      creditAmount: creditAmount,
      currencyCode: currencyCode,
      sortOrder: sortOrder,
    );
  }
}

class EmployeePayrollCloseProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime payDate;
  final String currencyCode;
  final EmployeePayrollCloseStatus status;
  final EmployeePayrollRunStatus runStatus;
  final EmployeePayrollPaymentStatus paymentStatus;
  final EmployeePayslipDeliveryStatus payslipStatus;
  final String exportBatchId;
  final String paymentReference;
  final String journalBatchId;
  final String closeOwner;
  final String closeNote;
  final List<EmployeePayrollJournalLine> journalLines;
  final DateTime? postedAt;
  final DateTime? closedAt;

  const EmployeePayrollCloseProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.periodStart,
    required this.periodEnd,
    required this.payDate,
    required this.currencyCode,
    required this.status,
    required this.runStatus,
    required this.paymentStatus,
    required this.payslipStatus,
    required this.exportBatchId,
    required this.paymentReference,
    required this.journalBatchId,
    required this.closeOwner,
    required this.closeNote,
    required this.journalLines,
    required this.postedAt,
    required this.closedAt,
  });

  EmployeePayrollCloseProfile copyWith({
    EmployeePayrollCloseStatus? status,
    String? journalBatchId,
    String? closeOwner,
    String? closeNote,
    List<EmployeePayrollJournalLine>? journalLines,
    DateTime? postedAt,
    DateTime? closedAt,
  }) {
    return EmployeePayrollCloseProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      periodStart: periodStart,
      periodEnd: periodEnd,
      payDate: payDate,
      currencyCode: currencyCode,
      status: status ?? this.status,
      runStatus: runStatus,
      paymentStatus: paymentStatus,
      payslipStatus: payslipStatus,
      exportBatchId: exportBatchId,
      paymentReference: paymentReference,
      journalBatchId: journalBatchId ?? this.journalBatchId,
      closeOwner: closeOwner ?? this.closeOwner,
      closeNote: closeNote ?? this.closeNote,
      journalLines: journalLines ?? this.journalLines,
      postedAt: postedAt ?? this.postedAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  List<EmployeePayrollJournalLine> get sortedJournalLines {
    final sorted = [...journalLines];
    sorted.sort((a, b) {
      final sortCompare = a.sortOrder.compareTo(b.sortOrder);
      if (sortCompare != 0) return sortCompare;
      return a.accountCode.compareTo(b.accountCode);
    });
    return sorted;
  }

  double get totalDebits {
    return journalLines.fold<double>(
      0,
      (total, line) => total + line.debitAmount,
    );
  }

  double get totalCredits {
    return journalLines.fold<double>(
      0,
      (total, line) => total + line.creditAmount,
    );
  }

  double get variance => (totalDebits - totalCredits).abs();

  bool get isBalanced => variance < 0.01;

  int get blockingCount {
    if (status != EmployeePayrollCloseStatus.blocked) return 0;

    var count = 0;
    if (runStatus != EmployeePayrollRunStatus.exported) count++;
    if (paymentStatus != EmployeePayrollPaymentStatus.paid) count++;
    if (payslipStatus != EmployeePayslipDeliveryStatus.published) count++;
    if (!isBalanced) count++;
    return count == 0 ? 1 : count;
  }

  bool get canPost => status == EmployeePayrollCloseStatus.ready && isBalanced;

  bool get canClose => status == EmployeePayrollCloseStatus.posted;

  int get attentionCount {
    if (status == EmployeePayrollCloseStatus.closed) return 0;
    if (status == EmployeePayrollCloseStatus.blocked) return blockingCount;
    return 1;
  }

  String get nextAction {
    if (status == EmployeePayrollCloseStatus.closed) {
      return 'Payroll period closed with $journalBatchId.';
    }
    if (runStatus != EmployeePayrollRunStatus.exported) {
      return 'Export payroll run before period close.';
    }
    if (paymentStatus != EmployeePayrollPaymentStatus.paid) {
      return 'Settle payroll payment before period close.';
    }
    if (payslipStatus != EmployeePayslipDeliveryStatus.published) {
      return 'Publish payslip before period close.';
    }
    if (!isBalanced) {
      return 'Balance payroll journal before posting.';
    }
    if (status == EmployeePayrollCloseStatus.posted) {
      return 'Close payroll period after accounting handoff.';
    }
    return 'Post payroll accounting journal.';
  }
}

class EmployeePayrollCloseDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String owner;
  final String journalBatchId;
  final String note;

  const EmployeePayrollCloseDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.owner,
    required this.journalBatchId,
    required this.note,
  });

  EmployeePayrollCloseDraft copyWith({
    String? owner,
    String? journalBatchId,
    String? note,
  }) {
    return EmployeePayrollCloseDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      owner: owner ?? this.owner,
      journalBatchId: journalBatchId ?? this.journalBatchId,
      note: note ?? this.note,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (owner.trim().length < 3) {
      errors.add('Close owner is required');
    }
    if (journalBatchId.trim().length < 6) {
      errors.add('Journal batch must be at least 6 characters');
    }
    if (note.trim().length < 12) {
      errors.add('Close note must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToPost => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          owner.trim().length >= 3,
          journalBatchId.trim().length >= 6,
          note.trim().length >= 12,
        ].where((item) => item).length;
    return completed / 3;
  }
}

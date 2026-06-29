import 'employee_payroll_run_launch_context_models.dart';

/// Payroll run lifecycle state for an employee preview.
enum EmployeePayrollRunStatus {
  blocked('Blocked'),
  draft('Draft'),
  ready('Ready'),
  exported('Exported');

  final String label;

  const EmployeePayrollRunStatus(this.label);
}

/// Category for a payroll run line item.
enum EmployeePayrollRunLineType {
  basePay('Base pay'),
  earning('Earning'),
  reimbursement('Reimbursement'),
  deduction('Deduction'),
  tax('Tax'),
  employerCost('Employer cost'),
  hold('Hold');

  final String label;

  const EmployeePayrollRunLineType(this.label);
}

/// Processing state for an individual payroll run line.
enum EmployeePayrollRunLineStatus {
  included('Included'),
  pending('Pending'),
  excluded('Excluded'),
  hold('Hold');

  final String label;

  const EmployeePayrollRunLineStatus(this.label);
}

/// Immutable payroll run line shown in employee run previews.
class EmployeePayrollRunLine {
  final String id;
  final EmployeePayrollRunLineType type;
  final EmployeePayrollRunLineStatus status;
  final String title;
  final String detail;
  final double amount;
  final String currencyCode;
  final bool taxable;
  final bool countsInNetPay;
  final int sortOrder;

  const EmployeePayrollRunLine({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.detail,
    required this.amount,
    required this.currencyCode,
    required this.taxable,
    required this.countsInNetPay,
    required this.sortOrder,
  });

  bool get isIncludedInPreview {
    return status == EmployeePayrollRunLineStatus.included ||
        status == EmployeePayrollRunLineStatus.pending;
  }

  bool get isHold => status == EmployeePayrollRunLineStatus.hold;

  bool get isCashLine => amount != 0;

  bool get isDeduction => amount < 0;
}

/// Aggregates employee payroll run totals, gates, and export metadata.
class EmployeePayrollRunProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime payDate;
  final DateTime cutoffDate;
  final String currencyCode;
  final EmployeePayrollRunStatus status;
  final List<EmployeePayrollRunLine> lines;
  final int payrollSetupIssueCount;
  final int cutoffBlockerCount;
  final int varianceApprovalCount;
  final String reviewer;
  final String reviewNote;
  final bool payslipVisible;
  final String exportBatchId;
  final DateTime? exportedAt;
  final EmployeePayrollRunLaunchContext? launchContext;

  const EmployeePayrollRunProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.periodStart,
    required this.periodEnd,
    required this.payDate,
    required this.cutoffDate,
    required this.currencyCode,
    required this.status,
    required this.lines,
    required this.payrollSetupIssueCount,
    required this.cutoffBlockerCount,
    required this.varianceApprovalCount,
    required this.reviewer,
    required this.reviewNote,
    required this.payslipVisible,
    required this.exportBatchId,
    required this.exportedAt,
    required this.launchContext,
  });

  EmployeePayrollRunProfile copyWith({
    EmployeePayrollRunStatus? status,
    String? reviewer,
    String? reviewNote,
    bool? payslipVisible,
    String? exportBatchId,
    DateTime? exportedAt,
    EmployeePayrollRunLaunchContext? launchContext,
  }) {
    return EmployeePayrollRunProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      periodStart: periodStart,
      periodEnd: periodEnd,
      payDate: payDate,
      cutoffDate: cutoffDate,
      currencyCode: currencyCode,
      status: status ?? this.status,
      lines: lines,
      payrollSetupIssueCount: payrollSetupIssueCount,
      cutoffBlockerCount: cutoffBlockerCount,
      varianceApprovalCount: varianceApprovalCount,
      reviewer: reviewer ?? this.reviewer,
      reviewNote: reviewNote ?? this.reviewNote,
      payslipVisible: payslipVisible ?? this.payslipVisible,
      exportBatchId: exportBatchId ?? this.exportBatchId,
      exportedAt: exportedAt ?? this.exportedAt,
      launchContext: launchContext ?? this.launchContext,
    );
  }

  List<EmployeePayrollRunLine> get sortedLines {
    final sorted = [...lines];
    sorted.sort((a, b) {
      final sortCompare = a.sortOrder.compareTo(b.sortOrder);
      if (sortCompare != 0) return sortCompare;
      return a.title.compareTo(b.title);
    });
    return sorted;
  }

  double get taxableGross {
    return lines
        .where((line) => line.taxable && line.isIncludedInPreview)
        .fold<double>(0, (total, line) => total + line.amount);
  }

  double get grossEarnings {
    return lines
        .where(
          (line) =>
              line.isIncludedInPreview &&
              line.countsInNetPay &&
              line.amount > 0 &&
              line.type != EmployeePayrollRunLineType.reimbursement,
        )
        .fold<double>(0, (total, line) => total + line.amount);
  }

  double get reimbursements {
    return lines
        .where(
          (line) =>
              line.isIncludedInPreview &&
              line.type == EmployeePayrollRunLineType.reimbursement,
        )
        .fold<double>(0, (total, line) => total + line.amount);
  }

  double get deductions {
    return lines
        .where(
          (line) =>
              line.isIncludedInPreview &&
              line.countsInNetPay &&
              line.amount < 0,
        )
        .fold<double>(0, (total, line) => total + line.amount.abs());
  }

  double get employerCost {
    return lines
        .where(
          (line) =>
              line.isIncludedInPreview &&
              line.type == EmployeePayrollRunLineType.employerCost,
        )
        .fold<double>(0, (total, line) => total + line.amount);
  }

  double get netPay {
    return lines
        .where(
          (line) =>
              line.isIncludedInPreview &&
              line.countsInNetPay &&
              line.type != EmployeePayrollRunLineType.hold,
        )
        .fold<double>(0, (total, line) => total + line.amount);
  }

  int get pendingLineCount {
    return lines
        .where((line) => line.status == EmployeePayrollRunLineStatus.pending)
        .length;
  }

  int get holdLineCount {
    return lines.where((line) => line.isHold).length;
  }

  int get blockerCount {
    return (payrollSetupIssueCount > 0 ? 1 : 0) +
        cutoffBlockerCount +
        varianceApprovalCount;
  }

  bool get canReview =>
      blockerCount == 0 && status == EmployeePayrollRunStatus.draft;

  bool get canExport => status == EmployeePayrollRunStatus.ready;

  bool get hasLaunchContext => launchContext != null;

  int get attentionCount {
    if (status == EmployeePayrollRunStatus.exported) return 0;
    if (blockerCount > 0) return blockerCount;
    return 1;
  }

  String get nextAction {
    if (status == EmployeePayrollRunStatus.exported) {
      return 'Payroll run exported in $exportBatchId.';
    }
    if (blockerCount > 0) {
      return 'Clear $blockerCount payroll run blocker${blockerCount == 1 ? '' : 's'}.';
    }
    if (status == EmployeePayrollRunStatus.ready) {
      return 'Export payroll run for $employeeName.';
    }
    return 'Review payroll run preview.';
  }
}

/// Operator input for marking an employee payroll run ready for export.
class EmployeePayrollRunReviewDraft {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final String reviewer;
  final String note;
  final bool payslipVisible;

  const EmployeePayrollRunReviewDraft({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.reviewer,
    required this.note,
    required this.payslipVisible,
  });

  EmployeePayrollRunReviewDraft copyWith({
    String? reviewer,
    String? note,
    bool? payslipVisible,
  }) {
    return EmployeePayrollRunReviewDraft(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      reviewer: reviewer ?? this.reviewer,
      note: note ?? this.note,
      payslipVisible: payslipVisible ?? this.payslipVisible,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (reviewer.trim().length < 3) {
      errors.add('Reviewer is required');
    }
    if (note.trim().length < 12) {
      errors.add('Review note must be at least 12 characters');
    }
    return errors;
  }

  bool get isReadyToReview => validationErrors.isEmpty;

  double get completionRatio {
    final completed =
        [
          reviewer.trim().length >= 3,
          note.trim().length >= 12,
        ].where((item) => item).length;
    return completed / 2;
  }
}

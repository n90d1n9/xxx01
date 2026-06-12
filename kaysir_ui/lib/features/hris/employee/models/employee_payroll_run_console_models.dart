import 'employee_directory_models.dart';
import 'employee_directory_roster_payroll_run_kickoff_models.dart';
import 'employee_payslip_delivery_models.dart';
import 'employee_payroll_close_models.dart';
import 'employee_payroll_payment_models.dart';
import 'employee_payroll_run_models.dart';

/// Employee-level row shown in the directory payroll run console.
class EmployeePayrollRunConsoleEmployeeRow {
  final String employeeId;
  final String employeeName;
  final EmployeePayrollRunStatus? runStatus;
  final EmployeePayrollPaymentStatus? paymentStatus;
  final EmployeePayslipDeliveryStatus? payslipStatus;
  final EmployeePayrollCloseStatus? closeStatus;
  final String exportBatchId;
  final String paymentReference;
  final String nextAction;
  final double netPay;
  final String currencyCode;
  final int attentionCount;

  const EmployeePayrollRunConsoleEmployeeRow({
    required this.employeeId,
    required this.employeeName,
    required this.runStatus,
    required this.paymentStatus,
    required this.payslipStatus,
    required this.closeStatus,
    required this.exportBatchId,
    required this.paymentReference,
    required this.nextAction,
    required this.netPay,
    required this.currencyCode,
    required this.attentionCount,
  });

  factory EmployeePayrollRunConsoleEmployeeRow.fromState({
    required EmployeeDirectoryMember member,
    required EmployeePayrollRunProfile? payrollRun,
    required EmployeePayrollPaymentProfile? payment,
    required EmployeePayslipDeliveryProfile? payslip,
    required EmployeePayrollCloseProfile? close,
  }) {
    return EmployeePayrollRunConsoleEmployeeRow(
      employeeId: member.id,
      employeeName: member.name,
      runStatus: payrollRun?.status,
      paymentStatus: payment?.status,
      payslipStatus: payslip?.status,
      closeStatus: close?.status,
      exportBatchId:
          close?.exportBatchId ??
          payslip?.exportBatchId ??
          payment?.exportBatchId ??
          payrollRun?.exportBatchId ??
          '',
      paymentReference:
          close?.paymentReference ?? payment?.paymentReference ?? '',
      nextAction:
          close?.nextAction ??
          payslip?.nextAction ??
          payment?.nextAction ??
          payrollRun?.nextAction ??
          'Payroll run is unavailable.',
      netPay: payment?.netPay ?? payrollRun?.netPay ?? 0,
      currencyCode: payrollRun?.currencyCode ?? payment?.currencyCode ?? '',
      attentionCount:
          close?.attentionCount ??
          payslip?.attentionCount ??
          payment?.attentionCount ??
          payrollRun?.attentionCount ??
          1,
    );
  }

  bool get isExported => runStatus == EmployeePayrollRunStatus.exported;

  bool get isPaymentPaid => paymentStatus == EmployeePayrollPaymentStatus.paid;

  bool get isPayslipPublished {
    return payslipStatus == EmployeePayslipDeliveryStatus.published;
  }

  bool get isClosed => closeStatus == EmployeePayrollCloseStatus.closed;

  String get stageLabel {
    if (isClosed) return 'Closed';
    if (closeStatus == EmployeePayrollCloseStatus.posted) return 'Journal';
    if (isPaymentPaid && isPayslipPublished) return 'Close ready';
    if (paymentStatus == EmployeePayrollPaymentStatus.scheduled) {
      return 'Payment scheduled';
    }
    if (isExported) return 'Exported';
    if (runStatus == EmployeePayrollRunStatus.ready) return 'Ready';
    if (runStatus == EmployeePayrollRunStatus.blocked) return 'Blocked';
    return 'Draft';
  }
}

/// Aggregated directory payroll run console state.
class EmployeePayrollRunConsoleReview {
  final List<EmployeeDirectoryRosterPayrollRunKickoffRecord> records;
  final List<EmployeePayrollRunConsoleEmployeeRow> rows;

  const EmployeePayrollRunConsoleReview({
    required this.records,
    required this.rows,
  });

  EmployeeDirectoryRosterPayrollRunKickoffRecord? get activeRun {
    return records.isEmpty ? null : records.first;
  }

  bool get hasActiveRun => activeRun != null;

  int get employeeCount => rows.length;

  int get exportedCount => rows.where((row) => row.isExported).length;

  int get paidCount => rows.where((row) => row.isPaymentPaid).length;

  int get payslipPublishedCount {
    return rows.where((row) => row.isPayslipPublished).length;
  }

  int get closedCount => rows.where((row) => row.isClosed).length;

  int get attentionCount {
    return rows.fold<int>(0, (total, row) => total + row.attentionCount);
  }

  double get totalNetPay {
    return rows.fold<double>(0, (total, row) => total + row.netPay);
  }

  String get currencyCode {
    for (final row in rows) {
      if (row.currencyCode.isNotEmpty) return row.currencyCode;
    }
    return 'IDR';
  }

  String get exportedLabel => '$exportedCount/$employeeCount exported';

  String get paymentLabel => '$paidCount/$employeeCount paid';

  String get payslipLabel => '$payslipPublishedCount/$employeeCount published';

  String get closeLabel => '$closedCount/$employeeCount closed';

  String get statusLabel {
    if (!hasActiveRun) return 'No run';
    if (employeeCount == 0) return 'Launched';
    if (closedCount == employeeCount) return 'Closed';
    if (paidCount == employeeCount && payslipPublishedCount == employeeCount) {
      return 'Close ready';
    }
    if (exportedCount == employeeCount) return 'Exported';
    return 'Launched';
  }

  String get summaryLabel {
    final run = activeRun;
    if (run == null) return 'Launch payroll run after import validation.';
    return '${run.runReference} from ${run.batchLabel}, $exportedLabel.';
  }

  String get nextAction {
    if (!hasActiveRun) return 'Launch payroll run after import validation.';
    if (employeeCount == 0) return 'Review payroll run employee coverage.';
    if (exportedCount < employeeCount) {
      return 'Export ${employeeCount - exportedCount} employee payroll run'
          '${employeeCount - exportedCount == 1 ? '' : 's'}.';
    }
    if (paidCount < employeeCount) {
      return 'Settle ${employeeCount - paidCount} payroll payment'
          '${employeeCount - paidCount == 1 ? '' : 's'}.';
    }
    if (payslipPublishedCount < employeeCount) {
      return 'Publish ${employeeCount - payslipPublishedCount} payslip'
          '${employeeCount - payslipPublishedCount == 1 ? '' : 's'}.';
    }
    if (closedCount < employeeCount) {
      return 'Close ${employeeCount - closedCount} payroll period'
          '${employeeCount - closedCount == 1 ? '' : 's'}.';
    }
    return 'Payroll run is closed for all covered employees.';
  }

  double get completionRatio {
    if (employeeCount == 0) return hasActiveRun ? 0.1 : 0;
    final completed =
        exportedCount + paidCount + payslipPublishedCount + closedCount;
    return completed / (employeeCount * 4);
  }
}

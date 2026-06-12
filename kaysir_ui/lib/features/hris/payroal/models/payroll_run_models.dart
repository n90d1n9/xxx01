import 'payroll_adjustment_models.dart';
import 'payroll_detail.dart';
import 'payroll_exception_models.dart';

enum PayrollRunStatus {
  draft('Draft'),
  needsReview('Needs review'),
  ready('Ready'),
  approved('Approved'),
  paid('Paid');

  final String label;

  const PayrollRunStatus(this.label);
}

class PayrollRunDashboard {
  final String periodLabel;
  final DateTime payDate;
  final PayrollRunStatus status;
  final double grossPayroll;
  final double netPayroll;
  final double deductions;
  final double approvedAdjustmentTotal;
  final int employeeCount;
  final int pendingPaymentCount;
  final int pendingAdjustmentCount;
  final int approvedAdjustmentCount;
  final int openExceptionCount;
  final int criticalExceptionCount;
  final int readinessScore;
  final String nextAction;

  const PayrollRunDashboard({
    required this.periodLabel,
    required this.payDate,
    required this.status,
    required this.grossPayroll,
    required this.netPayroll,
    required this.deductions,
    required this.approvedAdjustmentTotal,
    required this.employeeCount,
    required this.pendingPaymentCount,
    required this.pendingAdjustmentCount,
    required this.approvedAdjustmentCount,
    required this.openExceptionCount,
    required this.criticalExceptionCount,
    required this.readinessScore,
    required this.nextAction,
  });

  factory PayrollRunDashboard.fromSignals({
    required PayrollSummary summary,
    required List<PayrollAdjustmentRequest> adjustments,
    required List<PayrollExceptionItem> exceptions,
    required DateTime asOfDate,
  }) {
    final approvedAdjustments =
        adjustments.where((adjustment) => adjustment.isApproved).toList();
    final pendingAdjustmentCount =
        adjustments.where((adjustment) => adjustment.isPending).length;
    final openExceptions =
        exceptions.where((exception) => exception.isOpen).toList();
    final criticalExceptionCount =
        openExceptions.where((exception) => exception.isCritical).length;
    final approvedAdjustmentTotal = approvedAdjustments.fold<double>(
      0,
      (total, adjustment) => total + adjustment.amount,
    );
    final readinessScore =
        100 -
        (criticalExceptionCount * 24) -
        ((openExceptions.length - criticalExceptionCount) * 10) -
        (pendingAdjustmentCount * 8) -
        (summary.pendingCount * 6);

    return PayrollRunDashboard(
      periodLabel: _periodLabel(asOfDate),
      payDate: DateTime(asOfDate.year, asOfDate.month, 25),
      status: _runStatus(
        criticalExceptionCount: criticalExceptionCount,
        openExceptionCount: openExceptions.length,
        pendingAdjustmentCount: pendingAdjustmentCount,
        pendingPaymentCount: summary.pendingCount,
      ),
      grossPayroll: summary.totalGross + approvedAdjustmentTotal,
      netPayroll: summary.totalNet + approvedAdjustmentTotal,
      deductions: summary.totalDeductions,
      approvedAdjustmentTotal: approvedAdjustmentTotal,
      employeeCount: summary.employeeCount,
      pendingPaymentCount: summary.pendingCount,
      pendingAdjustmentCount: pendingAdjustmentCount,
      approvedAdjustmentCount: approvedAdjustments.length,
      openExceptionCount: openExceptions.length,
      criticalExceptionCount: criticalExceptionCount,
      readinessScore: readinessScore.clamp(0, 100).toInt(),
      nextAction: _nextAction(
        criticalExceptionCount: criticalExceptionCount,
        openExceptionCount: openExceptions.length,
        pendingAdjustmentCount: pendingAdjustmentCount,
        pendingPaymentCount: summary.pendingCount,
      ),
    );
  }
}

PayrollRunStatus _runStatus({
  required int criticalExceptionCount,
  required int openExceptionCount,
  required int pendingAdjustmentCount,
  required int pendingPaymentCount,
}) {
  if (criticalExceptionCount > 0 || openExceptionCount > 0) {
    return PayrollRunStatus.needsReview;
  }
  if (pendingAdjustmentCount > 0) return PayrollRunStatus.needsReview;
  if (pendingPaymentCount == 0) return PayrollRunStatus.paid;
  return PayrollRunStatus.ready;
}

String _nextAction({
  required int criticalExceptionCount,
  required int openExceptionCount,
  required int pendingAdjustmentCount,
  required int pendingPaymentCount,
}) {
  if (criticalExceptionCount > 0) {
    return 'Resolve critical payroll exceptions before approval.';
  }
  if (openExceptionCount > 0) {
    return 'Clear payroll warnings before locking the run.';
  }
  if (pendingAdjustmentCount > 0) {
    return 'Approve pending payroll adjustments.';
  }
  if (pendingPaymentCount > 0) {
    return 'Process remaining employee payments.';
  }
  return 'Payroll run is ready to close.';
}

String _periodLabel(DateTime asOfDate) {
  return '${_months[asOfDate.month - 1]} ${asOfDate.year} Payroll';
}

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

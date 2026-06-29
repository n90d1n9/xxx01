import 'payroll_approval_workflow_models.dart';
import 'payroll_archive_models.dart';
import 'payroll_attendance_bridge_models.dart';
import 'payroll_data_import_models.dart';
import 'payroll_input_change_models.dart';
import 'payroll_liability_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_payslip_models.dart';
import 'payroll_run_models.dart';
import 'payroll_statutory_report_models.dart';

enum PayrollCutoffRuleStatus {
  blocked('Blocked'),
  open('Open'),
  dueSoon('Due soon'),
  missed('Missed'),
  complete('Complete');

  final String label;

  const PayrollCutoffRuleStatus(this.label);
}

class PayrollCutoffRule {
  final String id;
  final String title;
  final String owner;
  final DateTime cutoffAt;
  final int completedCount;
  final int requiredCount;
  final int blockerCount;
  final String detail;

  const PayrollCutoffRule({
    required this.id,
    required this.title,
    required this.owner,
    required this.cutoffAt,
    required this.completedCount,
    required this.requiredCount,
    required this.blockerCount,
    required this.detail,
  });

  double get completionRate {
    if (requiredCount == 0) return 1;
    return completedCount / requiredCount;
  }

  bool get isComplete => completedCount >= requiredCount && blockerCount == 0;

  PayrollCutoffRuleStatus statusOn(DateTime asOfDate) {
    if (isComplete) return PayrollCutoffRuleStatus.complete;
    if (cutoffAt.isBefore(_dateOnly(asOfDate))) {
      return PayrollCutoffRuleStatus.missed;
    }
    if (blockerCount > 0) return PayrollCutoffRuleStatus.blocked;
    final daysUntilCutoff = cutoffAt.difference(_dateOnly(asOfDate)).inDays;
    if (daysUntilCutoff <= 3) return PayrollCutoffRuleStatus.dueSoon;
    return PayrollCutoffRuleStatus.open;
  }
}

class PayrollCutoffCalendarSummary {
  final String periodLabel;
  final DateTime asOfDate;
  final DateTime payDate;
  final List<PayrollCutoffRule> rules;

  const PayrollCutoffCalendarSummary({
    required this.periodLabel,
    required this.asOfDate,
    required this.payDate,
    required this.rules,
  });

  factory PayrollCutoffCalendarSummary.fromRun({
    required DateTime asOfDate,
    required PayrollRunDashboard dashboard,
    required List<PayrollDataImportBatch> importBatches,
    required PayrollInputChangeSummary inputChanges,
    required PayrollAttendanceBridgeSummary attendanceBridge,
    required PayrollApprovalWorkflowSummary approvalWorkflow,
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollPayslipPackageSummary payslipPackage,
    required PayrollLiabilitySummary liabilities,
    required PayrollStatutoryReportSummary statutoryReport,
    required PayrollArchivePackageSummary archivePackage,
  }) {
    final rules = [
      PayrollCutoffRule(
        id: 'data-import',
        title: 'Payroll data import cutoff',
        owner: 'Payroll Ops',
        cutoffAt: dashboard.payDate.subtract(const Duration(days: 15)),
        completedCount: importBatches.length,
        requiredCount: 1,
        blockerCount:
            importBatches.where((batch) => batch.errorCount > 0).length,
        detail:
            importBatches.isEmpty
                ? 'Import payroll changes before review starts.'
                : '${importBatches.length} payroll import batches captured.',
      ),
      PayrollCutoffRule(
        id: 'input-changes',
        title: 'Input change approval cutoff',
        owner: 'Payroll Manager',
        cutoffAt: dashboard.payDate.subtract(const Duration(days: 12)),
        completedCount: inputChanges.appliedCount,
        requiredCount: inputChanges.lines.length,
        blockerCount: inputChanges.blockedCount + inputChanges.pendingCount,
        detail: inputChanges.nextAction,
      ),
      PayrollCutoffRule(
        id: 'attendance',
        title: 'Attendance payroll cutoff',
        owner: 'Timekeeping',
        cutoffAt: dashboard.payDate.subtract(const Duration(days: 10)),
        completedCount: attendanceBridge.appliedCount,
        requiredCount: attendanceBridge.lines.length,
        blockerCount:
            attendanceBridge.blockedCount + attendanceBridge.pendingCount,
        detail: attendanceBridge.nextAction,
      ),
      PayrollCutoffRule(
        id: 'approvals',
        title: 'Approval chain cutoff',
        owner: 'Payroll Controller',
        cutoffAt: dashboard.payDate.subtract(const Duration(days: 4)),
        completedCount: approvalWorkflow.approvedCount,
        requiredCount: approvalWorkflow.stages.length,
        blockerCount: approvalWorkflow.blockedCount,
        detail: approvalWorkflow.nextAction,
      ),
      PayrollCutoffRule(
        id: 'payments',
        title: 'Payment release cutoff',
        owner: 'Finance Ops',
        cutoffAt: dashboard.payDate,
        completedCount: paymentBatch.paidCount,
        requiredCount: paymentBatch.lines.length,
        blockerCount:
            paymentBatch.lines.where((line) => line.hasBlockers).length,
        detail: paymentBatch.nextAction,
      ),
      PayrollCutoffRule(
        id: 'payslips',
        title: 'Payslip publication cutoff',
        owner: 'Payroll Ops',
        cutoffAt: dashboard.payDate.add(const Duration(days: 1)),
        completedCount: payslipPackage.publishedCount,
        requiredCount: payslipPackage.lines.length,
        blockerCount:
            payslipPackage.lines.where((line) => line.hasBlockers).length,
        detail: payslipPackage.nextAction,
      ),
      PayrollCutoffRule(
        id: 'liabilities',
        title: 'Liability remittance cutoff',
        owner: 'Payroll Tax',
        cutoffAt: liabilities.nextDueLine?.dueDate ?? dashboard.payDate,
        completedCount: liabilities.remittedCount,
        requiredCount: liabilities.lines.length,
        blockerCount: liabilities.blockedCount,
        detail: liabilities.nextAction,
      ),
      PayrollCutoffRule(
        id: 'statutory',
        title: 'Statutory filing cutoff',
        owner: 'Payroll Tax',
        cutoffAt: dashboard.payDate.add(const Duration(days: 7)),
        completedCount: statutoryReport.exportedCount,
        requiredCount: statutoryReport.lines.length,
        blockerCount: statutoryReport.blockedCount,
        detail: statutoryReport.nextAction,
      ),
      PayrollCutoffRule(
        id: 'archive',
        title: 'Archive retention cutoff',
        owner: 'Payroll Controller',
        cutoffAt: dashboard.payDate.add(const Duration(days: 10)),
        completedCount: archivePackage.capturedCount,
        requiredCount: archivePackage.evidenceItems.length,
        blockerCount: archivePackage.blockedCount,
        detail: archivePackage.nextAction,
      ),
    ]..sort((left, right) => left.cutoffAt.compareTo(right.cutoffAt));

    return PayrollCutoffCalendarSummary(
      periodLabel: dashboard.periodLabel,
      asOfDate: asOfDate,
      payDate: dashboard.payDate,
      rules: rules,
    );
  }

  int get completeCount => _count(PayrollCutoffRuleStatus.complete);

  int get blockedCount => _count(PayrollCutoffRuleStatus.blocked);

  int get dueSoonCount => _count(PayrollCutoffRuleStatus.dueSoon);

  int get missedCount => _count(PayrollCutoffRuleStatus.missed);

  String get nextAction {
    final activeRules = rules.where(
      (rule) => rule.statusOn(asOfDate) != PayrollCutoffRuleStatus.complete,
    );
    final next =
        _firstOrNull(
          activeRules.where(
            (rule) => rule.statusOn(asOfDate) == PayrollCutoffRuleStatus.missed,
          ),
        ) ??
        _firstOrNull(
          activeRules.where(
            (rule) =>
                rule.statusOn(asOfDate) == PayrollCutoffRuleStatus.blocked,
          ),
        ) ??
        _firstOrNull(activeRules);
    if (next == null) return 'Payroll cutoff calendar is complete.';
    return next.detail;
  }

  int _count(PayrollCutoffRuleStatus status) {
    return rules.where((rule) => rule.statusOn(asOfDate) == status).length;
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

PayrollCutoffRule? _firstOrNull(Iterable<PayrollCutoffRule> rules) {
  for (final rule in rules) {
    return rule;
  }
  return null;
}

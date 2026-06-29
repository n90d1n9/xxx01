import '../models/employee_directory_models.dart';
import '../models/employee_payroll_cutoff_models.dart';
import '../models/employee_payroll_models.dart';
import '../models/employee_payroll_run_launch_context_models.dart';
import '../models/employee_payroll_run_models.dart';
import '../models/employee_payroll_variance_models.dart';

/// Builds an employee payroll run preview from payroll and cutoff sources.
EmployeePayrollRunProfile buildEmployeePayrollRunProfile({
  required EmployeeDirectoryMember member,
  required EmployeePayrollProfile payroll,
  required EmployeePayrollCutoffReconciliationProfile cutoff,
  required EmployeePayrollVarianceProfile variance,
  EmployeePayrollRunLaunchContext? launchContext,
}) {
  final lines = <EmployeePayrollRunLine>[
    EmployeePayrollRunLine(
      id: 'run-base-pay',
      type: EmployeePayrollRunLineType.basePay,
      status: EmployeePayrollRunLineStatus.included,
      title: 'Base pay',
      detail: 'Monthly base pay for ${member.name}.',
      amount: variance.baselineGrossPay,
      currencyCode: payroll.schedule.currencyCode,
      taxable: true,
      countsInNetPay: true,
      sortOrder: 10,
    ),
    ..._varianceLines(variance, payroll.schedule.currencyCode),
  ];

  final taxableGross = lines
      .where((line) => line.taxable && line.isIncludedInPreview)
      .fold<double>(0, (total, line) => total + line.amount);
  final taxAmount =
      -(taxableGross * _taxRateFor(payroll.schedule.currencyCode));
  final employerCost = taxableGross * 0.04;
  final payrollSetupIssueCount = payroll.attentionCount;
  final cutoffBlockerCount = cutoff.blockingCount;
  final varianceApprovalCount = variance.approvalRequiredCount;
  final blockerCount =
      (payrollSetupIssueCount > 0 ? 1 : 0) +
      cutoffBlockerCount +
      varianceApprovalCount;

  lines.addAll([
    EmployeePayrollRunLine(
      id: 'run-tax-withholding',
      type: EmployeePayrollRunLineType.tax,
      status:
          payroll.taxAttentionCount > 0
              ? EmployeePayrollRunLineStatus.pending
              : EmployeePayrollRunLineStatus.included,
      title: 'Estimated withholding',
      detail: 'Estimated payroll withholding for this run.',
      amount: taxAmount,
      currencyCode: payroll.schedule.currencyCode,
      taxable: false,
      countsInNetPay: true,
      sortOrder: 80,
    ),
    EmployeePayrollRunLine(
      id: 'run-employer-cost',
      type: EmployeePayrollRunLineType.employerCost,
      status: EmployeePayrollRunLineStatus.included,
      title: 'Employer contribution estimate',
      detail: 'Estimated employer-side contribution for cost preview.',
      amount: employerCost,
      currencyCode: payroll.schedule.currencyCode,
      taxable: false,
      countsInNetPay: false,
      sortOrder: 90,
    ),
    ..._holdLines(
      payroll: payroll,
      cutoff: cutoff,
      variance: variance,
      currencyCode: payroll.schedule.currencyCode,
    ),
  ]);

  return EmployeePayrollRunProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: payroll.asOfDate,
    periodStart: variance.periodStart,
    periodEnd: variance.periodEnd,
    payDate: payroll.schedule.nextPayDate,
    cutoffDate: payroll.schedule.cutoffDate,
    currencyCode: payroll.schedule.currencyCode,
    status:
        blockerCount > 0
            ? EmployeePayrollRunStatus.blocked
            : EmployeePayrollRunStatus.draft,
    lines: lines,
    payrollSetupIssueCount: payrollSetupIssueCount,
    cutoffBlockerCount: cutoffBlockerCount,
    varianceApprovalCount: varianceApprovalCount,
    reviewer: '',
    reviewNote: '',
    payslipVisible: false,
    exportBatchId: '',
    exportedAt: null,
    launchContext: launchContext,
  );
}

/// Builds the default employee payroll run review draft.
EmployeePayrollRunReviewDraft buildEmployeePayrollRunReviewDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeePayrollRunReviewDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    reviewer: member.manager,
    note: '',
    payslipVisible: false,
  );
}

List<EmployeePayrollRunLine> _varianceLines(
  EmployeePayrollVarianceProfile variance,
  String currencyCode,
) {
  final lines = <EmployeePayrollRunLine>[];

  for (final line in variance.sortedLines) {
    if (line.id == 'variance-clear') continue;
    if (line.amount == 0 && !line.requiresApproval) continue;

    lines.add(
      EmployeePayrollRunLine(
        id: 'run-${line.id}',
        type: _lineTypeFor(line),
        status: _statusFor(line),
        title: line.title,
        detail: line.detail,
        amount: line.amount,
        currencyCode: currencyCode,
        taxable: line.taxableImpact,
        countsInNetPay: line.amount != 0,
        sortOrder: _sortOrderFor(line),
      ),
    );
  }

  return lines;
}

List<EmployeePayrollRunLine> _holdLines({
  required EmployeePayrollProfile payroll,
  required EmployeePayrollCutoffReconciliationProfile cutoff,
  required EmployeePayrollVarianceProfile variance,
  required String currencyCode,
}) {
  final lines = <EmployeePayrollRunLine>[];

  if (payroll.attentionCount > 0) {
    lines.add(
      EmployeePayrollRunLine(
        id: 'run-hold-payroll-profile',
        type: EmployeePayrollRunLineType.hold,
        status: EmployeePayrollRunLineStatus.hold,
        title: 'Payroll profile hold',
        detail:
            '${payroll.attentionCount} payroll setup item${payroll.attentionCount == 1 ? '' : 's'} must be cleared before export.',
        amount: 0,
        currencyCode: currencyCode,
        taxable: false,
        countsInNetPay: false,
        sortOrder: 100,
      ),
    );
  }

  if (cutoff.blockingCount > 0) {
    lines.add(
      EmployeePayrollRunLine(
        id: 'run-hold-cutoff',
        type: EmployeePayrollRunLineType.hold,
        status: EmployeePayrollRunLineStatus.hold,
        title: 'Cutoff reconciliation hold',
        detail:
            '${cutoff.blockingCount} payroll cutoff blocker${cutoff.blockingCount == 1 ? '' : 's'} prevent export.',
        amount: 0,
        currencyCode: currencyCode,
        taxable: false,
        countsInNetPay: false,
        sortOrder: 101,
      ),
    );
  }

  if (variance.approvalRequiredCount > 0) {
    lines.add(
      EmployeePayrollRunLine(
        id: 'run-hold-variance',
        type: EmployeePayrollRunLineType.hold,
        status: EmployeePayrollRunLineStatus.hold,
        title: 'Variance approval hold',
        detail:
            '${variance.approvalRequiredCount} payroll variance item${variance.approvalRequiredCount == 1 ? '' : 's'} need approval.',
        amount: 0,
        currencyCode: currencyCode,
        taxable: false,
        countsInNetPay: false,
        sortOrder: 102,
      ),
    );
  }

  return lines;
}

EmployeePayrollRunLineType _lineTypeFor(EmployeePayrollVarianceLine line) {
  if (line.amount == 0) return EmployeePayrollRunLineType.hold;
  if (line.source == EmployeePayrollVarianceSource.reimbursement) {
    return EmployeePayrollRunLineType.reimbursement;
  }
  if (line.amount < 0) return EmployeePayrollRunLineType.deduction;
  return EmployeePayrollRunLineType.earning;
}

EmployeePayrollRunLineStatus _statusFor(EmployeePayrollVarianceLine line) {
  return switch (line.status) {
    EmployeePayrollVarianceStatus.approved =>
      EmployeePayrollRunLineStatus.included,
    EmployeePayrollVarianceStatus.excluded =>
      EmployeePayrollRunLineStatus.excluded,
    EmployeePayrollVarianceStatus.open ||
    EmployeePayrollVarianceStatus.reviewed =>
      line.amount == 0
          ? EmployeePayrollRunLineStatus.hold
          : EmployeePayrollRunLineStatus.pending,
  };
}

int _sortOrderFor(EmployeePayrollVarianceLine line) {
  if (line.source == EmployeePayrollVarianceSource.overtime) return 20;
  if (line.source == EmployeePayrollVarianceSource.compensationChange) {
    return 25;
  }
  if (line.source == EmployeePayrollVarianceSource.manualAdjustment) return 30;
  if (line.source == EmployeePayrollVarianceSource.leave) return 35;
  if (line.source == EmployeePayrollVarianceSource.reimbursement) return 40;
  return 70;
}

double _taxRateFor(String currencyCode) {
  return currencyCode == 'SGD' ? 0.08 : 0.05;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

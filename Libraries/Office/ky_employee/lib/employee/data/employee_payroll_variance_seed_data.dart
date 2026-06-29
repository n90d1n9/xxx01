import '../models/employee_compensation_models.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_leave_models.dart';
import '../models/employee_payroll_cutoff_models.dart';
import '../models/employee_payroll_models.dart';
import '../models/employee_payroll_variance_models.dart';
import '../models/employee_reimbursement_models.dart';
import '../models/employee_timekeeping_models.dart';

EmployeePayrollVarianceProfile buildEmployeePayrollVarianceProfile({
  required EmployeeDirectoryMember member,
  required EmployeeCompensationPackage compensationPackage,
  required EmployeeCompensationReviewSummary compensationSummary,
  required EmployeePayrollProfile payroll,
  required EmployeeTimekeepingProfile timekeeping,
  required EmployeeLeaveProfile leave,
  required EmployeeReimbursementProfile reimbursement,
  required EmployeePayrollCutoffReconciliationProfile cutoff,
}) {
  final monthlyBasePay = compensationPackage.baseSalary / 12;
  final lines = <EmployeePayrollVarianceLine>[
    ..._payrollProfileLines(payroll),
    ..._timekeepingLines(
      timekeeping,
      monthlyBasePay,
      payroll.schedule.currencyCode,
    ),
    ..._leaveLines(leave, monthlyBasePay, payroll.schedule.currencyCode),
    ..._reimbursementLines(reimbursement),
    ..._compensationLines(
      compensationSummary,
      monthlyBasePay,
      compensationPackage.currencyCode,
    ),
    ..._cutoffLines(cutoff, payroll.schedule.currencyCode),
  ];

  if (lines.isEmpty) {
    lines.add(
      EmployeePayrollVarianceLine(
        id: 'variance-clear',
        source: EmployeePayrollVarianceSource.payrollProfile,
        severity: EmployeePayrollVarianceSeverity.low,
        status: EmployeePayrollVarianceStatus.approved,
        title: 'No payroll variance detected',
        detail:
            'Base pay, time, leave, claims, and payroll inputs match expectations.',
        owner: 'Payroll Operations',
        amount: 0,
        currencyCode: payroll.schedule.currencyCode,
        requiresApproval: false,
        taxableImpact: false,
      ),
    );
  }

  return EmployeePayrollVarianceProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: payroll.asOfDate,
    periodStart: DateTime(payroll.asOfDate.year, payroll.asOfDate.month),
    periodEnd: payroll.schedule.cutoffDate,
    currencyCode: payroll.schedule.currencyCode,
    baselineGrossPay: monthlyBasePay,
    lines: lines,
  );
}

EmployeePayrollVarianceAdjustmentDraft
buildEmployeePayrollVarianceAdjustmentDraft({
  required EmployeeDirectoryMember member,
  required EmployeePayrollProfile payroll,
}) {
  return EmployeePayrollVarianceAdjustmentDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: payroll.asOfDate,
    currencyCode: payroll.schedule.currencyCode,
    title: '',
    amount: 0,
    owner: member.manager,
    reason: '',
    taxableImpact: true,
  );
}

List<EmployeePayrollVarianceLine> _payrollProfileLines(
  EmployeePayrollProfile payroll,
) {
  if (payroll.attentionCount == 0) return const [];

  return [
    EmployeePayrollVarianceLine(
      id: 'variance-payroll-profile',
      source: EmployeePayrollVarianceSource.payrollProfile,
      severity: EmployeePayrollVarianceSeverity.blocker,
      status: EmployeePayrollVarianceStatus.open,
      title: 'Payroll profile hold',
      detail:
          '${payroll.attentionCount} payroll setup item${payroll.attentionCount == 1 ? '' : 's'} must be cleared before variance approval.',
      owner: 'Payroll Operations',
      amount: 0,
      currencyCode: payroll.schedule.currencyCode,
      requiresApproval: true,
      taxableImpact: false,
    ),
  ];
}

List<EmployeePayrollVarianceLine> _timekeepingLines(
  EmployeeTimekeepingProfile timekeeping,
  double monthlyBasePay,
  String currencyCode,
) {
  final lines = <EmployeePayrollVarianceLine>[];
  final hourlyRate = monthlyBasePay / 173;
  final overtimePremium = timekeeping.totalOvertimeHours * hourlyRate * 1.5;
  final hasTimeBlocker =
      timekeeping.payrollBlockingExceptionCount > 0 ||
      timekeeping.rejectedEntryCount > 0;

  if (overtimePremium > 0) {
    lines.add(
      EmployeePayrollVarianceLine(
        id: 'variance-overtime-premium',
        source: EmployeePayrollVarianceSource.overtime,
        severity:
            hasTimeBlocker
                ? EmployeePayrollVarianceSeverity.blocker
                : timekeeping.submittedEntryCount > 0
                ? EmployeePayrollVarianceSeverity.high
                : EmployeePayrollVarianceSeverity.medium,
        status: EmployeePayrollVarianceStatus.open,
        title: 'Overtime premium variance',
        detail:
            '${timekeeping.totalOvertimeHours.toStringAsFixed(1)} overtime hour${timekeeping.totalOvertimeHours == 1 ? '' : 's'} are included in projected payroll.',
        owner: 'People Operations',
        amount: overtimePremium,
        currencyCode: currencyCode,
        requiresApproval: timekeeping.submittedEntryCount > 0 || hasTimeBlocker,
        taxableImpact: true,
      ),
    );
  }

  if (timekeeping.payrollBlockingExceptionCount > 0) {
    lines.add(
      EmployeePayrollVarianceLine(
        id: 'variance-timekeeping-hold',
        source: EmployeePayrollVarianceSource.overtime,
        severity: EmployeePayrollVarianceSeverity.blocker,
        status: EmployeePayrollVarianceStatus.open,
        title: 'Timekeeping exception hold',
        detail:
            '${timekeeping.payrollBlockingExceptionCount} payroll-blocking timekeeping exception${timekeeping.payrollBlockingExceptionCount == 1 ? '' : 's'} need resolution.',
        owner: 'Payroll Operations',
        amount: 0,
        currencyCode: currencyCode,
        requiresApproval: true,
        taxableImpact: false,
      ),
    );
  }

  return lines;
}

List<EmployeePayrollVarianceLine> _leaveLines(
  EmployeeLeaveProfile leave,
  double monthlyBasePay,
  String currencyCode,
) {
  final unpaidImpact = leave.requests
      .where(
        (request) =>
            request.type == EmployeeLeaveType.unpaid &&
            (request.isPending || request.isApproved),
      )
      .fold<double>(
        0,
        (total, request) =>
            total - ((monthlyBasePay / 22) * request.durationDays),
      );

  if (leave.attentionCount == 0 && unpaidImpact == 0) return const [];

  return [
    EmployeePayrollVarianceLine(
      id: 'variance-leave-impact',
      source: EmployeePayrollVarianceSource.leave,
      severity:
          leave.blackoutConflictCount > 0
              ? EmployeePayrollVarianceSeverity.high
              : EmployeePayrollVarianceSeverity.medium,
      status: EmployeePayrollVarianceStatus.open,
      title: 'Leave impact review',
      detail:
          '${leave.pendingRequestCount} pending request${leave.pendingRequestCount == 1 ? '' : 's'}, ${leave.lowBalanceCount} low balance${leave.lowBalanceCount == 1 ? '' : 's'}, and ${leave.blackoutConflictCount} blackout conflict${leave.blackoutConflictCount == 1 ? '' : 's'} need payroll review.',
      owner: 'People Operations',
      amount: unpaidImpact,
      currencyCode: currencyCode,
      requiresApproval:
          leave.pendingRequestCount > 0 || leave.blackoutConflictCount > 0,
      taxableImpact: unpaidImpact != 0,
    ),
  ];
}

List<EmployeePayrollVarianceLine> _reimbursementLines(
  EmployeeReimbursementProfile reimbursement,
) {
  if (reimbursement.pendingAmount <= 0 && reimbursement.attentionCount == 0) {
    return const [];
  }

  return [
    EmployeePayrollVarianceLine(
      id: 'variance-reimbursement',
      source: EmployeePayrollVarianceSource.reimbursement,
      severity:
          reimbursement.missingReceiptCount > 0
              ? EmployeePayrollVarianceSeverity.high
              : EmployeePayrollVarianceSeverity.medium,
      status: EmployeePayrollVarianceStatus.open,
      title: 'Expense reimbursement variance',
      detail:
          '${reimbursement.submittedCount} submitted and ${reimbursement.approvedCount} approved claim${reimbursement.submittedCount + reimbursement.approvedCount == 1 ? '' : 's'} affect payroll reimbursement.',
      owner: 'Payroll Operations',
      amount: reimbursement.pendingAmount,
      currencyCode:
          reimbursement.allowances.isEmpty
              ? 'IDR'
              : reimbursement.allowances.first.currencyCode,
      requiresApproval:
          reimbursement.submittedCount > 0 ||
          reimbursement.missingReceiptCount > 0,
      taxableImpact: false,
    ),
  ];
}

List<EmployeePayrollVarianceLine> _compensationLines(
  EmployeeCompensationReviewSummary compensationSummary,
  double monthlyBasePay,
  String currencyCode,
) {
  if (compensationSummary.pendingAnnualBudget == 0) return const [];

  final monthlyImpact = compensationSummary.pendingAnnualBudget / 12;

  return [
    EmployeePayrollVarianceLine(
      id: 'variance-compensation-change',
      source: EmployeePayrollVarianceSource.compensationChange,
      severity:
          monthlyImpact.abs() >= monthlyBasePay * 0.05
              ? EmployeePayrollVarianceSeverity.high
              : EmployeePayrollVarianceSeverity.medium,
      status: EmployeePayrollVarianceStatus.open,
      title: 'Compensation change variance',
      detail:
          '${compensationSummary.submittedCount} submitted and ${compensationSummary.approvedCount} approved compensation review${compensationSummary.submittedCount + compensationSummary.approvedCount == 1 ? '' : 's'} affect projected base pay.',
      owner: 'Compensation',
      amount: monthlyImpact,
      currencyCode: currencyCode,
      requiresApproval: true,
      taxableImpact: true,
    ),
  ];
}

List<EmployeePayrollVarianceLine> _cutoffLines(
  EmployeePayrollCutoffReconciliationProfile cutoff,
  String currencyCode,
) {
  if (cutoff.blockingCount == 0) return const [];

  return [
    EmployeePayrollVarianceLine(
      id: 'variance-cutoff-blockers',
      source: EmployeePayrollVarianceSource.payrollCutoff,
      severity: EmployeePayrollVarianceSeverity.blocker,
      status: EmployeePayrollVarianceStatus.open,
      title: 'Cutoff blocker hold',
      detail:
          '${cutoff.blockingCount} payroll cutoff blocker${cutoff.blockingCount == 1 ? '' : 's'} prevent variance approval.',
      owner: 'Payroll Operations',
      amount: 0,
      currencyCode: currencyCode,
      requiresApproval: true,
      taxableImpact: false,
    ),
  ];
}

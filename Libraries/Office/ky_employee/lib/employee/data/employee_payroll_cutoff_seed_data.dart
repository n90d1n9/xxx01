import '../models/employee_directory_models.dart';
import '../models/employee_leave_models.dart';
import '../models/employee_payroll_cutoff_models.dart';
import '../models/employee_payroll_models.dart';
import '../models/employee_timekeeping_models.dart';

EmployeePayrollCutoffReconciliationProfile
buildEmployeePayrollCutoffReconciliationProfile({
  required EmployeeDirectoryMember member,
  required EmployeePayrollProfile payroll,
  required EmployeeTimekeepingProfile timekeeping,
  required EmployeeLeaveProfile leave,
}) {
  final items = <EmployeePayrollCutoffItem>[
    ..._payrollItems(payroll),
    ..._timekeepingItems(timekeeping, payroll.schedule.cutoffDate),
    ..._leaveItems(leave, payroll.schedule.cutoffDate),
  ];

  if (items.isEmpty) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'cutoff-inputs-clear',
        source: EmployeePayrollCutoffItemSource.schedule,
        severity: EmployeePayrollCutoffItemSeverity.low,
        status: EmployeePayrollCutoffItemStatus.resolved,
        title: 'Payroll inputs collected',
        detail: 'All payroll cutoff inputs are clear for review.',
        owner: 'Payroll Operations',
        dueDate: payroll.schedule.cutoffDate,
        payrollImpact: false,
      ),
    );
  }

  return EmployeePayrollCutoffReconciliationProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: payroll.asOfDate,
    periodStart: DateTime(payroll.asOfDate.year, payroll.asOfDate.month),
    periodEnd: payroll.schedule.cutoffDate,
    cutoffDate: payroll.schedule.cutoffDate,
    nextPayDate: payroll.schedule.nextPayDate,
    currencyCode: payroll.schedule.currencyCode,
    items: items,
    signoff: null,
  );
}

EmployeePayrollCutoffSignoffDraft buildEmployeePayrollCutoffSignoffDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeePayrollCutoffSignoffDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    reviewer: member.manager,
    reviewDate: today,
    note: '',
    acceptOpenWarnings: false,
  );
}

List<EmployeePayrollCutoffItem> _payrollItems(EmployeePayrollProfile payroll) {
  final items = <EmployeePayrollCutoffItem>[];
  final cutoffDate = payroll.schedule.cutoffDate;

  if (payroll.bankAttentionCount > 0) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'payroll-bank',
        source: EmployeePayrollCutoffItemSource.payrollProfile,
        severity: EmployeePayrollCutoffItemSeverity.blocker,
        status: EmployeePayrollCutoffItemStatus.open,
        title: 'Verify payroll bank account',
        detail:
            'Bank account is ${payroll.bankAccount.verificationStatus.label.toLowerCase()} and must be verified before payroll release.',
        owner: 'Payroll Operations',
        dueDate: cutoffDate,
        payrollImpact: true,
      ),
    );
  }

  if (payroll.taxAttentionCount > 0) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'payroll-tax',
        source: EmployeePayrollCutoffItemSource.payrollProfile,
        severity: EmployeePayrollCutoffItemSeverity.blocker,
        status: EmployeePayrollCutoffItemStatus.open,
        title: 'Refresh payroll tax profile',
        detail:
            'Tax profile is ${payroll.taxProfile.status.label.toLowerCase()} and needs correction before payroll cutoff.',
        owner: 'Payroll Operations',
        dueDate: cutoffDate,
        payrollImpact: true,
      ),
    );
  }

  if (payroll.submittedChangeCount > 0) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'payroll-change-review',
        source: EmployeePayrollCutoffItemSource.payrollProfile,
        severity: EmployeePayrollCutoffItemSeverity.high,
        status: EmployeePayrollCutoffItemStatus.open,
        title: 'Review submitted payroll changes',
        detail:
            '${payroll.submittedChangeCount} payroll change${payroll.submittedChangeCount == 1 ? '' : 's'} need approval before cutoff.',
        owner: 'People Operations',
        dueDate: cutoffDate.subtract(const Duration(days: 1)),
        payrollImpact: true,
      ),
    );
  }

  if (payroll.approvedChangeCount > 0) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'payroll-change-apply',
        source: EmployeePayrollCutoffItemSource.payrollProfile,
        severity: EmployeePayrollCutoffItemSeverity.high,
        status: EmployeePayrollCutoffItemStatus.open,
        title: 'Apply approved payroll changes',
        detail:
            '${payroll.approvedChangeCount} approved payroll change${payroll.approvedChangeCount == 1 ? '' : 's'} must be applied before release.',
        owner: 'Payroll Operations',
        dueDate: cutoffDate,
        payrollImpact: true,
      ),
    );
  }

  if (items.isEmpty) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'payroll-profile-clear',
        source: EmployeePayrollCutoffItemSource.payrollProfile,
        severity: EmployeePayrollCutoffItemSeverity.low,
        status: EmployeePayrollCutoffItemStatus.resolved,
        title: 'Payroll profile verified',
        detail: 'Bank, tax, and payroll change queues are clear.',
        owner: 'Payroll Operations',
        dueDate: cutoffDate,
        payrollImpact: false,
      ),
    );
  }

  if (payroll.schedule.isCutoffSoon(payroll.asOfDate)) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'payroll-cutoff-window',
        source: EmployeePayrollCutoffItemSource.schedule,
        severity: EmployeePayrollCutoffItemSeverity.medium,
        status: EmployeePayrollCutoffItemStatus.open,
        title: 'Cutoff window is active',
        detail: 'Payroll cutoff is within five days for this pay group.',
        owner: 'Payroll Operations',
        dueDate: cutoffDate,
        payrollImpact: false,
      ),
    );
  }

  return items;
}

List<EmployeePayrollCutoffItem> _timekeepingItems(
  EmployeeTimekeepingProfile timekeeping,
  DateTime cutoffDate,
) {
  final items = <EmployeePayrollCutoffItem>[];

  if (timekeeping.payrollBlockingExceptionCount > 0) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'timekeeping-payroll-blockers',
        source: EmployeePayrollCutoffItemSource.timekeeping,
        severity: EmployeePayrollCutoffItemSeverity.blocker,
        status: EmployeePayrollCutoffItemStatus.open,
        title: 'Resolve timekeeping payroll blockers',
        detail:
            '${timekeeping.payrollBlockingExceptionCount} timekeeping exception${timekeeping.payrollBlockingExceptionCount == 1 ? '' : 's'} block payroll readiness.',
        owner: 'Payroll Operations',
        dueDate: cutoffDate,
        payrollImpact: true,
      ),
    );
  }

  if (timekeeping.rejectedEntryCount > 0) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'timekeeping-rejected-entries',
        source: EmployeePayrollCutoffItemSource.timekeeping,
        severity: EmployeePayrollCutoffItemSeverity.high,
        status: EmployeePayrollCutoffItemStatus.open,
        title: 'Correct rejected timesheet entries',
        detail:
            '${timekeeping.rejectedEntryCount} rejected timesheet entr${timekeeping.rejectedEntryCount == 1 ? 'y' : 'ies'} need correction.',
        owner: 'People Operations',
        dueDate: cutoffDate.subtract(const Duration(days: 1)),
        payrollImpact: true,
      ),
    );
  }

  if (timekeeping.submittedEntryCount > 0) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'timekeeping-submitted-entries',
        source: EmployeePayrollCutoffItemSource.timekeeping,
        severity: EmployeePayrollCutoffItemSeverity.high,
        status: EmployeePayrollCutoffItemStatus.open,
        title: 'Approve submitted timesheet entries',
        detail:
            '${timekeeping.submittedEntryCount} submitted timesheet entr${timekeeping.submittedEntryCount == 1 ? 'y' : 'ies'} need manager approval.',
        owner: 'People Operations',
        dueDate: cutoffDate.subtract(const Duration(days: 1)),
        payrollImpact: true,
      ),
    );
  }

  if (timekeeping.payrollBlockingExceptionCount == 0 &&
      timekeeping.overdueExceptionCount > 0) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'timekeeping-overdue-exceptions',
        source: EmployeePayrollCutoffItemSource.timekeeping,
        severity: EmployeePayrollCutoffItemSeverity.high,
        status: EmployeePayrollCutoffItemStatus.open,
        title: 'Review overdue timekeeping exceptions',
        detail:
            '${timekeeping.overdueExceptionCount} overdue timekeeping exception${timekeeping.overdueExceptionCount == 1 ? '' : 's'} need reconciliation.',
        owner: 'Payroll Operations',
        dueDate: cutoffDate.subtract(const Duration(days: 1)),
        payrollImpact: true,
      ),
    );
  }

  if (items.isEmpty && timekeeping.isReadyForPayroll) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'timekeeping-ready',
        source: EmployeePayrollCutoffItemSource.timekeeping,
        severity: EmployeePayrollCutoffItemSeverity.low,
        status: EmployeePayrollCutoffItemStatus.resolved,
        title: 'Timekeeping payroll ready',
        detail: 'Timesheet entries and exceptions are ready for payroll.',
        owner: 'Payroll Operations',
        dueDate: cutoffDate,
        payrollImpact: false,
      ),
    );
  }

  return items;
}

List<EmployeePayrollCutoffItem> _leaveItems(
  EmployeeLeaveProfile leave,
  DateTime cutoffDate,
) {
  final items = <EmployeePayrollCutoffItem>[];

  if (leave.blackoutConflictCount > 0) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'leave-blackout-conflicts',
        source: EmployeePayrollCutoffItemSource.leave,
        severity: EmployeePayrollCutoffItemSeverity.high,
        status: EmployeePayrollCutoffItemStatus.open,
        title: 'Resolve leave blackout conflicts',
        detail:
            '${leave.blackoutConflictCount} leave request${leave.blackoutConflictCount == 1 ? '' : 's'} overlap blackout coverage.',
        owner: 'People Operations',
        dueDate: cutoffDate.subtract(const Duration(days: 2)),
        payrollImpact: true,
      ),
    );
  }

  if (leave.pendingRequestCount > 0) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'leave-pending-requests',
        source: EmployeePayrollCutoffItemSource.leave,
        severity: EmployeePayrollCutoffItemSeverity.medium,
        status: EmployeePayrollCutoffItemStatus.open,
        title: 'Review pending leave requests',
        detail:
            '${leave.pendingRequestCount} leave request${leave.pendingRequestCount == 1 ? '' : 's'} need approval before payroll calculation.',
        owner: 'People Operations',
        dueDate: cutoffDate.subtract(const Duration(days: 2)),
        payrollImpact: false,
      ),
    );
  }

  if (leave.lowBalanceCount > 0) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'leave-low-balances',
        source: EmployeePayrollCutoffItemSource.leave,
        severity: EmployeePayrollCutoffItemSeverity.low,
        status: EmployeePayrollCutoffItemStatus.open,
        title: 'Review low leave balances',
        detail:
            '${leave.lowBalanceCount} leave balance${leave.lowBalanceCount == 1 ? '' : 's'} are at or below two available days.',
        owner: 'People Operations',
        dueDate: cutoffDate,
        payrollImpact: false,
      ),
    );
  }

  if (items.isEmpty) {
    items.add(
      EmployeePayrollCutoffItem(
        id: 'leave-impact-clear',
        source: EmployeePayrollCutoffItemSource.leave,
        severity: EmployeePayrollCutoffItemSeverity.low,
        status: EmployeePayrollCutoffItemStatus.resolved,
        title: 'Leave impact cleared',
        detail: 'Leave requests and balances do not block payroll cutoff.',
        owner: 'People Operations',
        dueDate: cutoffDate,
        payrollImpact: false,
      ),
    );
  }

  return items;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

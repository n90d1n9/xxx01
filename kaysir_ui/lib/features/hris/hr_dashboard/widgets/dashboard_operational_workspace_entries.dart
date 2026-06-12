import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/attendance/models/attendance_record.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_self_service_summary.dart';
import 'package:kaysir/features/hris/holidays/models/holiday_models.dart';
import 'package:kaysir/features/hris/leave/models/leave_request.dart';
import 'package:kaysir/features/hris/manager/models/manager_models.dart';
import 'package:kaysir/features/hris/payroal/models/payroll_detail.dart';

import '../models/dashboard_workspace_entry.dart';
import '../models/dashboard_workspace_risk_signal.dart';
import '../models/hris_workspace.dart';

class DashboardOperationalWorkspaceSummaries {
  final AttendanceSummary attendance;
  final LeaveSummary leave;
  final HolidaySummary holidays;
  final PayrollSummary payroll;
  final EmployeeDirectorySummary employeeDirectory;
  final EmployeeSelfServiceSummary employeeSelfService;
  final ManagerSelfServiceSummary manager;

  const DashboardOperationalWorkspaceSummaries({
    required this.attendance,
    required this.leave,
    required this.holidays,
    required this.payroll,
    required this.employeeDirectory,
    required this.employeeSelfService,
    required this.manager,
  });
}

List<DashboardWorkspaceEntry> buildOperationalDashboardWorkspaceEntries(
  DashboardOperationalWorkspaceSummaries summaries, {
  Map<HrisWorkspaceId, DashboardWorkspaceRiskSignal> riskSignals = const {},
}) {
  return [
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.attendance),
      description: 'Clock-ins, late arrivals, open records, and history',
      riskSignal: riskSignals[HrisWorkspaceId.attendance],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.task_alt_outlined,
          label: 'Present',
          value: '${summaries.attendance.presentCount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.timelapse_outlined,
          label: 'Late',
          value: '${summaries.attendance.lateCount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.pending_actions_outlined,
          label: 'Open',
          value: '${summaries.attendance.openCount}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.leave),
      description: 'Balances, pending requests, approvals, and days planned',
      riskSignal: riskSignals[HrisWorkspaceId.leave],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Balance',
          value: '${summaries.leave.remainingBalance}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.pending_actions_outlined,
          label: 'Pending',
          value: '${summaries.leave.pendingCount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.check_circle_outline,
          label: 'Approved',
          value: '${summaries.leave.approvedDays}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.holidays),
      description:
          'National, fixed, anniversary, custom days, and coverage planning',
      riskSignal: riskSignals[HrisWorkspaceId.holidays],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.event_available_outlined,
          label: 'Rules',
          value: '${summaries.holidays.totalCount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.upcoming_outlined,
          label: 'Upcoming',
          value: '${summaries.holidays.upcomingCount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.tune_outlined,
          label: 'Custom',
          value: '${summaries.holidays.customCount}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.payroll),
      description: 'Payroll run status, pending payments, and net totals',
      riskSignal: riskSignals[HrisWorkspaceId.payroll],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.groups_outlined,
          label: 'People',
          value: '${summaries.payroll.employeeCount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.pending_actions_outlined,
          label: 'Pending',
          value: '${summaries.payroll.pendingCount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.task_alt_outlined,
          label: 'Paid',
          value: '${summaries.payroll.paidCount}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.employeeDirectory),
      description: 'Profiles, departments, tenure, performance, and watchlist',
      riskSignal: riskSignals[HrisWorkspaceId.employeeDirectory],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.groups_outlined,
          label: 'People',
          value: '${summaries.employeeDirectory.headcount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.account_tree_outlined,
          label: 'Depts',
          value: '${summaries.employeeDirectory.departmentCount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.visibility_outlined,
          label: 'Watch',
          value: '${summaries.employeeDirectory.watchlistCount}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.employeeSelfService),
      description: 'Pay stubs, profile actions, and employee time-off requests',
      riskSignal: riskSignals[HrisWorkspaceId.employeeSelfService],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.receipt_long_outlined,
          label: 'Stubs',
          value: '${summaries.employeeSelfService.payStubCount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.event_available_outlined,
          label: 'Time off',
          value: '${summaries.employeeSelfService.timeOffRequestCount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.pending_actions_outlined,
          label: 'Pending',
          value: '${summaries.employeeSelfService.pendingTimeOffCount}',
        ),
      ],
    ),
    DashboardWorkspaceEntry(
      workspace: hrisWorkspaceById(HrisWorkspaceId.manager),
      description: 'Team health, approval queue, capacity, and action items',
      riskSignal: riskSignals[HrisWorkspaceId.manager],
      metrics: [
        DashboardWorkspaceMetric(
          icon: Icons.groups_outlined,
          label: 'Team',
          value: '${summaries.manager.teamMemberCount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.approval_outlined,
          label: 'Pending',
          value: '${summaries.manager.pendingApprovalCount}',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.warning_amber_outlined,
          label: 'Attention',
          value: '${summaries.manager.attentionCount}',
        ),
      ],
    ),
  ];
}

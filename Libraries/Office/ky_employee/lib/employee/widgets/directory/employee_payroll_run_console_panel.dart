import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_roster_payroll_run_kickoff_models.dart';
import '../../models/employee_payroll_close_models.dart';
import '../../models/employee_payroll_payment_models.dart';
import '../../models/employee_payroll_run_console_audit_models.dart';
import '../../models/employee_payroll_run_console_command_models.dart';
import '../../models/employee_payroll_run_console_models.dart';
import '../../models/employee_payroll_run_models.dart';
import '../../models/employee_payslip_delivery_models.dart';
import 'employee_payroll_run_console_audit_timeline_panel.dart';
import 'employee_payroll_run_console_command_panel.dart';
import 'employee_payroll_close_styles.dart';
import 'employee_payroll_payment_styles.dart';
import 'employee_payroll_run_styles.dart';
import 'employee_payslip_delivery_styles.dart';

/// Directory-level console for a launched payroll run and employee coverage.
class EmployeePayrollRunConsolePanel extends StatelessWidget {
  final EmployeePayrollRunConsoleReview review;
  final Set<String> targetEmployeeIds;
  final List<EmployeePayrollRunConsoleAuditEvent> auditEvents;
  final EmployeePayrollRunConsoleCommandResult? lastCommandResult;
  final ValueChanged<EmployeePayrollRunConsoleCommandType>? onRunCommand;

  const EmployeePayrollRunConsolePanel({
    super.key,
    required this.review,
    this.targetEmployeeIds = const {},
    this.auditEvents = const [],
    this.lastCommandResult,
    this.onRunCommand,
  });

  @override
  Widget build(BuildContext context) {
    final commandPlan = EmployeePayrollRunConsoleCommandPlan.fromReview(
      review,
      targetEmployeeIds: targetEmployeeIds,
    );

    return HrisSectionPanel(
      key: const ValueKey('employee-payroll-run-console-panel'),
      icon: Icons.monitor_heart_outlined,
      title: 'Payroll run console',
      subtitle: review.summaryLabel,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Run',
              value: review.activeRun?.runReference ?? 'None',
            ),
            HrisMetricStripItem(
              label: 'Employees',
              value: '${review.employeeCount}',
            ),
            HrisMetricStripItem(label: 'Export', value: review.exportedLabel),
            HrisMetricStripItem(label: 'Close', value: review.closeLabel),
          ],
        ),
        if (!review.hasActiveRun)
          const HrisListSurface(
            child: Text('Launch payroll run after import validation.'),
          )
        else ...[
          _PayrollRunConsoleOverview(review: review),
          EmployeePayrollRunConsoleCommandPanel(
            plan: commandPlan,
            lastResult: lastCommandResult,
            onRunCommand: onRunCommand,
          ),
          EmployeePayrollRunConsoleAuditTimelinePanel(events: auditEvents),
          _PayrollRunConsoleEmployeeTable(rows: review.rows),
        ],
      ],
    );
  }
}

/// Summary card for active payroll run progress.
class _PayrollRunConsoleOverview extends StatelessWidget {
  final EmployeePayrollRunConsoleReview review;

  const _PayrollRunConsoleOverview({required this.review});

  @override
  Widget build(BuildContext context) {
    final run = review.activeRun!;
    final color = _reviewStatusColor(review);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Run command status',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: review.statusLabel, color: color),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: review.completionRatio,
            color: color,
            label: review.nextAction,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ConsoleMetaChip(
                icon: Icons.badge_outlined,
                label: run.batchLabel,
              ),
              _ConsoleMetaChip(
                icon: Icons.verified_outlined,
                label: run.releaseVersion,
              ),
              _ConsoleMetaChip(icon: Icons.person_outline, label: run.runOwner),
              _ConsoleMetaChip(
                icon: Icons.payments_outlined,
                label: _formatMoney(review.totalNetPay, review.currencyCode),
                color: const Color(0xFF15803D),
              ),
              _ConsoleMetaChip(
                icon: Icons.warning_amber_outlined,
                label: '${review.attentionCount} attention',
                color:
                    review.attentionCount == 0
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB45309),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Scrollable payroll run employee coverage table.
class _PayrollRunConsoleEmployeeTable extends StatelessWidget {
  final List<EmployeePayrollRunConsoleEmployeeRow> rows;

  const _PayrollRunConsoleEmployeeTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const HrisEmptyState(
        message: 'No employee coverage rows for this payroll run',
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: HrisColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          key: const ValueKey('employee-payroll-run-console-horizontal-scroll'),
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 1180,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(HrisColors.surfaceSubtle),
              dataRowMinHeight: 62,
              dataRowMaxHeight: 76,
              columnSpacing: 18,
              horizontalMargin: 16,
              columns: const [
                DataColumn(label: Text('Employee')),
                DataColumn(label: Text('Stage')),
                DataColumn(label: Text('Run')),
                DataColumn(label: Text('Payment')),
                DataColumn(label: Text('Payslip')),
                DataColumn(label: Text('Close')),
                DataColumn(label: Text('Net pay')),
                DataColumn(label: Text('Next action')),
              ],
              rows: rows
                  .map((row) => _buildRow(context, row))
                  .toList(growable: false),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(
    BuildContext context,
    EmployeePayrollRunConsoleEmployeeRow row,
  ) {
    return DataRow(
      key: ValueKey('employee-payroll-run-console-row-${row.employeeId}'),
      cells: [
        DataCell(
          SizedBox(
            width: 150,
            child: Text(
              key: ValueKey(
                'employee-payroll-run-console-name-${row.employeeId}',
              ),
              row.employeeName,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        DataCell(
          HrisStatusPill(label: row.stageLabel, color: _stageColor(row)),
        ),
        DataCell(_runStatusPill(row.runStatus)),
        DataCell(_paymentStatusPill(row.paymentStatus)),
        DataCell(_payslipStatusPill(row.payslipStatus)),
        DataCell(_closeStatusPill(row.closeStatus)),
        DataCell(
          Text(
            _formatMoney(row.netPay, row.currencyCode),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          SizedBox(
            width: 240,
            child: Text(
              row.nextAction,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small metadata chip used in the payroll run console overview.
class _ConsoleMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _ConsoleMetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? HrisColors.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: resolvedColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: resolvedColor),
          const SizedBox(width: 5),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: resolvedColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee payroll run console')
Widget employeePayrollRunConsolePanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunConsolePanel(
          review: EmployeePayrollRunConsoleReview(
            records: [
              EmployeeDirectoryRosterPayrollRunKickoffRecord(
                id: 'payroll-run-kickoff-1',
                validationRecordId: 'payroll-validation-1',
                batchLabel: 'PAY-202605-001',
                releaseVersion: '2026.05.30-001',
                runReference: 'RUN-202605-001',
                runOwner: 'Payroll Lead',
                kickoffNote: 'Funding and payroll controls prepared.',
                launchedAt: DateTime(2026, 5, 30),
                loadedProfileCount: 2,
                validationItemCount: 0,
                payrollImpactCount: 1,
              ),
            ],
            rows: const [
              EmployeePayrollRunConsoleEmployeeRow(
                employeeId: '1',
                employeeName: 'Sarah Johnson',
                runStatus: EmployeePayrollRunStatus.exported,
                paymentStatus: EmployeePayrollPaymentStatus.ready,
                payslipStatus: EmployeePayslipDeliveryStatus.ready,
                closeStatus: EmployeePayrollCloseStatus.blocked,
                exportBatchId: 'RUN-202605-001',
                paymentReference: '',
                nextAction: 'Schedule net pay disbursement.',
                netPay: 25175000,
                currencyCode: 'IDR',
                attentionCount: 1,
              ),
              EmployeePayrollRunConsoleEmployeeRow(
                employeeId: '2',
                employeeName: 'Maya Santoso',
                runStatus: EmployeePayrollRunStatus.blocked,
                paymentStatus: EmployeePayrollPaymentStatus.blocked,
                payslipStatus: EmployeePayslipDeliveryStatus.blocked,
                closeStatus: EmployeePayrollCloseStatus.blocked,
                exportBatchId: '',
                paymentReference: '',
                nextAction: 'Clear payroll run blockers.',
                netPay: 18000000,
                currencyCode: 'IDR',
                attentionCount: 3,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _runStatusPill(EmployeePayrollRunStatus? status) {
  if (status == null) return _emptyPill();
  return HrisStatusPill(
    label: status.label,
    color: employeePayrollRunStatusColor(status),
  );
}

Widget _paymentStatusPill(EmployeePayrollPaymentStatus? status) {
  if (status == null) return _emptyPill();
  return HrisStatusPill(
    label: status.label,
    color: employeePayrollPaymentStatusColor(status),
  );
}

Widget _payslipStatusPill(EmployeePayslipDeliveryStatus? status) {
  if (status == null) return _emptyPill();
  return HrisStatusPill(
    label: status.label,
    color: employeePayslipDeliveryStatusColor(status),
  );
}

Widget _closeStatusPill(EmployeePayrollCloseStatus? status) {
  if (status == null) return _emptyPill();
  return HrisStatusPill(
    label: status.label,
    color: employeePayrollCloseStatusColor(status),
  );
}

Widget _emptyPill() {
  return const HrisStatusPill(label: 'None', color: Color(0xFF6B7280));
}

Color _reviewStatusColor(EmployeePayrollRunConsoleReview review) {
  return switch (review.statusLabel) {
    'Closed' => const Color(0xFF15803D),
    'Close ready' => const Color(0xFF2563EB),
    'Exported' => const Color(0xFF7C3AED),
    'Launched' => const Color(0xFFB45309),
    _ => HrisColors.muted,
  };
}

Color _stageColor(EmployeePayrollRunConsoleEmployeeRow row) {
  if (row.isClosed) return const Color(0xFF15803D);
  if (row.isPaymentPaid && row.isPayslipPublished) {
    return const Color(0xFF2563EB);
  }
  if (row.isExported) return const Color(0xFF7C3AED);
  if (row.runStatus == EmployeePayrollRunStatus.blocked) {
    return const Color(0xFFB91C1C);
  }
  return const Color(0xFFB45309);
}

String _formatMoney(double value, String currencyCode) {
  return NumberFormat.compactCurrency(
    symbol: '${currencyCode.isEmpty ? 'IDR' : currencyCode} ',
    decimalDigits: 1,
  ).format(value);
}

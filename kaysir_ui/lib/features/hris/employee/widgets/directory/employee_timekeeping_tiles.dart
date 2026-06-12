import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_timekeeping_models.dart';
import 'employee_timekeeping_styles.dart';

class EmployeeTimekeepingSummaryStrip extends StatelessWidget {
  final EmployeeTimekeepingProfile profile;

  const EmployeeTimekeepingSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Regular',
          value: profile.totalRegularHours.toStringAsFixed(1),
        ),
        HrisMetricStripItem(
          label: 'Overtime',
          value: profile.totalOvertimeHours.toStringAsFixed(1),
        ),
        HrisMetricStripItem(
          label: 'Exceptions',
          value: '${profile.openExceptionCount}',
        ),
        HrisMetricStripItem(
          label: 'Payroll',
          value: profile.isReadyForPayroll ? 'Ready' : 'Hold',
        ),
      ],
    );
  }
}

class EmployeeTimesheetEntryTile extends StatelessWidget {
  final EmployeeTimesheetEntry entry;
  final VoidCallback onApprove;
  final VoidCallback onPayrollReady;
  final VoidCallback onReject;

  const EmployeeTimesheetEntryTile({
    super.key,
    required this.entry,
    required this.onApprove,
    required this.onPayrollReady,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeTimesheetEntryStatusColor(entry.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('EEE, MMM d').format(entry.workDate),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: entry.status.label, color: color),
            ],
          ),
          const SizedBox(height: 8),
          HrisProgressBar(
            value: entry.totalHours / (entry.scheduledHours + 4),
            color: color,
            label:
                '${entry.totalHours.toStringAsFixed(1)}h worked / ${entry.scheduledHours.toStringAsFixed(1)}h scheduled',
          ),
          const SizedBox(height: 8),
          Text(
            entry.note,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.access_time_outlined,
                label: '${entry.regularHours.toStringAsFixed(1)} regular',
              ),
              _MetaChip(
                icon: Icons.more_time_outlined,
                label: '${entry.overtimeHours.toStringAsFixed(1)} overtime',
                color:
                    entry.hasOvertime
                        ? const Color(0xFFB45309)
                        : HrisColors.muted,
              ),
              _MetaChip(
                icon: Icons.coffee_outlined,
                label: '${entry.breakMinutes}m break',
              ),
              OutlinedButton.icon(
                onPressed:
                    entry.status == EmployeeTimesheetEntryStatus.submitted ||
                            entry.status ==
                                EmployeeTimesheetEntryStatus.rejected
                        ? onApprove
                        : null,
                icon: const Icon(Icons.thumb_up_alt_outlined),
                label: const Text('Approve'),
              ),
              FilledButton.tonalIcon(
                onPressed: entry.isApproved ? onPayrollReady : null,
                icon: const Icon(Icons.price_check_outlined),
                label: const Text('Payroll'),
              ),
              TextButton.icon(
                onPressed: entry.isPayrollReady ? null : onReject,
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeeTimekeepingExceptionTile extends StatelessWidget {
  final EmployeeTimekeepingException exception;
  final DateTime asOfDate;
  final VoidCallback onReview;
  final VoidCallback onResolve;
  final VoidCallback onWaive;

  const EmployeeTimekeepingExceptionTile({
    super.key,
    required this.exception,
    required this.asOfDate,
    required this.onReview,
    required this.onResolve,
    required this.onWaive,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = exception.isOverdue(asOfDate);
    final severityColor = employeeTimekeepingExceptionSeverityColor(
      exception.severity,
    );
    final statusColor =
        overdue
            ? const Color(0xFFB91C1C)
            : employeeTimekeepingExceptionStatusColor(exception.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              employeeTimekeepingExceptionTypeIcon(exception.type),
              color: severityColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exception.type.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(
                      label: overdue ? 'Overdue' : exception.status.label,
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  exception.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.person_outline,
                      label: exception.owner,
                    ),
                    _MetaChip(
                      icon: Icons.event_outlined,
                      label: DateFormat('MMM d').format(exception.workDate),
                    ),
                    _MetaChip(
                      icon: Icons.timer_outlined,
                      label: '${exception.minutesImpact}m impact',
                      color: severityColor,
                    ),
                    if (exception.payrollImpact)
                      const _MetaChip(
                        icon: Icons.payments_outlined,
                        label: 'Payroll impact',
                        color: Color(0xFFB91C1C),
                      ),
                    OutlinedButton.icon(
                      onPressed:
                          exception.status ==
                                  EmployeeTimekeepingExceptionStatus.open
                              ? onReview
                              : null,
                      icon: const Icon(Icons.manage_search_outlined),
                      label: const Text('Review'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: exception.isClosed ? null : onResolve,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Resolve'),
                    ),
                    TextButton.icon(
                      onPressed: exception.isClosed ? null : onWaive,
                      icon: const Icon(Icons.do_disturb_on_outlined),
                      label: const Text('Waive'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

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

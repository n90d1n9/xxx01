import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_schedule_models.dart';
import 'employee_schedule_styles.dart';

class EmployeeScheduleSummaryStrip extends StatelessWidget {
  final EmployeeScheduleProfile profile;

  const EmployeeScheduleSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Pattern',
          value: profile.assignment.pattern.label,
        ),
        HrisMetricStripItem(
          label: 'Hours',
          value: profile.assignment.weeklyHours.toStringAsFixed(0),
        ),
        HrisMetricStripItem(
          label: 'Signals',
          value: '${profile.attendanceRiskCount}',
        ),
        HrisMetricStripItem(
          label: 'Pending',
          value: '${profile.pendingAdjustmentCount}',
        ),
      ],
    );
  }
}

class EmployeeScheduleAssignmentCard extends StatelessWidget {
  final EmployeeScheduleAssignment assignment;

  const EmployeeScheduleAssignmentCard({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: HrisColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              employeeSchedulePatternIcon(assignment.pattern),
              color: HrisColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${assignment.pattern.label} schedule',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${assignment.daysLabel} - ${assignment.hoursLabel}',
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
                      icon: Icons.place_outlined,
                      label: assignment.location,
                    ),
                    _MetaChip(
                      icon: Icons.public_outlined,
                      label: assignment.timezone,
                    ),
                    _MetaChip(
                      icon: Icons.event_available_outlined,
                      label:
                          'From ${DateFormat('MMM d, yyyy').format(assignment.effectiveFrom)}',
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

class EmployeeAttendanceSignalTile extends StatelessWidget {
  final EmployeeAttendanceSignal signal;
  final VoidCallback onResolve;

  const EmployeeAttendanceSignalTile({
    super.key,
    required this.signal,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        signal.resolved
            ? const Color(0xFF15803D)
            : employeeAttendanceSeverityColor(signal.severity);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeAttendanceSignalTypeIcon(signal.type),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      signal.type.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('MMM d, yyyy').format(signal.date),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label: signal.resolved ? 'Resolved' : signal.severity.label,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            signal.note,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.timelapse_outlined,
                label: '${signal.minutesVariance} min',
              ),
              if (!signal.resolved)
                FilledButton.tonalIcon(
                  onPressed: onResolve,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Resolve'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeeScheduleAdjustmentTile extends StatelessWidget {
  final EmployeeScheduleAdjustmentRequest request;
  final VoidCallback onApprove;
  final VoidCallback onApply;

  const EmployeeScheduleAdjustmentTile({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeScheduleAdjustmentStatusColor(request.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeScheduleAdjustmentTypeIcon(request.type),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.type.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${DateFormat('MMM d, yyyy').format(request.targetDate)} - ${request.startTimeLabel}-${request.endTimeLabel}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: request.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.reason,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(icon: Icons.place_outlined, label: request.location),
                if (request.canApprove)
                  FilledButton.tonalIcon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Approve'),
                  ),
                if (request.canApply)
                  FilledButton.icon(
                    onPressed: onApply,
                    icon: const Icon(Icons.assignment_turned_in_outlined),
                    label: const Text('Apply'),
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

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: HrisColors.muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: HrisColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

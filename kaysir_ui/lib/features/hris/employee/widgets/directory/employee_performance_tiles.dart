import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_performance_models.dart';
import 'employee_performance_styles.dart';

class EmployeePerformanceSummaryStrip extends StatelessWidget {
  final EmployeePerformancePlan plan;

  const EmployeePerformanceSummaryStrip({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Progress',
          value: '${(plan.weightedProgress * 100).round()}%',
        ),
        HrisMetricStripItem(label: 'At risk', value: '${plan.atRiskGoalCount}'),
        HrisMetricStripItem(
          label: 'Complete',
          value: '${plan.completeGoalCount}',
        ),
        HrisMetricStripItem(
          label: 'Check-ins',
          value: '${plan.checkIns.length}',
        ),
      ],
    );
  }
}

class EmployeePerformanceCycleCard extends StatelessWidget {
  final EmployeePerformancePlan plan;

  const EmployeePerformanceCycleCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final status = plan.cycleStatus;
    final color = employeePerformanceCycleStatusColor(status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.cycleName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: plan.weightedProgress,
            color: color,
            label: 'Weighted goal progress',
          ),
          const SizedBox(height: 8),
          Text(
            'Review due ${DateFormat('MMM d, yyyy').format(plan.reviewDueDate)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

class EmployeePerformanceGoalTile extends StatelessWidget {
  final EmployeePerformanceGoal goal;
  final DateTime asOfDate;
  final VoidCallback onNudgeProgress;
  final VoidCallback onComplete;
  final ValueChanged<EmployeePerformanceGoalStatus> onStatusChanged;

  const EmployeePerformanceGoalTile({
    super.key,
    required this.goal,
    required this.asOfDate,
    required this.onNudgeProgress,
    required this.onComplete,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeePerformanceGoalStatusColor(goal.status);
    final overdue = goal.isOverdue(asOfDate);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: goal.status.label, color: color),
            ],
          ),
          const SizedBox(height: 8),
          HrisProgressBar(
            value: goal.progress,
            color: overdue ? const Color(0xFFB91C1C) : color,
            label:
                '${(goal.progress * 100).round()}% progress - weight ${goal.weight}%',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.person_outline, label: goal.owner),
              _MetaChip(
                icon: Icons.event_outlined,
                label: DateFormat('MMM d').format(goal.targetDate),
                color: overdue ? const Color(0xFFB91C1C) : null,
              ),
              OutlinedButton.icon(
                onPressed: goal.isComplete ? null : onNudgeProgress,
                icon: const Icon(Icons.add_outlined),
                label: const Text('10%'),
              ),
              FilledButton.tonalIcon(
                onPressed: goal.isComplete ? null : onComplete,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Complete'),
              ),
              PopupMenuButton<EmployeePerformanceGoalStatus>(
                tooltip: 'Set goal status',
                onSelected: onStatusChanged,
                itemBuilder:
                    (context) =>
                        EmployeePerformanceGoalStatus.values
                            .map(
                              (status) => PopupMenuItem(
                                value: status,
                                child: Text(status.label),
                              ),
                            )
                            .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeePerformanceCheckInTile extends StatelessWidget {
  final EmployeePerformanceCheckIn checkIn;

  const EmployeePerformanceCheckInTile({super.key, required this.checkIn});

  @override
  Widget build(BuildContext context) {
    final color = employeePerformanceSentimentColor(checkIn.sentiment);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              employeePerformanceSentimentIcon(checkIn.sentiment),
              color: color,
              size: 19,
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
                        '${checkIn.author} - ${DateFormat('MMM d').format(checkIn.date)}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(
                      label: checkIn.sentiment.label,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  checkIn.summary,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 6),
                Text(
                  'Next: ${checkIn.nextStep}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: resolvedColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: resolvedColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

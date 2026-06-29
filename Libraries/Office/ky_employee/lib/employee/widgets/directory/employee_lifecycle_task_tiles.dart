import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_lifecycle_task_models.dart';
import 'employee_lifecycle_task_styles.dart';

class EmployeeLifecycleTaskTile extends StatelessWidget {
  final EmployeeLifecycleTask task;
  final DateTime asOfDate;
  final ValueChanged<EmployeeLifecycleTaskStatus> onStatusChanged;
  final VoidCallback onRemove;

  const EmployeeLifecycleTaskTile({
    super.key,
    required this.task,
    required this.asOfDate,
    required this.onStatusChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeLifecycleTaskStatusColor(task.status);
    final priorityColor = employeeLifecycleTaskPriorityColor(task.priority);
    final isOverdue = task.isOverdue(asOfDate);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              employeeLifecycleTaskStatusIcon(task.status),
              color: statusColor,
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
                        task.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(
                      label: task.status.label,
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _TaskMetaChip(
                      icon: Icons.person_outline,
                      label: task.owner,
                    ),
                    _TaskMetaChip(
                      icon: Icons.event_outlined,
                      label: DateFormat('MMM d').format(task.dueDate),
                      color:
                          isOverdue
                              ? const Color(0xFFB91C1C)
                              : HrisColors.muted,
                    ),
                    _TaskMetaChip(
                      icon: Icons.flag_outlined,
                      label: task.priority.label,
                      color: priorityColor,
                    ),
                  ],
                ),
                if (isOverdue) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Overdue',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<EmployeeLifecycleTaskStatus>(
            tooltip: 'Update status',
            icon: const Icon(Icons.more_horiz_outlined),
            onSelected: onStatusChanged,
            itemBuilder:
                (context) => [
                  ...EmployeeLifecycleTaskStatus.values.map(
                    (status) =>
                        PopupMenuItem(value: status, child: Text(status.label)),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: task.status,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRemove();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove task'),
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }
}

class EmployeeLifecyclePlanSummaryStrip extends StatelessWidget {
  final EmployeeLifecyclePlan plan;

  const EmployeeLifecyclePlanSummaryStrip({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Open', value: '${plan.openCount}'),
        HrisMetricStripItem(label: 'Blocked', value: '${plan.blockedCount}'),
        HrisMetricStripItem(label: 'Overdue', value: '${plan.overdueCount}'),
        HrisMetricStripItem(label: 'Done', value: '${plan.doneCount}'),
      ],
    );
  }
}

class _TaskMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _TaskMetaChip({required this.icon, required this.label, this.color});

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

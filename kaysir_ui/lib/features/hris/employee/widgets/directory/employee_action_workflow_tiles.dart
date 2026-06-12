import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_action_workflow_models.dart';
import 'employee_action_workflow_styles.dart';
import 'employee_next_action_styles.dart';

class EmployeeActionWorkflowSummaryStrip extends StatelessWidget {
  final EmployeeActionWorkflowProfile profile;

  const EmployeeActionWorkflowSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Open', value: '${profile.openCount}'),
            HrisMetricStripItem(
              label: 'Active',
              value: '${profile.inProgressCount}',
            ),
            HrisMetricStripItem(
              label: 'Overdue',
              value: '${profile.overdueCount}',
            ),
            HrisMetricStripItem(
              label: 'Done',
              value: '${profile.completedCount}',
            ),
          ],
        ),
        const SizedBox(height: 10),
        HrisProgressBar(
          value: profile.completionRatio,
          color: const Color(0xFF15803D),
          label:
              '${(profile.completionRatio * 100).round()}% workflow complete',
        ),
      ],
    );
  }
}

class EmployeeActionWorkflowTaskTile extends StatelessWidget {
  final EmployeeActionTask task;
  final DateTime asOfDate;
  final VoidCallback onStart;
  final VoidCallback onWait;
  final VoidCallback onComplete;
  final VoidCallback onReopen;
  final VoidCallback onCancel;

  const EmployeeActionWorkflowTaskTile({
    super.key,
    required this.task,
    required this.asOfDate,
    required this.onStart,
    required this.onWait,
    required this.onComplete,
    required this.onReopen,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeActionTaskStatusColor(task.status);
    final priorityColor = employeeNextActionPriorityColor(task.priority);
    final areaIcon = employeeNextActionAreaIcon(task.area);
    final overdue = task.isOverdue(asOfDate);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeActionTaskStatusIcon(task.status),
                  color: statusColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: task.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              HrisStatusPill(label: task.priority.label, color: priorityColor),
              _MetaChip(icon: areaIcon, label: task.area.label),
              _MetaChip(
                icon: Icons.person_outline,
                label: task.owner,
                color: HrisColors.ink,
              ),
              _MetaChip(
                icon: Icons.hub_outlined,
                label: task.sourceLabel,
                color: HrisColors.muted,
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: 'Due ${_formatDate(task.dueDate)}',
                color: overdue ? const Color(0xFFB91C1C) : statusColor,
              ),
              if (task.completedAt != null)
                _MetaChip(
                  icon: Icons.verified_outlined,
                  label: 'Done ${_formatDate(task.completedAt!)}',
                  color: const Color(0xFF15803D),
                ),
            ],
          ),
          if (_hasActions) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (task.canStart)
                  FilledButton.tonalIcon(
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: const Text('Start'),
                  ),
                if (task.canWait)
                  OutlinedButton.icon(
                    onPressed: onWait,
                    icon: const Icon(Icons.hourglass_top_outlined),
                    label: const Text('Wait'),
                  ),
                if (task.canComplete)
                  FilledButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Complete'),
                  ),
                if (task.canReopen)
                  OutlinedButton.icon(
                    onPressed: onReopen,
                    icon: const Icon(Icons.restart_alt_outlined),
                    label: const Text('Reopen'),
                  ),
                if (!task.isClosed)
                  OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasActions {
    return task.canStart ||
        task.canWait ||
        task.canComplete ||
        task.canReopen ||
        !task.isClosed;
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? HrisColors.muted;

    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: chipColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: chipColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

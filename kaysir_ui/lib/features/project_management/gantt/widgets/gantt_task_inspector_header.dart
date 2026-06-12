import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_task_context_label_service.dart';

class GanttTaskInspectorHeader extends StatelessWidget {
  const GanttTaskInspectorHeader({
    required this.task,
    required this.onDismiss,
    this.projectName,
    this.dependencyTitle,
    this.taskPositionLabel,
    this.previousTaskTitle,
    this.nextTaskTitle,
    this.previousTaskButtonKey,
    this.nextTaskButtonKey,
    this.onPreviousTask,
    this.onNextTask,
    super.key,
  });

  final gantt.GanttTask task;
  final String? projectName;
  final String? dependencyTitle;
  final String? taskPositionLabel;
  final String? previousTaskTitle;
  final String? nextTaskTitle;
  final Key? previousTaskButtonKey;
  final Key? nextTaskButtonKey;
  final VoidCallback? onPreviousTask;
  final VoidCallback? onNextTask;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const pillPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 3);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.manage_search_outlined, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Task Inspector',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        task.title,
                        if (taskPositionLabel != null) taskPositionLabel!,
                      ].join(' - '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: previousTaskButtonKey,
                tooltip:
                    previousTaskTitle == null
                        ? 'No previous visible task'
                        : 'Previous task: $previousTaskTitle',
                onPressed: onPreviousTask,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                key: nextTaskButtonKey,
                tooltip:
                    nextTaskTitle == null
                        ? 'No next visible task'
                        : 'Next task: $nextTaskTitle',
                onPressed: onNextTask,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
              IconButton(
                tooltip: 'Close inspector',
                onPressed: onDismiss,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppStatusPill(
                label: ganttTaskScheduleStatusContextLabel(task),
                icon: Icons.flag_outlined,
                color: _statusColor(colorScheme),
                maxWidth: 130,
                padding: pillPadding,
              ),
              if (projectName != null)
                AppStatusPill(
                  label: projectName!,
                  icon: Icons.workspaces_outline,
                  color: colorScheme.primary,
                  maxWidth: 190,
                  padding: pillPadding,
                ),
              AppStatusPill(
                label: ganttTaskProgressContextLabel(task),
                icon: Icons.trending_up_rounded,
                color: _progressColor(colorScheme, task.progress),
                maxWidth: 140,
                padding: pillPadding,
              ),
              AppStatusPill(
                label: ganttTaskScheduleContextLabel(task),
                icon:
                    task.isMilestone
                        ? Icons.diamond_outlined
                        : Icons.event_outlined,
                color: colorScheme.secondary,
                maxWidth: 180,
                padding: pillPadding,
              ),
              if (dependencyTitle != null)
                AppStatusPill(
                  label: ganttTaskDependencyContextLabel(dependencyTitle!),
                  icon: Icons.link_rounded,
                  color: colorScheme.tertiary,
                  maxWidth: 190,
                  padding: pillPadding,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(ColorScheme colorScheme) {
    if (task.progress >= 1) return Colors.green.shade700;
    if (task.progress <= 0) return colorScheme.onSurfaceVariant;
    return colorScheme.primary;
  }

  Color _progressColor(ColorScheme colorScheme, double progress) {
    if (progress >= 1) return Colors.green.shade700;
    if (progress <= 0) return colorScheme.onSurfaceVariant;
    return colorScheme.primary;
  }
}

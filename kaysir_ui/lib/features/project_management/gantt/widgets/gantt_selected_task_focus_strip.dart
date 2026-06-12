import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_task_context_label_service.dart';

/// Responsive strip summarizing the selected task and recovery actions.
class GanttSelectedTaskFocusStrip extends StatelessWidget {
  const GanttSelectedTaskFocusStrip({
    required this.task,
    required this.hiddenByFilters,
    required this.onInspectTask,
    required this.onClearSelection,
    this.projectName,
    this.dependencyTitle,
    super.key,
  });

  static const inspectButtonKey = ValueKey(
    'gantt-selected-task-inspect-button',
  );
  static const revealButtonKey = ValueKey('gantt-selected-task-reveal-button');
  static const clearButtonKey = ValueKey('gantt-selected-task-clear-button');

  final gantt.GanttTask? task;
  final bool hiddenByFilters;
  final String? projectName;
  final String? dependencyTitle;
  final VoidCallback? onInspectTask;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    final task = this.task;
    if (task == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final accent = hiddenByFilters ? colorScheme.tertiary : colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.07),
          border: Border.all(color: accent.withValues(alpha: 0.22)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 760;
              final summary = _SelectedTaskSummary(
                task: task,
                projectName: projectName,
                dependencyTitle: dependencyTitle,
                hiddenByFilters: hiddenByFilters,
                accent: accent,
              );
              final actions = _SelectedTaskActions(
                hiddenByFilters: hiddenByFilters,
                onInspectTask: onInspectTask,
                onClearSelection: onClearSelection,
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    summary,
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerLeft, child: actions),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: summary),
                  const SizedBox(width: 16),
                  actions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Status and context summary for the selected task strip.
class _SelectedTaskSummary extends StatelessWidget {
  const _SelectedTaskSummary({
    required this.task,
    required this.hiddenByFilters,
    required this.accent,
    this.projectName,
    this.dependencyTitle,
  });

  final gantt.GanttTask task;
  final bool hiddenByFilters;
  final Color accent;
  final String? projectName;
  final String? dependencyTitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              hiddenByFilters
                  ? Icons.visibility_off_outlined
                  : Icons.ads_click_rounded,
              size: 20,
              color: accent,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppStatusPill(
              label: hiddenByFilters ? 'Hidden by filters' : 'Selected task',
              icon:
                  hiddenByFilters
                      ? Icons.filter_alt_outlined
                      : Icons.task_alt_rounded,
              color: accent,
              maxWidth: 180,
            ),
            if (projectName != null)
              AppStatusPill(
                label: projectName!,
                icon: Icons.workspaces_outline,
                color: colorScheme.primary,
                maxWidth: 220,
              ),
            AppStatusPill(
              label: ganttTaskProgressContextLabel(task),
              icon: Icons.trending_up_rounded,
              color: _progressColor(colorScheme, task.progress),
              maxWidth: 180,
            ),
            AppStatusPill(
              label: ganttTaskScheduleContextLabel(task),
              icon:
                  task.isMilestone
                      ? Icons.diamond_outlined
                      : Icons.event_outlined,
              color: colorScheme.secondary,
              maxWidth: 220,
            ),
            if (dependencyTitle != null)
              AppStatusPill(
                label: ganttTaskDependencyContextLabel(dependencyTitle!),
                icon: Icons.link_rounded,
                color: colorScheme.tertiary,
                maxWidth: 220,
              ),
          ],
        ),
      ],
    );
  }

  Color _progressColor(ColorScheme colorScheme, double progress) {
    if (progress >= 1) return Colors.green.shade700;
    if (progress <= 0) return colorScheme.onSurfaceVariant;
    return colorScheme.primary;
  }
}

/// Action buttons for inspecting/revealing or clearing the selected task.
class _SelectedTaskActions extends StatelessWidget {
  const _SelectedTaskActions({
    required this.hiddenByFilters,
    required this.onInspectTask,
    required this.onClearSelection,
  });

  final bool hiddenByFilters;
  final VoidCallback? onInspectTask;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppActionButton(
          key:
              hiddenByFilters
                  ? GanttSelectedTaskFocusStrip.revealButtonKey
                  : GanttSelectedTaskFocusStrip.inspectButtonKey,
          label: hiddenByFilters ? 'Reveal Task' : 'Inspect Task',
          icon:
              hiddenByFilters
                  ? Icons.visibility_outlined
                  : Icons.open_in_new_rounded,
          compact: true,
          variant: AppActionButtonVariant.secondary,
          onPressed: onInspectTask,
        ),
        AppActionButton(
          key: GanttSelectedTaskFocusStrip.clearButtonKey,
          label: 'Clear Selection',
          icon: Icons.close_rounded,
          compact: true,
          variant: AppActionButtonVariant.text,
          onPressed: onClearSelection,
        ),
      ],
    );
  }
}

@Preview(name: 'Gantt selected task focus strip')
Widget ganttSelectedTaskFocusStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GanttSelectedTaskFocusStrip(
          task: gantt.GanttTask(
            id: 'planning',
            title: 'Project Planning',
            startDate: DateTime(2026, 1, 5),
            endDate: DateTime(2026, 1, 12),
            progress: 0.4,
            dependsOn: 'brief',
            projectId: 'retail',
          ),
          hiddenByFilters: true,
          projectName: 'Retail Modernization',
          dependencyTitle: 'Discovery Brief',
          onInspectTask: () {},
          onClearSelection: () {},
        ),
      ),
    ),
  );
}

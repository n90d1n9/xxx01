import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_dependency_service.dart';
import '../services/gantt_schedule_dependency_impact_service.dart';
import '../services/gantt_schedule_focus_service.dart';
import '../services/gantt_schedule_recovery_brief_service.dart';

class GanttScheduleFocusPanel extends StatefulWidget {
  const GanttScheduleFocusPanel({
    required this.tasks,
    this.dependencyTasks,
    this.projectNamesById = const {},
    this.scopeLabel = 'Roadmap',
    this.today,
    this.maxItems = 5,
    this.onTaskSelected,
    this.onProjectSelected,
    super.key,
  });

  final List<gantt.GanttTask> tasks;
  final List<gantt.GanttTask>? dependencyTasks;
  final Map<String, String> projectNamesById;
  final String scopeLabel;
  final DateTime? today;
  final int maxItems;
  final ValueChanged<String>? onTaskSelected;
  final ValueChanged<String>? onProjectSelected;

  @override
  State<GanttScheduleFocusPanel> createState() =>
      _GanttScheduleFocusPanelState();
}

class _GanttScheduleFocusPanelState extends State<GanttScheduleFocusPanel> {
  var _briefCopied = false;

  @override
  Widget build(BuildContext context) {
    final summary = buildGanttScheduleFocusSummary(
      tasks: widget.tasks,
      today: widget.today,
    );

    if (summary.totalTasks == 0) {
      return const AppEmptyState(
        icon: Icons.crisis_alert_outlined,
        title: 'No schedule focus yet',
        message: 'Timeline tasks will appear here once a schedule is linked.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.level.color(colorScheme);
    final visibleItems =
        summary.prioritizedItems.take(widget.maxItems).toList();
    final dependencyImpactSummary = buildGanttScheduleDependencyImpactSummary(
      focusItems: visibleItems,
      dependencyTasks: widget.dependencyTasks ?? widget.tasks,
      today: widget.today,
    );
    final dependencyImpactByTaskId = {
      for (final impact in dependencyImpactSummary.items)
        impact.focusItem.task.id: impact,
    };
    final recoveryBrief = buildGanttScheduleRecoveryBrief(
      tasks: widget.tasks,
      dependencyTasks: widget.dependencyTasks,
      projectNamesById: widget.projectNamesById,
      scopeLabel: widget.scopeLabel,
      today: widget.today,
      maxItems: widget.maxItems,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: 'Schedule ${summary.level.label}',
          subtitle:
              summary.focusCount == 0
                  ? '${summary.totalTasks} tracked tasks are clear for the current window.'
                  : '${summary.focusCount} focus items across ${summary.totalTasks} tracked tasks.',
          icon: summary.level.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.12),
          iconForegroundColor: signalColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.level.label,
            icon: summary.level.icon,
            color: signalColor,
            maxWidth: 128,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 5,
          metrics: [
            AppMetricGridItem(
              title: 'Overdue',
              value: summary.overdueCount.toString(),
              icon: Icons.event_busy_outlined,
              accentColor:
                  summary.overdueCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
            ),
            AppMetricGridItem(
              title: 'Behind',
              value: summary.behindCount.toString(),
              icon: Icons.trending_down_rounded,
              accentColor:
                  summary.behindCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
            ),
            AppMetricGridItem(
              title: 'Starting Soon',
              value: summary.startingSoonCount.toString(),
              icon: Icons.upcoming_outlined,
              accentColor: colorScheme.primary,
            ),
            AppMetricGridItem(
              title: 'Focus Items',
              value: summary.focusCount.toString(),
              icon: Icons.radar_outlined,
              accentColor: signalColor,
            ),
            AppMetricGridItem(
              title: 'Dependencies',
              value: dependencyImpactSummary.impactCount.toString(),
              helper: dependencyImpactSummary.metricHelper,
              icon: Icons.account_tree_outlined,
              accentColor: _dependencyImpactColor(
                dependencyImpactSummary,
                colorScheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleItems.isEmpty)
          AppInfoRow(
            title: 'No immediate schedule focus',
            subtitle: 'Keep the current cadence and review again next cycle.',
            icon: Icons.check_circle_outline,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
            iconBackgroundColor: Colors.green.shade700.withValues(alpha: 0.12),
            iconForegroundColor: Colors.green.shade700,
            titleMaxLines: 1,
            subtitleMaxLines: 2,
          )
        else
          for (var index = 0; index < visibleItems.length; index++) ...[
            _GanttScheduleFocusRow(
              item: visibleItems[index],
              projectName:
                  widget.projectNamesById[visibleItems[index].task.projectId],
              dependencyImpact:
                  dependencyImpactByTaskId[visibleItems[index].task.id],
              onTaskSelected:
                  widget.onTaskSelected == null
                      ? null
                      : () =>
                          widget.onTaskSelected!(visibleItems[index].task.id),
              onProjectSelected: _projectActionFor(visibleItems[index].task),
            ),
            if (index != visibleItems.length - 1) const SizedBox(height: 10),
          ],
        const SizedBox(height: 12),
        AppCopyBriefCard(
          title: 'Recovery brief',
          text: recoveryBrief.briefText,
          icon: Icons.assignment_returned_outlined,
          copied: _briefCopied,
          onCopy: () => _copyBrief(recoveryBrief.briefText),
        ),
      ],
    );
  }

  VoidCallback? _projectActionFor(gantt.GanttTask task) {
    final projectId = task.projectId;
    if (projectId == null || projectId.isEmpty) return null;

    final onProjectSelected = widget.onProjectSelected;
    if (onProjectSelected == null) return null;

    return () => onProjectSelected(projectId);
  }

  Future<void> _copyBrief(String briefText) async {
    await Clipboard.setData(ClipboardData(text: briefText));
    if (!mounted) return;

    setState(() => _briefCopied = true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Recovery brief copied')));
  }
}

class _GanttScheduleFocusRow extends StatelessWidget {
  const _GanttScheduleFocusRow({
    required this.item,
    required this.projectName,
    required this.dependencyImpact,
    required this.onTaskSelected,
    required this.onProjectSelected,
  });

  final GanttScheduleFocusItem item;
  final String? projectName;
  final GanttScheduleDependencyImpactItem? dependencyImpact;
  final VoidCallback? onTaskSelected;
  final VoidCallback? onProjectSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = item.level.color(colorScheme);

    return AppInfoRow(
      title: item.task.title,
      subtitle: [
        if (projectName != null) projectName!,
        ganttScheduleFocusDetail(item),
      ].join(' - '),
      icon: item.level.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: levelColor.withValues(alpha: 0.12),
      iconForegroundColor: levelColor,
      titleMaxLines: 1,
      subtitleMaxLines: 2,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppStatusPill(
            label: item.level.label,
            icon: item.level.icon,
            color: levelColor,
            maxWidth: 112,
          ),
          if (dependencyImpact != null)
            AppStatusPill(
              label: '${dependencyImpact!.insight.health.label} dep',
              icon: dependencyImpact!.insight.health.icon,
              color: dependencyImpact!.insight.health.color(colorScheme),
              tooltip: dependencyImpact!.insight.detail,
              maxWidth: 128,
            ),
          if (onTaskSelected != null)
            AppActionButton(
              label: 'Inspect',
              icon: Icons.manage_search_outlined,
              compact: true,
              variant: AppActionButtonVariant.secondary,
              onPressed: onTaskSelected,
            ),
          if (onProjectSelected != null)
            AppActionButton(
              label: 'Project',
              icon: Icons.workspaces_outline,
              compact: true,
              variant: AppActionButtonVariant.secondary,
              onPressed: onProjectSelected,
            ),
        ],
      ),
    );
  }
}

Color _dependencyImpactColor(
  GanttScheduleDependencyImpactSummary summary,
  ColorScheme colorScheme,
) {
  final leadingHealth = summary.leadingHealth;
  if (leadingHealth == null) return Colors.green.shade700;

  return leadingHealth.color(colorScheme);
}

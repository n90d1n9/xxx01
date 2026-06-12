import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_toggle_row.dart';

import '../services/gantt_taskbar_visual_presentation_service.dart';
import '../states/gantt_chart_display_provider.dart';
import 'gantt_segmented_option_tile.dart';

List<Widget> ganttChartTaskBarOptionTiles({
  required BuildContext context,
  required GanttChartDisplayPreferences displayPreferences,
  required ValueChanged<GanttChartDisplayPreferences> onDisplayChanged,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return [
    AppToggleRow(
      title: 'Status Badges',
      subtitle: 'Show progress status on taskbars',
      icon: Icons.label_important_outline,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showTaskBarStatusLabels,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showTaskBarStatusLabels: value),
          ),
    ),
    AppToggleRow(
      title: 'Schedule Badges',
      subtitle: 'Flag planned, due, overdue, and complete work',
      icon: Icons.timelapse_rounded,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showTaskBarScheduleBadges,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showTaskBarScheduleBadges: value),
          ),
    ),
    GanttSegmentedOptionTile<GanttTaskBarScheduleBadgeStyle>(
      title: 'Badge Style',
      subtitle: ganttTaskBarScheduleBadgeStyleSettingsSubtitle(),
      icon: Icons.label_outline_rounded,
      value: displayPreferences.taskBarScheduleBadgeStyle,
      enabled: displayPreferences.showTaskBarScheduleBadges,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttTaskBarScheduleBadgeStylePresentations)
          ButtonSegment(
            value: presentation.style,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(taskBarScheduleBadgeStyle: value),
          ),
    ),
    AppToggleRow(
      title: 'Date Labels',
      subtitle: 'Show schedule dates on wide taskbars',
      icon: Icons.event_note_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showTaskBarDateLabels,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showTaskBarDateLabels: value),
          ),
    ),
    AppToggleRow(
      title: 'Duration Labels',
      subtitle: 'Show task length on wide taskbars',
      icon: Icons.timer_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showTaskBarDurationLabels,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showTaskBarDurationLabels: value),
          ),
    ),
    AppToggleRow(
      title: 'Dependency Badges',
      subtitle: 'Show predecessor links on taskbars',
      icon: Icons.account_tree_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showTaskBarDependencyBadges,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showTaskBarDependencyBadges: value),
          ),
    ),
    AppToggleRow(
      title: 'Dependency Risks',
      subtitle: 'Flag tasks that start before predecessors finish',
      icon: Icons.warning_amber_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showTaskBarDependencyConflictBadges,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(
              showTaskBarDependencyConflictBadges: value,
            ),
          ),
    ),
    AppToggleRow(
      title: 'Progress Labels',
      subtitle: 'Show percent complete on taskbars',
      icon: Icons.percent_rounded,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showTaskBarProgressLabels,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showTaskBarProgressLabels: value),
          ),
    ),
  ];
}

import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_toggle_row.dart';

import '../services/gantt_identity_presentation_service.dart';
import '../states/gantt_chart_display_provider.dart';
import 'gantt_segmented_option_tile.dart';

List<Widget> ganttChartIdentityOptionTiles({
  required BuildContext context,
  required GanttChartDisplayPreferences displayPreferences,
  required ValueChanged<GanttChartDisplayPreferences> onDisplayChanged,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return [
    AppToggleRow(
      title: 'Team Avatars',
      subtitle: 'Show assigned team on taskbars',
      icon: Icons.groups_2_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showTeamAvatars,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showTeamAvatars: value),
          ),
    ),
    AppToggleRow(
      title: 'Task Tooltip',
      subtitle: 'Reveal task metadata on hover',
      icon: Icons.info_outline_rounded,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showTaskBarTooltips,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showTaskBarTooltips: value),
          ),
    ),
    GanttSegmentedOptionTile<GanttTaskBarTooltipDetail>(
      title: 'Tooltip Detail',
      subtitle: ganttTaskBarTooltipDetailSettingsSubtitle(),
      icon: Icons.article_outlined,
      value: displayPreferences.taskBarTooltipDetail,
      enabled: displayPreferences.showTaskBarTooltips,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttTaskBarTooltipDetailPresentations)
          ButtonSegment(
            value: presentation.detail,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(taskBarTooltipDetail: value),
          ),
    ),
    GanttSegmentedOptionTile<int>(
      title: 'Avatar Count',
      subtitle: ganttTeamAvatarCountSettingsSubtitle(),
      icon: Icons.group_work_outlined,
      value: displayPreferences.visibleTeamAvatarLimit,
      enabled: displayPreferences.showTeamAvatars,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttTeamAvatarCountPresentations)
          ButtonSegment(
            value: presentation.count,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(maxTeamAvatars: value),
          ),
    ),
    GanttSegmentedOptionTile<GanttTeamAvatarStyle>(
      title: 'Avatar Style',
      subtitle: ganttTeamAvatarStyleSettingsSubtitle(),
      icon: Icons.badge_outlined,
      value: displayPreferences.teamAvatarStyle,
      enabled: displayPreferences.showTeamAvatars,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttTeamAvatarStylePresentations)
          ButtonSegment(
            value: presentation.style,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(teamAvatarStyle: value),
          ),
    ),
  ];
}

import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_toggle_row.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../services/gantt_dependency_focus_scope_presentation_service.dart';
import '../services/gantt_timeline_visual_presentation_service.dart';
import '../states/gantt_chart_display_provider.dart';
import 'gantt_segmented_option_tile.dart';

List<Widget> ganttChartTimelineOptionTiles({
  required BuildContext context,
  required GanttChartDisplayPreferences displayPreferences,
  required ValueChanged<GanttChartDisplayPreferences> onDisplayChanged,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return [
    AppToggleRow(
      title: 'Today Marker',
      subtitle: 'Orient the timeline around the current date',
      icon: Icons.today_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showTodayMarker,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showTodayMarker: value),
          ),
    ),
    AppToggleRow(
      title: 'Weekend Bands',
      subtitle: 'Shade Saturdays and Sundays in the timeline',
      icon: Icons.weekend_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showWeekendBands,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showWeekendBands: value),
          ),
    ),
    GanttSegmentedOptionTile<GanttTimelineAccentIntensity>(
      title: 'Timeline Emphasis',
      subtitle: ganttTimelineAccentIntensitySettingsSubtitle(),
      icon: Icons.contrast_rounded,
      value: displayPreferences.timelineAccentIntensity,
      enabled:
          displayPreferences.showTodayMarker ||
          displayPreferences.showWeekendBands,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttTimelineAccentIntensityPresentations)
          ButtonSegment(
            value: presentation.intensity,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(timelineAccentIntensity: value),
          ),
    ),
    AppToggleRow(
      title: 'Dependency Lines',
      subtitle: 'Show predecessor connectors',
      icon: Icons.account_tree_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showDependencyLines,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showDependencyLines: value),
          ),
    ),
    AppToggleRow(
      title: 'Dependency Focus',
      subtitle: 'Spotlight selected task relationships',
      icon: Icons.hub_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.highlightSelectedDependencies,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          displayPreferences.showDependencyLines
              ? (value) => onDisplayChanged(
                displayPreferences.copyWith(
                  highlightSelectedDependencies: value,
                ),
              )
              : null,
    ),
    GanttSegmentedOptionTile<ky.KyGanttDependencyLineFocusScope>(
      title: 'Focus Scope',
      icon: Icons.route_outlined,
      value: displayPreferences.dependencyFocusScope,
      enabled:
          displayPreferences.showDependencyLines &&
          displayPreferences.highlightSelectedDependencies,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttDependencyFocusScopePresentations)
          ButtonSegment(
            value: presentation.scope,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(dependencyFocusScope: value),
          ),
    ),
    GanttSegmentedOptionTile<GanttDependencyLineIntensity>(
      title: 'Line Weight',
      subtitle: ganttDependencyLineIntensitySettingsSubtitle(),
      icon: Icons.show_chart_rounded,
      value: displayPreferences.dependencyLineIntensity,
      enabled: displayPreferences.showDependencyLines,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttDependencyLineIntensityPresentations)
          ButtonSegment(
            value: presentation.intensity,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(dependencyLineIntensity: value),
          ),
    ),
    GanttSegmentedOptionTile<GanttChartDensity>(
      title: 'Density',
      subtitle: ganttChartDensitySettingsSubtitle(),
      icon: Icons.density_medium_outlined,
      value: displayPreferences.density,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttChartDensityPresentations)
          ButtonSegment(
            value: presentation.density,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) =>
              onDisplayChanged(displayPreferences.copyWith(density: value)),
    ),
    GanttSegmentedOptionTile<GanttChartTimelineZoom>(
      title: 'Timeline Zoom',
      subtitle: ganttChartTimelineZoomSettingsSubtitle(),
      icon: Icons.zoom_in_map_outlined,
      value: displayPreferences.timelineZoom,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttChartTimelineZoomPresentations)
          ButtonSegment(
            value: presentation.zoom,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(timelineZoom: value),
          ),
    ),
    AppToggleRow(
      title: 'Milestone Labels',
      subtitle: 'Show labels beside milestone markers',
      icon: Icons.flag_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showMilestoneLabels,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showMilestoneLabels: value),
          ),
    ),
    AppToggleRow(
      title: 'Milestone Dates',
      subtitle: 'Show milestone dates beside markers',
      icon: Icons.event_available_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showMilestoneDateLabels,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showMilestoneDateLabels: value),
          ),
    ),
  ];
}

import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_toggle_row.dart';

import '../services/gantt_taskbar_visual_presentation_service.dart';
import '../states/gantt_chart_display_provider.dart';
import 'gantt_segmented_option_tile.dart';

List<Widget> ganttChartSelectionOptionTiles({
  required BuildContext context,
  required GanttChartDisplayPreferences displayPreferences,
  required ValueChanged<GanttChartDisplayPreferences> onDisplayChanged,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return [
    AppToggleRow(
      title: 'Selection Glow',
      subtitle: 'Highlight the selected taskbar',
      icon: Icons.center_focus_strong_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showSelectedTaskFocus,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showSelectedTaskFocus: value),
          ),
    ),
    AppToggleRow(
      title: 'Selection Row',
      subtitle: 'Track the selected task across the timeline',
      icon: Icons.table_rows_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showSelectedTaskRowHighlight,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showSelectedTaskRowHighlight: value),
          ),
    ),
    GanttSegmentedOptionTile<GanttSelectedTaskRowEmphasis>(
      title: 'Row Emphasis',
      subtitle: ganttSelectedTaskRowEmphasisSettingsSubtitle(),
      icon: Icons.format_line_spacing_rounded,
      value: displayPreferences.selectedTaskRowEmphasis,
      enabled: displayPreferences.showSelectedTaskRowHighlight,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttSelectedTaskRowEmphasisPresentations)
          ButtonSegment(
            value: presentation.emphasis,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(selectedTaskRowEmphasis: value),
          ),
    ),
    AppToggleRow(
      title: 'Bar Shadows',
      subtitle: 'Add depth to timeline bars',
      icon: Icons.layers_outlined,
      contained: true,
      iconBadge: true,
      value: displayPreferences.showTaskBarShadows,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(showTaskBarShadows: value),
          ),
    ),
    GanttSegmentedOptionTile<GanttTaskBarDepth>(
      title: 'Bar Depth',
      subtitle: ganttTaskBarDepthSettingsSubtitle(),
      icon: Icons.layers_rounded,
      value: displayPreferences.taskBarDepth,
      enabled: displayPreferences.showTaskBarShadows,
      backgroundColor: colorScheme.surfaceContainerLow,
      segments: [
        for (final presentation in ganttTaskBarDepthPresentations)
          ButtonSegment(
            value: presentation.depth,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
          ),
      ],
      onChanged:
          (value) => onDisplayChanged(
            displayPreferences.copyWith(taskBarDepth: value),
          ),
    ),
  ];
}

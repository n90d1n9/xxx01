import 'package:flutter/material.dart';

import '../services/gantt_chart_display_preset_service.dart';
import '../services/gantt_chart_view_profile_service.dart';
import '../states/gantt_chart_display_provider.dart';
import '../states/gantt_chart_interaction_provider.dart';
import 'gantt_chart_display_preset_tile.dart';
import 'gantt_chart_view_profile_tile.dart';
import 'gantt_chart_view_reset_tile.dart';

List<Widget> ganttChartProfileOptionTiles({
  required BuildContext context,
  required GanttChartDisplayPreferences displayPreferences,
  required ValueChanged<GanttChartDisplayPreferences> onDisplayChanged,
  required GanttChartInteractionPreferences interactionPreferences,
  required ValueChanged<GanttChartInteractionPreferences> onInteractionChanged,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  const viewProfileService = GanttChartViewProfileService();
  const displayPresetService = GanttChartDisplayPresetService();
  final viewProfile = viewProfileService.profileFor(
    displayPreferences: displayPreferences,
    interactionPreferences: interactionPreferences,
  );
  final displayPreset = displayPresetService.presetFor(displayPreferences);

  return [
    GanttChartViewProfileTile(
      value: viewProfile,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged: (profile) {
        final snapshot = viewProfileService.snapshotFor(profile);
        onDisplayChanged(snapshot.displayPreferences);
        onInteractionChanged(snapshot.interactionPreferences);
      },
    ),
    GanttChartDisplayPresetTile(
      value: displayPreset,
      backgroundColor: colorScheme.surfaceContainerLow,
      onChanged: (preset) {
        onDisplayChanged(displayPresetService.preferencesFor(preset));
      },
    ),
    GanttChartViewResetTile(
      isCustomized:
          displayPreferences != GanttChartDisplayPreferences.initial ||
          interactionPreferences != GanttChartInteractionPreferences.initial,
      backgroundColor: colorScheme.surfaceContainerLow,
      onReset: () {
        onDisplayChanged(GanttChartDisplayPreferences.initial);
        onInteractionChanged(GanttChartInteractionPreferences.initial);
      },
    ),
  ];
}

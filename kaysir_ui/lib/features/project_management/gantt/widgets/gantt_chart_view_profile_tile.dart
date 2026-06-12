import 'package:flutter/material.dart';

import '../services/gantt_chart_view_profile_presentation_service.dart';
import '../services/gantt_chart_view_profile_service.dart';
import 'gantt_segmented_option_tile.dart';

/// Segmented control for applying coordinated Gantt view profiles.
class GanttChartViewProfileTile extends StatelessWidget {
  const GanttChartViewProfileTile({
    required this.value,
    required this.onChanged,
    required this.backgroundColor,
    super.key,
  });

  final GanttChartViewProfile value;
  final ValueChanged<GanttChartViewProfile> onChanged;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final activePresentation = ganttChartViewProfilePresentation(value);

    return GanttSegmentedOptionTile<GanttChartViewProfile>(
      title: 'View Profile',
      subtitle: ganttChartViewProfileSettingsSubtitle(),
      icon: activePresentation.icon,
      value: value,
      backgroundColor: backgroundColor,
      segments: [
        for (final presentation in ganttChartViewProfilePresentationsFor(value))
          ButtonSegment(
            value: presentation.profile,
            label: Text(presentation.label),
            tooltip: presentation.tooltip,
            enabled:
                presentation.isPreset || value == GanttChartViewProfile.custom,
          ),
      ],
      onChanged: (profile) {
        if (!ganttChartViewProfilePresentation(profile).isPreset) return;

        onChanged(profile);
      },
    );
  }
}

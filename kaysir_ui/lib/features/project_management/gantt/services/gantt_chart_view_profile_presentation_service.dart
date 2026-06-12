import 'package:flutter/material.dart';

import 'gantt_chart_view_profile_service.dart';

/// Presentation metadata for coordinated Gantt view profile choices.
class GanttChartViewProfilePresentation {
  const GanttChartViewProfilePresentation({
    required this.profile,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
    required this.icon,
  });

  final GanttChartViewProfile profile;
  final String label;
  final String summaryLabel;
  final String tooltip;
  final IconData icon;

  bool get isPreset => profile != GanttChartViewProfile.custom;
}

const ganttChartViewProfilePresentations = [
  GanttChartViewProfilePresentation(
    profile: GanttChartViewProfile.planner,
    label: 'Plan',
    summaryLabel: 'Plan balances editing',
    tooltip:
        'Plan profile keeps editing tools and balanced chart defaults ready.',
    icon: Icons.edit_calendar_outlined,
  ),
  GanttChartViewProfilePresentation(
    profile: GanttChartViewProfile.team,
    label: 'Team',
    summaryLabel: 'Team highlights ownership',
    tooltip:
        'Team profile highlights ownership with prominent avatars and weekly snap.',
    icon: Icons.groups_2_outlined,
  ),
  GanttChartViewProfilePresentation(
    profile: GanttChartViewProfile.review,
    label: 'Review',
    summaryLabel: 'Review locks inspection',
    tooltip:
        'Review profile disables direct timeline edits and quiets feedback for inspection.',
    icon: Icons.visibility_outlined,
  ),
  GanttChartViewProfilePresentation(
    profile: GanttChartViewProfile.custom,
    label: 'Custom',
    summaryLabel: 'Custom reflects manual tuning',
    tooltip:
        'Custom appears when display or interaction settings diverge from a profile.',
    icon: Icons.tune_outlined,
  ),
];

GanttChartViewProfilePresentation ganttChartViewProfilePresentation(
  GanttChartViewProfile profile,
) {
  for (final presentation in ganttChartViewProfilePresentations) {
    if (presentation.profile == profile) return presentation;
  }

  throw ArgumentError.value(profile, 'profile', 'Unknown view profile');
}

List<GanttChartViewProfilePresentation> ganttChartViewProfilePresentationsFor(
  GanttChartViewProfile value,
) {
  return [
    for (final presentation in ganttChartViewProfilePresentations)
      if (presentation.isPreset || value == GanttChartViewProfile.custom)
        presentation,
  ];
}

String ganttChartViewProfileSettingsSubtitle() {
  return ganttChartViewProfilePresentations
      .where((presentation) => presentation.isPreset)
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

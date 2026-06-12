import 'package:flutter/material.dart';

/// Toggle roles for optional Gantt chart layers and dependency focus controls.
enum GanttChartLayerToggleRole {
  teamAvatars,
  dependencyLines,
  dependencyFocus,
  weekendBands,
  todayMarker,
}

const ganttChartLayerTeamAvatarsChipKey = ValueKey(
  'gantt-chart-layer-team-avatars-chip',
);
const ganttChartLayerDependencyLinesChipKey = ValueKey(
  'gantt-chart-layer-dependency-lines-chip',
);
const ganttChartLayerDependencyFocusChipKey = ValueKey(
  'gantt-chart-layer-dependency-focus-chip',
);
const ganttChartLayerWeekendBandsChipKey = ValueKey(
  'gantt-chart-layer-weekend-bands-chip',
);
const ganttChartLayerTodayMarkerChipKey = ValueKey(
  'gantt-chart-layer-today-marker-chip',
);

/// Presentation metadata for one chart layer toggle chip.
class GanttChartLayerTogglePresentation {
  const GanttChartLayerTogglePresentation({
    required this.role,
    required this.key,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
    required this.icon,
    required this.countsAsLayer,
  });

  final GanttChartLayerToggleRole role;
  final Key key;
  final String label;
  final String summaryLabel;
  final String tooltip;
  final IconData icon;
  final bool countsAsLayer;
}

const ganttChartLayerTogglePresentations = [
  GanttChartLayerTogglePresentation(
    role: GanttChartLayerToggleRole.teamAvatars,
    key: ganttChartLayerTeamAvatarsChipKey,
    label: 'Team',
    summaryLabel: 'Team avatars',
    tooltip: 'Team avatars',
    icon: Icons.groups_2_outlined,
    countsAsLayer: true,
  ),
  GanttChartLayerTogglePresentation(
    role: GanttChartLayerToggleRole.dependencyLines,
    key: ganttChartLayerDependencyLinesChipKey,
    label: 'Links',
    summaryLabel: 'Dependency lines',
    tooltip: 'Dependency lines',
    icon: Icons.account_tree_outlined,
    countsAsLayer: true,
  ),
  GanttChartLayerTogglePresentation(
    role: GanttChartLayerToggleRole.dependencyFocus,
    key: ganttChartLayerDependencyFocusChipKey,
    label: 'Focus',
    summaryLabel: 'Dependency focus',
    tooltip: 'Selected task dependency focus',
    icon: Icons.hub_outlined,
    countsAsLayer: false,
  ),
  GanttChartLayerTogglePresentation(
    role: GanttChartLayerToggleRole.weekendBands,
    key: ganttChartLayerWeekendBandsChipKey,
    label: 'Weekends',
    summaryLabel: 'Weekend bands',
    tooltip: 'Weekend bands',
    icon: Icons.weekend_outlined,
    countsAsLayer: true,
  ),
  GanttChartLayerTogglePresentation(
    role: GanttChartLayerToggleRole.todayMarker,
    key: ganttChartLayerTodayMarkerChipKey,
    label: 'Today',
    summaryLabel: 'Today marker',
    tooltip: 'Today marker',
    icon: Icons.today_outlined,
    countsAsLayer: true,
  ),
];

GanttChartLayerTogglePresentation ganttChartLayerTogglePresentation(
  GanttChartLayerToggleRole role,
) {
  for (final presentation in ganttChartLayerTogglePresentations) {
    if (presentation.role == role) return presentation;
  }

  throw ArgumentError.value(role, 'role', 'Unknown chart layer toggle');
}

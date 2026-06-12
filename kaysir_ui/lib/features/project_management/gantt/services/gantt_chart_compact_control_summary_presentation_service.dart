import 'package:flutter/material.dart';

import 'gantt_chart_compact_control_summary_service.dart';

/// Theme accent group used by compact Gantt control summary pills.
enum GanttChartCompactControlSummaryAccent { primary, secondary, tertiary }

/// Visual metadata for one compact Gantt control summary role.
class GanttChartCompactControlSummaryRolePresentation {
  const GanttChartCompactControlSummaryRolePresentation({
    required this.role,
    required this.icon,
    required this.accent,
    required this.maxWidth,
  });

  final GanttChartCompactControlSummaryRole role;
  final IconData icon;
  final GanttChartCompactControlSummaryAccent accent;
  final double maxWidth;
}

const ganttChartCompactControlSummaryRolePresentations = [
  GanttChartCompactControlSummaryRolePresentation(
    role: GanttChartCompactControlSummaryRole.quickPreset,
    icon: Icons.bolt_outlined,
    accent: GanttChartCompactControlSummaryAccent.tertiary,
    maxWidth: 144,
  ),
  GanttChartCompactControlSummaryRolePresentation(
    role: GanttChartCompactControlSummaryRole.timelineLens,
    icon: Icons.manage_search_outlined,
    accent: GanttChartCompactControlSummaryAccent.primary,
    maxWidth: 230,
  ),
  GanttChartCompactControlSummaryRolePresentation(
    role: GanttChartCompactControlSummaryRole.chartLayers,
    icon: Icons.layers_outlined,
    accent: GanttChartCompactControlSummaryAccent.primary,
    maxWidth: 120,
  ),
  GanttChartCompactControlSummaryRolePresentation(
    role: GanttChartCompactControlSummaryRole.dependencyFocus,
    icon: Icons.route_outlined,
    accent: GanttChartCompactControlSummaryAccent.primary,
    maxWidth: 154,
  ),
  GanttChartCompactControlSummaryRolePresentation(
    role: GanttChartCompactControlSummaryRole.viewport,
    icon: Icons.view_week_outlined,
    accent: GanttChartCompactControlSummaryAccent.secondary,
    maxWidth: 210,
  ),
  GanttChartCompactControlSummaryRolePresentation(
    role: GanttChartCompactControlSummaryRole.editTools,
    icon: Icons.edit_outlined,
    accent: GanttChartCompactControlSummaryAccent.tertiary,
    maxWidth: 140,
  ),
  GanttChartCompactControlSummaryRolePresentation(
    role: GanttChartCompactControlSummaryRole.dragSnap,
    icon: Icons.grid_4x4_outlined,
    accent: GanttChartCompactControlSummaryAccent.tertiary,
    maxWidth: 112,
  ),
  GanttChartCompactControlSummaryRolePresentation(
    role: GanttChartCompactControlSummaryRole.previewDetail,
    icon: Icons.preview_outlined,
    accent: GanttChartCompactControlSummaryAccent.tertiary,
    maxWidth: 136,
  ),
];

GanttChartCompactControlSummaryRolePresentation
ganttChartCompactControlSummaryRolePresentation(
  GanttChartCompactControlSummaryRole role,
) {
  for (final presentation in ganttChartCompactControlSummaryRolePresentations) {
    if (presentation.role == role) return presentation;
  }

  throw ArgumentError.value(role, 'role', 'Unknown compact summary role');
}

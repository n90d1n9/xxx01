import 'package:flutter/material.dart';

/// Section roles used to organize the expanded full-screen Gantt controls.
enum GanttChartExpandedControlSectionRole {
  timeline,
  presets,
  display,
  execution,
}

/// Presentation metadata for one expanded Gantt control section.
class GanttChartExpandedControlSectionPresentation {
  const GanttChartExpandedControlSectionPresentation({
    required this.role,
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  final GanttChartExpandedControlSectionRole role;
  final String label;
  final String subtitle;
  final IconData icon;
}

const ganttChartExpandedControlSectionPresentations = [
  GanttChartExpandedControlSectionPresentation(
    role: GanttChartExpandedControlSectionRole.timeline,
    label: 'Timeline scope',
    subtitle: 'Filters, saved views, and viewport jumps',
    icon: Icons.travel_explore_outlined,
  ),
  GanttChartExpandedControlSectionPresentation(
    role: GanttChartExpandedControlSectionRole.presets,
    label: 'Focus presets',
    subtitle: 'Reusable risk, team, and milestone setups',
    icon: Icons.auto_awesome_motion_outlined,
  ),
  GanttChartExpandedControlSectionPresentation(
    role: GanttChartExpandedControlSectionRole.display,
    label: 'Canvas display',
    subtitle: 'Layers, density, and timeline scale',
    icon: Icons.dashboard_customize_outlined,
  ),
  GanttChartExpandedControlSectionPresentation(
    role: GanttChartExpandedControlSectionRole.execution,
    label: 'Execution controls',
    subtitle: 'Editing tools, tree state, and dependency health',
    icon: Icons.construction_outlined,
  ),
];

GanttChartExpandedControlSectionPresentation
ganttChartExpandedControlSectionPresentation(
  GanttChartExpandedControlSectionRole role,
) {
  for (final presentation in ganttChartExpandedControlSectionPresentations) {
    if (presentation.role == role) return presentation;
  }

  throw ArgumentError.value(role, 'role', 'Unknown expanded control section');
}

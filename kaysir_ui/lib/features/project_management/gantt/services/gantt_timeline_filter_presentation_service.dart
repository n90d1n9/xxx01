import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;

/// Field roles shown in the expanded Gantt timeline filter bar.
enum GanttTimelineFilterFieldRole { search, project, status, view, range }

/// Presentation metadata for one Gantt timeline filter field.
class GanttTimelineFilterFieldPresentation {
  const GanttTimelineFilterFieldPresentation({
    required this.role,
    required this.label,
    required this.icon,
    required this.expandedWidth,
  });

  final GanttTimelineFilterFieldRole role;
  final String label;
  final IconData icon;
  final double expandedWidth;

  double? widthFor({required bool compact}) {
    return compact ? null : expandedWidth;
  }
}

/// Presentation metadata for one Gantt view-mode option.
class GanttViewModePresentation {
  const GanttViewModePresentation({required this.mode, required this.label});

  final gantt.ViewMode mode;
  final String label;
}

const ganttTimelineFilterCompactBreakpoint = 760.0;

const ganttTimelineFilterFieldPresentations = [
  GanttTimelineFilterFieldPresentation(
    role: GanttTimelineFilterFieldRole.search,
    label: 'Search timeline tasks',
    icon: Icons.search,
    expandedWidth: 280,
  ),
  GanttTimelineFilterFieldPresentation(
    role: GanttTimelineFilterFieldRole.project,
    label: 'Project',
    icon: Icons.workspaces_outline,
    expandedWidth: 230,
  ),
  GanttTimelineFilterFieldPresentation(
    role: GanttTimelineFilterFieldRole.status,
    label: 'Status',
    icon: Icons.filter_list_rounded,
    expandedWidth: 190,
  ),
  GanttTimelineFilterFieldPresentation(
    role: GanttTimelineFilterFieldRole.view,
    label: 'View',
    icon: Icons.calendar_view_week_outlined,
    expandedWidth: 170,
  ),
  GanttTimelineFilterFieldPresentation(
    role: GanttTimelineFilterFieldRole.range,
    label: 'Range Preset',
    icon: Icons.today_outlined,
    expandedWidth: 210,
  ),
];

const ganttViewModePresentations = [
  GanttViewModePresentation(mode: gantt.ViewMode.day, label: 'Day'),
  GanttViewModePresentation(mode: gantt.ViewMode.week, label: 'Week'),
  GanttViewModePresentation(mode: gantt.ViewMode.month, label: 'Month'),
  GanttViewModePresentation(mode: gantt.ViewMode.quarter, label: 'Quarter'),
];

bool ganttTimelineFilterUsesCompactLayout(double maxWidth) {
  return maxWidth < ganttTimelineFilterCompactBreakpoint;
}

GanttTimelineFilterFieldPresentation ganttTimelineFilterFieldPresentation(
  GanttTimelineFilterFieldRole role,
) {
  for (final presentation in ganttTimelineFilterFieldPresentations) {
    if (presentation.role == role) return presentation;
  }

  throw ArgumentError.value(role, 'role', 'Unknown timeline filter field');
}

GanttViewModePresentation ganttViewModePresentation(gantt.ViewMode mode) {
  for (final presentation in ganttViewModePresentations) {
    if (presentation.mode == mode) return presentation;
  }

  throw ArgumentError.value(mode, 'mode', 'Unknown Gantt view mode');
}

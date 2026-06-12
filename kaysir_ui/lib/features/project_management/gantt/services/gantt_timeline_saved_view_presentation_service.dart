import 'package:flutter/material.dart';

import 'gantt_saved_view_service.dart';

/// Presentation metadata for a saved Gantt timeline view preset.
class GanttTimelineSavedViewPresentation {
  const GanttTimelineSavedViewPresentation({
    required this.preset,
    required this.label,
    required this.icon,
    required this.intentLabel,
    required this.detail,
  });

  final GanttTimelineViewPreset preset;
  final String label;
  final IconData icon;
  final String intentLabel;
  final String detail;
}

const ganttTimelineSavedViewPresentations = [
  GanttTimelineSavedViewPresentation(
    preset: GanttTimelineViewPreset.all,
    label: 'All Tasks',
    icon: Icons.account_tree_outlined,
    intentLabel: 'Complete schedule',
    detail: 'Shows every task in the current timeline scope.',
  ),
  GanttTimelineSavedViewPresentation(
    preset: GanttTimelineViewPreset.activeNow,
    label: 'Active Now',
    icon: Icons.play_circle_outline_rounded,
    intentLabel: 'In-flight work',
    detail: 'Shows tasks active today.',
  ),
  GanttTimelineSavedViewPresentation(
    preset: GanttTimelineViewPreset.dueSoon,
    label: 'Due Soon',
    icon: Icons.upcoming_outlined,
    intentLabel: 'Near deadlines',
    detail: 'Shows incomplete tasks due in the next 7 days.',
  ),
  GanttTimelineSavedViewPresentation(
    preset: GanttTimelineViewPreset.dependencyWatch,
    label: 'Dependency Watch',
    icon: Icons.link_rounded,
    intentLabel: 'Dependency attention',
    detail: 'Shows tasks waiting on, blocked by, or missing dependencies.',
  ),
  GanttTimelineSavedViewPresentation(
    preset: GanttTimelineViewPreset.readyNext,
    label: 'Ready Next',
    icon: Icons.next_plan_outlined,
    intentLabel: 'Ready starts',
    detail: 'Shows upcoming tasks with clear dependencies.',
  ),
];

GanttTimelineSavedViewPresentation ganttTimelineSavedViewPresentation(
  GanttTimelineViewPreset preset,
) {
  for (final presentation in ganttTimelineSavedViewPresentations) {
    if (presentation.preset == preset) return presentation;
  }

  throw ArgumentError.value(preset, 'preset', 'Unknown saved timeline view');
}

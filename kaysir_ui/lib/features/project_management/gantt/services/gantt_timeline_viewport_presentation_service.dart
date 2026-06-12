import 'package:flutter/material.dart';

import 'gantt_timeline_range_preset_service.dart';
import 'gantt_timeline_viewport_summary_service.dart';

/// Accent group used by timeline viewport navigator status pills.
enum GanttTimelineViewportAccent { neutral, primary, tertiary }

/// Timeline viewport quick-jump action roles.
enum GanttTimelineViewportAction { today, attention, fitAll }

const ganttViewportTodayButtonKey = ValueKey('gantt-viewport-today-button');
const ganttViewportAttentionButtonKey = ValueKey(
  'gantt-viewport-attention-button',
);
const ganttViewportFitAllButtonKey = ValueKey('gantt-viewport-fit-all-button');

/// Visual metadata for a viewport visibility state.
class GanttTimelineViewportVisibilityPresentation {
  const GanttTimelineViewportVisibilityPresentation({
    required this.state,
    required this.icon,
    required this.accent,
    required this.maxWidth,
  });

  final GanttTimelineViewportVisibilityState state;
  final IconData icon;
  final GanttTimelineViewportAccent accent;
  final double maxWidth;
}

/// Visual metadata for the hidden-task count pill.
class GanttTimelineViewportHiddenPresentation {
  const GanttTimelineViewportHiddenPresentation({
    required this.icon,
    required this.tooltip,
    required this.accent,
    required this.maxWidth,
  });

  final IconData icon;
  final String tooltip;
  final GanttTimelineViewportAccent accent;
  final double maxWidth;
}

/// Presentation metadata for a timeline viewport quick-jump button.
class GanttTimelineViewportActionPresentation {
  const GanttTimelineViewportActionPresentation({
    required this.action,
    required this.key,
    required this.rangePreset,
    required this.label,
    required this.tooltip,
    required this.icon,
  });

  final GanttTimelineViewportAction action;
  final Key key;
  final GanttTimelineRangePreset rangePreset;
  final String label;
  final String tooltip;
  final IconData icon;
}

const ganttTimelineViewportVisibilityPresentations = [
  GanttTimelineViewportVisibilityPresentation(
    state: GanttTimelineViewportVisibilityState.empty,
    icon: Icons.inbox_outlined,
    accent: GanttTimelineViewportAccent.neutral,
    maxWidth: 136,
  ),
  GanttTimelineViewportVisibilityPresentation(
    state: GanttTimelineViewportVisibilityState.complete,
    icon: Icons.visibility_outlined,
    accent: GanttTimelineViewportAccent.primary,
    maxWidth: 136,
  ),
  GanttTimelineViewportVisibilityPresentation(
    state: GanttTimelineViewportVisibilityState.filtered,
    icon: Icons.filter_alt_outlined,
    accent: GanttTimelineViewportAccent.tertiary,
    maxWidth: 136,
  ),
];

const ganttTimelineViewportHiddenPresentation =
    GanttTimelineViewportHiddenPresentation(
      icon: Icons.visibility_off_outlined,
      tooltip: 'Tasks currently hidden by filters or focus',
      accent: GanttTimelineViewportAccent.tertiary,
      maxWidth: 150,
    );

const ganttTimelineViewportActionPresentations = [
  GanttTimelineViewportActionPresentation(
    action: GanttTimelineViewportAction.today,
    key: ganttViewportTodayButtonKey,
    rangePreset: GanttTimelineRangePreset.planningWindow,
    label: 'Today',
    tooltip: 'Jump to the active planning window',
    icon: Icons.today_outlined,
  ),
  GanttTimelineViewportActionPresentation(
    action: GanttTimelineViewportAction.attention,
    key: ganttViewportAttentionButtonKey,
    rangePreset: GanttTimelineRangePreset.attentionWindow,
    label: 'Risks',
    tooltip: 'Jump to active, overdue, and due-soon tasks',
    icon: Icons.crisis_alert_outlined,
  ),
  GanttTimelineViewportActionPresentation(
    action: GanttTimelineViewportAction.fitAll,
    key: ganttViewportFitAllButtonKey,
    rangePreset: GanttTimelineRangePreset.projectSpan,
    label: 'Fit All',
    tooltip: 'Fit the whole visible project span',
    icon: Icons.fit_screen_outlined,
  ),
];

GanttTimelineViewportVisibilityPresentation
ganttTimelineViewportVisibilityPresentation(
  GanttTimelineViewportVisibilityState state,
) {
  for (final presentation in ganttTimelineViewportVisibilityPresentations) {
    if (presentation.state == state) return presentation;
  }

  throw ArgumentError.value(state, 'state', 'Unknown viewport state');
}

GanttTimelineViewportActionPresentation ganttTimelineViewportActionPresentation(
  GanttTimelineViewportAction action,
) {
  for (final presentation in ganttTimelineViewportActionPresentations) {
    if (presentation.action == action) return presentation;
  }

  throw ArgumentError.value(action, 'action', 'Unknown viewport action');
}

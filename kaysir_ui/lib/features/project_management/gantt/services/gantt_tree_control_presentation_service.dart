import 'package:flutter/material.dart';

import 'gantt_tree_control_summary_service.dart';

/// Accent group used for task-tree status pills.
enum GanttTreeControlAccent { primary, secondary, tertiary }

/// Task-tree bulk action roles.
enum GanttTreeControlAction { collapseAll, expandAll }

const ganttTreeCollapseAllButtonKey = ValueKey(
  'gantt-tree-collapse-all-button',
);
const ganttTreeExpandAllButtonKey = ValueKey('gantt-tree-expand-all-button');

/// Visual metadata for a task-tree collapse state.
class GanttTreeCollapseStatePresentation {
  const GanttTreeCollapseStatePresentation({
    required this.state,
    required this.icon,
    required this.accent,
  });

  final GanttTreeCollapseState state;
  final IconData icon;
  final GanttTreeControlAccent accent;
}

/// Presentation metadata for a task-tree bulk action.
class GanttTreeControlActionPresentation {
  const GanttTreeControlActionPresentation({
    required this.action,
    required this.key,
    required this.label,
    required this.icon,
  });

  final GanttTreeControlAction action;
  final Key key;
  final String label;
  final IconData icon;
}

const ganttTreeCollapseStatePresentations = [
  GanttTreeCollapseStatePresentation(
    state: GanttTreeCollapseState.expanded,
    icon: Icons.unfold_more_rounded,
    accent: GanttTreeControlAccent.primary,
  ),
  GanttTreeCollapseStatePresentation(
    state: GanttTreeCollapseState.mixed,
    icon: Icons.tune_rounded,
    accent: GanttTreeControlAccent.tertiary,
  ),
  GanttTreeCollapseStatePresentation(
    state: GanttTreeCollapseState.collapsed,
    icon: Icons.unfold_less_rounded,
    accent: GanttTreeControlAccent.secondary,
  ),
];

const ganttTreeControlActionPresentations = [
  GanttTreeControlActionPresentation(
    action: GanttTreeControlAction.collapseAll,
    key: ganttTreeCollapseAllButtonKey,
    label: 'Collapse All',
    icon: Icons.unfold_less_rounded,
  ),
  GanttTreeControlActionPresentation(
    action: GanttTreeControlAction.expandAll,
    key: ganttTreeExpandAllButtonKey,
    label: 'Expand All',
    icon: Icons.unfold_more_rounded,
  ),
];

GanttTreeCollapseStatePresentation ganttTreeCollapseStatePresentation(
  GanttTreeCollapseState state,
) {
  for (final presentation in ganttTreeCollapseStatePresentations) {
    if (presentation.state == state) return presentation;
  }

  throw ArgumentError.value(state, 'state', 'Unknown tree collapse state');
}

GanttTreeControlActionPresentation ganttTreeControlActionPresentation(
  GanttTreeControlAction action,
) {
  for (final presentation in ganttTreeControlActionPresentations) {
    if (presentation.action == action) return presentation;
  }

  throw ArgumentError.value(action, 'action', 'Unknown tree control action');
}

import 'package:flutter/material.dart';

/// Action roles shown in the full-screen Gantt chart header.
enum GanttChartHeaderActionRole {
  toggleControls,
  undoEdit,
  viewSettings,
  dashboard,
}

const ganttHeaderToggleControlsButtonKey = ValueKey(
  'gantt-header-toggle-controls-button',
);
const ganttHeaderUndoEditButtonKey = ValueKey('gantt-header-undo-edit-button');
const ganttHeaderViewSettingsButtonKey = ValueKey(
  'gantt-header-view-settings-button',
);
const ganttHeaderDashboardButtonKey = ValueKey('gantt-header-dashboard-button');

/// Presentation metadata for one header action button.
class GanttChartHeaderActionPresentation {
  const GanttChartHeaderActionPresentation({
    required this.role,
    required this.key,
    required this.label,
    required this.tooltip,
    required this.icon,
    required this.enabled,
  });

  final GanttChartHeaderActionRole role;
  final Key key;
  final String label;
  final String tooltip;
  final IconData icon;
  final bool enabled;
}

List<GanttChartHeaderActionPresentation> ganttChartHeaderActionPresentations({
  required bool controlsExpanded,
  required bool canUndoLastEdit,
}) {
  return [
    GanttChartHeaderActionPresentation(
      role: GanttChartHeaderActionRole.toggleControls,
      key: ganttHeaderToggleControlsButtonKey,
      label: controlsExpanded ? 'Hide Controls' : 'Show Controls',
      tooltip: controlsExpanded ? 'Hide Controls' : 'Show Controls',
      icon:
          controlsExpanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.tune_outlined,
      enabled: true,
    ),
    GanttChartHeaderActionPresentation(
      role: GanttChartHeaderActionRole.undoEdit,
      key: ganttHeaderUndoEditButtonKey,
      label: 'Undo Edit',
      tooltip: 'Undo Edit',
      icon: Icons.undo_rounded,
      enabled: canUndoLastEdit,
    ),
    const GanttChartHeaderActionPresentation(
      role: GanttChartHeaderActionRole.viewSettings,
      key: ganttHeaderViewSettingsButtonKey,
      label: 'View Settings',
      tooltip: 'View Settings',
      icon: Icons.tune_rounded,
      enabled: true,
    ),
    const GanttChartHeaderActionPresentation(
      role: GanttChartHeaderActionRole.dashboard,
      key: ganttHeaderDashboardButtonKey,
      label: 'Dashboard',
      tooltip: 'Dashboard',
      icon: Icons.space_dashboard_outlined,
      enabled: true,
    ),
  ];
}

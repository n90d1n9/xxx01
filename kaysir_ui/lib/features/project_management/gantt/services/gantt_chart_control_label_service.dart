import 'package:ky_gantt/ky_gantt.dart' as ky;

import 'gantt_chart_edit_tool_presentation_service.dart';
import 'gantt_chart_layer_toggle_presentation_service.dart';
import 'gantt_chart_quick_preset_presentation_service.dart';
import 'gantt_chart_quick_preset_service.dart';
import 'gantt_dependency_focus_scope_presentation_service.dart';
import 'gantt_interaction_segment_presentation_service.dart';
import 'gantt_saved_view_service.dart';
import 'gantt_timeline_saved_view_presentation_service.dart';
import 'gantt_timeline_visual_presentation_service.dart';
import 'gantt_timeline_range_preset_service.dart';
import '../states/gantt_chart_display_provider.dart';
import '../states/gantt_chart_interaction_provider.dart';

int ganttChartVisibleLayerCount(GanttChartDisplayPreferences preferences) {
  return _visibleLayerPresentations(preferences).length;
}

List<String> ganttChartVisibleLayerLabels(
  GanttChartDisplayPreferences preferences,
) {
  return [
    for (final presentation in _visibleLayerPresentations(preferences))
      presentation.summaryLabel,
  ];
}

int ganttChartActiveEditToolCount(
  GanttChartInteractionPreferences preferences,
) {
  return _activeEditToolPresentations(preferences).length;
}

List<String> ganttChartActiveEditToolLabels(
  GanttChartInteractionPreferences preferences,
) {
  return [
    for (final presentation in _activeEditToolPresentations(preferences))
      presentation.summaryLabel,
  ];
}

String ganttChartLayerCountLabel(GanttChartDisplayPreferences preferences) {
  final count = ganttChartVisibleLayerCount(preferences);
  return '$count ${count == 1 ? 'layer' : 'layers'}';
}

String ganttChartLayerStripSubtitleLabel(
  GanttChartDisplayPreferences preferences,
) {
  return '${ganttChartVisibleLayerCount(preferences)} active - '
      '${ganttChartDependencyFocusControlLabel(preferences)}';
}

String ganttChartLayerDetailLabel(GanttChartDisplayPreferences preferences) {
  final labels = ganttChartVisibleLayerLabels(preferences);
  if (labels.isEmpty) return 'No optional chart layers visible';

  return '${labels.join(', ')} visible';
}

String ganttChartQuickPresetSummaryLabel(
  GanttChartDisplayPreferences preferences,
) {
  const service = GanttChartQuickPresetService();
  final preset = service.presetFor(preferences);
  return '${ganttChartQuickPresetPresentation(preset).label} focus';
}

String ganttChartTimelineLensSummaryLabel(
  GanttTimelineViewPreset timelineView,
  GanttTimelineRangePreset rangePreset,
) {
  return '${ganttTimelineSavedViewPresentation(timelineView).label} / '
      '${rangePreset.label}';
}

String ganttChartDependencyFocusControlLabel(
  GanttChartDisplayPreferences preferences,
) {
  if (!preferences.showDependencyLines) return 'Deps hidden';
  if (!preferences.highlightSelectedDependencies) return 'Focus off';

  return ganttDependencyFocusScopePresentation(
    preferences.dependencyFocusScope,
  ).summaryLabel;
}

String ganttChartDependencyFocusDetailLabel(
  GanttChartDisplayPreferences preferences,
) {
  if (!preferences.showDependencyLines) {
    return 'Dependency connectors are hidden';
  }
  if (!preferences.highlightSelectedDependencies) {
    return 'Selected task dependency focus is disabled';
  }

  return ganttDependencyFocusScopePresentation(
    preferences.dependencyFocusScope,
  ).tooltip;
}

String ganttChartEditToolCountLabel(
  GanttChartInteractionPreferences preferences,
) {
  final count = ganttChartActiveEditToolCount(preferences);
  return '$count edit ${count == 1 ? 'tool' : 'tools'}';
}

String ganttChartEditToolStripSubtitleLabel(
  GanttChartInteractionPreferences preferences,
) {
  return '${ganttChartActiveEditToolCount(preferences)} active - '
      '${ganttChartDragSnapSummaryLabel(preferences)}';
}

String ganttChartEditToolDetailLabel(
  GanttChartInteractionPreferences preferences,
) {
  final labels = ganttChartActiveEditToolLabels(preferences);
  if (labels.isEmpty) return 'No edit tools enabled';

  return '${labels.join(', ')} enabled';
}

String ganttChartDensityControlLabel(GanttChartDensity density) {
  return ganttChartDensityPresentation(density).controlLabel;
}

String ganttChartTimelineZoomControlLabel(GanttChartTimelineZoom zoom) {
  return ganttChartTimelineZoomPresentation(zoom).controlLabel;
}

String ganttChartViewportControlLabel(
  GanttChartDisplayPreferences preferences,
) {
  return '${ganttChartDensityControlLabel(preferences.density)} rows / '
      '${ganttChartTimelineZoomControlLabel(preferences.timelineZoom)} scale';
}

String ganttChartViewportStripSubtitleLabel(
  GanttChartDisplayPreferences preferences,
) {
  return '${ganttChartDensityControlLabel(preferences.density)} rows - '
      '${ganttChartTimelineZoomControlLabel(preferences.timelineZoom)} scale';
}

String ganttChartViewportDetailLabel(GanttChartDisplayPreferences preferences) {
  return '${ganttChartDensityControlLabel(preferences.density)} rows with '
      '${ganttChartTimelineZoomControlLabel(preferences.timelineZoom)} '
      'timeline scale';
}

String ganttChartDragSnapControlLabel(ky.KyGanttTaskDragSnap snap) {
  return ganttDragSnapPresentation(snap).label;
}

String ganttChartDragSnapSummaryLabel(
  GanttChartInteractionPreferences preferences,
) {
  return '${ganttChartDragSnapControlLabel(preferences.dragSnap)} snap';
}

String ganttChartDragSnapDetailLabel(
  GanttChartInteractionPreferences preferences,
) {
  final snapLabel = ganttChartDragSnapControlLabel(preferences.dragSnap);
  final snapEnabled =
      preferences.enableTaskBarDrag || preferences.enableTaskBarResize;

  if (!snapEnabled) {
    return '$snapLabel snap is idle until drag or resize is enabled';
  }

  return 'Task bars snap to $snapLabel increments while editing';
}

List<GanttChartLayerTogglePresentation> _visibleLayerPresentations(
  GanttChartDisplayPreferences preferences,
) {
  return [
    for (final presentation in ganttChartLayerTogglePresentations)
      if (presentation.countsAsLayer &&
          _isGanttChartLayerToggleActive(preferences, presentation.role))
        presentation,
  ];
}

bool _isGanttChartLayerToggleActive(
  GanttChartDisplayPreferences preferences,
  GanttChartLayerToggleRole role,
) {
  switch (role) {
    case GanttChartLayerToggleRole.teamAvatars:
      return preferences.showTeamAvatars;
    case GanttChartLayerToggleRole.dependencyLines:
      return preferences.showDependencyLines;
    case GanttChartLayerToggleRole.dependencyFocus:
      return preferences.showDependencyLines &&
          preferences.highlightSelectedDependencies;
    case GanttChartLayerToggleRole.weekendBands:
      return preferences.showWeekendBands;
    case GanttChartLayerToggleRole.todayMarker:
      return preferences.showTodayMarker;
  }
}

List<GanttChartEditToolPresentation> _activeEditToolPresentations(
  GanttChartInteractionPreferences preferences,
) {
  return [
    for (final presentation in ganttChartEditToolPresentations)
      if (_isGanttChartEditToolActive(preferences, presentation.role))
        presentation,
  ];
}

bool _isGanttChartEditToolActive(
  GanttChartInteractionPreferences preferences,
  GanttChartEditToolRole role,
) {
  switch (role) {
    case GanttChartEditToolRole.drag:
      return preferences.enableTaskBarDrag;
    case GanttChartEditToolRole.resize:
      return preferences.enableTaskBarResize;
    case GanttChartEditToolRole.scheduleGuard:
      return preferences.enableScheduleGuard;
  }
}

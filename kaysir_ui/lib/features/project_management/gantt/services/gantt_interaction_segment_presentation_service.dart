import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../states/gantt_chart_interaction_provider.dart';

/// Presentation metadata for taskbar resize handle visibility options.
class GanttResizeHandleVisibilityPresentation {
  const GanttResizeHandleVisibilityPresentation({
    required this.visibility,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
  });

  final ky.KyGanttTaskResizeHandleVisibility visibility;
  final String label;
  final String summaryLabel;
  final String tooltip;
}

/// Presentation metadata for taskbar drag and resize snap options.
class GanttDragSnapPresentation {
  const GanttDragSnapPresentation({
    required this.snap,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
  });

  final ky.KyGanttTaskDragSnap snap;
  final String label;
  final String summaryLabel;
  final String tooltip;
}

/// Presentation metadata for task inspector placement options.
class GanttInspectorPlacementPresentation {
  const GanttInspectorPlacementPresentation({
    required this.placement,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
  });

  final GanttTaskInspectorPlacement placement;
  final String label;
  final String summaryLabel;
  final String tooltip;
}

const ganttResizeHandleVisibilityPresentations = [
  GanttResizeHandleVisibilityPresentation(
    visibility: ky.KyGanttTaskResizeHandleVisibility.focused,
    label: 'Focus',
    summaryLabel: 'Focus shows grips on intent',
    tooltip:
        'Focus grips appear when a task is selected, hovered, or being edited.',
  ),
  GanttResizeHandleVisibilityPresentation(
    visibility: ky.KyGanttTaskResizeHandleVisibility.always,
    label: 'Always',
    summaryLabel: 'Always keeps grips visible',
    tooltip: 'Always keeps resize grips visible on editable task bars.',
  ),
];

const ganttDragSnapPresentations = [
  GanttDragSnapPresentation(
    snap: ky.KyGanttTaskDragSnap.day,
    label: 'Day',
    summaryLabel: 'Day edits are precise',
    tooltip: 'Day snap moves and resizes task bars by single-day increments.',
  ),
  GanttDragSnapPresentation(
    snap: ky.KyGanttTaskDragSnap.week,
    label: 'Week',
    summaryLabel: 'Week aligns schedules',
    tooltip: 'Week snap aligns task edits to whole-week movement.',
  ),
];

const ganttInspectorPlacementPresentations = [
  GanttInspectorPlacementPresentation(
    placement: GanttTaskInspectorPlacement.adaptive,
    label: 'Auto',
    summaryLabel: 'Auto chooses by space',
    tooltip: 'Auto places the inspector beside or below based on screen space.',
  ),
  GanttInspectorPlacementPresentation(
    placement: GanttTaskInspectorPlacement.side,
    label: 'Side',
    summaryLabel: 'Side keeps chart context',
    tooltip: 'Side docks task details beside the chart on wide screens.',
  ),
  GanttInspectorPlacementPresentation(
    placement: GanttTaskInspectorPlacement.bottom,
    label: 'Bottom',
    summaryLabel: 'Bottom preserves width',
    tooltip:
        'Bottom docks task details below the chart for more horizontal room.',
  ),
];

GanttResizeHandleVisibilityPresentation ganttResizeHandleVisibilityPresentation(
  ky.KyGanttTaskResizeHandleVisibility visibility,
) {
  for (final presentation in ganttResizeHandleVisibilityPresentations) {
    if (presentation.visibility == visibility) return presentation;
  }

  throw ArgumentError.value(
    visibility,
    'visibility',
    'Unknown resize handle visibility',
  );
}

GanttDragSnapPresentation ganttDragSnapPresentation(
  ky.KyGanttTaskDragSnap snap,
) {
  for (final presentation in ganttDragSnapPresentations) {
    if (presentation.snap == snap) return presentation;
  }

  throw ArgumentError.value(snap, 'snap', 'Unknown drag snap');
}

GanttInspectorPlacementPresentation ganttInspectorPlacementPresentation(
  GanttTaskInspectorPlacement placement,
) {
  for (final presentation in ganttInspectorPlacementPresentations) {
    if (presentation.placement == placement) return presentation;
  }

  throw ArgumentError.value(
    placement,
    'placement',
    'Unknown inspector placement',
  );
}

String ganttResizeHandleVisibilitySettingsSubtitle() {
  return ganttResizeHandleVisibilityPresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

String ganttDragSnapSettingsSubtitle() {
  return ganttDragSnapPresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

String ganttInspectorPlacementSettingsSubtitle() {
  return ganttInspectorPlacementPresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

import 'package:flutter/material.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../states/gantt_chart_interaction_provider.dart';
import 'gantt_drag_preview_detail_presentation_service.dart';
import 'gantt_interaction_feedback_depth_presentation_service.dart';
import 'gantt_interaction_segment_presentation_service.dart';

/// Toggle roles for direct Gantt chart timeline editing tools.
enum GanttChartEditToolRole { drag, resize, scheduleGuard }

const ganttChartEditToolDragChipKey = ValueKey(
  'gantt-chart-edit-tools-drag-chip',
);
const ganttChartEditToolResizeChipKey = ValueKey(
  'gantt-chart-edit-tools-resize-chip',
);
const ganttChartEditToolGuardChipKey = ValueKey(
  'gantt-chart-edit-tools-guard-chip',
);
const ganttChartEditToolBlockedPatternChipKey = ValueKey(
  'gantt-chart-edit-tools-blocked-pattern-chip',
);
const ganttChartEditToolDropTargetChipKey = ValueKey(
  'gantt-chart-edit-tools-drop-target-chip',
);
const ganttChartEditToolDragPreviewChipKey = ValueKey(
  'gantt-chart-edit-tools-drag-preview-chip',
);
const ganttChartEditToolImpactSummaryChipKey = ValueKey(
  'gantt-chart-edit-tools-impact-summary-chip',
);
const ganttChartEditToolSnapGuidesChipKey = ValueKey(
  'gantt-chart-edit-tools-snap-guides-chip',
);
const ganttChartEditToolGuideDatesChipKey = ValueKey(
  'gantt-chart-edit-tools-guide-dates-chip',
);
const ganttChartEditToolValidationWarningsChipKey = ValueKey(
  'gantt-chart-edit-tools-validation-warnings-chip',
);
const ganttChartEditToolDaySnapChipKey = ValueKey(
  'gantt-chart-edit-tools-day-snap',
);
const ganttChartEditToolWeekSnapChipKey = ValueKey(
  'gantt-chart-edit-tools-week-snap',
);
const ganttChartEditToolSubtleDepthChipKey = ValueKey(
  'gantt-chart-edit-tools-subtle-depth',
);
const ganttChartEditToolBalancedDepthChipKey = ValueKey(
  'gantt-chart-edit-tools-balanced-depth',
);
const ganttChartEditToolElevatedDepthChipKey = ValueKey(
  'gantt-chart-edit-tools-elevated-depth',
);
const ganttChartEditToolLeanPreviewChipKey = ValueKey(
  'gantt-chart-edit-tools-lean-preview',
);
const ganttChartEditToolBalancedPreviewChipKey = ValueKey(
  'gantt-chart-edit-tools-balanced-preview',
);
const ganttChartEditToolDetailedPreviewChipKey = ValueKey(
  'gantt-chart-edit-tools-detailed-preview',
);

/// Presentation metadata for one edit tool toggle chip.
class GanttChartEditToolPresentation {
  const GanttChartEditToolPresentation({
    required this.role,
    required this.key,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
    required this.icon,
  });

  final GanttChartEditToolRole role;
  final Key key;
  final String label;
  final String summaryLabel;
  final String tooltip;
  final IconData icon;
}

/// Presentation metadata for one taskbar drag snap chip.
class GanttChartEditSnapPresentation {
  const GanttChartEditSnapPresentation({
    required this.snap,
    required this.key,
    required this.icon,
  });

  final ky.KyGanttTaskDragSnap snap;
  final Key key;
  final IconData icon;

  String get label => ganttDragSnapPresentation(snap).label;

  String get tooltip => ganttDragSnapPresentation(snap).tooltip;
}

/// Presentation metadata for one taskbar feedback depth chip.
class GanttChartEditFeedbackDepthPresentation {
  const GanttChartEditFeedbackDepthPresentation({
    required this.depth,
    required this.key,
    required this.icon,
  });

  final GanttInteractionFeedbackDepth depth;
  final Key key;
  final IconData icon;

  String get label => ganttInteractionFeedbackDepthPresentation(depth).label;

  String get tooltip =>
      ganttInteractionFeedbackDepthPresentation(depth).tooltip;
}

/// Presentation metadata for one taskbar drag preview detail chip.
class GanttChartEditPreviewDetailPresentation {
  const GanttChartEditPreviewDetailPresentation({
    required this.detail,
    required this.key,
    required this.icon,
  });

  final GanttDragPreviewDetail detail;
  final Key key;
  final IconData icon;

  String get label => ganttDragPreviewDetailPresentation(detail).label;

  String get tooltip => ganttDragPreviewDetailPresentation(detail).tooltip;
}

const ganttChartEditToolPresentations = [
  GanttChartEditToolPresentation(
    role: GanttChartEditToolRole.drag,
    key: ganttChartEditToolDragChipKey,
    label: 'Drag',
    summaryLabel: 'Drag',
    tooltip: 'Drag task bars',
    icon: Icons.open_with_rounded,
  ),
  GanttChartEditToolPresentation(
    role: GanttChartEditToolRole.resize,
    key: ganttChartEditToolResizeChipKey,
    label: 'Resize',
    summaryLabel: 'Resize',
    tooltip: 'Resize task bars',
    icon: Icons.open_in_full_rounded,
  ),
  GanttChartEditToolPresentation(
    role: GanttChartEditToolRole.scheduleGuard,
    key: ganttChartEditToolGuardChipKey,
    label: 'Guard',
    summaryLabel: 'Schedule guard',
    tooltip: 'Schedule guard',
    icon: Icons.verified_user_outlined,
  ),
];

const ganttChartEditSnapPresentations = [
  GanttChartEditSnapPresentation(
    snap: ky.KyGanttTaskDragSnap.day,
    key: ganttChartEditToolDaySnapChipKey,
    icon: Icons.calendar_view_day_outlined,
  ),
  GanttChartEditSnapPresentation(
    snap: ky.KyGanttTaskDragSnap.week,
    key: ganttChartEditToolWeekSnapChipKey,
    icon: Icons.view_week_outlined,
  ),
];

const ganttChartEditFeedbackDepthPresentations = [
  GanttChartEditFeedbackDepthPresentation(
    depth: GanttInteractionFeedbackDepth.subtle,
    key: ganttChartEditToolSubtleDepthChipKey,
    icon: Icons.opacity_rounded,
  ),
  GanttChartEditFeedbackDepthPresentation(
    depth: GanttInteractionFeedbackDepth.balanced,
    key: ganttChartEditToolBalancedDepthChipKey,
    icon: Icons.blur_on_rounded,
  ),
  GanttChartEditFeedbackDepthPresentation(
    depth: GanttInteractionFeedbackDepth.elevated,
    key: ganttChartEditToolElevatedDepthChipKey,
    icon: Icons.layers_rounded,
  ),
];

const ganttChartEditPreviewDetailPresentations = [
  GanttChartEditPreviewDetailPresentation(
    detail: GanttDragPreviewDetail.lean,
    key: ganttChartEditToolLeanPreviewChipKey,
    icon: Icons.short_text_rounded,
  ),
  GanttChartEditPreviewDetailPresentation(
    detail: GanttDragPreviewDetail.balanced,
    key: ganttChartEditToolBalancedPreviewChipKey,
    icon: Icons.view_stream_outlined,
  ),
  GanttChartEditPreviewDetailPresentation(
    detail: GanttDragPreviewDetail.detailed,
    key: ganttChartEditToolDetailedPreviewChipKey,
    icon: Icons.ssid_chart_rounded,
  ),
];

GanttChartEditToolPresentation ganttChartEditToolPresentation(
  GanttChartEditToolRole role,
) {
  for (final presentation in ganttChartEditToolPresentations) {
    if (presentation.role == role) return presentation;
  }

  throw ArgumentError.value(role, 'role', 'Unknown edit tool');
}

GanttChartEditSnapPresentation ganttChartEditSnapPresentation(
  ky.KyGanttTaskDragSnap snap,
) {
  for (final presentation in ganttChartEditSnapPresentations) {
    if (presentation.snap == snap) return presentation;
  }

  throw ArgumentError.value(snap, 'snap', 'Unknown edit snap');
}

GanttChartEditFeedbackDepthPresentation ganttChartEditFeedbackDepthPresentation(
  GanttInteractionFeedbackDepth depth,
) {
  for (final presentation in ganttChartEditFeedbackDepthPresentations) {
    if (presentation.depth == depth) return presentation;
  }

  throw ArgumentError.value(depth, 'depth', 'Unknown feedback depth');
}

GanttChartEditPreviewDetailPresentation ganttChartEditPreviewDetailPresentation(
  GanttDragPreviewDetail detail,
) {
  for (final presentation in ganttChartEditPreviewDetailPresentations) {
    if (presentation.detail == detail) return presentation;
  }

  throw ArgumentError.value(detail, 'detail', 'Unknown preview detail');
}

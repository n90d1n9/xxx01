import 'package:ky_gantt/ky_gantt.dart' as ky;

import 'gantt_task_drag_preview_label_service.dart';

class GanttTaskDragPreviewDeltaSummary {
  const GanttTaskDragPreviewDeltaSummary({
    required this.beforeLabel,
    required this.afterLabel,
    required this.deltaLabel,
    required this.impactLabel,
    required this.hasDateChange,
  });

  final String beforeLabel;
  final String afterLabel;
  final String deltaLabel;
  final String impactLabel;
  final bool hasDateChange;
}

GanttTaskDragPreviewDeltaSummary ganttTaskDragPreviewDeltaSummary(
  ky.KyGanttTaskDragPreview preview,
) {
  return GanttTaskDragPreviewDeltaSummary(
    beforeLabel: ganttTaskDragPreviewOriginalDateRangeLabel(preview),
    afterLabel: ganttTaskDragPreviewDateRangeLabel(preview),
    deltaLabel: preview.deltaLabel,
    impactLabel: ganttTaskDragPreviewImpactLabel(preview),
    hasDateChange: preview.deltaDays != 0,
  );
}

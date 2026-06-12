import 'package:ky_gantt/ky_gantt.dart' as ky;

String ganttTaskDragPreviewTitle(ky.KyGanttTaskDragPreview preview) {
  return '${preview.actionLabel} ${preview.deltaLabel}';
}

String ganttTaskDragPreviewDateRangeLabel(ky.KyGanttTaskDragPreview preview) {
  return ky.ganttTaskDateRangeLabel(
    preview.task.copyWith(
      startDate: preview.startDate,
      endDate: preview.endDate,
    ),
  );
}

String ganttTaskDragPreviewOriginalDateRangeLabel(
  ky.KyGanttTaskDragPreview preview,
) {
  return ky.ganttTaskDateRangeLabel(preview.task);
}

String ganttTaskDragPreviewRangeShiftLabel(ky.KyGanttTaskDragPreview preview) {
  return '${ganttTaskDragPreviewOriginalDateRangeLabel(preview)} to '
      '${ganttTaskDragPreviewDateRangeLabel(preview)}';
}

String ganttTaskDragPreviewMetadataLabel(ky.KyGanttTaskDragPreview preview) {
  return '${ganttTaskDragPreviewDateRangeLabel(preview)} - '
      '${preview.durationLabel} - ${preview.snapLabel}';
}

String ganttTaskDragPreviewSummaryLabel(
  ky.KyGanttTaskDragPreview preview, {
  bool includeImpact = true,
}) {
  final parts = [
    ganttTaskDragPreviewTitle(preview),
    ganttTaskDragPreviewDateRangeLabel(preview),
    if (includeImpact) ganttTaskDragPreviewImpactLabel(preview),
    preview.durationLabel,
    preview.snapLabel,
    ganttTaskDragPreviewValidationTitle(preview.validation),
    if (preview.validation.message != null &&
        preview.validation.message!.isNotEmpty)
      preview.validation.message!,
  ];

  return parts.join(', ');
}

String ganttTaskDragPreviewImpactLabel(ky.KyGanttTaskDragPreview preview) {
  if (preview.deltaDays == 0) return 'No date change';

  final later = preview.deltaDays > 0;

  switch (preview.action) {
    case ky.KyGanttTaskRangePreviewAction.move:
      return later ? 'Moves later' : 'Moves earlier';
    case ky.KyGanttTaskRangePreviewAction.resizeStart:
      return later ? 'Starts later' : 'Starts earlier';
    case ky.KyGanttTaskRangePreviewAction.resizeEnd:
      return later ? 'Finishes later' : 'Finishes earlier';
  }
}

String ganttTaskDragPreviewValidationTitle(
  ky.KyGanttTaskDateRangeValidation validation,
) {
  switch (validation.severity) {
    case ky.KyGanttTaskDateRangeValidationSeverity.valid:
      return 'Ready';
    case ky.KyGanttTaskDateRangeValidationSeverity.warning:
      return 'Check';
    case ky.KyGanttTaskDateRangeValidationSeverity.error:
      return 'Blocked';
  }
}

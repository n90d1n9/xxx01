import '../states/gantt_chart_interaction_provider.dart';

class GanttDragPreviewDetailPresentation {
  const GanttDragPreviewDetailPresentation({
    required this.detail,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
  });

  final GanttDragPreviewDetail detail;
  final String label;
  final String summaryLabel;
  final String tooltip;
}

const ganttDragPreviewDetailPresentations = [
  GanttDragPreviewDetailPresentation(
    detail: GanttDragPreviewDetail.lean,
    label: 'Lean',
    summaryLabel: 'Lean hides extras',
    tooltip: 'Lean preview keeps the drag card compact.',
  ),
  GanttDragPreviewDetailPresentation(
    detail: GanttDragPreviewDetail.balanced,
    label: 'Balanced',
    summaryLabel: 'Balanced adds ghost bar',
    tooltip: 'Balanced preview adds the original versus target ghost bar.',
  ),
  GanttDragPreviewDetailPresentation(
    detail: GanttDragPreviewDetail.detailed,
    label: 'Detailed',
    summaryLabel: 'Detailed adds deltas',
    tooltip: 'Detailed preview adds ghost bar and before/after delta ranges.',
  ),
];

GanttDragPreviewDetailPresentation ganttDragPreviewDetailPresentation(
  GanttDragPreviewDetail detail,
) {
  for (final presentation in ganttDragPreviewDetailPresentations) {
    if (presentation.detail == detail) return presentation;
  }

  throw ArgumentError.value(detail, 'detail', 'Unknown drag preview detail');
}

String ganttDragPreviewDetailSettingsSubtitle() {
  return ganttDragPreviewDetailPresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

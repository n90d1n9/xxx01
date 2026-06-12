import '../states/gantt_chart_interaction_provider.dart';

/// Presentation metadata for the taskbar interaction feedback depth setting.
class GanttInteractionFeedbackDepthPresentation {
  const GanttInteractionFeedbackDepthPresentation({
    required this.depth,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
  });

  final GanttInteractionFeedbackDepth depth;
  final String label;
  final String summaryLabel;
  final String tooltip;
}

const ganttInteractionFeedbackDepthPresentations = [
  GanttInteractionFeedbackDepthPresentation(
    depth: GanttInteractionFeedbackDepth.subtle,
    label: 'Subtle',
    summaryLabel: 'Subtle keeps feedback quiet',
    tooltip:
        'Subtle feedback reduces hover opacity, shadow blur, and lift distance.',
  ),
  GanttInteractionFeedbackDepthPresentation(
    depth: GanttInteractionFeedbackDepth.balanced,
    label: 'Balanced',
    summaryLabel: 'Balanced is standard',
    tooltip:
        'Balanced feedback keeps the default hover, lift, and edit shadows.',
  ),
  GanttInteractionFeedbackDepthPresentation(
    depth: GanttInteractionFeedbackDepth.elevated,
    label: 'Elevated',
    summaryLabel: 'Elevated adds lift',
    tooltip:
        'Elevated feedback strengthens lift, shadow, and edit movement cues.',
  ),
];

GanttInteractionFeedbackDepthPresentation
ganttInteractionFeedbackDepthPresentation(GanttInteractionFeedbackDepth depth) {
  for (final presentation in ganttInteractionFeedbackDepthPresentations) {
    if (presentation.depth == depth) return presentation;
  }

  throw ArgumentError.value(depth, 'depth', 'Unknown feedback depth');
}

String ganttInteractionFeedbackDepthSettingsSubtitle() {
  return ganttInteractionFeedbackDepthPresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

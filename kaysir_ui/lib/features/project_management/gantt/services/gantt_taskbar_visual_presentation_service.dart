import '../states/gantt_chart_display_provider.dart';

/// Presentation metadata for schedule badge style choices on taskbars.
class GanttTaskBarScheduleBadgeStylePresentation {
  const GanttTaskBarScheduleBadgeStylePresentation({
    required this.style,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
  });

  final GanttTaskBarScheduleBadgeStyle style;
  final String label;
  final String summaryLabel;
  final String tooltip;
}

/// Presentation metadata for the selected task row emphasis setting.
class GanttSelectedTaskRowEmphasisPresentation {
  const GanttSelectedTaskRowEmphasisPresentation({
    required this.emphasis,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
  });

  final GanttSelectedTaskRowEmphasis emphasis;
  final String label;
  final String summaryLabel;
  final String tooltip;
}

/// Presentation metadata for taskbar depth and shadow strength choices.
class GanttTaskBarDepthPresentation {
  const GanttTaskBarDepthPresentation({
    required this.depth,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
  });

  final GanttTaskBarDepth depth;
  final String label;
  final String summaryLabel;
  final String tooltip;
}

const ganttTaskBarScheduleBadgeStylePresentations = [
  GanttTaskBarScheduleBadgeStylePresentation(
    style: GanttTaskBarScheduleBadgeStyle.full,
    label: 'Full',
    summaryLabel: 'Full shows label and accent',
    tooltip: 'Full badges show both schedule label and accent marker.',
  ),
  GanttTaskBarScheduleBadgeStylePresentation(
    style: GanttTaskBarScheduleBadgeStyle.marker,
    label: 'Marker',
    summaryLabel: 'Marker stays compact',
    tooltip: 'Marker badges use schedule color without extra label text.',
  ),
  GanttTaskBarScheduleBadgeStylePresentation(
    style: GanttTaskBarScheduleBadgeStyle.text,
    label: 'Text',
    summaryLabel: 'Text keeps labels plain',
    tooltip: 'Text badges show schedule labels without the accent marker.',
  ),
];

const ganttSelectedTaskRowEmphasisPresentations = [
  GanttSelectedTaskRowEmphasisPresentation(
    emphasis: GanttSelectedTaskRowEmphasis.subtle,
    label: 'Subtle',
    summaryLabel: 'Subtle row is quiet',
    tooltip: 'Subtle row emphasis uses a light selected-row wash.',
  ),
  GanttSelectedTaskRowEmphasisPresentation(
    emphasis: GanttSelectedTaskRowEmphasis.balanced,
    label: 'Balanced',
    summaryLabel: 'Balanced is steady',
    tooltip: 'Balanced row emphasis keeps the selected task easy to scan.',
  ),
  GanttSelectedTaskRowEmphasisPresentation(
    emphasis: GanttSelectedTaskRowEmphasis.strong,
    label: 'Strong',
    summaryLabel: 'Strong draws focus',
    tooltip: 'Strong row emphasis uses a stronger row highlight for reviews.',
  ),
];

const ganttTaskBarDepthPresentations = [
  GanttTaskBarDepthPresentation(
    depth: GanttTaskBarDepth.subtle,
    label: 'Subtle',
    summaryLabel: 'Subtle keeps bars flat',
    tooltip: 'Subtle depth uses lighter, tighter taskbar shadows.',
  ),
  GanttTaskBarDepthPresentation(
    depth: GanttTaskBarDepth.balanced,
    label: 'Balanced',
    summaryLabel: 'Balanced adds dimension',
    tooltip: 'Balanced depth keeps standard taskbar shadow and lift.',
  ),
  GanttTaskBarDepthPresentation(
    depth: GanttTaskBarDepth.elevated,
    label: 'Elevated',
    summaryLabel: 'Elevated feels lifted',
    tooltip: 'Elevated depth strengthens taskbar shadows and vertical lift.',
  ),
];

GanttTaskBarScheduleBadgeStylePresentation
ganttTaskBarScheduleBadgeStylePresentation(
  GanttTaskBarScheduleBadgeStyle style,
) {
  for (final presentation in ganttTaskBarScheduleBadgeStylePresentations) {
    if (presentation.style == style) return presentation;
  }

  throw ArgumentError.value(style, 'style', 'Unknown schedule badge style');
}

GanttSelectedTaskRowEmphasisPresentation
ganttSelectedTaskRowEmphasisPresentation(
  GanttSelectedTaskRowEmphasis emphasis,
) {
  for (final presentation in ganttSelectedTaskRowEmphasisPresentations) {
    if (presentation.emphasis == emphasis) return presentation;
  }

  throw ArgumentError.value(emphasis, 'emphasis', 'Unknown row emphasis');
}

GanttTaskBarDepthPresentation ganttTaskBarDepthPresentation(
  GanttTaskBarDepth depth,
) {
  for (final presentation in ganttTaskBarDepthPresentations) {
    if (presentation.depth == depth) return presentation;
  }

  throw ArgumentError.value(depth, 'depth', 'Unknown taskbar depth');
}

String ganttTaskBarScheduleBadgeStyleSettingsSubtitle() {
  return ganttTaskBarScheduleBadgeStylePresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

String ganttSelectedTaskRowEmphasisSettingsSubtitle() {
  return ganttSelectedTaskRowEmphasisPresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

String ganttTaskBarDepthSettingsSubtitle() {
  return ganttTaskBarDepthPresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

import 'package:flutter/material.dart';

import '../states/gantt_chart_display_provider.dart';

/// Presentation metadata for timeline marker and band emphasis choices.
class GanttTimelineAccentIntensityPresentation {
  const GanttTimelineAccentIntensityPresentation({
    required this.intensity,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
  });

  final GanttTimelineAccentIntensity intensity;
  final String label;
  final String summaryLabel;
  final String tooltip;
}

/// Presentation metadata for dependency connector line strength choices.
class GanttDependencyLineIntensityPresentation {
  const GanttDependencyLineIntensityPresentation({
    required this.intensity,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
  });

  final GanttDependencyLineIntensity intensity;
  final String label;
  final String summaryLabel;
  final String tooltip;
}

/// Presentation metadata for timeline row density choices.
class GanttChartDensityPresentation {
  const GanttChartDensityPresentation({
    required this.density,
    required this.label,
    required this.controlLabel,
    required this.controlIcon,
    required this.summaryLabel,
    required this.tooltip,
  });

  final GanttChartDensity density;
  final String label;
  final String controlLabel;
  final IconData controlIcon;
  final String summaryLabel;
  final String tooltip;
}

/// Presentation metadata for horizontal timeline scale choices.
class GanttChartTimelineZoomPresentation {
  const GanttChartTimelineZoomPresentation({
    required this.zoom,
    required this.label,
    required this.controlLabel,
    required this.controlIcon,
    required this.summaryLabel,
    required this.tooltip,
  });

  final GanttChartTimelineZoom zoom;
  final String label;
  final String controlLabel;
  final IconData controlIcon;
  final String summaryLabel;
  final String tooltip;
}

const ganttTimelineAccentIntensityPresentations = [
  GanttTimelineAccentIntensityPresentation(
    intensity: GanttTimelineAccentIntensity.subtle,
    label: 'Subtle',
    summaryLabel: 'Subtle keeps markers quiet',
    tooltip: 'Subtle emphasis softens weekend bands and today markers.',
  ),
  GanttTimelineAccentIntensityPresentation(
    intensity: GanttTimelineAccentIntensity.balanced,
    label: 'Balanced',
    summaryLabel: 'Balanced is standard',
    tooltip:
        'Balanced emphasis keeps timeline markers visible without dominating.',
  ),
  GanttTimelineAccentIntensityPresentation(
    intensity: GanttTimelineAccentIntensity.strong,
    label: 'Strong',
    summaryLabel: 'Strong raises contrast',
    tooltip: 'Strong emphasis increases weekend and today marker contrast.',
  ),
];

const ganttDependencyLineIntensityPresentations = [
  GanttDependencyLineIntensityPresentation(
    intensity: GanttDependencyLineIntensity.subtle,
    label: 'Subtle',
    summaryLabel: 'Subtle reduces connector noise',
    tooltip: 'Subtle lines keep dependencies visible with lighter strokes.',
  ),
  GanttDependencyLineIntensityPresentation(
    intensity: GanttDependencyLineIntensity.balanced,
    label: 'Balanced',
    summaryLabel: 'Balanced keeps links readable',
    tooltip: 'Balanced lines use the default dependency connector weight.',
  ),
  GanttDependencyLineIntensityPresentation(
    intensity: GanttDependencyLineIntensity.strong,
    label: 'Strong',
    summaryLabel: 'Strong highlights chains',
    tooltip: 'Strong lines increase connector opacity and stroke weight.',
  ),
];

const ganttChartDensityPresentations = [
  GanttChartDensityPresentation(
    density: GanttChartDensity.airy,
    label: 'Airy',
    controlLabel: 'Loose',
    controlIcon: Icons.height_rounded,
    summaryLabel: 'Airy gives room',
    tooltip: 'Airy rows maximize breathing room for dense task details.',
  ),
  GanttChartDensityPresentation(
    density: GanttChartDensity.cozy,
    label: 'Cozy',
    controlLabel: 'Steady',
    controlIcon: Icons.density_medium_outlined,
    summaryLabel: 'Cozy balances scan speed',
    tooltip: 'Cozy rows balance readability with more visible tasks.',
  ),
  GanttChartDensityPresentation(
    density: GanttChartDensity.dense,
    label: 'Dense',
    controlLabel: 'Tight',
    controlIcon: Icons.density_small_outlined,
    summaryLabel: 'Dense fits more work',
    tooltip: 'Dense rows fit more tasks into the visible timeline.',
  ),
];

const ganttChartTimelineZoomPresentations = [
  GanttChartTimelineZoomPresentation(
    zoom: GanttChartTimelineZoom.compact,
    label: 'Compact',
    controlLabel: 'Fit',
    controlIcon: Icons.zoom_in_map_outlined,
    summaryLabel: 'Compact fits more dates',
    tooltip: 'Compact zoom shows a wider schedule range in the same space.',
  ),
  GanttChartTimelineZoomPresentation(
    zoom: GanttChartTimelineZoom.balanced,
    label: 'Balanced',
    controlLabel: 'Normal',
    controlIcon: Icons.center_focus_strong_outlined,
    summaryLabel: 'Balanced is standard',
    tooltip: 'Balanced zoom keeps date spacing at the default scale.',
  ),
  GanttChartTimelineZoomPresentation(
    zoom: GanttChartTimelineZoom.wide,
    label: 'Wide',
    controlLabel: 'Open',
    controlIcon: Icons.zoom_out_map_outlined,
    summaryLabel: 'Wide opens spacing',
    tooltip: 'Wide zoom gives each day more horizontal room for precision.',
  ),
];

GanttTimelineAccentIntensityPresentation
ganttTimelineAccentIntensityPresentation(
  GanttTimelineAccentIntensity intensity,
) {
  for (final presentation in ganttTimelineAccentIntensityPresentations) {
    if (presentation.intensity == intensity) return presentation;
  }

  throw ArgumentError.value(
    intensity,
    'intensity',
    'Unknown timeline accent intensity',
  );
}

GanttDependencyLineIntensityPresentation
ganttDependencyLineIntensityPresentation(
  GanttDependencyLineIntensity intensity,
) {
  for (final presentation in ganttDependencyLineIntensityPresentations) {
    if (presentation.intensity == intensity) return presentation;
  }

  throw ArgumentError.value(
    intensity,
    'intensity',
    'Unknown dependency line intensity',
  );
}

GanttChartDensityPresentation ganttChartDensityPresentation(
  GanttChartDensity density,
) {
  for (final presentation in ganttChartDensityPresentations) {
    if (presentation.density == density) return presentation;
  }

  throw ArgumentError.value(density, 'density', 'Unknown chart density');
}

GanttChartTimelineZoomPresentation ganttChartTimelineZoomPresentation(
  GanttChartTimelineZoom zoom,
) {
  for (final presentation in ganttChartTimelineZoomPresentations) {
    if (presentation.zoom == zoom) return presentation;
  }

  throw ArgumentError.value(zoom, 'zoom', 'Unknown timeline zoom');
}

String ganttTimelineAccentIntensitySettingsSubtitle() {
  return ganttTimelineAccentIntensityPresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

String ganttDependencyLineIntensitySettingsSubtitle() {
  return ganttDependencyLineIntensityPresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

String ganttChartDensitySettingsSubtitle() {
  return ganttChartDensityPresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

String ganttChartTimelineZoomSettingsSubtitle() {
  return ganttChartTimelineZoomPresentations
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

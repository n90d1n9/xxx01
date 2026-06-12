import 'package:flutter/material.dart';

import 'gantt_chart_display_preset_service.dart';

/// Presentation metadata for chart appearance preset choices.
class GanttChartDisplayPresetPresentation {
  const GanttChartDisplayPresetPresentation({
    required this.preset,
    required this.label,
    required this.summaryLabel,
    required this.tooltip,
    required this.icon,
  });

  final GanttChartDisplayPreset preset;
  final String label;
  final String summaryLabel;
  final String tooltip;
  final IconData icon;

  bool get isPreset => preset != GanttChartDisplayPreset.custom;
}

const ganttChartDisplayPresetPresentations = [
  GanttChartDisplayPresetPresentation(
    preset: GanttChartDisplayPreset.compact,
    label: 'Compact',
    summaryLabel: 'Compact saves space',
    tooltip:
        'Compact preset reduces labels, bands, and visual depth for dense planning.',
    icon: Icons.density_small_outlined,
  ),
  GanttChartDisplayPresetPresentation(
    preset: GanttChartDisplayPreset.balanced,
    label: 'Balanced',
    summaryLabel: 'Balanced fits daily work',
    tooltip:
        'Balanced preset keeps the standard chart balance for everyday planning.',
    icon: Icons.dashboard_customize_outlined,
  ),
  GanttChartDisplayPresetPresentation(
    preset: GanttChartDisplayPreset.presentation,
    label: 'Present',
    summaryLabel: 'Presentation highlights ownership',
    tooltip: 'Present preset opens spacing and highlights team ownership.',
    icon: Icons.slideshow_outlined,
  ),
  GanttChartDisplayPresetPresentation(
    preset: GanttChartDisplayPreset.review,
    label: 'Review',
    summaryLabel: 'Review trims visual noise',
    tooltip:
        'Review preset reduces decorative and editing-heavy chrome for inspection.',
    icon: Icons.visibility_outlined,
  ),
  GanttChartDisplayPresetPresentation(
    preset: GanttChartDisplayPreset.custom,
    label: 'Custom',
    summaryLabel: 'Custom reflects manual tuning',
    tooltip:
        'Custom appears when display settings do not match an appearance preset.',
    icon: Icons.tune_outlined,
  ),
];

GanttChartDisplayPresetPresentation ganttChartDisplayPresetPresentation(
  GanttChartDisplayPreset preset,
) {
  for (final presentation in ganttChartDisplayPresetPresentations) {
    if (presentation.preset == preset) return presentation;
  }

  throw ArgumentError.value(preset, 'preset', 'Unknown display preset');
}

List<GanttChartDisplayPresetPresentation>
ganttChartDisplayPresetPresentationsFor(GanttChartDisplayPreset value) {
  return [
    for (final presentation in ganttChartDisplayPresetPresentations)
      if (presentation.isPreset || value == GanttChartDisplayPreset.custom)
        presentation,
  ];
}

String ganttChartDisplayPresetSettingsSubtitle() {
  return ganttChartDisplayPresetPresentations
      .where((presentation) => presentation.isPreset)
      .map((presentation) => presentation.summaryLabel)
      .join(', ');
}

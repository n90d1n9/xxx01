import 'package:flutter/material.dart';

import 'gantt_chart_quick_preset_service.dart';

/// Presentation metadata for one-click Gantt chart focus presets.
class GanttChartQuickPresetPresentation {
  const GanttChartQuickPresetPresentation({
    required this.preset,
    required this.label,
    required this.icon,
    required this.tooltip,
  });

  final GanttChartQuickPreset preset;
  final String label;
  final IconData icon;
  final String tooltip;

  bool get isPreset => preset != GanttChartQuickPreset.custom;
}

const ganttChartQuickPresetPresentations = [
  GanttChartQuickPresetPresentation(
    preset: GanttChartQuickPreset.risk,
    label: 'Risk',
    icon: Icons.warning_amber_rounded,
    tooltip:
        'Risk: Dependency Watch, Attention Window - highlights blocked '
        'dependencies and schedule conflicts.',
  ),
  GanttChartQuickPresetPresentation(
    preset: GanttChartQuickPreset.team,
    label: 'Team',
    icon: Icons.groups_2_outlined,
    tooltip:
        'Team: Active Now, Next 90 Days - emphasizes ownership, progress, '
        'and active work.',
  ),
  GanttChartQuickPresetPresentation(
    preset: GanttChartQuickPreset.milestones,
    label: 'Milestones',
    icon: Icons.flag_outlined,
    tooltip:
        'Milestones: All Tasks, Project Span - simplifies bars for a '
        'roadmap-level milestone scan.',
  ),
  GanttChartQuickPresetPresentation(
    preset: GanttChartQuickPreset.custom,
    label: 'Custom',
    icon: Icons.tune_outlined,
    tooltip: 'Custom setup uses the current chart controls.',
  ),
];

GanttChartQuickPresetPresentation ganttChartQuickPresetPresentation(
  GanttChartQuickPreset preset,
) {
  for (final presentation in ganttChartQuickPresetPresentations) {
    if (presentation.preset == preset) return presentation;
  }

  throw ArgumentError.value(preset, 'preset', 'Unknown quick preset');
}

List<GanttChartQuickPresetPresentation> ganttChartQuickPresetPresentationsFor(
  GanttChartQuickPreset value,
) {
  return [
    for (final presentation in ganttChartQuickPresetPresentations)
      if (presentation.isPreset || value == GanttChartQuickPreset.custom)
        presentation,
  ];
}

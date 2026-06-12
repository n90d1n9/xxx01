import 'package:flutter/material.dart';

import '../services/gantt_chart_quick_preset_presentation_service.dart';
import '../services/gantt_chart_quick_preset_service.dart';
import '../services/gantt_chart_quick_preset_summary_service.dart';
import '../services/gantt_saved_view_service.dart';
import '../services/gantt_timeline_range_preset_service.dart';
import '../states/gantt_chart_display_provider.dart';
import 'gantt_control_strip_primitives.dart';

/// Compact quick-preset strip for applying chart focus and timeline lens.
class GanttChartQuickPresetStrip extends StatelessWidget {
  const GanttChartQuickPresetStrip({
    required this.displayPreferences,
    required this.onChanged,
    this.onTimelineViewChanged,
    this.onRangePresetChanged,
    this.showLensSummary = true,
    this.showPresetTooltips = true,
    super.key,
  });

  static Key presetChipKey(GanttChartQuickPreset preset) {
    return ValueKey('gantt-chart-quick-preset-${preset.name}');
  }

  final GanttChartDisplayPreferences displayPreferences;
  final ValueChanged<GanttChartDisplayPreferences> onChanged;
  final ValueChanged<GanttTimelineViewPreset>? onTimelineViewChanged;
  final ValueChanged<GanttTimelineRangePreset>? onRangePresetChanged;
  final bool showLensSummary;
  final bool showPresetTooltips;

  @override
  Widget build(BuildContext context) {
    const service = GanttChartQuickPresetService();
    const summaryService = GanttChartQuickPresetSummaryService();
    final value = service.presetFor(displayPreferences);
    final selectedSummary = summaryService.summaryFor(
      value,
      showLensSummary: showLensSummary,
    );
    final options = [
      for (final presentation in ganttChartQuickPresetPresentationsFor(value))
        GanttControlChipOption(
          key: presetChipKey(presentation.preset),
          value: presentation.preset,
          label: presentation.label,
          icon: presentation.icon,
          tooltip: _tooltipFor(presentation),
          enabled: presentation.isPreset,
        ),
    ];

    return GanttControlStripShell(
      title: 'Chart focus',
      subtitle: selectedSummary.subtitle,
      icon: Icons.bolt_outlined,
      accent: GanttControlAccent.tertiary,
      children: [
        GanttControlChipGroup<GanttChartQuickPreset>(
          label: 'Preset',
          value: value,
          options: options,
          accent: GanttControlAccent.tertiary,
          onChanged: (preset) {
            if (!ganttChartQuickPresetPresentation(preset).isPreset) return;

            final snapshot = service.snapshotFor(preset);
            onChanged(snapshot.displayPreferences);

            final timelineView = snapshot.timelineView;
            if (timelineView != null) onTimelineViewChanged?.call(timelineView);

            final rangePreset = snapshot.rangePreset;
            if (rangePreset != null) onRangePresetChanged?.call(rangePreset);
          },
        ),
      ],
    );
  }

  String? _tooltipFor(GanttChartQuickPresetPresentation presentation) {
    if (!showPresetTooltips) return null;

    return presentation.tooltip;
  }
}

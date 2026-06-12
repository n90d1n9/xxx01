import 'package:flutter/material.dart';

import '../services/gantt_chart_control_label_service.dart';
import '../services/gantt_timeline_visual_presentation_service.dart';
import '../states/gantt_chart_display_provider.dart';
import 'gantt_control_strip_primitives.dart';

/// Header control strip for row density and horizontal timeline scale.
class GanttChartViewportControlStrip extends StatelessWidget {
  const GanttChartViewportControlStrip({
    required this.displayPreferences,
    required this.onChanged,
    super.key,
  });

  static const airyRowsChipKey = ValueKey('gantt-chart-viewport-rows-airy');
  static const cozyRowsChipKey = ValueKey('gantt-chart-viewport-rows-cozy');
  static const denseRowsChipKey = ValueKey('gantt-chart-viewport-rows-dense');
  static const compactScaleChipKey = ValueKey(
    'gantt-chart-viewport-scale-compact',
  );
  static const balancedScaleChipKey = ValueKey(
    'gantt-chart-viewport-scale-balanced',
  );
  static const wideScaleChipKey = ValueKey('gantt-chart-viewport-scale-wide');

  static Key densityChipKey(GanttChartDensity density) {
    switch (density) {
      case GanttChartDensity.airy:
        return airyRowsChipKey;
      case GanttChartDensity.cozy:
        return cozyRowsChipKey;
      case GanttChartDensity.dense:
        return denseRowsChipKey;
    }
  }

  static Key timelineZoomChipKey(GanttChartTimelineZoom zoom) {
    switch (zoom) {
      case GanttChartTimelineZoom.compact:
        return compactScaleChipKey;
      case GanttChartTimelineZoom.balanced:
        return balancedScaleChipKey;
      case GanttChartTimelineZoom.wide:
        return wideScaleChipKey;
    }
  }

  final GanttChartDisplayPreferences displayPreferences;
  final ValueChanged<GanttChartDisplayPreferences> onChanged;

  @override
  Widget build(BuildContext context) {
    return GanttControlStripShell(
      title: 'Viewport',
      subtitle: ganttChartViewportStripSubtitleLabel(displayPreferences),
      icon: Icons.view_week_outlined,
      accent: GanttControlAccent.secondary,
      spacing: 16,
      children: [
        GanttControlChipGroup<GanttChartDensity>(
          label: 'Rows',
          value: displayPreferences.density,
          accent: GanttControlAccent.secondary,
          options: [
            for (final presentation in ganttChartDensityPresentations)
              GanttControlChipOption(
                key: densityChipKey(presentation.density),
                value: presentation.density,
                label: presentation.controlLabel,
                icon: presentation.controlIcon,
                tooltip: presentation.tooltip,
              ),
          ],
          onChanged:
              (value) => onChanged(displayPreferences.copyWith(density: value)),
        ),
        GanttControlChipGroup<GanttChartTimelineZoom>(
          label: 'Scale',
          value: displayPreferences.timelineZoom,
          accent: GanttControlAccent.secondary,
          options: [
            for (final presentation in ganttChartTimelineZoomPresentations)
              GanttControlChipOption(
                key: timelineZoomChipKey(presentation.zoom),
                value: presentation.zoom,
                label: presentation.controlLabel,
                icon: presentation.controlIcon,
                tooltip: presentation.tooltip,
              ),
          ],
          onChanged:
              (value) =>
                  onChanged(displayPreferences.copyWith(timelineZoom: value)),
        ),
      ],
    );
  }
}

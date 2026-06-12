import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/gantt_timeline_range_preset_service.dart';
import '../services/gantt_timeline_viewport_presentation_service.dart';
import '../services/gantt_timeline_viewport_summary_service.dart';
import 'gantt_control_strip_primitives.dart';

/// Header control strip for timeline viewport visibility and range jumps.
class GanttTimelineViewportNavigator extends StatelessWidget {
  const GanttTimelineViewportNavigator({
    required this.rangePreset,
    required this.visibleTaskCount,
    required this.totalTaskCount,
    required this.onPresetSelected,
    super.key,
  });

  static const todayButtonKey = ganttViewportTodayButtonKey;
  static const attentionButtonKey = ganttViewportAttentionButtonKey;
  static const fitAllButtonKey = ganttViewportFitAllButtonKey;

  final GanttTimelineRangePreset rangePreset;
  final int visibleTaskCount;
  final int totalTaskCount;
  final ValueChanged<GanttTimelineRangePreset> onPresetSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final summary = const GanttTimelineViewportSummaryService().summaryFor(
      rangePreset: rangePreset,
      visibleTaskCount: visibleTaskCount,
      totalTaskCount: totalTaskCount,
    );
    final visibilityPresentation = ganttTimelineViewportVisibilityPresentation(
      summary.visibilityState,
    );
    const hiddenPresentation = ganttTimelineViewportHiddenPresentation;

    return GanttControlStripShell(
      title: 'Navigate timeline',
      subtitle: summary.subtitle,
      icon: Icons.travel_explore_outlined,
      accent: GanttControlAccent.primary,
      children: [
        AppStatusPill(
          label: summary.stateLabel,
          tooltip: summary.visibilityTooltip,
          icon: visibilityPresentation.icon,
          color: _accentColor(colorScheme, visibilityPresentation.accent),
          maxWidth: visibilityPresentation.maxWidth,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        ),
        if (summary.hiddenLabel != null)
          AppStatusPill(
            label: summary.hiddenLabel!,
            tooltip: hiddenPresentation.tooltip,
            icon: hiddenPresentation.icon,
            color: _accentColor(colorScheme, hiddenPresentation.accent),
            maxWidth: hiddenPresentation.maxWidth,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          ),
        for (final presentation in ganttTimelineViewportActionPresentations)
          _ViewportActionButton(
            presentation: presentation,
            active: rangePreset == presentation.rangePreset,
            onPressed: () => onPresetSelected(presentation.rangePreset),
          ),
      ],
    );
  }

  Color _accentColor(
    ColorScheme colorScheme,
    GanttTimelineViewportAccent accent,
  ) {
    switch (accent) {
      case GanttTimelineViewportAccent.neutral:
        return colorScheme.onSurfaceVariant;
      case GanttTimelineViewportAccent.primary:
        return colorScheme.primary;
      case GanttTimelineViewportAccent.tertiary:
        return colorScheme.tertiary;
    }
  }
}

class _ViewportActionButton extends StatelessWidget {
  const _ViewportActionButton({
    required this.presentation,
    required this.active,
    required this.onPressed,
  });

  final GanttTimelineViewportActionPresentation presentation;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: presentation.tooltip,
      child: AppActionButton(
        key: presentation.key,
        label: presentation.label,
        icon: presentation.icon,
        compact: true,
        height: 34,
        variant:
            active
                ? AppActionButtonVariant.primary
                : AppActionButtonVariant.secondary,
        onPressed: active ? null : onPressed,
      ),
    );
  }
}

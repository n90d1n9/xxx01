import 'gantt_chart_control_label_service.dart';
import 'gantt_drag_preview_detail_presentation_service.dart';
import 'gantt_saved_view_service.dart';
import 'gantt_timeline_saved_view_presentation_service.dart';
import 'gantt_timeline_range_preset_service.dart';
import '../states/gantt_chart_display_provider.dart';
import '../states/gantt_chart_interaction_provider.dart';

enum GanttChartCompactControlSummaryRole {
  quickPreset,
  timelineLens,
  chartLayers,
  dependencyFocus,
  viewport,
  editTools,
  dragSnap,
  previewDetail,
}

/// One collapsed-control item shown in the compact Gantt header summary.
class GanttChartCompactControlSummaryItem {
  const GanttChartCompactControlSummaryItem({
    required this.role,
    required this.label,
    required this.tooltip,
  });

  final GanttChartCompactControlSummaryRole role;
  final String label;
  final String tooltip;
}

/// Snapshot for the collapsed Gantt header setup summary.
class GanttChartCompactControlSummarySnapshot {
  const GanttChartCompactControlSummarySnapshot({
    required this.title,
    required this.headline,
    required this.items,
  });

  final String title;
  final String headline;
  final List<GanttChartCompactControlSummaryItem> items;

  String get semanticsLabel {
    final itemLabels = items.map((item) => item.label).join(', ');
    return '$title. $headline. Active controls: $itemLabels.';
  }
}

/// Builds compact header copy from display, interaction, and timeline state.
class GanttChartCompactControlSummaryService {
  const GanttChartCompactControlSummaryService();

  GanttChartCompactControlSummarySnapshot summaryFor({
    required GanttChartDisplayPreferences displayPreferences,
    required GanttChartInteractionPreferences interactionPreferences,
    required GanttTimelineViewPreset timelineView,
    required GanttTimelineRangePreset rangePreset,
  }) {
    final quickPresetLabel = ganttChartQuickPresetSummaryLabel(
      displayPreferences,
    );
    final timelineLensLabel = ganttChartTimelineLensSummaryLabel(
      timelineView,
      rangePreset,
    );
    final timelineViewLabel =
        ganttTimelineSavedViewPresentation(timelineView).label;
    final layerLabel = ganttChartLayerCountLabel(displayPreferences);
    final dependencyFocusLabel = ganttChartDependencyFocusControlLabel(
      displayPreferences,
    );
    final viewportLabel = ganttChartViewportControlLabel(displayPreferences);
    final editToolLabel = ganttChartEditToolCountLabel(interactionPreferences);
    final dragSnapLabel = ganttChartDragSnapSummaryLabel(
      interactionPreferences,
    );
    final previewDetailItem = _previewDetailItem(interactionPreferences);

    return GanttChartCompactControlSummarySnapshot(
      title: 'Chart setup',
      headline: [
        quickPresetLabel,
        timelineLensLabel,
        layerLabel,
        editToolLabel,
      ].join(' - '),
      items: [
        GanttChartCompactControlSummaryItem(
          role: GanttChartCompactControlSummaryRole.quickPreset,
          label: quickPresetLabel,
          tooltip: 'Quick preset: $quickPresetLabel',
        ),
        GanttChartCompactControlSummaryItem(
          role: GanttChartCompactControlSummaryRole.timelineLens,
          label: timelineLensLabel,
          tooltip:
              'Timeline lens: $timelineViewLabel; range: ${rangePreset.label}',
        ),
        GanttChartCompactControlSummaryItem(
          role: GanttChartCompactControlSummaryRole.chartLayers,
          label: layerLabel,
          tooltip: ganttChartLayerDetailLabel(displayPreferences),
        ),
        GanttChartCompactControlSummaryItem(
          role: GanttChartCompactControlSummaryRole.dependencyFocus,
          label: dependencyFocusLabel,
          tooltip: ganttChartDependencyFocusDetailLabel(displayPreferences),
        ),
        GanttChartCompactControlSummaryItem(
          role: GanttChartCompactControlSummaryRole.viewport,
          label: viewportLabel,
          tooltip: ganttChartViewportDetailLabel(displayPreferences),
        ),
        GanttChartCompactControlSummaryItem(
          role: GanttChartCompactControlSummaryRole.editTools,
          label: editToolLabel,
          tooltip: ganttChartEditToolDetailLabel(interactionPreferences),
        ),
        GanttChartCompactControlSummaryItem(
          role: GanttChartCompactControlSummaryRole.dragSnap,
          label: dragSnapLabel,
          tooltip: ganttChartDragSnapDetailLabel(interactionPreferences),
        ),
        previewDetailItem,
      ],
    );
  }

  GanttChartCompactControlSummaryItem _previewDetailItem(
    GanttChartInteractionPreferences preferences,
  ) {
    final hasTimelineEditing =
        preferences.enableTaskBarDrag || preferences.enableTaskBarResize;
    if (!hasTimelineEditing) {
      return const GanttChartCompactControlSummaryItem(
        role: GanttChartCompactControlSummaryRole.previewDetail,
        label: 'Preview idle',
        tooltip: 'Drag preview is idle until drag or resize is enabled',
      );
    }
    if (!preferences.showDragPreview) {
      return const GanttChartCompactControlSummaryItem(
        role: GanttChartCompactControlSummaryRole.previewDetail,
        label: 'Preview off',
        tooltip: 'Drag preview is hidden while editing',
      );
    }
    if (!preferences.showDragImpactSummary) {
      return const GanttChartCompactControlSummaryItem(
        role: GanttChartCompactControlSummaryRole.previewDetail,
        label: 'Basic preview',
        tooltip: 'Drag preview shows live dates without impact summary',
      );
    }

    final presentation = ganttDragPreviewDetailPresentation(
      preferences.dragPreviewDetail,
    );
    return GanttChartCompactControlSummaryItem(
      role: GanttChartCompactControlSummaryRole.previewDetail,
      label: '${presentation.label} preview',
      tooltip: presentation.tooltip,
    );
  }
}

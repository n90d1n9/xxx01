import 'gantt_timeline_range_preset_service.dart';

/// Visibility state for the currently selected timeline viewport.
enum GanttTimelineViewportVisibilityState { empty, complete, filtered }

/// Summary of visible and hidden task counts in a timeline viewport.
class GanttTimelineViewportSummary {
  const GanttTimelineViewportSummary({
    required this.rangePreset,
    required this.visibleTaskCount,
    required this.totalTaskCount,
    required this.visibilityState,
  });

  final GanttTimelineRangePreset rangePreset;
  final int visibleTaskCount;
  final int totalTaskCount;
  final GanttTimelineViewportVisibilityState visibilityState;

  int get hiddenTaskCount => totalTaskCount - visibleTaskCount;

  String get subtitle => '${rangePreset.label} - $visibilityLabel';

  String get visibilityLabel {
    if (totalTaskCount <= 0) return 'No tasks';
    return '$visibleTaskCount of $totalTaskCount tasks visible';
  }

  String? get hiddenLabel {
    if (hiddenTaskCount <= 0) return null;
    return '$hiddenTaskCount filtered out';
  }

  String get stateLabel {
    switch (visibilityState) {
      case GanttTimelineViewportVisibilityState.empty:
        return 'Empty';
      case GanttTimelineViewportVisibilityState.complete:
        return 'All visible';
      case GanttTimelineViewportVisibilityState.filtered:
        return 'Filtered';
    }
  }

  String get visibilityTooltip {
    switch (visibilityState) {
      case GanttTimelineViewportVisibilityState.empty:
        return 'No tasks are available for this timeline scope';
      case GanttTimelineViewportVisibilityState.complete:
        return 'All timeline tasks are visible in the current scope';
      case GanttTimelineViewportVisibilityState.filtered:
        return '$hiddenTaskCount tasks are hidden by current filters or focus';
    }
  }
}

/// Builds timeline viewport summaries from range preset and task counts.
class GanttTimelineViewportSummaryService {
  const GanttTimelineViewportSummaryService();

  GanttTimelineViewportSummary summaryFor({
    required GanttTimelineRangePreset rangePreset,
    required int visibleTaskCount,
    required int totalTaskCount,
  }) {
    final normalizedTotal = totalTaskCount < 0 ? 0 : totalTaskCount;
    final normalizedVisible =
        visibleTaskCount.clamp(0, normalizedTotal).toInt();

    return GanttTimelineViewportSummary(
      rangePreset: rangePreset,
      visibleTaskCount: normalizedVisible,
      totalTaskCount: normalizedTotal,
      visibilityState: _stateFor(
        visibleTaskCount: normalizedVisible,
        totalTaskCount: normalizedTotal,
      ),
    );
  }

  GanttTimelineViewportVisibilityState _stateFor({
    required int visibleTaskCount,
    required int totalTaskCount,
  }) {
    if (totalTaskCount <= 0) return GanttTimelineViewportVisibilityState.empty;
    if (visibleTaskCount >= totalTaskCount) {
      return GanttTimelineViewportVisibilityState.complete;
    }

    return GanttTimelineViewportVisibilityState.filtered;
  }
}

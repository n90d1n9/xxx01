import 'gantt_saved_view_service.dart';
import 'gantt_timeline_saved_view_presentation_service.dart';

/// Count-aware summary copy for one saved Gantt timeline view.
class GanttTimelineSavedViewSummary {
  const GanttTimelineSavedViewSummary({
    required this.preset,
    required this.count,
    required this.intentLabel,
    required this.tooltip,
  });

  final GanttTimelineViewPreset preset;
  final int count;
  final String intentLabel;
  final String tooltip;
}

/// Builds saved-view summaries from preset metadata and matching task counts.
class GanttTimelineSavedViewSummaryService {
  const GanttTimelineSavedViewSummaryService();

  GanttTimelineSavedViewSummary summaryFor({
    required GanttTimelineViewPreset preset,
    required int count,
  }) {
    final normalizedCount = count < 0 ? 0 : count;
    final presentation = ganttTimelineSavedViewPresentation(preset);

    return GanttTimelineSavedViewSummary(
      preset: preset,
      count: normalizedCount,
      intentLabel: presentation.intentLabel,
      tooltip:
          '${presentation.label}: ${_countSentence(normalizedCount)} '
          '${presentation.detail}',
    );
  }

  String _countSentence(int count) {
    if (count == 0) return 'No matching tasks.';
    if (count == 1) return '1 matching task.';

    return '$count matching tasks.';
  }
}

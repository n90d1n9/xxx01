import 'gantt_saved_view_service.dart';
import 'gantt_timeline_range_preset_service.dart';
import '../states/gantt_filter_provider.dart';

/// Summary of currently applied timeline focus layers.
class GanttActiveFocusSummary {
  const GanttActiveFocusSummary({
    required this.activeFocusCount,
    required this.headline,
    this.resultLabel,
    this.filteredOutLabel,
  });

  final int activeFocusCount;
  final String headline;
  final String? resultLabel;
  final String? filteredOutLabel;

  bool get hasFocus => activeFocusCount > 0;
}

/// Builds concise active-focus labels from current Gantt filter state.
class GanttActiveFocusSummaryService {
  const GanttActiveFocusSummaryService();

  GanttActiveFocusSummary summaryFor({
    required String query,
    required bool hasProjectFocus,
    required bool hasBranchFocus,
    required GanttTaskStatusFilter statusFilter,
    required GanttTimelineViewPreset viewPreset,
    required GanttTimelineRangePreset rangePreset,
    int? visibleTaskCount,
    int? totalTaskCount,
  }) {
    final normalizedQuery = query.trim();
    final activeFocusCount =
        [
          hasProjectFocus,
          hasBranchFocus,
          viewPreset != GanttTimelineViewPreset.all,
          rangePreset != GanttTimelineRangePreset.planningWindow,
          statusFilter != GanttTaskStatusFilter.all,
          normalizedQuery.isNotEmpty,
        ].where((active) => active).length;

    return GanttActiveFocusSummary(
      activeFocusCount: activeFocusCount,
      headline: _headlineFor(activeFocusCount),
      resultLabel: _resultLabel(
        visibleTaskCount: visibleTaskCount,
        totalTaskCount: totalTaskCount,
      ),
      filteredOutLabel: _filteredOutLabel(
        visibleTaskCount: visibleTaskCount,
        totalTaskCount: totalTaskCount,
      ),
    );
  }

  String _headlineFor(int activeFocusCount) {
    if (activeFocusCount <= 0) return 'No focus layers active';

    return '$activeFocusCount focus '
        '${activeFocusCount == 1 ? 'layer' : 'layers'} active';
  }

  String? _resultLabel({
    required int? visibleTaskCount,
    required int? totalTaskCount,
  }) {
    final visible = visibleTaskCount;
    final total = totalTaskCount;
    if (visible == null || total == null || total <= 0) return null;

    final normalizedVisible = visible.clamp(0, total).toInt();
    return '$normalizedVisible of $total shown';
  }

  String? _filteredOutLabel({
    required int? visibleTaskCount,
    required int? totalTaskCount,
  }) {
    final visible = visibleTaskCount;
    final total = totalTaskCount;
    if (visible == null || total == null || total <= 0) return null;

    final normalizedVisible = visible.clamp(0, total).toInt();
    final hiddenCount = total - normalizedVisible;
    if (hiddenCount <= 0) return null;

    return '$hiddenCount filtered out';
  }
}

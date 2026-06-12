import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_viewport_summary_service.dart';

void main() {
  group('GanttTimelineViewportSummaryService', () {
    const service = GanttTimelineViewportSummaryService();

    test('summarizes a fully visible viewport', () {
      final summary = service.summaryFor(
        rangePreset: GanttTimelineRangePreset.planningWindow,
        visibleTaskCount: 7,
        totalTaskCount: 7,
      );

      expect(
        summary.visibilityState,
        GanttTimelineViewportVisibilityState.complete,
      );
      expect(summary.visibilityLabel, '7 of 7 tasks visible');
      expect(summary.hiddenLabel, isNull);
      expect(summary.stateLabel, 'All visible');
      expect(summary.subtitle, 'Planning Window - 7 of 7 tasks visible');
    });

    test('summarizes a filtered viewport', () {
      final summary = service.summaryFor(
        rangePreset: GanttTimelineRangePreset.attentionWindow,
        visibleTaskCount: 3,
        totalTaskCount: 9,
      );

      expect(
        summary.visibilityState,
        GanttTimelineViewportVisibilityState.filtered,
      );
      expect(summary.visibilityLabel, '3 of 9 tasks visible');
      expect(summary.hiddenLabel, '6 filtered out');
      expect(summary.stateLabel, 'Filtered');
      expect(
        summary.visibilityTooltip,
        '6 tasks are hidden by current filters or focus',
      );
    });

    test('normalizes empty and impossible counts', () {
      final empty = service.summaryFor(
        rangePreset: GanttTimelineRangePreset.projectSpan,
        visibleTaskCount: -2,
        totalTaskCount: -1,
      );
      final clamped = service.summaryFor(
        rangePreset: GanttTimelineRangePreset.projectSpan,
        visibleTaskCount: 20,
        totalTaskCount: 4,
      );

      expect(empty.visibilityState, GanttTimelineViewportVisibilityState.empty);
      expect(empty.visibilityLabel, 'No tasks');
      expect(empty.hiddenLabel, isNull);
      expect(clamped.visibilityLabel, '4 of 4 tasks visible');
      expect(clamped.hiddenLabel, isNull);
    });
  });
}

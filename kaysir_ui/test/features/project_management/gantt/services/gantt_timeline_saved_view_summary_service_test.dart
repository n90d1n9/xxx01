import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_saved_view_summary_service.dart';

void main() {
  group('GanttTimelineSavedViewSummaryService', () {
    const service = GanttTimelineSavedViewSummaryService();

    test('describes every saved timeline view', () {
      final all = service.summaryFor(
        preset: GanttTimelineViewPreset.all,
        count: 7,
      );
      final active = service.summaryFor(
        preset: GanttTimelineViewPreset.activeNow,
        count: 1,
      );
      final dependencyWatch = service.summaryFor(
        preset: GanttTimelineViewPreset.dependencyWatch,
        count: 2,
      );

      expect(all.intentLabel, 'Complete schedule');
      expect(all.tooltip, contains('7 matching tasks'));
      expect(all.tooltip, contains('every task'));

      expect(active.intentLabel, 'In-flight work');
      expect(active.tooltip, contains('1 matching task'));
      expect(active.tooltip, contains('active today'));

      expect(dependencyWatch.intentLabel, 'Dependency attention');
      expect(dependencyWatch.tooltip, contains('2 matching tasks'));
      expect(dependencyWatch.tooltip, contains('missing dependencies'));
    });

    test('normalizes empty or invalid counts', () {
      final summary = service.summaryFor(
        preset: GanttTimelineViewPreset.readyNext,
        count: -4,
      );

      expect(summary.count, 0);
      expect(summary.intentLabel, 'Ready starts');
      expect(summary.tooltip, contains('No matching tasks'));
      expect(summary.tooltip, contains('clear dependencies'));
    });
  });
}

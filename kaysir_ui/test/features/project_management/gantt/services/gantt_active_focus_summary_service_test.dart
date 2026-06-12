import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_active_focus_summary_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_filter_provider.dart';

void main() {
  group('GanttActiveFocusSummaryService', () {
    const service = GanttActiveFocusSummaryService();

    test('stays inactive for the default timeline focus', () {
      final summary = service.summaryFor(
        query: '',
        hasProjectFocus: false,
        hasBranchFocus: false,
        statusFilter: GanttTaskStatusFilter.all,
        viewPreset: GanttTimelineViewPreset.all,
        rangePreset: GanttTimelineRangePreset.planningWindow,
        visibleTaskCount: 5,
        totalTaskCount: 5,
      );

      expect(summary.hasFocus, isFalse);
      expect(summary.activeFocusCount, 0);
      expect(summary.headline, 'No focus layers active');
      expect(summary.resultLabel, '5 of 5 shown');
      expect(summary.filteredOutLabel, isNull);
    });

    test('counts active focus layers and filtered tasks', () {
      final summary = service.summaryFor(
        query: ' release ',
        hasProjectFocus: true,
        hasBranchFocus: true,
        statusFilter: GanttTaskStatusFilter.inProgress,
        viewPreset: GanttTimelineViewPreset.dependencyWatch,
        rangePreset: GanttTimelineRangePreset.attentionWindow,
        visibleTaskCount: 3,
        totalTaskCount: 9,
      );

      expect(summary.hasFocus, isTrue);
      expect(summary.activeFocusCount, 6);
      expect(summary.headline, '6 focus layers active');
      expect(summary.resultLabel, '3 of 9 shown');
      expect(summary.filteredOutLabel, '6 filtered out');
    });

    test('clamps impossible visible counts', () {
      final summary = service.summaryFor(
        query: 'x',
        hasProjectFocus: false,
        hasBranchFocus: false,
        statusFilter: GanttTaskStatusFilter.all,
        viewPreset: GanttTimelineViewPreset.all,
        rangePreset: GanttTimelineRangePreset.planningWindow,
        visibleTaskCount: 20,
        totalTaskCount: 4,
      );

      expect(summary.resultLabel, '4 of 4 shown');
      expect(summary.filteredOutLabel, isNull);
    });
  });
}

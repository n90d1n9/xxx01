import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_timeline_focus_intent_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_filter_provider.dart';

void main() {
  group('GanttChartTimelineFocusIntentService', () {
    const service = GanttChartTimelineFocusIntentService();
    const dispatcher = GanttChartTimelineFocusIntentDispatcher();

    test('clears every timeline focus layer', () {
      final result = service.clearAll(_focusedSnapshot);

      expect(result.clearSearchController, isTrue);
      expect(result.applyRangePreset, isTrue);
      expect(result.focus.query, isEmpty);
      expect(result.focus.projectId, isNull);
      expect(result.focus.branchFocusTaskId, isNull);
      expect(result.focus.viewPreset, GanttTimelineViewPreset.all);
      expect(result.focus.rangePreset, GanttTimelineRangePreset.planningWindow);
      expect(result.focus.statusFilter, GanttTaskStatusFilter.all);
    });

    test('clears individual focus layers without disturbing the rest', () {
      expect(service.clearProject(_focusedSnapshot).focus.projectId, isNull);
      expect(
        service.clearProject(_focusedSnapshot).focus.branchFocusTaskId,
        _focusedSnapshot.branchFocusTaskId,
      );

      expect(
        service.clearBranch(_focusedSnapshot).focus.branchFocusTaskId,
        isNull,
      );
      expect(
        service.clearView(_focusedSnapshot).focus.viewPreset,
        GanttTimelineViewPreset.all,
      );
      expect(
        service.clearStatus(_focusedSnapshot).focus.statusFilter,
        GanttTaskStatusFilter.all,
      );

      final queryResult = service.clearQuery(_focusedSnapshot);
      expect(queryResult.focus.query, isEmpty);
      expect(queryResult.clearSearchController, isTrue);
      expect(queryResult.applyRangePreset, isFalse);
      expect(queryResult.focus.projectId, _focusedSnapshot.projectId);
    });

    test('clears range preset and asks caller to apply the default range', () {
      final result = service.clearRange(_focusedSnapshot);

      expect(result.focus.rangePreset, GanttTimelineRangePreset.planningWindow);
      expect(result.applyRangePreset, isTrue);
      expect(result.clearSearchController, isFalse);
      expect(result.focus.query, _focusedSnapshot.query);
    });

    test('delegates date range calculation for presets', () {
      final tasks = [
        gantt.GanttTask(
          id: 'alpha',
          title: 'Alpha',
          startDate: DateTime(2026, 5, 5),
          endDate: DateTime(2026, 5, 10),
          progress: 0.4,
        ),
      ];

      final range = service.rangeForPreset(
        preset: GanttTimelineRangePreset.projectSpan,
        tasks: tasks,
      );

      expect(
        range,
        DateTimeRange(start: DateTime(2026, 5, 2), end: DateTime(2026, 5, 13)),
      );
    });

    test('dispatches clear-search, focus, and range preset in order', () {
      final operations = <String>[];

      dispatcher.dispatch(
        intent: service.clearAll(_focusedSnapshot),
        onClearSearchController: () => operations.add('clear-search'),
        onApplyFocus:
            (focus) => operations.add('focus-${focus.rangePreset.name}'),
        onApplyRangePreset: (preset) => operations.add('range-${preset.name}'),
      );

      expect(operations, [
        'clear-search',
        'focus-planningWindow',
        'range-planningWindow',
      ]);
    });

    test('dispatches focused updates without optional side effects', () {
      final operations = <String>[];

      dispatcher.dispatch(
        intent: service.clearProject(_focusedSnapshot),
        onClearSearchController: () => operations.add('clear-search'),
        onApplyFocus: (focus) => operations.add('project-${focus.projectId}'),
        onApplyRangePreset: (preset) => operations.add('range-${preset.name}'),
      );

      expect(operations, ['project-null']);
    });
  });
}

const _focusedSnapshot = GanttChartTimelineFocusSnapshot(
  query: 'release',
  projectId: 'project-alpha',
  branchFocusTaskId: 'branch-beta',
  viewPreset: GanttTimelineViewPreset.dependencyWatch,
  rangePreset: GanttTimelineRangePreset.attentionWindow,
  statusFilter: GanttTaskStatusFilter.inProgress,
);

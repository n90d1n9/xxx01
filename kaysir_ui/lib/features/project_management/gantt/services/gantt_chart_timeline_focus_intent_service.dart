import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;
import '../states/gantt_filter_provider.dart';
import 'gantt_saved_view_service.dart';
import 'gantt_timeline_range_preset_service.dart';

/// Current timeline focus state controlled by the full-screen Gantt chart.
class GanttChartTimelineFocusSnapshot {
  const GanttChartTimelineFocusSnapshot({
    required this.query,
    required this.projectId,
    required this.branchFocusTaskId,
    required this.viewPreset,
    required this.rangePreset,
    required this.statusFilter,
  });

  final String query;
  final String? projectId;
  final String? branchFocusTaskId;
  final GanttTimelineViewPreset viewPreset;
  final GanttTimelineRangePreset rangePreset;
  final GanttTaskStatusFilter statusFilter;

  GanttChartTimelineFocusSnapshot copyWith({
    String? query,
    String? projectId,
    bool clearProjectId = false,
    String? branchFocusTaskId,
    bool clearBranchFocusTaskId = false,
    GanttTimelineViewPreset? viewPreset,
    GanttTimelineRangePreset? rangePreset,
    GanttTaskStatusFilter? statusFilter,
  }) {
    return GanttChartTimelineFocusSnapshot(
      query: query ?? this.query,
      projectId: clearProjectId ? null : projectId ?? this.projectId,
      branchFocusTaskId:
          clearBranchFocusTaskId
              ? null
              : branchFocusTaskId ?? this.branchFocusTaskId,
      viewPreset: viewPreset ?? this.viewPreset,
      rangePreset: rangePreset ?? this.rangePreset,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

/// Result of a timeline focus intent before the screen writes provider state.
class GanttChartTimelineFocusIntentResult {
  const GanttChartTimelineFocusIntentResult({
    required this.focus,
    required this.clearSearchController,
    required this.applyRangePreset,
  });

  final GanttChartTimelineFocusSnapshot focus;
  final bool clearSearchController;
  final bool applyRangePreset;
}

/// Applies timeline focus intent results through caller-owned state callbacks.
class GanttChartTimelineFocusIntentDispatcher {
  const GanttChartTimelineFocusIntentDispatcher();

  void dispatch({
    required GanttChartTimelineFocusIntentResult intent,
    required void Function() onClearSearchController,
    required void Function(GanttChartTimelineFocusSnapshot focus) onApplyFocus,
    required void Function(GanttTimelineRangePreset preset) onApplyRangePreset,
  }) {
    if (intent.clearSearchController) {
      onClearSearchController();
    }

    onApplyFocus(intent.focus);

    if (intent.applyRangePreset) {
      onApplyRangePreset(intent.focus.rangePreset);
    }
  }
}

/// Centralizes timeline focus clearing and range intent rules for the Gantt chart.
class GanttChartTimelineFocusIntentService {
  const GanttChartTimelineFocusIntentService();

  static const defaultViewPreset = GanttTimelineViewPreset.all;
  static const defaultRangePreset = GanttTimelineRangePreset.planningWindow;
  static const defaultStatusFilter = GanttTaskStatusFilter.all;

  GanttChartTimelineFocusIntentResult clearAll(
    GanttChartTimelineFocusSnapshot focus,
  ) {
    return GanttChartTimelineFocusIntentResult(
      focus: GanttChartTimelineFocusSnapshot(
        query: '',
        projectId: null,
        branchFocusTaskId: null,
        viewPreset: defaultViewPreset,
        rangePreset: defaultRangePreset,
        statusFilter: defaultStatusFilter,
      ),
      clearSearchController: true,
      applyRangePreset: true,
    );
  }

  GanttChartTimelineFocusIntentResult clearProject(
    GanttChartTimelineFocusSnapshot focus,
  ) {
    return _result(focus.copyWith(clearProjectId: true));
  }

  GanttChartTimelineFocusIntentResult clearBranch(
    GanttChartTimelineFocusSnapshot focus,
  ) {
    return _result(focus.copyWith(clearBranchFocusTaskId: true));
  }

  GanttChartTimelineFocusIntentResult clearView(
    GanttChartTimelineFocusSnapshot focus,
  ) {
    return _result(focus.copyWith(viewPreset: defaultViewPreset));
  }

  GanttChartTimelineFocusIntentResult clearRange(
    GanttChartTimelineFocusSnapshot focus,
  ) {
    return _result(
      focus.copyWith(rangePreset: defaultRangePreset),
      applyRangePreset: true,
    );
  }

  GanttChartTimelineFocusIntentResult clearStatus(
    GanttChartTimelineFocusSnapshot focus,
  ) {
    return _result(focus.copyWith(statusFilter: defaultStatusFilter));
  }

  GanttChartTimelineFocusIntentResult clearQuery(
    GanttChartTimelineFocusSnapshot focus,
  ) {
    return _result(focus.copyWith(query: ''), clearSearchController: true);
  }

  DateTimeRange rangeForPreset({
    required GanttTimelineRangePreset preset,
    required List<gantt.GanttTask> tasks,
  }) {
    return const GanttTimelineRangePresetService().rangeFor(
      preset: preset,
      tasks: tasks,
    );
  }

  GanttChartTimelineFocusIntentResult _result(
    GanttChartTimelineFocusSnapshot focus, {
    bool clearSearchController = false,
    bool applyRangePreset = false,
  }) {
    return GanttChartTimelineFocusIntentResult(
      focus: focus,
      clearSearchController: clearSearchController,
      applyRangePreset: applyRangePreset,
    );
  }
}

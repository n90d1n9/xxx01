import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_compact_control_summary_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  group('GanttChartCompactControlSummaryService', () {
    const service = GanttChartCompactControlSummaryService();

    test('builds a collapsed header snapshot from default settings', () {
      final summary = service.summaryFor(
        displayPreferences: GanttChartDisplayPreferences.initial,
        interactionPreferences: GanttChartInteractionPreferences.initial,
        timelineView: GanttTimelineViewPreset.all,
        rangePreset: GanttTimelineRangePreset.planningWindow,
      );

      expect(summary.title, 'Chart setup');
      expect(
        summary.headline,
        'Custom focus - All Tasks / Planning Window - 3 layers - '
        '3 edit tools',
      );
      expect(summary.items.map((item) => item.label), [
        'Custom focus',
        'All Tasks / Planning Window',
        '3 layers',
        'Full deps',
        'Loose rows / Normal scale',
        '3 edit tools',
        'Day snap',
        'Detailed preview',
      ]);
      expect(
        summary.semanticsLabel,
        'Chart setup. Custom focus - All Tasks / Planning Window - 3 layers - '
        '3 edit tools. Active controls: Custom focus, All Tasks / Planning '
        'Window, 3 layers, Full deps, Loose rows / Normal scale, 3 edit '
        'tools, Day snap, Detailed preview.',
      );
      expect(
        summary.items
            .firstWhere(
              (item) =>
                  item.role == GanttChartCompactControlSummaryRole.chartLayers,
            )
            .tooltip,
        'Dependency lines, Weekend bands, Today marker visible',
      );
      expect(
        summary.items
            .firstWhere(
              (item) =>
                  item.role ==
                  GanttChartCompactControlSummaryRole.dependencyFocus,
            )
            .tooltip,
        'Highlights upstream and downstream dependency chains',
      );
      expect(
        summary.items
            .firstWhere(
              (item) =>
                  item.role ==
                  GanttChartCompactControlSummaryRole.previewDetail,
            )
            .tooltip,
        'Detailed preview adds ghost bar and before/after delta ranges.',
      );
    });

    test('keeps disabled layers and idle snap understandable', () {
      const display = GanttChartDisplayPreferences(
        showTeamAvatars: false,
        showDependencyLines: false,
        showWeekendBands: false,
        showTodayMarker: false,
        density: GanttChartDensity.dense,
        timelineZoom: GanttChartTimelineZoom.compact,
      );
      const interaction = GanttChartInteractionPreferences(
        enableTaskBarDrag: false,
        enableTaskBarResize: false,
        enableScheduleGuard: false,
        dragSnap: KyGanttTaskDragSnap.week,
      );

      final summary = service.summaryFor(
        displayPreferences: display,
        interactionPreferences: interaction,
        timelineView: GanttTimelineViewPreset.dependencyWatch,
        rangePreset: GanttTimelineRangePreset.attentionWindow,
      );

      expect(
        summary.headline,
        'Custom focus - Dependency Watch / Attention Window - 0 layers - '
        '0 edit tools',
      );
      expect(
        summary.items
            .firstWhere(
              (item) =>
                  item.role == GanttChartCompactControlSummaryRole.chartLayers,
            )
            .tooltip,
        'No optional chart layers visible',
      );
      expect(
        summary.items
            .firstWhere(
              (item) =>
                  item.role ==
                  GanttChartCompactControlSummaryRole.dependencyFocus,
            )
            .label,
        'Deps hidden',
      );
      expect(
        summary.items
            .firstWhere(
              (item) =>
                  item.role == GanttChartCompactControlSummaryRole.dragSnap,
            )
            .tooltip,
        'Week snap is idle until drag or resize is enabled',
      );
      expect(
        summary.items
            .firstWhere(
              (item) =>
                  item.role ==
                  GanttChartCompactControlSummaryRole.previewDetail,
            )
            .label,
        'Preview idle',
      );
      expect(
        summary.items
            .firstWhere(
              (item) =>
                  item.role ==
                  GanttChartCompactControlSummaryRole.previewDetail,
            )
            .tooltip,
        'Drag preview is idle until drag or resize is enabled',
      );
    });
  });
}

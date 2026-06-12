import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_control_label_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_quick_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  group('gantt chart control labels', () {
    test('summarizes default display and edit preferences', () {
      expect(
        ganttChartVisibleLayerCount(GanttChartDisplayPreferences.initial),
        3,
      );
      expect(
        ganttChartLayerCountLabel(GanttChartDisplayPreferences.initial),
        '3 layers',
      );
      expect(
        ganttChartLayerStripSubtitleLabel(GanttChartDisplayPreferences.initial),
        '3 active - Full deps',
      );
      expect(
        ganttChartQuickPresetSummaryLabel(GanttChartDisplayPreferences.initial),
        'Custom focus',
      );
      expect(
        ganttChartViewportControlLabel(GanttChartDisplayPreferences.initial),
        'Loose rows / Normal scale',
      );
      expect(
        ganttChartViewportStripSubtitleLabel(
          GanttChartDisplayPreferences.initial,
        ),
        'Loose rows - Normal scale',
      );
      expect(
        ganttChartTimelineLensSummaryLabel(
          GanttTimelineViewPreset.all,
          GanttTimelineRangePreset.planningWindow,
        ),
        'All Tasks / Planning Window',
      );
      expect(
        ganttChartDependencyFocusControlLabel(
          GanttChartDisplayPreferences.initial,
        ),
        'Full deps',
      );
      expect(
        ganttChartDependencyFocusDetailLabel(
          GanttChartDisplayPreferences.initial,
        ),
        'Highlights upstream and downstream dependency chains',
      );
      expect(
        ganttChartActiveEditToolCount(GanttChartInteractionPreferences.initial),
        3,
      );
      expect(
        ganttChartEditToolCountLabel(GanttChartInteractionPreferences.initial),
        '3 edit tools',
      );
      expect(
        ganttChartEditToolStripSubtitleLabel(
          GanttChartInteractionPreferences.initial,
        ),
        '3 active - Day snap',
      );
      expect(
        ganttChartDragSnapSummaryLabel(
          GanttChartInteractionPreferences.initial,
        ),
        'Day snap',
      );
    });

    test('summarizes customized display and edit preferences', () {
      const display = GanttChartDisplayPreferences(
        showTeamAvatars: true,
        showDependencyLines: false,
        showWeekendBands: false,
        showTodayMarker: false,
        dependencyFocusScope: KyGanttDependencyLineFocusScope.upstream,
        density: GanttChartDensity.dense,
        timelineZoom: GanttChartTimelineZoom.wide,
      );
      const focusedDisplay = GanttChartDisplayPreferences(
        dependencyFocusScope: KyGanttDependencyLineFocusScope.upstream,
      );
      const interaction = GanttChartInteractionPreferences(
        enableTaskBarDrag: false,
        enableTaskBarResize: false,
        dragSnap: KyGanttTaskDragSnap.week,
      );

      expect(ganttChartLayerCountLabel(display), '1 layer');
      expect(
        ganttChartLayerStripSubtitleLabel(display),
        '1 active - Deps hidden',
      );
      expect(
        ganttChartQuickPresetSummaryLabel(
          const GanttChartQuickPresetService().preferencesFor(
            GanttChartQuickPreset.team,
          ),
        ),
        'Team focus',
      );
      expect(
        ganttChartViewportControlLabel(display),
        'Tight rows / Open scale',
      );
      expect(
        ganttChartViewportStripSubtitleLabel(display),
        'Tight rows - Open scale',
      );
      expect(
        ganttChartTimelineLensSummaryLabel(
          GanttTimelineViewPreset.dependencyWatch,
          GanttTimelineRangePreset.attentionWindow,
        ),
        'Dependency Watch / Attention Window',
      );
      expect(ganttChartDependencyFocusControlLabel(display), 'Deps hidden');
      expect(
        ganttChartDependencyFocusControlLabel(focusedDisplay),
        'Upstream deps',
      );
      expect(
        ganttChartDependencyFocusDetailLabel(focusedDisplay),
        'Highlights the upstream chain feeding the selected task',
      );
      expect(ganttChartEditToolCountLabel(interaction), '1 edit tool');
      expect(
        ganttChartEditToolStripSubtitleLabel(interaction),
        '1 active - Week snap',
      );
      expect(ganttChartDragSnapSummaryLabel(interaction), 'Week snap');
    });
  });
}

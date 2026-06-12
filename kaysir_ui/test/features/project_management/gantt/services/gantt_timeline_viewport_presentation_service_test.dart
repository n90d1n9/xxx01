import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_viewport_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_viewport_summary_service.dart';

void main() {
  group('ganttTimelineViewportPresentation', () {
    test('describes viewport visibility states', () {
      final empty = ganttTimelineViewportVisibilityPresentation(
        GanttTimelineViewportVisibilityState.empty,
      );
      final complete = ganttTimelineViewportVisibilityPresentation(
        GanttTimelineViewportVisibilityState.complete,
      );
      final filtered = ganttTimelineViewportVisibilityPresentation(
        GanttTimelineViewportVisibilityState.filtered,
      );

      expect(empty.icon, Icons.inbox_outlined);
      expect(empty.accent, GanttTimelineViewportAccent.neutral);
      expect(complete.icon, Icons.visibility_outlined);
      expect(complete.accent, GanttTimelineViewportAccent.primary);
      expect(filtered.icon, Icons.filter_alt_outlined);
      expect(filtered.accent, GanttTimelineViewportAccent.tertiary);
      expect(filtered.maxWidth, 136);
    });

    test('describes hidden task count pill', () {
      expect(
        ganttTimelineViewportHiddenPresentation.icon,
        Icons.visibility_off_outlined,
      );
      expect(
        ganttTimelineViewportHiddenPresentation.tooltip,
        'Tasks currently hidden by filters or focus',
      );
      expect(
        ganttTimelineViewportHiddenPresentation.accent,
        GanttTimelineViewportAccent.tertiary,
      );
      expect(ganttTimelineViewportHiddenPresentation.maxWidth, 150);
    });

    test('describes viewport quick-jump actions', () {
      final today = ganttTimelineViewportActionPresentation(
        GanttTimelineViewportAction.today,
      );
      final attention = ganttTimelineViewportActionPresentation(
        GanttTimelineViewportAction.attention,
      );
      final fitAll = ganttTimelineViewportActionPresentation(
        GanttTimelineViewportAction.fitAll,
      );

      expect(today.key, ganttViewportTodayButtonKey);
      expect(today.rangePreset, GanttTimelineRangePreset.planningWindow);
      expect(today.label, 'Today');
      expect(today.icon, Icons.today_outlined);
      expect(attention.rangePreset, GanttTimelineRangePreset.attentionWindow);
      expect(attention.label, 'Risks');
      expect(attention.icon, Icons.crisis_alert_outlined);
      expect(fitAll.key, ganttViewportFitAllButtonKey);
      expect(fitAll.rangePreset, GanttTimelineRangePreset.projectSpan);
      expect(fitAll.label, 'Fit All');
      expect(fitAll.icon, Icons.fit_screen_outlined);
    });
  });
}

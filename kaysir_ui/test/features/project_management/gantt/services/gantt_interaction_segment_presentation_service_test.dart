import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_interaction_segment_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  group('GanttInteractionSegmentPresentationService', () {
    test('describes resize handle visibility options', () {
      final focused = ganttResizeHandleVisibilityPresentation(
        KyGanttTaskResizeHandleVisibility.focused,
      );
      final always = ganttResizeHandleVisibilityPresentation(
        KyGanttTaskResizeHandleVisibility.always,
      );

      expect(focused.label, 'Focus');
      expect(focused.summaryLabel, 'Focus shows grips on intent');
      expect(focused.tooltip, contains('selected, hovered, or being edited'));

      expect(always.label, 'Always');
      expect(always.summaryLabel, 'Always keeps grips visible');
      expect(always.tooltip, contains('editable task bars'));
      expect(
        ganttResizeHandleVisibilitySettingsSubtitle(),
        'Focus shows grips on intent, Always keeps grips visible',
      );
    });

    test('describes drag snap options', () {
      final day = ganttDragSnapPresentation(KyGanttTaskDragSnap.day);
      final week = ganttDragSnapPresentation(KyGanttTaskDragSnap.week);

      expect(day.label, 'Day');
      expect(day.summaryLabel, 'Day edits are precise');
      expect(day.tooltip, contains('single-day increments'));

      expect(week.label, 'Week');
      expect(week.summaryLabel, 'Week aligns schedules');
      expect(week.tooltip, contains('whole-week movement'));
      expect(
        ganttDragSnapSettingsSubtitle(),
        'Day edits are precise, Week aligns schedules',
      );
    });

    test('describes inspector placement options', () {
      final adaptive = ganttInspectorPlacementPresentation(
        GanttTaskInspectorPlacement.adaptive,
      );
      final side = ganttInspectorPlacementPresentation(
        GanttTaskInspectorPlacement.side,
      );
      final bottom = ganttInspectorPlacementPresentation(
        GanttTaskInspectorPlacement.bottom,
      );

      expect(adaptive.label, 'Auto');
      expect(adaptive.summaryLabel, 'Auto chooses by space');
      expect(adaptive.tooltip, contains('based on screen space'));

      expect(side.label, 'Side');
      expect(side.summaryLabel, 'Side keeps chart context');
      expect(side.tooltip, contains('wide screens'));

      expect(bottom.label, 'Bottom');
      expect(bottom.summaryLabel, 'Bottom preserves width');
      expect(bottom.tooltip, contains('horizontal room'));
      expect(
        ganttInspectorPlacementSettingsSubtitle(),
        'Auto chooses by space, Side keeps chart context, '
        'Bottom preserves width',
      );
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_edit_tool_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  group('ganttChartEditToolPresentation', () {
    test('describes edit tool toggles in strip order', () {
      expect(ganttChartEditToolPresentations.map((item) => item.role), [
        GanttChartEditToolRole.drag,
        GanttChartEditToolRole.resize,
        GanttChartEditToolRole.scheduleGuard,
      ]);

      final drag = ganttChartEditToolPresentation(GanttChartEditToolRole.drag);
      final resize = ganttChartEditToolPresentation(
        GanttChartEditToolRole.resize,
      );
      final guard = ganttChartEditToolPresentation(
        GanttChartEditToolRole.scheduleGuard,
      );

      expect(drag.key, ganttChartEditToolDragChipKey);
      expect(drag.label, 'Drag');
      expect(drag.summaryLabel, 'Drag');
      expect(drag.icon, Icons.open_with_rounded);

      expect(resize.key, ganttChartEditToolResizeChipKey);
      expect(resize.label, 'Resize');
      expect(resize.summaryLabel, 'Resize');
      expect(resize.icon, Icons.open_in_full_rounded);

      expect(guard.key, ganttChartEditToolGuardChipKey);
      expect(guard.label, 'Guard');
      expect(guard.summaryLabel, 'Schedule guard');
      expect(guard.icon, Icons.verified_user_outlined);
    });

    test('describes snap options in strip order', () {
      expect(ganttChartEditSnapPresentations.map((item) => item.snap), [
        KyGanttTaskDragSnap.day,
        KyGanttTaskDragSnap.week,
      ]);

      final day = ganttChartEditSnapPresentation(KyGanttTaskDragSnap.day);
      final week = ganttChartEditSnapPresentation(KyGanttTaskDragSnap.week);

      expect(day.key, ganttChartEditToolDaySnapChipKey);
      expect(day.label, 'Day');
      expect(day.icon, Icons.calendar_view_day_outlined);
      expect(day.tooltip, contains('single-day'));

      expect(week.key, ganttChartEditToolWeekSnapChipKey);
      expect(week.label, 'Week');
      expect(week.icon, Icons.view_week_outlined);
      expect(week.tooltip, contains('whole-week'));
    });

    test('describes feedback depth options in strip order', () {
      expect(
        ganttChartEditFeedbackDepthPresentations.map((item) => item.depth),
        [
          GanttInteractionFeedbackDepth.subtle,
          GanttInteractionFeedbackDepth.balanced,
          GanttInteractionFeedbackDepth.elevated,
        ],
      );

      final subtle = ganttChartEditFeedbackDepthPresentation(
        GanttInteractionFeedbackDepth.subtle,
      );
      final balanced = ganttChartEditFeedbackDepthPresentation(
        GanttInteractionFeedbackDepth.balanced,
      );
      final elevated = ganttChartEditFeedbackDepthPresentation(
        GanttInteractionFeedbackDepth.elevated,
      );

      expect(subtle.key, ganttChartEditToolSubtleDepthChipKey);
      expect(subtle.label, 'Subtle');
      expect(subtle.icon, Icons.opacity_rounded);
      expect(subtle.tooltip, contains('reduces hover opacity'));

      expect(balanced.key, ganttChartEditToolBalancedDepthChipKey);
      expect(balanced.label, 'Balanced');
      expect(balanced.icon, Icons.blur_on_rounded);
      expect(balanced.tooltip, contains('default hover'));

      expect(elevated.key, ganttChartEditToolElevatedDepthChipKey);
      expect(elevated.label, 'Elevated');
      expect(elevated.icon, Icons.layers_rounded);
      expect(elevated.tooltip, contains('strengthens lift'));
    });

    test('describes preview detail options in strip order', () {
      expect(
        ganttChartEditPreviewDetailPresentations.map((item) => item.detail),
        [
          GanttDragPreviewDetail.lean,
          GanttDragPreviewDetail.balanced,
          GanttDragPreviewDetail.detailed,
        ],
      );

      final lean = ganttChartEditPreviewDetailPresentation(
        GanttDragPreviewDetail.lean,
      );
      final balanced = ganttChartEditPreviewDetailPresentation(
        GanttDragPreviewDetail.balanced,
      );
      final detailed = ganttChartEditPreviewDetailPresentation(
        GanttDragPreviewDetail.detailed,
      );

      expect(lean.key, ganttChartEditToolLeanPreviewChipKey);
      expect(lean.label, 'Lean');
      expect(lean.icon, Icons.short_text_rounded);
      expect(lean.tooltip, contains('compact'));

      expect(balanced.key, ganttChartEditToolBalancedPreviewChipKey);
      expect(balanced.label, 'Balanced');
      expect(balanced.icon, Icons.view_stream_outlined);
      expect(balanced.tooltip, contains('ghost bar'));

      expect(detailed.key, ganttChartEditToolDetailedPreviewChipKey);
      expect(detailed.label, 'Detailed');
      expect(detailed.icon, Icons.ssid_chart_rounded);
      expect(detailed.tooltip, contains('before/after'));
    });
  });
}

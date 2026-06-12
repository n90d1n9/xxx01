import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_compact_control_summary_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_compact_control_summary_service.dart';

void main() {
  group('ganttChartCompactControlSummaryRolePresentation', () {
    test('describes visual metadata for compact summary roles', () {
      final quickPreset = ganttChartCompactControlSummaryRolePresentation(
        GanttChartCompactControlSummaryRole.quickPreset,
      );
      final timelineLens = ganttChartCompactControlSummaryRolePresentation(
        GanttChartCompactControlSummaryRole.timelineLens,
      );
      final viewport = ganttChartCompactControlSummaryRolePresentation(
        GanttChartCompactControlSummaryRole.viewport,
      );
      final preview = ganttChartCompactControlSummaryRolePresentation(
        GanttChartCompactControlSummaryRole.previewDetail,
      );

      expect(quickPreset.icon, Icons.bolt_outlined);
      expect(
        quickPreset.accent,
        GanttChartCompactControlSummaryAccent.tertiary,
      );
      expect(quickPreset.maxWidth, 144);

      expect(timelineLens.icon, Icons.manage_search_outlined);
      expect(
        timelineLens.accent,
        GanttChartCompactControlSummaryAccent.primary,
      );
      expect(timelineLens.maxWidth, 230);

      expect(viewport.icon, Icons.view_week_outlined);
      expect(viewport.accent, GanttChartCompactControlSummaryAccent.secondary);
      expect(viewport.maxWidth, 210);

      expect(preview.icon, Icons.preview_outlined);
      expect(preview.accent, GanttChartCompactControlSummaryAccent.tertiary);
      expect(preview.maxWidth, 136);
    });

    test('covers every compact summary role exactly once', () {
      expect(
        ganttChartCompactControlSummaryRolePresentations.map(
          (presentation) => presentation.role,
        ),
        GanttChartCompactControlSummaryRole.values,
      );
    });
  });
}

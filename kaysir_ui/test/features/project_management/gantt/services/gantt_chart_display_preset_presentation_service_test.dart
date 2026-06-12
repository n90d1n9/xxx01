import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_display_preset_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_display_preset_service.dart';

void main() {
  group('ganttChartDisplayPresetPresentation', () {
    test('describes appearance preset choices', () {
      final compact = ganttChartDisplayPresetPresentation(
        GanttChartDisplayPreset.compact,
      );
      final balanced = ganttChartDisplayPresetPresentation(
        GanttChartDisplayPreset.balanced,
      );
      final presentation = ganttChartDisplayPresetPresentation(
        GanttChartDisplayPreset.presentation,
      );
      final review = ganttChartDisplayPresetPresentation(
        GanttChartDisplayPreset.review,
      );

      expect(compact.label, 'Compact');
      expect(compact.icon, Icons.density_small_outlined);
      expect(compact.isPreset, isTrue);
      expect(balanced.summaryLabel, 'Balanced fits daily work');
      expect(presentation.label, 'Present');
      expect(review.tooltip, contains('inspection'));
      expect(ganttChartDisplayPresetSettingsSubtitle(), contains('Compact'));
    });

    test('shows custom only when the current display preset is custom', () {
      expect(
        ganttChartDisplayPresetPresentationsFor(
          GanttChartDisplayPreset.balanced,
        ).map((presentation) => presentation.preset),
        isNot(contains(GanttChartDisplayPreset.custom)),
      );
      expect(
        ganttChartDisplayPresetPresentationsFor(
          GanttChartDisplayPreset.custom,
        ).map((presentation) => presentation.preset),
        contains(GanttChartDisplayPreset.custom),
      );
    });
  });
}

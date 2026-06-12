import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_quick_preset_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_quick_preset_service.dart';

void main() {
  group('ganttChartQuickPresetPresentation', () {
    test('describes chart focus presets', () {
      final risk = ganttChartQuickPresetPresentation(
        GanttChartQuickPreset.risk,
      );
      final team = ganttChartQuickPresetPresentation(
        GanttChartQuickPreset.team,
      );
      final milestones = ganttChartQuickPresetPresentation(
        GanttChartQuickPreset.milestones,
      );

      expect(risk.label, 'Risk');
      expect(risk.icon, Icons.warning_amber_rounded);
      expect(risk.tooltip, contains('blocked dependencies'));
      expect(risk.isPreset, isTrue);
      expect(team.label, 'Team');
      expect(team.icon, Icons.groups_2_outlined);
      expect(milestones.label, 'Milestones');
      expect(milestones.icon, Icons.flag_outlined);
    });

    test('shows custom only when the current quick preset is custom', () {
      expect(
        ganttChartQuickPresetPresentationsFor(
          GanttChartQuickPreset.risk,
        ).map((presentation) => presentation.preset),
        isNot(contains(GanttChartQuickPreset.custom)),
      );
      expect(
        ganttChartQuickPresetPresentationsFor(
          GanttChartQuickPreset.custom,
        ).map((presentation) => presentation.preset),
        contains(GanttChartQuickPreset.custom),
      );
      expect(
        ganttChartQuickPresetPresentation(
          GanttChartQuickPreset.custom,
        ).isPreset,
        isFalse,
      );
    });
  });
}

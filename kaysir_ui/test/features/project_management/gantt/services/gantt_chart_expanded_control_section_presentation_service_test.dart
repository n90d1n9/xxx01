import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_expanded_control_section_presentation_service.dart';

void main() {
  group('ganttChartExpandedControlSectionPresentation', () {
    test('describes expanded control sections in workflow order', () {
      expect(
        ganttChartExpandedControlSectionPresentations.map((item) => item.role),
        [
          GanttChartExpandedControlSectionRole.timeline,
          GanttChartExpandedControlSectionRole.presets,
          GanttChartExpandedControlSectionRole.display,
          GanttChartExpandedControlSectionRole.execution,
        ],
      );

      final timeline = ganttChartExpandedControlSectionPresentation(
        GanttChartExpandedControlSectionRole.timeline,
      );
      final display = ganttChartExpandedControlSectionPresentation(
        GanttChartExpandedControlSectionRole.display,
      );
      final execution = ganttChartExpandedControlSectionPresentation(
        GanttChartExpandedControlSectionRole.execution,
      );

      expect(timeline.label, 'Timeline scope');
      expect(timeline.subtitle, contains('saved views'));
      expect(timeline.icon, Icons.travel_explore_outlined);

      expect(display.label, 'Canvas display');
      expect(display.subtitle, contains('timeline scale'));
      expect(display.icon, Icons.dashboard_customize_outlined);

      expect(execution.label, 'Execution controls');
      expect(execution.subtitle, contains('dependency health'));
      expect(execution.icon, Icons.construction_outlined);
    });
  });
}

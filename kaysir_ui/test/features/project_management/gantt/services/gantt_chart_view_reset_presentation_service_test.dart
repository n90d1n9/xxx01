import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_view_reset_presentation_service.dart';

void main() {
  group('ganttChartViewResetPresentation', () {
    test('describes the default settings state', () {
      final presentation = ganttChartViewResetPresentation(isCustomized: false);

      expect(presentation.title, 'View Defaults');
      expect(presentation.subtitle, 'Default preferences active');
      expect(presentation.icon, Icons.check_circle_outline_rounded);
      expect(presentation.buttonTooltip, 'Reset view defaults');
    });

    test('describes the customized settings state', () {
      final presentation = ganttChartViewResetPresentation(isCustomized: true);

      expect(presentation.title, 'View Defaults');
      expect(presentation.subtitle, 'Custom preferences active');
      expect(presentation.icon, Icons.tune_outlined);
      expect(presentation.buttonTooltip, 'Reset view defaults');
    });
  });
}

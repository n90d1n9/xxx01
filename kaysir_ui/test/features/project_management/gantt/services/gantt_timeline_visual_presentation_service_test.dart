import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_visual_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';

void main() {
  group('GanttTimelineVisualPresentationService', () {
    test('describes timeline accent intensity choices', () {
      final subtle = ganttTimelineAccentIntensityPresentation(
        GanttTimelineAccentIntensity.subtle,
      );
      final balanced = ganttTimelineAccentIntensityPresentation(
        GanttTimelineAccentIntensity.balanced,
      );
      final strong = ganttTimelineAccentIntensityPresentation(
        GanttTimelineAccentIntensity.strong,
      );

      expect(subtle.label, 'Subtle');
      expect(subtle.summaryLabel, 'Subtle keeps markers quiet');
      expect(subtle.tooltip, contains('softens weekend bands'));

      expect(balanced.label, 'Balanced');
      expect(balanced.summaryLabel, 'Balanced is standard');
      expect(balanced.tooltip, contains('without dominating'));

      expect(strong.label, 'Strong');
      expect(strong.summaryLabel, 'Strong raises contrast');
      expect(strong.tooltip, contains('today marker contrast'));
      expect(
        ganttTimelineAccentIntensitySettingsSubtitle(),
        'Subtle keeps markers quiet, Balanced is standard, '
        'Strong raises contrast',
      );
    });

    test('describes dependency line intensity choices', () {
      final subtle = ganttDependencyLineIntensityPresentation(
        GanttDependencyLineIntensity.subtle,
      );
      final balanced = ganttDependencyLineIntensityPresentation(
        GanttDependencyLineIntensity.balanced,
      );
      final strong = ganttDependencyLineIntensityPresentation(
        GanttDependencyLineIntensity.strong,
      );

      expect(subtle.label, 'Subtle');
      expect(subtle.summaryLabel, 'Subtle reduces connector noise');
      expect(subtle.tooltip, contains('lighter strokes'));

      expect(balanced.label, 'Balanced');
      expect(balanced.summaryLabel, 'Balanced keeps links readable');
      expect(balanced.tooltip, contains('default dependency connector'));

      expect(strong.label, 'Strong');
      expect(strong.summaryLabel, 'Strong highlights chains');
      expect(strong.tooltip, contains('stroke weight'));
      expect(
        ganttDependencyLineIntensitySettingsSubtitle(),
        'Subtle reduces connector noise, Balanced keeps links readable, '
        'Strong highlights chains',
      );
    });

    test('describes chart density choices', () {
      final airy = ganttChartDensityPresentation(GanttChartDensity.airy);
      final cozy = ganttChartDensityPresentation(GanttChartDensity.cozy);
      final dense = ganttChartDensityPresentation(GanttChartDensity.dense);

      expect(airy.label, 'Airy');
      expect(airy.controlLabel, 'Loose');
      expect(airy.controlIcon, Icons.height_rounded);
      expect(airy.summaryLabel, 'Airy gives room');
      expect(airy.tooltip, contains('breathing room'));

      expect(cozy.label, 'Cozy');
      expect(cozy.controlLabel, 'Steady');
      expect(cozy.controlIcon, Icons.density_medium_outlined);
      expect(cozy.summaryLabel, 'Cozy balances scan speed');
      expect(cozy.tooltip, contains('more visible tasks'));

      expect(dense.label, 'Dense');
      expect(dense.controlLabel, 'Tight');
      expect(dense.controlIcon, Icons.density_small_outlined);
      expect(dense.summaryLabel, 'Dense fits more work');
      expect(dense.tooltip, contains('visible timeline'));
      expect(
        ganttChartDensitySettingsSubtitle(),
        'Airy gives room, Cozy balances scan speed, Dense fits more work',
      );
    });

    test('describes timeline zoom choices', () {
      final compact = ganttChartTimelineZoomPresentation(
        GanttChartTimelineZoom.compact,
      );
      final balanced = ganttChartTimelineZoomPresentation(
        GanttChartTimelineZoom.balanced,
      );
      final wide = ganttChartTimelineZoomPresentation(
        GanttChartTimelineZoom.wide,
      );

      expect(compact.label, 'Compact');
      expect(compact.controlLabel, 'Fit');
      expect(compact.controlIcon, Icons.zoom_in_map_outlined);
      expect(compact.summaryLabel, 'Compact fits more dates');
      expect(compact.tooltip, contains('wider schedule range'));

      expect(balanced.label, 'Balanced');
      expect(balanced.controlLabel, 'Normal');
      expect(balanced.controlIcon, Icons.center_focus_strong_outlined);
      expect(balanced.summaryLabel, 'Balanced is standard');
      expect(balanced.tooltip, contains('default scale'));

      expect(wide.label, 'Wide');
      expect(wide.controlLabel, 'Open');
      expect(wide.controlIcon, Icons.zoom_out_map_outlined);
      expect(wide.summaryLabel, 'Wide opens spacing');
      expect(wide.tooltip, contains('horizontal room'));
      expect(
        ganttChartTimelineZoomSettingsSubtitle(),
        'Compact fits more dates, Balanced is standard, Wide opens spacing',
      );
    });
  });
}

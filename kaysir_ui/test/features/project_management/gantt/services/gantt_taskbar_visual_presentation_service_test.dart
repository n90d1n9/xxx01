import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_taskbar_visual_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';

void main() {
  group('GanttTaskbarVisualPresentationService', () {
    test('describes schedule badge style choices', () {
      final full = ganttTaskBarScheduleBadgeStylePresentation(
        GanttTaskBarScheduleBadgeStyle.full,
      );
      final marker = ganttTaskBarScheduleBadgeStylePresentation(
        GanttTaskBarScheduleBadgeStyle.marker,
      );
      final text = ganttTaskBarScheduleBadgeStylePresentation(
        GanttTaskBarScheduleBadgeStyle.text,
      );

      expect(full.label, 'Full');
      expect(full.summaryLabel, 'Full shows label and accent');
      expect(full.tooltip, contains('label and accent marker'));

      expect(marker.label, 'Marker');
      expect(marker.summaryLabel, 'Marker stays compact');
      expect(marker.tooltip, contains('without extra label text'));

      expect(text.label, 'Text');
      expect(text.summaryLabel, 'Text keeps labels plain');
      expect(text.tooltip, contains('without the accent marker'));
      expect(
        ganttTaskBarScheduleBadgeStyleSettingsSubtitle(),
        'Full shows label and accent, Marker stays compact, '
        'Text keeps labels plain',
      );
    });

    test('describes selected row emphasis choices', () {
      final subtle = ganttSelectedTaskRowEmphasisPresentation(
        GanttSelectedTaskRowEmphasis.subtle,
      );
      final balanced = ganttSelectedTaskRowEmphasisPresentation(
        GanttSelectedTaskRowEmphasis.balanced,
      );
      final strong = ganttSelectedTaskRowEmphasisPresentation(
        GanttSelectedTaskRowEmphasis.strong,
      );

      expect(subtle.label, 'Subtle');
      expect(subtle.summaryLabel, 'Subtle row is quiet');
      expect(subtle.tooltip, contains('light selected-row wash'));

      expect(balanced.label, 'Balanced');
      expect(balanced.summaryLabel, 'Balanced is steady');
      expect(balanced.tooltip, contains('easy to scan'));

      expect(strong.label, 'Strong');
      expect(strong.summaryLabel, 'Strong draws focus');
      expect(strong.tooltip, contains('stronger row highlight'));
      expect(
        ganttSelectedTaskRowEmphasisSettingsSubtitle(),
        'Subtle row is quiet, Balanced is steady, Strong draws focus',
      );
    });

    test('describes taskbar depth choices', () {
      final subtle = ganttTaskBarDepthPresentation(GanttTaskBarDepth.subtle);
      final balanced = ganttTaskBarDepthPresentation(
        GanttTaskBarDepth.balanced,
      );
      final elevated = ganttTaskBarDepthPresentation(
        GanttTaskBarDepth.elevated,
      );

      expect(subtle.label, 'Subtle');
      expect(subtle.summaryLabel, 'Subtle keeps bars flat');
      expect(subtle.tooltip, contains('lighter, tighter'));

      expect(balanced.label, 'Balanced');
      expect(balanced.summaryLabel, 'Balanced adds dimension');
      expect(balanced.tooltip, contains('standard taskbar shadow'));

      expect(elevated.label, 'Elevated');
      expect(elevated.summaryLabel, 'Elevated feels lifted');
      expect(elevated.tooltip, contains('vertical lift'));
      expect(
        ganttTaskBarDepthSettingsSubtitle(),
        'Subtle keeps bars flat, Balanced adds dimension, '
        'Elevated feels lifted',
      );
    });
  });
}

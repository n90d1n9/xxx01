import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_interaction_feedback_depth_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';

void main() {
  group('GanttInteractionFeedbackDepthPresentationService', () {
    test('describes feedback depth modes', () {
      final subtle = ganttInteractionFeedbackDepthPresentation(
        GanttInteractionFeedbackDepth.subtle,
      );
      final balanced = ganttInteractionFeedbackDepthPresentation(
        GanttInteractionFeedbackDepth.balanced,
      );
      final elevated = ganttInteractionFeedbackDepthPresentation(
        GanttInteractionFeedbackDepth.elevated,
      );

      expect(subtle.label, 'Subtle');
      expect(subtle.summaryLabel, 'Subtle keeps feedback quiet');
      expect(subtle.tooltip, contains('reduces hover opacity'));

      expect(balanced.label, 'Balanced');
      expect(balanced.summaryLabel, 'Balanced is standard');
      expect(balanced.tooltip, contains('default hover'));

      expect(elevated.label, 'Elevated');
      expect(elevated.summaryLabel, 'Elevated adds lift');
      expect(elevated.tooltip, contains('strengthens lift'));
    });

    test('builds a concise settings subtitle from available modes', () {
      expect(
        ganttInteractionFeedbackDepthSettingsSubtitle(),
        'Subtle keeps feedback quiet, Balanced is standard, Elevated adds lift',
      );
    });
  });
}

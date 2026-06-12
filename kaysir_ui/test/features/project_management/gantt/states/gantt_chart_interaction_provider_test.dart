import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';

void main() {
  group('GanttChartInteractionPreferences', () {
    test('maps drag preview detail into card visibility rules', () {
      expect(GanttDragPreviewDetail.lean.showMetadataPills, isFalse);
      expect(GanttDragPreviewDetail.lean.showGhostBar, isFalse);
      expect(GanttDragPreviewDetail.lean.showDeltaStrip, isFalse);

      expect(GanttDragPreviewDetail.balanced.showMetadataPills, isTrue);
      expect(GanttDragPreviewDetail.balanced.showGhostBar, isTrue);
      expect(GanttDragPreviewDetail.balanced.showDeltaStrip, isFalse);

      expect(GanttDragPreviewDetail.detailed.showMetadataPills, isTrue);
      expect(GanttDragPreviewDetail.detailed.showGhostBar, isTrue);
      expect(GanttDragPreviewDetail.detailed.showDeltaStrip, isTrue);
    });

    test('maps feedback depth into package interaction options', () {
      final subtle =
          GanttChartInteractionPreferences.initial
              .copyWith(
                interactionFeedbackDepth: GanttInteractionFeedbackDepth.subtle,
              )
              .kyOptions
              .taskBarInteractionFeedback;
      final balanced =
          GanttChartInteractionPreferences
              .initial
              .kyOptions
              .taskBarInteractionFeedback;
      final elevated =
          GanttChartInteractionPreferences.initial
              .copyWith(
                interactionFeedbackDepth:
                    GanttInteractionFeedbackDepth.elevated,
              )
              .kyOptions
              .taskBarInteractionFeedback;

      expect(subtle.opacityScale, 0.72);
      expect(subtle.blurScale, 0.78);
      expect(subtle.offsetScale, 0.72);

      expect(balanced.opacityScale, 1);
      expect(balanced.blurScale, 1);
      expect(balanced.offsetScale, 1);

      expect(elevated.opacityScale, 1.22);
      expect(elevated.blurScale, 1.18);
      expect(elevated.offsetScale, 1.14);
    });

    test('maps blocked drop pattern into package interaction options', () {
      expect(
        GanttChartInteractionPreferences
            .initial
            .kyOptions
            .showTaskBarBlockedDropPattern,
        isTrue,
      );
      expect(
        GanttChartInteractionPreferences.initial
            .copyWith(showBlockedDropPattern: false)
            .kyOptions
            .showTaskBarBlockedDropPattern,
        isFalse,
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_drag_preview_detail_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';

void main() {
  group('GanttDragPreviewDetailPresentationService', () {
    test('describes drag preview detail modes', () {
      final lean = ganttDragPreviewDetailPresentation(
        GanttDragPreviewDetail.lean,
      );
      final balanced = ganttDragPreviewDetailPresentation(
        GanttDragPreviewDetail.balanced,
      );
      final detailed = ganttDragPreviewDetailPresentation(
        GanttDragPreviewDetail.detailed,
      );

      expect(lean.label, 'Lean');
      expect(lean.summaryLabel, 'Lean hides extras');
      expect(lean.tooltip, contains('compact'));

      expect(balanced.label, 'Balanced');
      expect(balanced.summaryLabel, 'Balanced adds ghost bar');
      expect(balanced.tooltip, contains('ghost bar'));

      expect(detailed.label, 'Detailed');
      expect(detailed.summaryLabel, 'Detailed adds deltas');
      expect(detailed.tooltip, contains('before/after'));
    });

    test('builds a concise settings subtitle from available modes', () {
      expect(
        ganttDragPreviewDetailSettingsSubtitle(),
        'Lean hides extras, Balanced adds ghost bar, Detailed adds deltas',
      );
    });
  });
}

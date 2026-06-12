import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_task_drag_preview_ghost_bar_service.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  group('GanttTaskDragPreviewGhostBarGeometryService', () {
    const service = GanttTaskDragPreviewGhostBarGeometryService();

    test('maps moved tasks onto a shared date span', () {
      final geometry = service.geometryFor(
        KyGanttTaskDragPreview(
          task: GanttTask(
            id: 'build',
            title: 'Build',
            startDate: DateTime(2026, 1, 1),
            endDate: DateTime(2026, 1, 14),
          ),
          startDate: DateTime(2026, 1, 8),
          endDate: DateTime(2026, 1, 21),
          deltaDays: 7,
          snap: KyGanttTaskDragSnap.week,
        ),
      );

      expect(geometry.originalStartFraction, 0);
      expect(geometry.originalWidthFraction, moreOrLessEquals(14 / 21));
      expect(geometry.targetStartFraction, moreOrLessEquals(7 / 21));
      expect(geometry.targetWidthFraction, moreOrLessEquals(14 / 21));
      expect(geometry.hasDateChange, isTrue);
      expect(geometry.targetMovesLater, isTrue);
      expect(geometry.connectorWidthFraction, greaterThan(0));
    });

    test('marks unchanged edits without connector movement', () {
      final geometry = service.geometryFor(
        KyGanttTaskDragPreview(
          task: GanttTask(
            id: 'design',
            title: 'Design',
            startDate: DateTime(2026, 1, 1),
            endDate: DateTime(2026, 1, 4),
          ),
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 4),
          deltaDays: 0,
        ),
      );

      expect(geometry.originalStartFraction, 0);
      expect(geometry.targetStartFraction, 0);
      expect(geometry.originalWidthFraction, 1);
      expect(geometry.targetWidthFraction, 1);
      expect(geometry.hasDateChange, isFalse);
      expect(geometry.connectorWidthFraction, 0);
    });
  });
}

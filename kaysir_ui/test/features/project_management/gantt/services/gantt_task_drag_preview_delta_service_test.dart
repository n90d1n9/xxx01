import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_task_drag_preview_delta_service.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  test(
    'gantt task drag preview delta summary exposes before and after ranges',
    () {
      final summary = ganttTaskDragPreviewDeltaSummary(
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

      expect(summary.beforeLabel, 'Jan 1-14');
      expect(summary.afterLabel, 'Jan 8-21');
      expect(summary.deltaLabel, '+7d');
      expect(summary.impactLabel, 'Moves later');
      expect(summary.hasDateChange, isTrue);
    },
  );

  test('gantt task drag preview delta summary marks unchanged edits', () {
    final summary = ganttTaskDragPreviewDeltaSummary(
      KyGanttTaskDragPreview(
        task: GanttTask(
          id: 'build',
          title: 'Build',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 14),
        ),
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 14),
        deltaDays: 0,
      ),
    );

    expect(summary.deltaLabel, 'No change');
    expect(summary.impactLabel, 'No date change');
    expect(summary.hasDateChange, isFalse);
  });
}

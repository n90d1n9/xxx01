import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_schedule_focus_service.dart';

void main() {
  test('gantt schedule focus prioritizes slipping work', () {
    final summary = buildGanttScheduleFocusSummary(
      tasks: [
        _task(
          id: 'late',
          title: 'Late Foundation',
          start: DateTime(2026, 4, 1),
          end: DateTime(2026, 4, 8),
          progress: 0.5,
        ),
        _task(
          id: 'behind',
          title: 'Slow Fit Out',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 10),
          progress: 0.2,
        ),
        _task(
          id: 'ready',
          title: 'Upcoming QA',
          start: DateTime(2026, 5, 8),
          end: DateTime(2026, 5, 12),
          progress: 0,
        ),
        _task(
          id: 'done',
          title: 'Closed Work',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 5),
          progress: 1,
        ),
      ],
      today: DateTime(2026, 5, 6),
    );

    expect(summary.totalTasks, 4);
    expect(summary.focusCount, 3);
    expect(summary.criticalCount, 1);
    expect(summary.warningCount, 1);
    expect(summary.monitorCount, 1);
    expect(summary.overdueCount, 1);
    expect(summary.behindCount, 1);
    expect(summary.startingSoonCount, 1);
    expect(summary.level, GanttScheduleFocusLevel.critical);
    expect(summary.prioritizedItems.first.task.id, 'late');
    expect(
      ganttScheduleFocusDetail(summary.prioritizedItems.first),
      contains('Reset finish plan'),
    );
  });

  test('gantt schedule focus reports clear schedules', () {
    final summary = buildGanttScheduleFocusSummary(
      tasks: [
        _task(
          id: 'steady',
          title: 'Steady Work',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 10),
          progress: 0.7,
        ),
      ],
      today: DateTime(2026, 5, 6),
    );

    expect(summary.totalTasks, 1);
    expect(summary.items, isEmpty);
    expect(summary.level, GanttScheduleFocusLevel.clear);
  });
}

gantt.GanttTask _task({
  required String id,
  required String title,
  required DateTime start,
  required DateTime end,
  required double progress,
}) {
  return gantt.GanttTask(
    id: id,
    title: title,
    startDate: start,
    endDate: end,
    progress: progress,
  );
}

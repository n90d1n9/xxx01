import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_schedule_health_service.dart';

void main() {
  test('gantt schedule health classifies task timing', () {
    final today = DateTime(2026, 5, 31);

    expect(
      ganttScheduleHealthFor(
        _task(
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 15),
          progress: 1,
        ),
        today: today,
      ),
      GanttScheduleHealth.complete,
    );
    expect(
      ganttScheduleHealthFor(
        _task(start: DateTime(2026, 5, 1), end: DateTime(2026, 5, 30)),
        today: today,
      ),
      GanttScheduleHealth.overdue,
    );
    expect(
      ganttScheduleHealthFor(
        _task(start: DateTime(2026, 5, 20), end: DateTime(2026, 6, 5)),
        today: today,
      ),
      GanttScheduleHealth.active,
    );
    expect(
      ganttScheduleHealthFor(
        _task(start: DateTime(2026, 6, 4), end: DateTime(2026, 6, 12)),
        today: today,
      ),
      GanttScheduleHealth.dueSoon,
    );
    expect(
      ganttScheduleHealthFor(
        _task(start: DateTime(2026, 6, 20), end: DateTime(2026, 6, 28)),
        today: today,
      ),
      GanttScheduleHealth.scheduled,
    );
  });

  test('gantt schedule health descriptions stay operator friendly', () {
    final today = DateTime(2026, 5, 31);

    expect(
      ganttScheduleHealthDetail(
        _task(start: DateTime(2026, 5, 1), end: DateTime(2026, 5, 30)),
        today: today,
      ),
      '1 day overdue',
    );
    expect(
      ganttScheduleDueLabel(
        _task(start: DateTime(2026, 5, 1), end: DateTime(2026, 5, 30)),
        today: today,
      ),
      '1d late',
    );
  });
}

gantt.GanttTask _task({
  required DateTime start,
  required DateTime end,
  double progress = 0.3,
}) {
  return gantt.GanttTask(
    id: 'task',
    title: 'Task',
    startDate: start,
    endDate: end,
    progress: progress,
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_service.dart';

void main() {
  test('gantt dependency insight classifies dependency readiness', () {
    final today = DateTime(2026, 5, 31);
    final readyDependency = _task(
      id: 'ready',
      title: 'Ready Dependency',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 20),
      progress: 1,
    );
    final waitingDependency = _task(
      id: 'waiting',
      title: 'Waiting Dependency',
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 6, 6),
      progress: 0.25,
    );
    final blockedDependency = _task(
      id: 'blocked',
      title: 'Blocked Dependency',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 20),
      progress: 0.5,
    );

    expect(
      ganttDependencyInsightFor(
        _task(id: 'free', start: DateTime(2026, 6, 10)),
        [readyDependency],
        today: today,
      ).health,
      GanttDependencyHealth.independent,
    );
    expect(
      ganttDependencyInsightFor(
        _task(
          id: 'ready-task',
          start: DateTime(2026, 6, 10),
          dependsOn: 'ready',
        ),
        [readyDependency],
        today: today,
      ).health,
      GanttDependencyHealth.ready,
    );
    expect(
      ganttDependencyInsightFor(
        _task(
          id: 'waiting-task',
          start: DateTime(2026, 6, 10),
          dependsOn: 'waiting',
        ),
        [waitingDependency],
        today: today,
      ).health,
      GanttDependencyHealth.waiting,
    );
    expect(
      ganttDependencyInsightFor(
        _task(
          id: 'blocked-task',
          start: DateTime(2026, 5, 28),
          dependsOn: 'blocked',
        ),
        [blockedDependency],
        today: today,
      ).health,
      GanttDependencyHealth.blocked,
    );
    expect(
      ganttDependencyInsightFor(
        _task(
          id: 'missing-task',
          start: DateTime(2026, 6, 10),
          dependsOn: 'missing',
        ),
        const [],
        today: today,
      ).health,
      GanttDependencyHealth.missing,
    );
  });

  test('gantt dependency alert count reports blocked and missing links', () {
    final dependency = _task(
      id: 'dependency',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 20),
      progress: 0.5,
    );

    final count = ganttDependencyAlertCount(
      [
        _task(
          id: 'blocked-task',
          start: DateTime(2026, 5, 28),
          dependsOn: 'dependency',
        ),
        _task(
          id: 'missing-task',
          start: DateTime(2026, 6, 2),
          dependsOn: 'missing',
        ),
      ],
      [dependency],
      today: DateTime(2026, 5, 31),
    );

    expect(count, 2);
  });
}

gantt.GanttTask _task({
  required String id,
  String title = 'Task',
  required DateTime start,
  DateTime? end,
  double progress = 0,
  String? dependsOn,
}) {
  return gantt.GanttTask(
    id: id,
    title: title,
    startDate: start,
    endDate: end ?? start.add(const Duration(days: 3)),
    progress: progress,
    dependsOn: dependsOn,
  );
}

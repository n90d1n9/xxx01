import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_overview_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_service.dart';

void main() {
  test('gantt dependency overview prioritizes dependency attention', () {
    final dependency = _task(
      id: 'dependency',
      title: 'Project Planning',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 20),
      progress: 0.5,
    );
    final completeDependency = _task(
      id: 'complete',
      title: 'Discovery',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 20),
      progress: 1,
    );

    final summary = buildGanttDependencyOverviewSummary(
      today: DateTime(2026, 5, 31),
      dependencyTasks: [dependency, completeDependency],
      tasks: [
        _task(
          id: 'blocked',
          title: 'Blocked Work',
          start: DateTime(2026, 5, 28),
          dependsOn: 'dependency',
        ),
        _task(
          id: 'ready',
          title: 'Ready Work',
          start: DateTime(2026, 5, 20),
          dependsOn: 'complete',
        ),
        _task(
          id: 'missing',
          title: 'Missing Work',
          start: DateTime(2026, 6, 10),
          dependsOn: 'missing',
        ),
      ],
    );

    expect(summary.linkedCount, 3);
    expect(summary.alertCount, 2);
    expect(summary.waitingCount, 0);
    expect(summary.readyCount, 1);
    expect(summary.attentionCount, 2);
    expect(summary.scheduleConflictCount, 1);
    expect(
      summary.prioritizedItems
          .singleWhere((item) => item.task.id == 'ready')
          .hasScheduleConflict,
      isTrue,
    );
    expect(summary.signal, GanttDependencyHealth.missing);
    expect(summary.prioritizedItems.first.task.id, 'missing');
    expect(
      ganttDependencyOverviewDetail(summary.prioritizedItems.first),
      contains('not available'),
    );
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

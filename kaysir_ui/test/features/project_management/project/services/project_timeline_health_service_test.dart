import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/services/project_timeline_health_service.dart';

void main() {
  test('project timeline health rollup summarizes linked task state', () {
    final today = DateTime(2026, 5, 31);
    final dependency = _task(
      id: 'dependency',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 20),
      progress: 0.6,
    );

    final rollup = buildProjectTimelineHealthRollup(
      tasks: [
        _task(
          id: 'complete',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 10),
          progress: 1,
        ),
        _task(
          id: 'overdue',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 20),
          progress: 0.4,
        ),
        _task(
          id: 'active',
          start: DateTime(2026, 5, 25),
          end: DateTime(2026, 6, 5),
          progress: 0.5,
        ),
        _task(
          id: 'due-soon',
          start: DateTime(2026, 6, 4),
          end: DateTime(2026, 6, 10),
        ),
        _task(
          id: 'blocked',
          start: DateTime(2026, 6, 8),
          end: DateTime(2026, 6, 15),
          dependsOn: 'dependency',
        ),
      ],
      dependencyTasks: [dependency],
      today: today,
    );

    expect(rollup.totalTasks, 5);
    expect(rollup.completeCount, 1);
    expect(rollup.overdueCount, 1);
    expect(rollup.activeCount, 1);
    expect(rollup.dueSoonCount, 1);
    expect(rollup.dependencyBlockCount, 1);
    expect(rollup.signal, ProjectTimelineHealthSignal.blocked);
    expect(rollup.averageProgress, closeTo(0.38, 0.01));
    expect(rollup.issues.map((issue) => issue.kind), [
      ProjectTimelineHealthIssueKind.dependencyBlock,
      ProjectTimelineHealthIssueKind.overdue,
      ProjectTimelineHealthIssueKind.dueSoon,
      ProjectTimelineHealthIssueKind.active,
    ]);
    expect(rollup.issues.first.title, 'blocked');
    expect(rollup.issues.first.detail, contains('blocks this task'));
  });

  test('project timeline health rollup handles empty timelines', () {
    final rollup = buildProjectTimelineHealthRollup(tasks: const []);

    expect(rollup.totalTasks, 0);
    expect(rollup.signal, ProjectTimelineHealthSignal.empty);
    expect(rollup.hasAttention, false);
    expect(rollup.issues, isEmpty);
  });
}

gantt.GanttTask _task({
  required String id,
  required DateTime start,
  required DateTime end,
  double progress = 0,
  String? dependsOn,
}) {
  return gantt.GanttTask(
    id: id,
    title: id,
    startDate: start,
    endDate: end,
    progress: progress,
    dependsOn: dependsOn,
  );
}

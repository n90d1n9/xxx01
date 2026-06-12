import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_successor_impact_service.dart';

void main() {
  test('gantt successor impact follows direct and indirect successors', () {
    final design = _task(
      id: 'design',
      title: 'Design',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 6, 6),
      progress: 0.4,
    );
    final build = _task(
      id: 'build',
      title: 'Build',
      start: DateTime(2026, 6, 5),
      end: DateTime(2026, 6, 12),
      dependsOn: 'design',
    );
    final launch = _task(
      id: 'launch',
      title: 'Launch',
      start: DateTime(2026, 6, 20),
      end: DateTime(2026, 6, 21),
      dependsOn: 'build',
    );

    final summary = buildGanttSuccessorImpactSummary(
      task: design,
      dependencyTasks: [design, build, launch],
      today: DateTime(2026, 5, 31),
    );

    expect(summary.totalCount, 2);
    expect(summary.directCount, 1);
    expect(summary.indirectCount, 1);
    expect(summary.scheduleConflictCount, 1);
    expect(summary.signal, GanttDependencyHealth.blocked);
    expect(summary.summaryText, '1 downstream schedule conflict needs review.');
    expect(summary.prioritizedItems.map((item) => item.task.id), [
      'build',
      'launch',
    ]);
    expect(summary.prioritizedItems.first.relationshipLabel, 'Direct');
    expect(summary.prioritizedItems.last.relationshipLabel, 'Indirect');
  });

  test('gantt successor impact reports clear leaf tasks', () {
    final task = _task(
      id: 'leaf',
      title: 'Leaf',
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 6, 3),
    );

    final summary = buildGanttSuccessorImpactSummary(
      task: task,
      dependencyTasks: [task],
      today: DateTime(2026, 5, 31),
    );

    expect(summary.hasImpact, false);
    expect(summary.totalCount, 0);
    expect(summary.signal, GanttDependencyHealth.independent);
    expect(
      summary.summaryText,
      'No downstream successors depend on this task.',
    );
  });
}

gantt.GanttTask _task({
  required String id,
  required String title,
  required DateTime start,
  required DateTime end,
  double progress = 0,
  String? dependsOn,
}) {
  return gantt.GanttTask(
    id: id,
    title: title,
    startDate: start,
    endDate: end,
    progress: progress,
    dependsOn: dependsOn,
  );
}

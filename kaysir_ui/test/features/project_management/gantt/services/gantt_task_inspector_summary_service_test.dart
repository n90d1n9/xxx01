import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_schedule_health_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_task_inspector_summary_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_filter_provider.dart';

void main() {
  const service = GanttTaskInspectorSummaryService();

  test('builds progress, duration, due, and schedule labels', () {
    final summary = service.build(
      task: gantt.GanttTask(
        id: 'build',
        title: 'Build',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 14),
        progress: 0.42,
      ),
      dependencyTasks: const [],
      today: DateTime(2026, 1, 6),
    );

    expect(summary.status, GanttTaskStatusFilter.inProgress);
    expect(summary.scheduleHealth, GanttScheduleHealth.active);
    expect(summary.dependencyInsight.health, GanttDependencyHealth.independent);
    expect(summary.hasVisibleDependencyStatus, false);
    expect(summary.progressValue, '42%');
    expect(summary.durationDays, 14);
    expect(summary.durationValue, '14 d');
    expect(summary.dueValue, '8d');
    expect(summary.scheduleRangeLabel, 'Jan 1, 2026 - Jan 14, 2026');
    expect(summary.scheduleDetail, '8 days remaining');
  });

  test('includes dependency readiness for linked tasks', () {
    final design = gantt.GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 4),
      progress: 1,
    );
    final build = gantt.GanttTask(
      id: 'build',
      title: 'Build',
      startDate: DateTime(2026, 1, 5),
      endDate: DateTime(2026, 1, 10),
      dependsOn: 'design',
    );

    final summary = service.build(
      task: build,
      dependencyTasks: [design, build],
      today: DateTime(2026, 1, 5),
    );

    expect(summary.dependencyInsight.health, GanttDependencyHealth.ready);
    expect(summary.hasVisibleDependencyStatus, true);
    expect(
      summary.dependencyInsight.detail,
      'Design is complete; this task can proceed.',
    );
  });
}

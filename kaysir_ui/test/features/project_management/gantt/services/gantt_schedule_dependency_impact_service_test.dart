import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_schedule_dependency_impact_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_schedule_focus_service.dart';

void main() {
  test('gantt schedule dependency impact summarizes blocked focus work', () {
    final today = DateTime(2026, 5, 6);
    final focusSummary = buildGanttScheduleFocusSummary(
      tasks: [
        _task(
          id: 'blocked',
          title: 'Blocked Build',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 10),
          progress: 0.1,
          dependsOn: 'late',
        ),
        _task(
          id: 'missing',
          title: 'Missing Scope',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 7),
          progress: 0.2,
          dependsOn: 'ghost',
        ),
        _task(
          id: 'waiting',
          title: 'Waiting Launch',
          start: DateTime(2026, 5, 8),
          end: DateTime(2026, 5, 14),
          progress: 0,
          dependsOn: 'handoff',
        ),
        _task(
          id: 'ready',
          title: 'Ready Build',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 12),
          progress: 0.2,
          dependsOn: 'done',
        ),
      ],
      today: today,
    );

    final summary = buildGanttScheduleDependencyImpactSummary(
      focusItems: focusSummary.prioritizedItems,
      dependencyTasks: [
        _task(
          id: 'late',
          title: 'Late Foundation',
          start: DateTime(2026, 4, 25),
          end: DateTime(2026, 5, 4),
          progress: 0.5,
        ),
        _task(
          id: 'handoff',
          title: 'Client Handoff',
          start: DateTime(2026, 5, 5),
          end: DateTime(2026, 5, 12),
          progress: 0.2,
        ),
        _task(
          id: 'done',
          title: 'Done Discovery',
          start: DateTime(2026, 4, 20),
          end: DateTime(2026, 4, 24),
          progress: 1,
        ),
      ],
      today: today,
    );

    expect(summary.impactCount, 3);
    expect(summary.alertCount, 2);
    expect(summary.waitingCount, 1);
    expect(summary.leadingHealth, GanttDependencyHealth.blocked);
    expect(summary.metricHelper, '2 blocked or missing');
    expect(summary.items.map((item) => item.focusItem.task.title), [
      'Blocked Build',
      'Missing Scope',
      'Waiting Launch',
    ]);
  });
}

gantt.GanttTask _task({
  required String id,
  required String title,
  required DateTime start,
  required DateTime end,
  required double progress,
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

import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_baseline_variance_service.dart';

void main() {
  test('gantt baseline variance classifies pace against elapsed schedule', () {
    final today = DateTime(2026, 5, 6);

    expect(
      ganttBaselineVarianceFor(
        _task(
          id: 'behind',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 10),
          progress: 0.2,
        ),
        today: today,
      ).state,
      GanttBaselineVarianceState.behind,
    );
    expect(
      ganttBaselineVarianceFor(
        _task(
          id: 'ahead',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 10),
          progress: 0.9,
        ),
        today: today,
      ).state,
      GanttBaselineVarianceState.ahead,
    );
    expect(
      ganttBaselineVarianceFor(
        _task(
          id: 'late',
          start: DateTime(2026, 4, 1),
          end: DateTime(2026, 4, 10),
          progress: 0.9,
        ),
        today: today,
      ).state,
      GanttBaselineVarianceState.late,
    );
    expect(
      ganttBaselineVarianceFor(
        _task(
          id: 'complete',
          start: DateTime(2026, 4, 1),
          end: DateTime(2026, 4, 10),
          progress: 1,
        ),
        today: today,
      ).state,
      GanttBaselineVarianceState.complete,
    );
  });

  test('gantt baseline variance summary reports operational counts', () {
    final summary = buildGanttBaselineVarianceSummary(
      tasks: [
        _task(
          id: 'behind',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 10),
          progress: 0.2,
        ),
        _task(
          id: 'ahead',
          start: DateTime(2026, 5, 1),
          end: DateTime(2026, 5, 10),
          progress: 0.9,
        ),
        _task(
          id: 'late',
          start: DateTime(2026, 4, 1),
          end: DateTime(2026, 4, 10),
          progress: 0.5,
        ),
      ],
      today: DateTime(2026, 5, 6),
    );

    expect(summary.totalTasks, 3);
    expect(summary.behindCount, 1);
    expect(summary.lateCount, 1);
    expect(summary.aheadCount, 1);
    expect(summary.attentionCount, 2);
    expect(summary.signal, GanttBaselineVarianceState.late);
    expect(summary.prioritizedItems.first.task.id, 'late');
  });
}

gantt.GanttTask _task({
  required String id,
  required DateTime start,
  required DateTime end,
  required double progress,
}) {
  return gantt.GanttTask(
    id: id,
    title: id,
    startDate: start,
    endDate: end,
    progress: progress,
  );
}

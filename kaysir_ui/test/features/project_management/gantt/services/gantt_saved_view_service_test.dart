import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';

void main() {
  test('gantt saved views classify timeline presets', () {
    final today = DateTime(2026, 5, 31);
    final readyDependency = _task(
      id: 'ready-dependency',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 20),
      progress: 1,
    );
    final waitingDependency = _task(
      id: 'waiting-dependency',
      start: DateTime(2026, 6, 4),
      end: DateTime(2026, 6, 8),
      progress: 0.25,
    );
    final active = _task(
      id: 'active',
      start: DateTime(2026, 5, 28),
      end: DateTime(2026, 6, 10),
      progress: 0.5,
    );
    final dueSoon = _task(
      id: 'due-soon',
      start: DateTime(2026, 5, 20),
      end: DateTime(2026, 6, 5),
      progress: 0.4,
    );
    final dependencyWatch = _task(
      id: 'dependency-watch',
      start: DateTime(2026, 6, 10),
      end: DateTime(2026, 6, 14),
      dependsOn: waitingDependency.id,
    );
    final readyNext = _task(
      id: 'ready-next',
      start: DateTime(2026, 6, 3),
      end: DateTime(2026, 6, 7),
      dependsOn: readyDependency.id,
    );
    final dependencyPool = [
      readyDependency,
      waitingDependency,
      active,
      dueSoon,
      dependencyWatch,
      readyNext,
    ];

    expect(
      ganttTaskMatchesTimelineView(
        active,
        GanttTimelineViewPreset.activeNow,
        dependencyPool,
        today: today,
      ),
      true,
    );
    expect(
      ganttTaskMatchesTimelineView(
        dueSoon,
        GanttTimelineViewPreset.dueSoon,
        dependencyPool,
        today: today,
      ),
      true,
    );
    expect(
      ganttTaskMatchesTimelineView(
        dependencyWatch,
        GanttTimelineViewPreset.dependencyWatch,
        dependencyPool,
        today: today,
      ),
      true,
    );
    expect(
      ganttTaskMatchesTimelineView(
        readyNext,
        GanttTimelineViewPreset.readyNext,
        dependencyPool,
        today: today,
      ),
      true,
    );
  });

  test('gantt saved views count each preset', () {
    final today = DateTime(2026, 5, 31);
    final readyDependency = _task(
      id: 'ready-dependency',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 20),
      progress: 1,
    );
    final waitingDependency = _task(
      id: 'waiting-dependency',
      start: DateTime(2026, 6, 4),
      end: DateTime(2026, 6, 8),
      progress: 0.25,
    );
    final active = _task(
      id: 'active',
      start: DateTime(2026, 5, 28),
      end: DateTime(2026, 6, 10),
      progress: 0.5,
    );
    final dueSoon = _task(
      id: 'due-soon',
      start: DateTime(2026, 5, 20),
      end: DateTime(2026, 6, 5),
      progress: 0.4,
    );
    final dependencyWatch = _task(
      id: 'dependency-watch',
      start: DateTime(2026, 6, 10),
      end: DateTime(2026, 6, 14),
      dependsOn: waitingDependency.id,
    );
    final readyNext = _task(
      id: 'ready-next',
      start: DateTime(2026, 6, 3),
      end: DateTime(2026, 6, 7),
      dependsOn: readyDependency.id,
    );
    final tasks = [active, dueSoon, dependencyWatch, readyNext];
    final counts = countGanttTimelineViews(
      tasks,
      dependencyTasks: [readyDependency, waitingDependency, ...tasks],
      today: today,
    );

    expect(counts[GanttTimelineViewPreset.all], 4);
    expect(counts[GanttTimelineViewPreset.activeNow], 2);
    expect(counts[GanttTimelineViewPreset.dueSoon], 2);
    expect(counts[GanttTimelineViewPreset.dependencyWatch], 1);
    expect(counts[GanttTimelineViewPreset.readyNext], 1);
  });
}

gantt.GanttTask _task({
  required String id,
  required DateTime start,
  DateTime? end,
  double progress = 0,
  String? dependsOn,
}) {
  return gantt.GanttTask(
    id: id,
    title: id,
    startDate: start,
    endDate: end ?? start.add(const Duration(days: 3)),
    progress: progress,
    dependsOn: dependsOn,
  );
}

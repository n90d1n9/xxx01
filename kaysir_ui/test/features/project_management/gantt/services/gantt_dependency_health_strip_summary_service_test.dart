import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_health_strip_summary_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_overview_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_service.dart';

void main() {
  group('GanttDependencyHealthStripSummaryService', () {
    const service = GanttDependencyHealthStripSummaryService();

    test('summarizes dependency attention and schedule risks', () {
      final predecessor = _task(
        id: 'predecessor',
        title: 'Foundation',
        start: DateTime(2026, 5, 1),
        end: DateTime(2026, 5, 8),
        progress: 0.4,
      );
      final complete = _task(
        id: 'complete',
        title: 'Discovery',
        start: DateTime(2026, 5, 1),
        progress: 1,
      );
      final overview = buildGanttDependencyOverviewSummary(
        today: DateTime(2026, 5, 10),
        dependencyTasks: [predecessor, complete],
        tasks: [
          _task(
            id: 'blocked',
            title: 'Blocked Work',
            start: DateTime(2026, 5, 7),
            dependsOn: 'predecessor',
          ),
          _task(
            id: 'ready',
            title: 'Ready Work',
            start: DateTime(2026, 5, 7),
            dependsOn: 'complete',
          ),
        ],
      );

      final summary = service.summaryFor(overview);

      expect(summary.title, 'Dependency health');
      expect(summary.headline, '1 needs attention / 1 schedule risk');
      expect(summary.metrics.map((metric) => metric.label), [
        GanttDependencyHealth.blocked.label,
        '2 linked',
        '1 attention',
        '1 schedule risk',
      ]);
      expect(
        summary.metrics.last.tooltip,
        '1 linked task has a schedule conflict',
      );
    });

    test('summarizes clear linked dependencies', () {
      final complete = _task(
        id: 'complete',
        title: 'Discovery',
        start: DateTime(2026, 5, 1),
        progress: 1,
      );
      final overview = buildGanttDependencyOverviewSummary(
        dependencyTasks: [complete],
        tasks: [
          _task(
            id: 'ready',
            title: 'Ready Work',
            start: DateTime(2026, 5, 12),
            dependsOn: 'complete',
          ),
        ],
      );

      final summary = service.summaryFor(overview);

      expect(summary.headline, '1 linked task clear');
      expect(summary.metrics.map((metric) => metric.label), [
        GanttDependencyHealth.ready.label,
        '1 linked',
        '0 attention',
        'No schedule risk',
      ]);
      expect(summary.metrics[2].isClear, isTrue);
      expect(
        summary.metrics[3].tooltip,
        'No dependency dates conflict with successors',
      );
    });
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

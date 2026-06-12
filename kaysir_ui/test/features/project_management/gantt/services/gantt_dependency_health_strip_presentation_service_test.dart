import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_health_strip_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_health_strip_summary_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_overview_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_service.dart';

void main() {
  group('GanttDependencyHealthStripPresentationService', () {
    const service = GanttDependencyHealthStripPresentationService();

    test('calculates relaxed and compact layout values', () {
      final relaxed = service.layoutFor(compact: false);
      final compact = service.layoutFor(compact: true);

      expect(relaxed.topPadding, 12);
      expect(
        relaxed.pillPadding,
        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      );
      expect(relaxed.summaryMinWidth, 210);
      expect(relaxed.summaryMaxWidth, 310);

      expect(compact.topPadding, 4);
      expect(
        compact.pillPadding,
        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      );
      expect(compact.summaryMinWidth, 178);
      expect(compact.summaryMaxWidth, 260);
    });

    test('describes blocked dependency metric visuals', () {
      final overview = _blockedOverview();
      final metrics =
          const GanttDependencyHealthStripSummaryService()
              .summaryFor(overview)
              .metrics;
      final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

      final signal = service.metricPresentationFor(
        metric: metrics[0],
        overview: overview,
        compact: false,
      );
      final linked = service.metricPresentationFor(
        metric: metrics[1],
        overview: overview,
        compact: true,
      );
      final attention = service.metricPresentationFor(
        metric: metrics[2],
        overview: overview,
        compact: false,
      );
      final risk = service.metricPresentationFor(
        metric: metrics[3],
        overview: overview,
        compact: true,
      );

      expect(signal.icon, GanttDependencyHealth.blocked.icon);
      expect(signal.maxWidth, 150);
      expect(
        signal.colorFor(
          colorScheme: colorScheme,
          overview: overview,
          isClear: metrics[0].isClear,
        ),
        overview.signal.color(colorScheme),
      );

      expect(linked.icon, Icons.account_tree_outlined);
      expect(linked.maxWidth, 130);
      expect(
        linked.colorFor(
          colorScheme: colorScheme,
          overview: overview,
          isClear: metrics[1].isClear,
        ),
        colorScheme.primary,
      );

      expect(attention.icon, Icons.priority_high_rounded);
      expect(attention.maxWidth, 170);
      expect(
        attention.colorFor(
          colorScheme: colorScheme,
          overview: overview,
          isClear: metrics[2].isClear,
        ),
        colorScheme.error,
      );

      expect(risk.icon, Icons.warning_amber_outlined);
      expect(risk.maxWidth, 168);
    });

    test('describes clear dependency metric visuals', () {
      final overview = _clearOverview();
      final metrics =
          const GanttDependencyHealthStripSummaryService()
              .summaryFor(overview)
              .metrics;
      final colorScheme = ColorScheme.fromSeed(seedColor: Colors.teal);

      final attention = service.metricPresentationFor(
        metric: metrics[2],
        overview: overview,
        compact: false,
      );
      final risk = service.metricPresentationFor(
        metric: metrics[3],
        overview: overview,
        compact: false,
      );

      expect(attention.icon, Icons.check_circle_outline);
      expect(
        attention.colorFor(
          colorScheme: colorScheme,
          overview: overview,
          isClear: metrics[2].isClear,
        ),
        Colors.green.shade700,
      );
      expect(risk.icon, Icons.verified_outlined);
      expect(risk.maxWidth, 190);
    });
  });
}

GanttDependencyOverviewSummary _blockedOverview() {
  final predecessor = _task(
    id: 'predecessor',
    title: 'Foundation',
    start: DateTime(2026, 5),
    end: DateTime(2026, 5, 8),
    progress: 0.4,
  );

  return buildGanttDependencyOverviewSummary(
    today: DateTime(2026, 5, 10),
    dependencyTasks: [predecessor],
    tasks: [
      _task(
        id: 'blocked',
        title: 'Blocked Work',
        start: DateTime(2026, 5, 7),
        dependsOn: predecessor.id,
      ),
    ],
  );
}

GanttDependencyOverviewSummary _clearOverview() {
  final complete = _task(
    id: 'complete',
    title: 'Discovery',
    start: DateTime(2026, 5),
    progress: 1,
  );

  return buildGanttDependencyOverviewSummary(
    dependencyTasks: [complete],
    tasks: [
      _task(
        id: 'ready',
        title: 'Ready Work',
        start: DateTime(2026, 5, 12),
        dependsOn: complete.id,
      ),
    ],
  );
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

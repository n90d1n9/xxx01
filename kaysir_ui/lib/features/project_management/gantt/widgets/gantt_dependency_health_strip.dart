import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_dependency_health_strip_presentation_service.dart';
import '../services/gantt_dependency_health_strip_summary_service.dart';
import '../services/gantt_dependency_overview_service.dart';
import '../services/gantt_dependency_service.dart';

/// Compact dependency health summary for the full-screen Gantt header.
class GanttDependencyHealthStrip extends StatelessWidget {
  const GanttDependencyHealthStrip({
    required this.tasks,
    required this.dependencyTasks,
    this.today,
    this.compact = false,
    super.key,
  });

  final List<gantt.GanttTask> tasks;
  final List<gantt.GanttTask> dependencyTasks;
  final DateTime? today;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final summary = buildGanttDependencyOverviewSummary(
      tasks: tasks,
      dependencyTasks: dependencyTasks,
      today: today,
    );
    if (summary.linkedCount == 0) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final stripSummary = const GanttDependencyHealthStripSummaryService()
        .summaryFor(summary);
    final presentationService =
        const GanttDependencyHealthStripPresentationService();
    final layout = presentationService.layoutFor(compact: compact);

    return Padding(
      padding: EdgeInsets.only(top: layout.topPadding),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: layout.summaryMinWidth,
              maxWidth: layout.summaryMaxWidth,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  size: 18,
                  color: summary.signal.color(colorScheme),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stripSummary.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        stripSummary.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final metric in stripSummary.metrics)
            _DependencyHealthMetricPill(
              metric: metric,
              overview: summary,
              compact: compact,
              pillPadding: layout.pillPadding,
            ),
        ],
      ),
    );
  }
}

/// Metric pill rendered inside the dependency health strip.
class _DependencyHealthMetricPill extends StatelessWidget {
  const _DependencyHealthMetricPill({
    required this.metric,
    required this.overview,
    required this.compact,
    required this.pillPadding,
  });

  final GanttDependencyHealthStripMetricItem metric;
  final GanttDependencyOverviewSummary overview;
  final bool compact;
  final EdgeInsets pillPadding;

  @override
  Widget build(BuildContext context) {
    final presentation = const GanttDependencyHealthStripPresentationService()
        .metricPresentationFor(
          metric: metric,
          overview: overview,
          compact: compact,
        );
    final colorScheme = Theme.of(context).colorScheme;

    return AppStatusPill(
      label: metric.label,
      tooltip: metric.tooltip,
      icon: presentation.icon,
      color: presentation.colorFor(
        colorScheme: colorScheme,
        overview: overview,
        isClear: metric.isClear,
      ),
      maxWidth: presentation.maxWidth,
      padding: pillPadding,
    );
  }
}

@Preview(name: 'Gantt dependency health strip')
Widget ganttDependencyHealthStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GanttDependencyHealthStrip(
          today: DateTime(2026, 5, 10),
          dependencyTasks: [_previewFoundationTask, _previewDiscoveryTask],
          tasks: [_previewBlockedTask, _previewReadyTask],
        ),
      ),
    ),
  );
}

final _previewFoundationTask = gantt.GanttTask(
  id: 'preview-foundation',
  title: 'Foundation',
  startDate: DateTime(2026, 5, 1),
  endDate: DateTime(2026, 5, 8),
  progress: 0.42,
);

final _previewDiscoveryTask = gantt.GanttTask(
  id: 'preview-discovery',
  title: 'Discovery',
  startDate: DateTime(2026, 5, 1),
  endDate: DateTime(2026, 5, 6),
  progress: 1,
);

final _previewBlockedTask = gantt.GanttTask(
  id: 'preview-blocked',
  title: 'Implementation',
  startDate: DateTime(2026, 5, 7),
  endDate: DateTime(2026, 5, 16),
  progress: 0.18,
  dependsOn: _previewFoundationTask.id,
);

final _previewReadyTask = gantt.GanttTask(
  id: 'preview-ready',
  title: 'QA Readiness',
  startDate: DateTime(2026, 5, 12),
  endDate: DateTime(2026, 5, 18),
  progress: 0.08,
  dependsOn: _previewDiscoveryTask.id,
);

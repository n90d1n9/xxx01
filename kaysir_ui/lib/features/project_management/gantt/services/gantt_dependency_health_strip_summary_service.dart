import 'gantt_dependency_overview_service.dart';
import 'gantt_dependency_service.dart';

/// Metric roles shown in the dependency health strip.
enum GanttDependencyHealthStripMetric {
  signal,
  linked,
  attention,
  scheduleRisk,
}

/// Summary text for one dependency health strip metric.
class GanttDependencyHealthStripMetricItem {
  const GanttDependencyHealthStripMetricItem({
    required this.metric,
    required this.label,
    required this.tooltip,
    required this.isClear,
  });

  final GanttDependencyHealthStripMetric metric;
  final String label;
  final String tooltip;
  final bool isClear;
}

/// Text snapshot rendered by the dependency health strip.
class GanttDependencyHealthStripSummary {
  const GanttDependencyHealthStripSummary({
    required this.title,
    required this.headline,
    required this.metrics,
  });

  final String title;
  final String headline;
  final List<GanttDependencyHealthStripMetricItem> metrics;
}

/// Builds concise dependency health strip labels from dependency overview data.
class GanttDependencyHealthStripSummaryService {
  const GanttDependencyHealthStripSummaryService();

  GanttDependencyHealthStripSummary summaryFor(
    GanttDependencyOverviewSummary overview,
  ) {
    return GanttDependencyHealthStripSummary(
      title: 'Dependency health',
      headline: _headlineFor(overview),
      metrics: [
        GanttDependencyHealthStripMetricItem(
          metric: GanttDependencyHealthStripMetric.signal,
          label: overview.signal.label,
          tooltip:
              'Current dependency signal: ${overview.signal.label}. '
              '${_attentionSentence(overview)}',
          isClear: overview.attentionCount == 0,
        ),
        GanttDependencyHealthStripMetricItem(
          metric: GanttDependencyHealthStripMetric.linked,
          label: _countLabel(overview.linkedCount, 'linked', 'linked'),
          tooltip: _sentenceLabel(
            overview.linkedCount,
            '1 task has a dependency',
            '${overview.linkedCount} tasks have dependencies',
          ),
          isClear: true,
        ),
        GanttDependencyHealthStripMetricItem(
          metric: GanttDependencyHealthStripMetric.attention,
          label: _countLabel(overview.attentionCount, 'attention', 'attention'),
          tooltip:
              overview.attentionCount == 0
                  ? 'No dependency blockers need attention'
                  : _sentenceLabel(
                    overview.attentionCount,
                    '1 dependency blocker needs attention',
                    '${overview.attentionCount} dependency blockers need attention',
                  ),
          isClear: overview.attentionCount == 0,
        ),
        GanttDependencyHealthStripMetricItem(
          metric: GanttDependencyHealthStripMetric.scheduleRisk,
          label:
              overview.scheduleConflictCount == 0
                  ? 'No schedule risk'
                  : _countLabel(
                    overview.scheduleConflictCount,
                    'schedule risk',
                    'schedule risks',
                  ),
          tooltip:
              overview.scheduleConflictCount == 0
                  ? 'No dependency dates conflict with successors'
                  : _sentenceLabel(
                    overview.scheduleConflictCount,
                    '1 linked task has a schedule conflict',
                    '${overview.scheduleConflictCount} linked tasks have schedule conflicts',
                  ),
          isClear: overview.scheduleConflictCount == 0,
        ),
      ],
    );
  }

  String _headlineFor(GanttDependencyOverviewSummary overview) {
    if (overview.linkedCount == 0) return 'No linked tasks in view';
    if (overview.attentionCount == 0 && overview.scheduleConflictCount == 0) {
      return _sentenceLabel(
        overview.linkedCount,
        '1 linked task clear',
        '${overview.linkedCount} linked tasks clear',
      );
    }

    final signals = [
      if (overview.attentionCount > 0)
        _sentenceLabel(
          overview.attentionCount,
          '1 needs attention',
          '${overview.attentionCount} need attention',
        ),
      if (overview.scheduleConflictCount > 0)
        _sentenceLabel(
          overview.scheduleConflictCount,
          '1 schedule risk',
          '${overview.scheduleConflictCount} schedule risks',
        ),
    ];

    return signals.join(' / ');
  }

  String _attentionSentence(GanttDependencyOverviewSummary overview) {
    if (overview.attentionCount == 0) {
      return 'No linked tasks need attention.';
    }

    return _sentenceLabel(
      overview.attentionCount,
      '1 linked task needs attention.',
      '${overview.attentionCount} linked tasks need attention.',
    );
  }

  String _countLabel(int count, String singular, String plural) {
    return '$count ${count == 1 ? singular : plural}';
  }

  String _sentenceLabel(int count, String singular, String plural) {
    return count == 1 ? singular : plural;
  }
}

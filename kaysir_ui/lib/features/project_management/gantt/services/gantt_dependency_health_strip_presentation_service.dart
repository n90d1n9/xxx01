import 'package:flutter/material.dart';

import 'gantt_dependency_health_strip_summary_service.dart';
import 'gantt_dependency_overview_service.dart';
import 'gantt_dependency_service.dart';

/// Layout values for the dependency health strip in compact or relaxed modes.
class GanttDependencyHealthStripLayout {
  const GanttDependencyHealthStripLayout({
    required this.topPadding,
    required this.pillPadding,
    required this.summaryMinWidth,
    required this.summaryMaxWidth,
  });

  final double topPadding;
  final EdgeInsets pillPadding;
  final double summaryMinWidth;
  final double summaryMaxWidth;
}

/// Color role used by dependency health metric pills.
enum GanttDependencyHealthStripMetricAccent { signal, primary, state }

/// Visual metadata for one dependency health metric pill.
class GanttDependencyHealthStripMetricPresentation {
  const GanttDependencyHealthStripMetricPresentation({
    required this.metric,
    required this.icon,
    required this.maxWidth,
    required this.accent,
  });

  final GanttDependencyHealthStripMetric metric;
  final IconData icon;
  final double maxWidth;
  final GanttDependencyHealthStripMetricAccent accent;

  Color colorFor({
    required ColorScheme colorScheme,
    required GanttDependencyOverviewSummary overview,
    required bool isClear,
  }) {
    switch (accent) {
      case GanttDependencyHealthStripMetricAccent.signal:
        return overview.signal.color(colorScheme);
      case GanttDependencyHealthStripMetricAccent.primary:
        return colorScheme.primary;
      case GanttDependencyHealthStripMetricAccent.state:
        return isClear ? Colors.green.shade700 : colorScheme.error;
    }
  }
}

/// Provides reusable layout and visual rules for dependency health strips.
class GanttDependencyHealthStripPresentationService {
  const GanttDependencyHealthStripPresentationService();

  static const signalMetricWidth = 150.0;
  static const linkedMetricWidth = 150.0;
  static const compactLinkedMetricWidth = 130.0;
  static const attentionMetricWidth = 170.0;
  static const compactAttentionMetricWidth = 148.0;
  static const scheduleRiskMetricWidth = 190.0;
  static const compactScheduleRiskMetricWidth = 168.0;

  GanttDependencyHealthStripLayout layoutFor({required bool compact}) {
    return GanttDependencyHealthStripLayout(
      topPadding: compact ? 4 : 12,
      pillPadding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      summaryMinWidth: compact ? 178 : 210,
      summaryMaxWidth: compact ? 260 : 310,
    );
  }

  GanttDependencyHealthStripMetricPresentation metricPresentationFor({
    required GanttDependencyHealthStripMetricItem metric,
    required GanttDependencyOverviewSummary overview,
    required bool compact,
  }) {
    return GanttDependencyHealthStripMetricPresentation(
      metric: metric.metric,
      icon: _metricIcon(metric, overview),
      maxWidth: _metricWidth(metric.metric, compact: compact),
      accent: _metricAccent(metric.metric),
    );
  }

  IconData _metricIcon(
    GanttDependencyHealthStripMetricItem metric,
    GanttDependencyOverviewSummary overview,
  ) {
    switch (metric.metric) {
      case GanttDependencyHealthStripMetric.signal:
        return overview.signal.icon;
      case GanttDependencyHealthStripMetric.linked:
        return Icons.account_tree_outlined;
      case GanttDependencyHealthStripMetric.attention:
        return metric.isClear
            ? Icons.check_circle_outline
            : Icons.priority_high_rounded;
      case GanttDependencyHealthStripMetric.scheduleRisk:
        return metric.isClear
            ? Icons.verified_outlined
            : Icons.warning_amber_outlined;
    }
  }

  GanttDependencyHealthStripMetricAccent _metricAccent(
    GanttDependencyHealthStripMetric metric,
  ) {
    switch (metric) {
      case GanttDependencyHealthStripMetric.signal:
        return GanttDependencyHealthStripMetricAccent.signal;
      case GanttDependencyHealthStripMetric.linked:
        return GanttDependencyHealthStripMetricAccent.primary;
      case GanttDependencyHealthStripMetric.attention:
      case GanttDependencyHealthStripMetric.scheduleRisk:
        return GanttDependencyHealthStripMetricAccent.state;
    }
  }

  double _metricWidth(
    GanttDependencyHealthStripMetric metric, {
    required bool compact,
  }) {
    switch (metric) {
      case GanttDependencyHealthStripMetric.signal:
        return signalMetricWidth;
      case GanttDependencyHealthStripMetric.linked:
        return compact ? compactLinkedMetricWidth : linkedMetricWidth;
      case GanttDependencyHealthStripMetric.attention:
        return compact ? compactAttentionMetricWidth : attentionMetricWidth;
      case GanttDependencyHealthStripMetric.scheduleRisk:
        return compact
            ? compactScheduleRiskMetricWidth
            : scheduleRiskMetricWidth;
    }
  }
}

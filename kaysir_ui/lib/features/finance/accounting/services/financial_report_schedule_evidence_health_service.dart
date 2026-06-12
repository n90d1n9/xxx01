import '../models/financial_report_pack.dart';

enum FinancialReportScheduleEvidenceHealthLevel { ready, monitor, action }

extension FinancialReportScheduleEvidenceHealthLevelLabel
    on FinancialReportScheduleEvidenceHealthLevel {
  String get label {
    switch (this) {
      case FinancialReportScheduleEvidenceHealthLevel.ready:
        return 'Ready';
      case FinancialReportScheduleEvidenceHealthLevel.monitor:
        return 'Monitor';
      case FinancialReportScheduleEvidenceHealthLevel.action:
        return 'Action';
    }
  }
}

class FinancialReportScheduleEvidenceHealthSummary {
  final int criticalSignalCount;
  final int watchSignalCount;
  final int readySignalCount;
  final List<String> actions;

  const FinancialReportScheduleEvidenceHealthSummary({
    required this.criticalSignalCount,
    required this.watchSignalCount,
    required this.readySignalCount,
    this.actions = const [],
  });

  bool get isReady => level == FinancialReportScheduleEvidenceHealthLevel.ready;

  FinancialReportScheduleEvidenceHealthLevel get level {
    if (criticalSignalCount > 0) {
      return FinancialReportScheduleEvidenceHealthLevel.action;
    }
    if (watchSignalCount > 0) {
      return FinancialReportScheduleEvidenceHealthLevel.monitor;
    }
    return FinancialReportScheduleEvidenceHealthLevel.ready;
  }

  String get actionLabel {
    if (criticalSignalCount > 0) {
      return [
        'Resolve $criticalSignalCount critical evidence signal(s).',
        if (watchSignalCount > 0) 'Monitor $watchSignalCount watch signal(s).',
        if (actions.isNotEmpty) actions.first,
      ].join(' ');
    }
    if (watchSignalCount > 0) {
      return [
        'Monitor $watchSignalCount evidence signal(s).',
        if (actions.isNotEmpty) actions.first,
      ].join(' ');
    }
    return 'Evidence ready';
  }
}

class FinancialReportScheduleEvidenceHealthItem {
  final FinancialReportSupportingScheduleKind scheduleKind;
  final String scheduleTitle;
  final FinancialReportScheduleEvidenceHealthSummary summary;

  const FinancialReportScheduleEvidenceHealthItem({
    required this.scheduleKind,
    required this.scheduleTitle,
    required this.summary,
  });

  FinancialReportScheduleEvidenceHealthLevel get level => summary.level;

  String get actionLabel => summary.actionLabel;
}

class FinancialReportScheduleEvidenceHealthService {
  const FinancialReportScheduleEvidenceHealthService();

  FinancialReportScheduleEvidenceHealthSummary summarize(
    Iterable<FinancialReportSupportingSchedule> schedules,
  ) {
    final items = summarizeBySchedule(schedules);
    return _combine(items.map((item) => item.summary));
  }

  List<FinancialReportScheduleEvidenceHealthItem> summarizeBySchedule(
    Iterable<FinancialReportSupportingSchedule> schedules,
  ) {
    return schedules.map(_summarizeSchedule).toList(growable: false);
  }

  FinancialReportScheduleEvidenceHealthSummary _combine(
    Iterable<FinancialReportScheduleEvidenceHealthSummary> summaries,
  ) {
    var criticalCount = 0;
    var watchCount = 0;
    var readyCount = 0;
    final actions = <String>{};

    for (final summary in summaries) {
      criticalCount += summary.criticalSignalCount;
      watchCount += summary.watchSignalCount;
      readyCount += summary.readySignalCount;
      actions.addAll(summary.actions);
    }

    return FinancialReportScheduleEvidenceHealthSummary(
      criticalSignalCount: criticalCount,
      watchSignalCount: watchCount,
      readySignalCount: readyCount,
      actions: actions.toList(growable: false),
    );
  }

  FinancialReportScheduleEvidenceHealthItem _summarizeSchedule(
    FinancialReportSupportingSchedule schedule,
  ) {
    var criticalCount = 0;
    var watchCount = 0;
    var readyCount = 0;
    final actions = <String>{};

    final hasMetricEvidence = _hasMetricEvidence(schedule);
    for (final metric in schedule.metrics) {
      final metricHealth = _metricHealth(metric);
      criticalCount += metricHealth.criticalCount;
      watchCount += metricHealth.watchCount;
      readyCount += metricHealth.readyCount;
      if (metricHealth.action != null) {
        actions.add(metricHealth.action!);
      }
    }

    if (!hasMetricEvidence) {
      for (final line in schedule.lines) {
        switch (_lineHealthLevel(line.sourceCategory)) {
          case FinancialReportScheduleEvidenceHealthLevel.action:
            criticalCount += 1;
          case FinancialReportScheduleEvidenceHealthLevel.monitor:
            watchCount += 1;
          case FinancialReportScheduleEvidenceHealthLevel.ready:
            if (line.sourceCategory != null) {
              readyCount += 1;
            }
        }
      }
    }

    return FinancialReportScheduleEvidenceHealthItem(
      scheduleKind: schedule.kind,
      scheduleTitle: schedule.title,
      summary: FinancialReportScheduleEvidenceHealthSummary(
        criticalSignalCount: criticalCount,
        watchSignalCount: watchCount,
        readySignalCount: readyCount,
        actions: actions.toList(growable: false),
      ),
    );
  }

  bool _hasMetricEvidence(FinancialReportSupportingSchedule schedule) {
    return schedule.metrics.any(
      (metric) =>
          metric.label == 'Timing deadline risk' ||
          metric.label == 'Timing review gaps',
    );
  }

  _MetricHealth _metricHealth(FinancialReportScheduleMetric metric) {
    switch (metric.label) {
      case 'Timing deadline risk':
        final overdueCount = _countBefore(metric.value, 'overdue');
        final dueSoonCount = _countBefore(metric.value, 'due soon');
        return _MetricHealth(
          criticalCount: overdueCount,
          watchCount: dueSoonCount,
          action:
              overdueCount > 0
                  ? 'Clear overdue timing deadline(s).'
                  : dueSoonCount > 0
                  ? 'Confirm timing items due soon.'
                  : null,
        );
      case 'Timing review gaps':
        final unreviewedCount = _countBefore(metric.value, 'unreviewed');
        final ownerGapCount = _countBefore(metric.value, 'owner gaps');
        final overdueUnresolvedCount = _countBefore(
          metric.value,
          'overdue unresolved',
        );
        return _MetricHealth(
          criticalCount: ownerGapCount + overdueUnresolvedCount,
          watchCount: unreviewedCount,
          action:
              overdueUnresolvedCount > 0
                  ? 'Resolve overdue timing review gap(s).'
                  : ownerGapCount > 0
                  ? 'Assign timing review owner(s).'
                  : unreviewedCount > 0
                  ? 'Document open timing review(s).'
                  : null,
        );
      case 'Timing review action':
        return _MetricHealth(
          action:
              metric.value == 'Timing review evidence complete'
                  ? null
                  : metric.value,
        );
      case 'Timing review coverage':
        return _MetricHealth(readyCount: metric.value.contains('/0') ? 0 : 1);
      default:
        return const _MetricHealth();
    }
  }

  FinancialReportScheduleEvidenceHealthLevel _lineHealthLevel(String? source) {
    final normalized = source?.toLowerCase() ?? '';
    if (normalized.isEmpty) {
      return FinancialReportScheduleEvidenceHealthLevel.ready;
    }
    if (normalized.contains('overdue') ||
        normalized.contains('escalate') ||
        normalized.contains('unassigned')) {
      return FinancialReportScheduleEvidenceHealthLevel.action;
    }
    if (normalized.contains('due soon') ||
        normalized.contains('monitor') ||
        normalized.contains('review deferred') ||
        normalized.contains('in review') ||
        normalized.contains('review open')) {
      return FinancialReportScheduleEvidenceHealthLevel.monitor;
    }
    return FinancialReportScheduleEvidenceHealthLevel.ready;
  }

  int _countBefore(String value, String label) {
    final match = RegExp(
      r'(\d+)\s+' + RegExp.escape(label),
      caseSensitive: false,
    ).firstMatch(value);
    if (match == null) {
      return 0;
    }
    return int.tryParse(match.group(1) ?? '') ?? 0;
  }
}

class _MetricHealth {
  final int criticalCount;
  final int watchCount;
  final int readyCount;
  final String? action;

  const _MetricHealth({
    this.criticalCount = 0,
    this.watchCount = 0,
    this.readyCount = 0,
    this.action,
  });
}

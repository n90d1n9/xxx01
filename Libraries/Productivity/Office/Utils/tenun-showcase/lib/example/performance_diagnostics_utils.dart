import 'dart:convert';
import 'dart:math' as math;

import 'package:tenun/tenun_core.dart';

abstract final class PerformanceDiagnosticsData {
  static List<double> buildSignal(int points) {
    return List.generate(points, (i) {
      final wave = math.sin(i / 21) * 42;
      final season = math.cos(i / 83) * 24;
      final trend = i / math.max(1, points) * 70;
      final spike = i % 907 == 0 ? 80 : 0;
      return 120 + trend + wave + season + spike;
    });
  }

  static Map<String, dynamic> buildChartPayload({
    required ChartType chartType,
    required ChartDataMode dataMode,
    required SamplingStrategy? samplingStrategy,
    required int renderThreshold,
    required List<double> signal,
  }) {
    return {
      'type': chartTypeToString(chartType),
      'dataMode': dataMode.name,
      'title': {'text': 'Diagnostics Signal'},
      'tooltip': {'show': true},
      'legend': {'show': true},
      'sampling': {
        'enabled': dataMode != ChartDataMode.regular,
        'threshold': renderThreshold,
        'strategy': samplingStrategy?.name ?? 'auto',
      },
      'diagnostics': {
        'performancePolicy': {
          'largeDatasetPointThreshold': math.max(1, renderThreshold * 4),
          'cachePressureWarningThreshold': '85%',
          'lowRenderCacheHitRateThreshold': '20%',
          'lowRenderCacheMinRequests': 4,
        },
      },
      'series': [
        {'name': 'Signal', 'data': signal},
      ],
    };
  }

  static int renderedPointCount(Map<String, dynamic> payload) {
    try {
      final config = BaseChartConfig.fromJson(payload);
      return config.series.fold<int>(
        0,
        (total, series) => total + (series.data?.length ?? 0),
      );
    } catch (_) {
      return 0;
    }
  }
}

abstract final class PerformanceDiagnosticsFormat {
  static String micros(Duration duration) {
    if (duration.inMilliseconds >= 1) {
      return '${duration.inMilliseconds} ms';
    }
    return '${duration.inMicroseconds} us';
  }

  static String percent(double ratio) => '${(ratio * 100).toStringAsFixed(1)}%';

  static String signedInt(int value, {String suffix = ''}) {
    final sign = value > 0 ? '+' : '';
    final suffixText = suffix.isEmpty ? '' : ' $suffix';
    return '$sign$value$suffixText';
  }

  static String signedPercent(double ratio) {
    final sign = ratio > 0 ? '+' : '';
    return '$sign${percent(ratio)}';
  }

  static String signedMicros(Duration duration) {
    final value = duration.inMicroseconds;
    if (value == 0) return micros(Duration.zero);

    final sign = value > 0 ? '+' : '-';
    final magnitude = Duration(microseconds: value.abs());
    return '$sign${micros(magnitude)}';
  }

  static String objectCache(ChartObjectCacheStats stats) {
    final cap = stats.maxSize == null ? '' : '/${stats.maxSize}';
    return '${stats.size}$cap | ${stats.hits}/${stats.misses} | '
        '${(stats.hitRate * 100).toStringAsFixed(1)}%';
  }

  static String bytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class PerformanceDiagnosticsHistoryEntry {
  final int run;
  final int dataPointCount;
  final int sampleInputPointCount;
  final int outputPointCount;
  final double samplingReductionRatio;
  final double cacheHitRate;
  final bool cacheHit;
  final bool usedIsolate;
  final bool wasDownsampled;
  final String path;
  final Duration totalDuration;

  const PerformanceDiagnosticsHistoryEntry({
    required this.run,
    required this.dataPointCount,
    required this.sampleInputPointCount,
    required this.outputPointCount,
    required this.samplingReductionRatio,
    required this.cacheHitRate,
    required this.cacheHit,
    required this.usedIsolate,
    required this.wasDownsampled,
    required this.path,
    required this.totalDuration,
  });

  factory PerformanceDiagnosticsHistoryEntry.fromReport(
    AsyncChartProcessingReport report, {
    required int run,
  }) {
    return PerformanceDiagnosticsHistoryEntry(
      run: run,
      dataPointCount: report.dataPointCount,
      sampleInputPointCount: report.sampleInputPointCount,
      outputPointCount: report.outputPointCount,
      samplingReductionRatio: report.samplingReductionRatio,
      cacheHitRate: ChartDataProcessor.processingCacheStats.hitRate,
      cacheHit: report.cacheHit,
      usedIsolate: report.usedIsolate,
      wasDownsampled: report.wasDownsampled,
      path: report.processingReport.path.name,
      totalDuration: report.totalDuration,
    );
  }

  Map<String, dynamic> toJson() => {
    'run': run,
    'dataPointCount': dataPointCount,
    'sampleInputPointCount': sampleInputPointCount,
    'outputPointCount': outputPointCount,
    'samplingReductionRatio': samplingReductionRatio,
    'cacheHitRate': cacheHitRate,
    'cacheHit': cacheHit,
    'usedIsolate': usedIsolate,
    'wasDownsampled': wasDownsampled,
    'path': path,
    'totalDurationMicros': totalDuration.inMicroseconds,
  };
}

enum PerformanceDiagnosticsTrendSeverity { pending, healthy, info, warning }

enum PerformanceDiagnosticsTrendRecommendation {
  collectAnotherRun,
  stable,
  improved,
  reviewDurationRegression,
  reviewCacheRegression,
  reviewSamplingRegression,
}

enum PerformanceDiagnosticsAggregateSeverity { pending, healthy, info, warning }

enum PerformanceDiagnosticsAggregateRecommendation {
  collectMoreRuns,
  stable,
  reviewDurationVariance,
  reviewCacheConsistency,
  reviewSamplingConsistency,
}

class PerformanceDiagnosticsHistorySummary {
  static const double durationRegressionRatioThreshold = 0.2;
  static const int durationRegressionMinMicros = 2000;
  static const double cacheRegressionThreshold = -0.15;
  static const double samplingRegressionThreshold = -0.1;
  static const double improvementRatioThreshold = -0.15;
  static const double cacheImprovementThreshold = 0.15;
  static const double samplingImprovementThreshold = 0.1;

  final int runCount;
  final PerformanceDiagnosticsHistoryEntry latest;
  final PerformanceDiagnosticsHistoryEntry? previous;

  const PerformanceDiagnosticsHistorySummary({
    required this.runCount,
    required this.latest,
    required this.previous,
  });

  factory PerformanceDiagnosticsHistorySummary.fromEntries(
    List<PerformanceDiagnosticsHistoryEntry> entries,
  ) {
    if (entries.isEmpty) {
      throw ArgumentError.value(entries, 'entries', 'must not be empty');
    }

    return PerformanceDiagnosticsHistorySummary(
      runCount: entries.length,
      latest: entries.first,
      previous: entries.length > 1 ? entries[1] : null,
    );
  }

  static PerformanceDiagnosticsHistorySummary? tryFromEntries(
    List<PerformanceDiagnosticsHistoryEntry> entries,
  ) {
    if (entries.isEmpty) return null;
    return PerformanceDiagnosticsHistorySummary.fromEntries(entries);
  }

  bool get hasPrevious => previous != null;

  int get dataPointDelta =>
      previous == null ? 0 : latest.dataPointCount - previous!.dataPointCount;

  int get sampleInputPointDelta => previous == null
      ? 0
      : latest.sampleInputPointCount - previous!.sampleInputPointCount;

  int get outputPointDelta => previous == null
      ? 0
      : latest.outputPointCount - previous!.outputPointCount;

  double get samplingReductionDelta => previous == null
      ? 0
      : latest.samplingReductionRatio - previous!.samplingReductionRatio;

  double get cacheHitRateDelta =>
      previous == null ? 0 : latest.cacheHitRate - previous!.cacheHitRate;

  Duration get totalDurationDelta => previous == null
      ? Duration.zero
      : latest.totalDuration - previous!.totalDuration;

  double get totalDurationDeltaRatio {
    final baseline = previous?.totalDuration.inMicroseconds;
    if (baseline == null || baseline <= 0) return 0;
    return totalDurationDelta.inMicroseconds / baseline;
  }

  bool get hasDurationRegression =>
      hasPrevious &&
      totalDurationDelta.inMicroseconds >= durationRegressionMinMicros &&
      totalDurationDeltaRatio >= durationRegressionRatioThreshold;

  bool get hasCacheRegression =>
      hasPrevious && cacheHitRateDelta <= cacheRegressionThreshold;

  bool get hasSamplingRegression =>
      hasPrevious &&
      outputPointDelta > 0 &&
      samplingReductionDelta <= samplingRegressionThreshold;

  bool get hasMeaningfulImprovement =>
      hasPrevious &&
      (totalDurationDeltaRatio <= improvementRatioThreshold ||
          cacheHitRateDelta >= cacheImprovementThreshold ||
          samplingReductionDelta >= samplingImprovementThreshold);

  PerformanceDiagnosticsTrendRecommendation get recommendation {
    if (!hasPrevious) {
      return PerformanceDiagnosticsTrendRecommendation.collectAnotherRun;
    }
    if (hasDurationRegression) {
      return PerformanceDiagnosticsTrendRecommendation.reviewDurationRegression;
    }
    if (hasCacheRegression) {
      return PerformanceDiagnosticsTrendRecommendation.reviewCacheRegression;
    }
    if (hasSamplingRegression) {
      return PerformanceDiagnosticsTrendRecommendation.reviewSamplingRegression;
    }
    if (hasMeaningfulImprovement) {
      return PerformanceDiagnosticsTrendRecommendation.improved;
    }
    return PerformanceDiagnosticsTrendRecommendation.stable;
  }

  PerformanceDiagnosticsTrendSeverity get severity {
    switch (recommendation) {
      case PerformanceDiagnosticsTrendRecommendation.collectAnotherRun:
        return PerformanceDiagnosticsTrendSeverity.pending;
      case PerformanceDiagnosticsTrendRecommendation.stable:
        return PerformanceDiagnosticsTrendSeverity.healthy;
      case PerformanceDiagnosticsTrendRecommendation.improved:
        return PerformanceDiagnosticsTrendSeverity.info;
      case PerformanceDiagnosticsTrendRecommendation.reviewDurationRegression:
      case PerformanceDiagnosticsTrendRecommendation.reviewCacheRegression:
      case PerformanceDiagnosticsTrendRecommendation.reviewSamplingRegression:
        return PerformanceDiagnosticsTrendSeverity.warning;
    }
  }

  String get recommendationHint {
    switch (recommendation) {
      case PerformanceDiagnosticsTrendRecommendation.collectAnotherRun:
        return 'Run diagnostics again to build a comparison baseline.';
      case PerformanceDiagnosticsTrendRecommendation.stable:
        return 'Latest run is within the trend thresholds.';
      case PerformanceDiagnosticsTrendRecommendation.improved:
        return 'Latest run improved duration, cache reuse, or sampling reduction.';
      case PerformanceDiagnosticsTrendRecommendation.reviewDurationRegression:
        return 'Latest run is materially slower; compare data size, sampling mode, and cache hit state.';
      case PerformanceDiagnosticsTrendRecommendation.reviewCacheRegression:
        return 'Processing cache hit rate dropped; confirm payload keys and reusable config remain stable.';
      case PerformanceDiagnosticsTrendRecommendation.reviewSamplingRegression:
        return 'Sampling reduction weakened while output grew; review threshold and sampling strategy.';
    }
  }

  Map<String, dynamic> toJson() => {
    'runCount': runCount,
    'latestRun': latest.run,
    'previousRun': previous?.run,
    'dataPointDelta': dataPointDelta,
    'sampleInputPointDelta': sampleInputPointDelta,
    'outputPointDelta': outputPointDelta,
    'samplingReductionDelta': samplingReductionDelta,
    'cacheHitRateDelta': cacheHitRateDelta,
    'totalDurationDeltaMicros': totalDurationDelta.inMicroseconds,
    'totalDurationDeltaRatio': totalDurationDeltaRatio,
    'trendSeverity': severity.name,
    'trendRecommendation': recommendation.name,
    'trendRecommendationHint': recommendationHint,
  };
}

class PerformanceDiagnosticsHistoryAggregate {
  static const int stabilityMinRunCount = 3;
  static const double durationSpreadWarningRatio = 0.5;

  final int runCount;
  final Duration averageDuration;
  final PerformanceDiagnosticsHistoryEntry fastest;
  final PerformanceDiagnosticsHistoryEntry slowest;
  final double averageDataPointCount;
  final double averageSampleInputPointCount;
  final double averageOutputPointCount;
  final double averageSamplingReductionRatio;
  final double averageCacheHitRate;
  final int cacheHitRunCount;
  final int downsampledRunCount;
  final int isolateRunCount;

  const PerformanceDiagnosticsHistoryAggregate({
    required this.runCount,
    required this.averageDuration,
    required this.fastest,
    required this.slowest,
    required this.averageDataPointCount,
    required this.averageSampleInputPointCount,
    required this.averageOutputPointCount,
    required this.averageSamplingReductionRatio,
    required this.averageCacheHitRate,
    required this.cacheHitRunCount,
    required this.downsampledRunCount,
    required this.isolateRunCount,
  });

  factory PerformanceDiagnosticsHistoryAggregate.fromEntries(
    List<PerformanceDiagnosticsHistoryEntry> entries,
  ) {
    if (entries.isEmpty) {
      throw ArgumentError.value(entries, 'entries', 'must not be empty');
    }

    var totalDurationMicros = 0;
    var totalDataPoints = 0;
    var totalSampleInputPoints = 0;
    var totalOutputPoints = 0;
    var totalSamplingReduction = 0.0;
    var totalCacheHitRate = 0.0;
    var cacheHits = 0;
    var downsampled = 0;
    var isolates = 0;
    var fastest = entries.first;
    var slowest = entries.first;

    for (final entry in entries) {
      totalDurationMicros += entry.totalDuration.inMicroseconds;
      totalDataPoints += entry.dataPointCount;
      totalSampleInputPoints += entry.sampleInputPointCount;
      totalOutputPoints += entry.outputPointCount;
      totalSamplingReduction += entry.samplingReductionRatio;
      totalCacheHitRate += entry.cacheHitRate;
      if (entry.cacheHit) cacheHits++;
      if (entry.wasDownsampled) downsampled++;
      if (entry.usedIsolate) isolates++;
      if (entry.totalDuration < fastest.totalDuration) fastest = entry;
      if (entry.totalDuration > slowest.totalDuration) slowest = entry;
    }

    final runCount = entries.length;
    return PerformanceDiagnosticsHistoryAggregate(
      runCount: runCount,
      averageDuration: Duration(
        microseconds: (totalDurationMicros / runCount).round(),
      ),
      fastest: fastest,
      slowest: slowest,
      averageDataPointCount: totalDataPoints / runCount,
      averageSampleInputPointCount: totalSampleInputPoints / runCount,
      averageOutputPointCount: totalOutputPoints / runCount,
      averageSamplingReductionRatio: totalSamplingReduction / runCount,
      averageCacheHitRate: totalCacheHitRate / runCount,
      cacheHitRunCount: cacheHits,
      downsampledRunCount: downsampled,
      isolateRunCount: isolates,
    );
  }

  static PerformanceDiagnosticsHistoryAggregate? tryFromEntries(
    List<PerformanceDiagnosticsHistoryEntry> entries,
  ) {
    if (entries.isEmpty) return null;
    return PerformanceDiagnosticsHistoryAggregate.fromEntries(entries);
  }

  double get cacheHitRunRatio => _runRatio(cacheHitRunCount);

  double get downsampledRunRatio => _runRatio(downsampledRunCount);

  double get isolateRunRatio => _runRatio(isolateRunCount);

  Duration get durationSpread => slowest.totalDuration - fastest.totalDuration;

  double get durationSpreadRatio {
    final baseline = averageDuration.inMicroseconds;
    if (baseline <= 0) return 0;
    return durationSpread.inMicroseconds / baseline;
  }

  bool get hasEnoughRunsForStability => runCount >= stabilityMinRunCount;

  bool get hasDurationVarianceWarning =>
      hasEnoughRunsForStability &&
      durationSpreadRatio >= durationSpreadWarningRatio;

  bool get hasMixedCacheState =>
      hasEnoughRunsForStability &&
      cacheHitRunCount > 0 &&
      cacheHitRunCount < runCount;

  bool get hasMixedSamplingState =>
      hasEnoughRunsForStability &&
      downsampledRunCount > 0 &&
      downsampledRunCount < runCount;

  PerformanceDiagnosticsAggregateRecommendation get recommendation {
    if (!hasEnoughRunsForStability) {
      return PerformanceDiagnosticsAggregateRecommendation.collectMoreRuns;
    }
    if (hasDurationVarianceWarning) {
      return PerformanceDiagnosticsAggregateRecommendation
          .reviewDurationVariance;
    }
    if (hasMixedCacheState) {
      return PerformanceDiagnosticsAggregateRecommendation
          .reviewCacheConsistency;
    }
    if (hasMixedSamplingState) {
      return PerformanceDiagnosticsAggregateRecommendation
          .reviewSamplingConsistency;
    }
    return PerformanceDiagnosticsAggregateRecommendation.stable;
  }

  PerformanceDiagnosticsAggregateSeverity get severity {
    switch (recommendation) {
      case PerformanceDiagnosticsAggregateRecommendation.collectMoreRuns:
        return PerformanceDiagnosticsAggregateSeverity.pending;
      case PerformanceDiagnosticsAggregateRecommendation.stable:
        return PerformanceDiagnosticsAggregateSeverity.healthy;
      case PerformanceDiagnosticsAggregateRecommendation.reviewDurationVariance:
        return PerformanceDiagnosticsAggregateSeverity.warning;
      case PerformanceDiagnosticsAggregateRecommendation.reviewCacheConsistency:
      case PerformanceDiagnosticsAggregateRecommendation
          .reviewSamplingConsistency:
        return PerformanceDiagnosticsAggregateSeverity.info;
    }
  }

  String get recommendationHint {
    switch (recommendation) {
      case PerformanceDiagnosticsAggregateRecommendation.collectMoreRuns:
        return 'Collect at least $stabilityMinRunCount runs before judging stability.';
      case PerformanceDiagnosticsAggregateRecommendation.stable:
        return 'Recent runs are stable across timing, cache state, and sampling state.';
      case PerformanceDiagnosticsAggregateRecommendation.reviewDurationVariance:
        return 'Fastest and slowest runs differ materially; rerun with the same controls and inspect cache warm-up.';
      case PerformanceDiagnosticsAggregateRecommendation.reviewCacheConsistency:
        return 'Some runs hit the processing cache and others missed; confirm stable payload keys and config inputs.';
      case PerformanceDiagnosticsAggregateRecommendation
          .reviewSamplingConsistency:
        return 'Some runs were downsampled and others were not; confirm data mode, threshold, and viewport controls.';
    }
  }

  double _runRatio(int count) => runCount <= 0 ? 0 : count / runCount;

  Map<String, dynamic> toJson() => {
    'runCount': runCount,
    'aggregateSeverity': severity.name,
    'aggregateRecommendation': recommendation.name,
    'aggregateRecommendationHint': recommendationHint,
    'averageDurationMicros': averageDuration.inMicroseconds,
    'durationSpreadMicros': durationSpread.inMicroseconds,
    'durationSpreadRatio': durationSpreadRatio,
    'fastestRun': fastest.run,
    'fastestDurationMicros': fastest.totalDuration.inMicroseconds,
    'slowestRun': slowest.run,
    'slowestDurationMicros': slowest.totalDuration.inMicroseconds,
    'averageDataPointCount': averageDataPointCount,
    'averageSampleInputPointCount': averageSampleInputPointCount,
    'averageOutputPointCount': averageOutputPointCount,
    'averageSamplingReductionRatio': averageSamplingReductionRatio,
    'averageCacheHitRate': averageCacheHitRate,
    'cacheHitRunCount': cacheHitRunCount,
    'cacheHitRunRatio': cacheHitRunRatio,
    'downsampledRunCount': downsampledRunCount,
    'downsampledRunRatio': downsampledRunRatio,
    'isolateRunCount': isolateRunCount,
    'isolateRunRatio': isolateRunRatio,
  };
}

enum PerformanceDiagnosticsExportSeverity { healthy, info, warning }

enum PerformanceDiagnosticsExportRecommendation {
  ready,
  collectRuntimeDiagnostics,
  collectMoreHistory,
  useCompactExport,
  reviewLargeCompactExport,
}

enum PerformanceDiagnosticsSupportBundleValidationSeverity {
  valid,
  warning,
  error,
}

class PerformanceDiagnosticsSupportBundleValidationResult {
  final List<String> errors;
  final List<String> warnings;

  PerformanceDiagnosticsSupportBundleValidationResult({
    List<String> errors = const [],
    List<String> warnings = const [],
  }) : errors = List.unmodifiable(errors),
       warnings = List.unmodifiable(warnings);

  bool get isValid => errors.isEmpty;

  bool get hasWarnings => warnings.isNotEmpty;

  PerformanceDiagnosticsSupportBundleValidationSeverity get severity {
    if (errors.isNotEmpty) {
      return PerformanceDiagnosticsSupportBundleValidationSeverity.error;
    }
    if (warnings.isNotEmpty) {
      return PerformanceDiagnosticsSupportBundleValidationSeverity.warning;
    }
    return PerformanceDiagnosticsSupportBundleValidationSeverity.valid;
  }

  String get summary {
    if (errors.isNotEmpty) {
      return '${errors.length} error${errors.length == 1 ? '' : 's'}';
    }
    if (warnings.isNotEmpty) {
      return '${warnings.length} warning${warnings.length == 1 ? '' : 's'}';
    }
    return 'Bundle schema and fingerprints are valid.';
  }

  Map<String, dynamic> toJson() => {
    'valid': isValid,
    'severity': severity.name,
    'summary': summary,
    'errors': errors,
    'warnings': warnings,
  };
}

class PerformanceDiagnosticsSupportBundlePreview {
  final int? bundleVersion;
  final String? kind;
  final int? maxHistoryEntries;
  final String? bundleFingerprint;
  final String? compactFingerprint;
  final String? exportSeverity;
  final String? exportRecommendation;
  final String? exportRecommendationHint;
  final int? diagnosticOutputPoints;
  final int? historyRunCount;
  final int? includedHistoryRunCount;
  final bool? hasRuntimeDiagnostics;
  final int? sourceDataPointCount;
  final int? renderedDataPointCount;
  final PerformanceDiagnosticsSupportBundleValidationResult validation;

  PerformanceDiagnosticsSupportBundlePreview({
    this.bundleVersion,
    this.kind,
    this.maxHistoryEntries,
    this.bundleFingerprint,
    this.compactFingerprint,
    this.exportSeverity,
    this.exportRecommendation,
    this.exportRecommendationHint,
    this.diagnosticOutputPoints,
    this.historyRunCount,
    this.includedHistoryRunCount,
    this.hasRuntimeDiagnostics,
    this.sourceDataPointCount,
    this.renderedDataPointCount,
    required this.validation,
  });

  bool get isValid => validation.isValid;

  String get summary {
    final action = exportRecommendation ?? 'unknownAction';
    final pointText = diagnosticOutputPoints == null
        ? 'unknown points'
        : '$diagnosticOutputPoints pts';
    final historyText = historyRunCount == null
        ? 'unknown history'
        : '$historyRunCount runs';
    return '${validation.severity.name} | $action | $pointText | $historyText';
  }

  static PerformanceDiagnosticsSupportBundlePreview fromJsonString(
    String source,
  ) {
    try {
      return fromJson(jsonDecode(source));
    } catch (error) {
      return PerformanceDiagnosticsSupportBundlePreview(
        validation: PerformanceDiagnosticsSupportBundleValidationResult(
          errors: ['Support bundle JSON could not be decoded: $error'],
        ),
      );
    }
  }

  static PerformanceDiagnosticsSupportBundlePreview fromJson(Object? value) {
    final validation = PerformanceDiagnosticsSupportBundleValidator.validate(
      value,
    );
    if (value is! Map) {
      return PerformanceDiagnosticsSupportBundlePreview(validation: validation);
    }

    final exportSummary = _mapValue(value['exportSummary']);
    final compactSnapshot = _mapValue(value['compactSnapshot']);
    final latest = _mapValue(compactSnapshot?['latest']);
    final runtime = _mapValue(compactSnapshot?['runtime']);

    return PerformanceDiagnosticsSupportBundlePreview(
      bundleVersion: _intValue(value['bundleVersion']),
      kind: _stringValue(value['kind']),
      maxHistoryEntries: _intValue(value['maxHistoryEntries']),
      bundleFingerprint: _stringValue(value['fingerprint']),
      compactFingerprint: _stringValue(compactSnapshot?['fingerprint']),
      exportSeverity: _stringValue(exportSummary?['severity']),
      exportRecommendation: _stringValue(exportSummary?['recommendation']),
      exportRecommendationHint: _stringValue(
        exportSummary?['recommendationHint'],
      ),
      diagnosticOutputPoints: _intValue(
        compactSnapshot?['diagnosticOutputPoints'],
      ),
      historyRunCount: _intValue(compactSnapshot?['historyRunCount']),
      includedHistoryRunCount: _intValue(
        compactSnapshot?['includedHistoryRunCount'],
      ),
      hasRuntimeDiagnostics: _boolValue(
        compactSnapshot?['hasRuntimeDiagnostics'],
      ),
      sourceDataPointCount: _intValue(
        runtime?['sourceDataPointCount'] ?? latest?['dataPointCount'],
      ),
      renderedDataPointCount: _intValue(
        runtime?['renderedDataPointCount'] ?? latest?['outputPointCount'],
      ),
      validation: validation,
    );
  }

  Map<String, dynamic> toJson() => {
    'summary': summary,
    'valid': isValid,
    'validation': validation.toJson(),
    if (bundleVersion != null) 'bundleVersion': bundleVersion,
    if (kind != null) 'kind': kind,
    if (maxHistoryEntries != null) 'maxHistoryEntries': maxHistoryEntries,
    if (bundleFingerprint != null) 'bundleFingerprint': bundleFingerprint,
    if (compactFingerprint != null) 'compactFingerprint': compactFingerprint,
    if (exportSeverity != null) 'exportSeverity': exportSeverity,
    if (exportRecommendation != null)
      'exportRecommendation': exportRecommendation,
    if (exportRecommendationHint != null)
      'exportRecommendationHint': exportRecommendationHint,
    if (diagnosticOutputPoints != null)
      'diagnosticOutputPoints': diagnosticOutputPoints,
    if (historyRunCount != null) 'historyRunCount': historyRunCount,
    if (includedHistoryRunCount != null)
      'includedHistoryRunCount': includedHistoryRunCount,
    if (hasRuntimeDiagnostics != null)
      'hasRuntimeDiagnostics': hasRuntimeDiagnostics,
    if (sourceDataPointCount != null)
      'sourceDataPointCount': sourceDataPointCount,
    if (renderedDataPointCount != null)
      'renderedDataPointCount': renderedDataPointCount,
  };

  static Map? _mapValue(Object? value) => value is Map ? value : null;

  static int? _intValue(Object? value) => value is int ? value : null;

  static String? _stringValue(Object? value) => value is String ? value : null;

  static bool? _boolValue(Object? value) => value is bool ? value : null;
}

abstract final class PerformanceDiagnosticsSupportBundleValidator {
  static final RegExp _fingerprintPattern = RegExp(r'^[0-9a-f]{8}$');

  static PerformanceDiagnosticsSupportBundleValidationResult validateJsonString(
    String source,
  ) {
    try {
      return validate(jsonDecode(source));
    } catch (error) {
      return PerformanceDiagnosticsSupportBundleValidationResult(
        errors: ['Support bundle JSON could not be decoded: $error'],
      );
    }
  }

  static PerformanceDiagnosticsSupportBundleValidationResult validate(
    Object? value,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    if (value is! Map) {
      return PerformanceDiagnosticsSupportBundleValidationResult(
        errors: const ['Support bundle must be a JSON object.'],
      );
    }

    final bundleVersion = value['bundleVersion'];
    if (bundleVersion != PerformanceDiagnosticsSnapshot.supportBundleVersion) {
      errors.add(
        'bundleVersion must be ${PerformanceDiagnosticsSnapshot.supportBundleVersion}.',
      );
    }

    final kind = value['kind'];
    if (kind != PerformanceDiagnosticsSnapshot.supportBundleKind) {
      errors.add(
        'kind must be ${PerformanceDiagnosticsSnapshot.supportBundleKind}.',
      );
    }

    final maxHistoryEntries = value['maxHistoryEntries'];
    if (maxHistoryEntries is! int || maxHistoryEntries < 0) {
      errors.add('maxHistoryEntries must be a non-negative integer.');
    }

    final exportSummary = value['exportSummary'];
    final compactSnapshot = value['compactSnapshot'];
    if (exportSummary is! Map) {
      errors.add('exportSummary must be a JSON object.');
    }
    if (compactSnapshot is! Map) {
      errors.add('compactSnapshot must be a JSON object.');
    }

    _validateFingerprint(
      label: 'support bundle',
      fingerprint: value['fingerprint'],
      expectedFingerprint: PerformanceDiagnosticsSnapshot._fingerprint(
        _supportBundlePayloadFromMap(value),
      ),
      errors: errors,
    );

    if (compactSnapshot is Map) {
      _validateCompactSnapshot(compactSnapshot, errors, warnings);
    }
    if (exportSummary is Map && compactSnapshot is Map) {
      _validateExportSummary(exportSummary, compactSnapshot, errors, warnings);
    }
    if (maxHistoryEntries is int &&
        maxHistoryEntries >= 0 &&
        compactSnapshot is Map) {
      final includedHistoryRunCount =
          compactSnapshot['includedHistoryRunCount'];
      if (includedHistoryRunCount is int &&
          includedHistoryRunCount > maxHistoryEntries) {
        errors.add('includedHistoryRunCount exceeds maxHistoryEntries.');
      }
    }

    return PerformanceDiagnosticsSupportBundleValidationResult(
      errors: errors,
      warnings: warnings,
    );
  }

  static void _validateCompactSnapshot(
    Map compactSnapshot,
    List<String> errors,
    List<String> warnings,
  ) {
    if (compactSnapshot['snapshotVersion'] != 1) {
      errors.add('compactSnapshot.snapshotVersion must be 1.');
    }
    if (compactSnapshot['exportMode'] != 'compact') {
      errors.add('compactSnapshot.exportMode must be compact.');
    }
    if (compactSnapshot['latest'] is! Map) {
      errors.add('compactSnapshot.latest must be a JSON object.');
    }
    if (compactSnapshot['cache'] is! Map) {
      warnings.add('compactSnapshot.cache is missing or invalid.');
    }
    if (compactSnapshot['history'] is! List) {
      warnings.add('compactSnapshot.history is missing or invalid.');
    }

    _validateFingerprint(
      label: 'compact snapshot',
      fingerprint: compactSnapshot['fingerprint'],
      expectedFingerprint: PerformanceDiagnosticsSnapshot._fingerprint(
        _compactSnapshotPayloadFromMap(compactSnapshot),
      ),
      errors: errors,
    );
  }

  static void _validateExportSummary(
    Map exportSummary,
    Map compactSnapshot,
    List<String> errors,
    List<String> warnings,
  ) {
    final summaryFingerprint = exportSummary['compactFingerprint'];
    final compactFingerprint = compactSnapshot['fingerprint'];
    if (summaryFingerprint != compactFingerprint) {
      errors.add(
        'exportSummary.compactFingerprint does not match compactSnapshot.fingerprint.',
      );
    }

    if (exportSummary['historyRunCount'] !=
        compactSnapshot['historyRunCount']) {
      warnings.add(
        'exportSummary.historyRunCount does not match compactSnapshot.historyRunCount.',
      );
    }
    if (exportSummary['hasRuntimeDiagnostics'] !=
        compactSnapshot['hasRuntimeDiagnostics']) {
      warnings.add(
        'exportSummary.hasRuntimeDiagnostics does not match compactSnapshot.hasRuntimeDiagnostics.',
      );
    }
    if (exportSummary['severity'] is! String) {
      warnings.add('exportSummary.severity is missing or invalid.');
    }
    if (exportSummary['recommendation'] is! String) {
      warnings.add('exportSummary.recommendation is missing or invalid.');
    }
  }

  static void _validateFingerprint({
    required String label,
    required Object? fingerprint,
    required String expectedFingerprint,
    required List<String> errors,
  }) {
    if (fingerprint is! String || !_fingerprintPattern.hasMatch(fingerprint)) {
      errors.add('$label fingerprint must be an 8-character hex string.');
      return;
    }
    if (fingerprint != expectedFingerprint) {
      errors.add('$label fingerprint mismatch.');
    }
  }

  static Map<String, dynamic> _supportBundlePayloadFromMap(Map bundle) => {
    'bundleVersion': bundle['bundleVersion'],
    'kind': bundle['kind'],
    'maxHistoryEntries': bundle['maxHistoryEntries'],
    'exportSummary': bundle['exportSummary'],
    'compactSnapshot': bundle['compactSnapshot'],
  };

  static Map<String, dynamic> _compactSnapshotPayloadFromMap(Map snapshot) => {
    'snapshotVersion': snapshot['snapshotVersion'],
    'exportMode': snapshot['exportMode'],
    'diagnosticOutputPoints': snapshot['diagnosticOutputPoints'],
    'hasFirstReport': snapshot['hasFirstReport'],
    'hasRuntimeDiagnostics': snapshot['hasRuntimeDiagnostics'],
    if (snapshot.containsKey('first')) 'first': snapshot['first'],
    'latest': snapshot['latest'],
    if (snapshot.containsKey('runtime')) 'runtime': snapshot['runtime'],
    'cache': snapshot['cache'],
    'historyRunCount': snapshot['historyRunCount'],
    'includedHistoryRunCount': snapshot['includedHistoryRunCount'],
    'history': snapshot['history'],
    if (snapshot.containsKey('trend')) 'trend': snapshot['trend'],
    if (snapshot.containsKey('aggregate')) 'aggregate': snapshot['aggregate'],
  };
}

class PerformanceDiagnosticsSnapshot {
  static const int supportBundleVersion = 1;
  static const String supportBundleKind =
      'tenunPerformanceDiagnosticsSupportBundle';
  static const int defaultCompactHistoryEntries = 3;
  static const int exportHistoryConfidenceRunCount = 3;
  static const int compactExportWarningBytes = 64 * 1024;
  static const int fullExportWarningBytes = 256 * 1024;
  static const double compactReductionUsefulRatio = 0.25;

  final AsyncChartProcessingReport? firstReport;
  final AsyncChartProcessingReport lastReport;
  final ChartRuntimeDiagnostics? widgetRuntime;
  final ChartDataProcessingCacheStats cacheStats;
  final int diagnosticOutputPoints;
  final List<PerformanceDiagnosticsHistoryEntry> history;
  final PerformanceDiagnosticsHistorySummary? trend;
  final PerformanceDiagnosticsHistoryAggregate? aggregate;

  PerformanceDiagnosticsSnapshot({
    required this.firstReport,
    required this.lastReport,
    required this.widgetRuntime,
    required this.cacheStats,
    required this.diagnosticOutputPoints,
    required List<PerformanceDiagnosticsHistoryEntry> history,
  }) : history = List.unmodifiable(history),
       trend = PerformanceDiagnosticsHistorySummary.tryFromEntries(history),
       aggregate = PerformanceDiagnosticsHistoryAggregate.tryFromEntries(
         history,
       );

  static PerformanceDiagnosticsSnapshot? tryCreate({
    required AsyncChartProcessingReport? firstReport,
    required AsyncChartProcessingReport? lastReport,
    required ChartRuntimeDiagnostics? widgetRuntime,
    required ChartDataProcessingCacheStats cacheStats,
    required int diagnosticOutputPoints,
    required List<PerformanceDiagnosticsHistoryEntry> history,
  }) {
    if (lastReport == null) return null;
    return PerformanceDiagnosticsSnapshot(
      firstReport: firstReport,
      lastReport: lastReport,
      widgetRuntime: widgetRuntime,
      cacheStats: cacheStats,
      diagnosticOutputPoints: diagnosticOutputPoints,
      history: history,
    );
  }

  bool get hasFirstReport => firstReport != null;

  bool get hasRuntimeDiagnostics => widgetRuntime != null;

  int get historyRunCount => history.length;

  List<String> get topLevelKeys => List.unmodifiable(toJson().keys);

  int get fullExportBytes => _utf8Bytes(toPrettyJson());

  int compactExportBytes({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    return _utf8Bytes(
      toPrettyCompactJson(maxHistoryEntries: maxHistoryEntries),
    );
  }

  int supportBundleBytes({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    return _utf8Bytes(
      toPrettySupportBundleJson(maxHistoryEntries: maxHistoryEntries),
    );
  }

  double compactReductionRatio({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    final fullBytes = fullExportBytes;
    final compactBytes = compactExportBytes(
      maxHistoryEntries: maxHistoryEntries,
    );
    return _compactReductionFromBytes(fullBytes, compactBytes);
  }

  String compactFingerprint({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    return _fingerprint(
      _compactJsonPayload(maxHistoryEntries: maxHistoryEntries),
    );
  }

  String supportBundleFingerprint({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    return _fingerprint(
      _supportBundlePayload(maxHistoryEntries: maxHistoryEntries),
    );
  }

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String toPrettyCompactJson({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    return const JsonEncoder.withIndent(
      '  ',
    ).convert(toCompactJson(maxHistoryEntries: maxHistoryEntries));
  }

  String toPrettySupportBundleJson({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    return const JsonEncoder.withIndent(
      '  ',
    ).convert(toSupportBundleJson(maxHistoryEntries: maxHistoryEntries));
  }

  PerformanceDiagnosticsExportRecommendation exportRecommendation({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    final fullBytes = fullExportBytes;
    final compactBytes = compactExportBytes(
      maxHistoryEntries: maxHistoryEntries,
    );
    final compactReduction = _compactReductionFromBytes(
      fullBytes,
      compactBytes,
    );
    return _exportRecommendationFromMetrics(
      fullBytes: fullBytes,
      compactBytes: compactBytes,
      compactReduction: compactReduction,
    );
  }

  PerformanceDiagnosticsExportSeverity exportSeverity({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    return _exportSeverityFor(
      exportRecommendation(maxHistoryEntries: maxHistoryEntries),
    );
  }

  String exportRecommendationHint({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    return _exportRecommendationHintFor(
      exportRecommendation(maxHistoryEntries: maxHistoryEntries),
    );
  }

  Map<String, dynamic> exportSummaryJson({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    final fullBytes = fullExportBytes;
    final compactBytes = compactExportBytes(
      maxHistoryEntries: maxHistoryEntries,
    );
    final compactReduction = _compactReductionFromBytes(
      fullBytes,
      compactBytes,
    );
    final recommendation = _exportRecommendationFromMetrics(
      fullBytes: fullBytes,
      compactBytes: compactBytes,
      compactReduction: compactReduction,
    );
    final severity = _exportSeverityFor(recommendation);

    return {
      'severity': severity.name,
      'recommendation': recommendation.name,
      'recommendationHint': _exportRecommendationHintFor(recommendation),
      'fullExportBytes': fullBytes,
      'compactExportBytes': compactBytes,
      'compactReductionRatio': compactReduction,
      'compactFingerprint': compactFingerprint(
        maxHistoryEntries: maxHistoryEntries,
      ),
      'historyRunCount': historyRunCount,
      'historyConfidenceRunCount': exportHistoryConfidenceRunCount,
      'hasRuntimeDiagnostics': hasRuntimeDiagnostics,
    };
  }

  Map<String, dynamic> toCompactJson({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    final payload = _compactJsonPayload(maxHistoryEntries: maxHistoryEntries);
    return {...payload, 'fingerprint': _fingerprint(payload)};
  }

  Map<String, dynamic> toSupportBundleJson({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    final payload = _supportBundlePayload(maxHistoryEntries: maxHistoryEntries);
    return {...payload, 'fingerprint': _fingerprint(payload)};
  }

  PerformanceDiagnosticsSupportBundleValidationResult validateSupportBundle({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    return PerformanceDiagnosticsSupportBundleValidator.validate(
      toSupportBundleJson(maxHistoryEntries: maxHistoryEntries),
    );
  }

  PerformanceDiagnosticsSupportBundlePreview supportBundlePreview({
    int maxHistoryEntries = defaultCompactHistoryEntries,
  }) {
    return PerformanceDiagnosticsSupportBundlePreview.fromJson(
      toSupportBundleJson(maxHistoryEntries: maxHistoryEntries),
    );
  }

  Map<String, dynamic> _supportBundlePayload({required int maxHistoryEntries}) {
    final historyLimit = maxHistoryEntries < 0 ? 0 : maxHistoryEntries;
    return {
      'bundleVersion': supportBundleVersion,
      'kind': supportBundleKind,
      'maxHistoryEntries': historyLimit,
      'exportSummary': exportSummaryJson(maxHistoryEntries: historyLimit),
      'compactSnapshot': toCompactJson(maxHistoryEntries: historyLimit),
    };
  }

  Map<String, dynamic> _compactJsonPayload({required int maxHistoryEntries}) {
    final historyLimit = maxHistoryEntries < 0 ? 0 : maxHistoryEntries;
    final includedHistory = history.take(historyLimit).toList();

    return {
      'snapshotVersion': 1,
      'exportMode': 'compact',
      'diagnosticOutputPoints': diagnosticOutputPoints,
      'hasFirstReport': hasFirstReport,
      'hasRuntimeDiagnostics': hasRuntimeDiagnostics,
      if (firstReport != null) 'first': _compactReport(firstReport!),
      'latest': _compactReport(lastReport),
      if (widgetRuntime != null) 'runtime': _compactRuntime(widgetRuntime!),
      'cache': _compactCache(cacheStats),
      'historyRunCount': historyRunCount,
      'includedHistoryRunCount': includedHistory.length,
      'history': [for (final entry in includedHistory) entry.toJson()],
      if (trend != null) 'trend': trend!.toJson(),
      if (aggregate != null) 'aggregate': aggregate!.toJson(),
    };
  }

  Map<String, dynamic> toJson() => {
    'snapshotVersion': 1,
    'diagnosticOutputPoints': diagnosticOutputPoints,
    'hasFirstReport': hasFirstReport,
    'hasRuntimeDiagnostics': hasRuntimeDiagnostics,
    if (firstReport != null) 'firstReport': firstReport!.toJson(),
    'lastReport': lastReport.toJson(),
    if (widgetRuntime != null) 'widgetRuntime': widgetRuntime!.toJson(),
    'cacheStats': cacheStats.toJson(),
    'historyRunCount': historyRunCount,
    'history': [for (final entry in history) entry.toJson()],
    if (trend != null) 'trend': trend!.toJson(),
    if (aggregate != null) 'aggregate': aggregate!.toJson(),
  };

  Map<String, dynamic> _compactReport(AsyncChartProcessingReport report) => {
    'usedIsolate': report.usedIsolate,
    'isolateEligible': report.isolateEligible,
    'isolatePointThreshold': report.isolatePointThreshold,
    'dataPointCount': report.dataPointCount,
    'effectiveDataPointCount': report.effectiveDataPointCount,
    'sampleInputPointCount': report.sampleInputPointCount,
    'outputPointCount': report.outputPointCount,
    'wasDownsampled': report.wasDownsampled,
    'reducedPointCount': report.reducedPointCount,
    'samplingOutputRatio': report.samplingOutputRatio,
    'samplingReductionRatio': report.samplingReductionRatio,
    'cacheHit': report.cacheHit,
    'path': report.processingReport.path.name,
    'samplingStrategy':
        report.processingReport.samplingStrategy?.name ?? 'auto',
    'resolvedSamplingStrategy':
        report.processingReport.resolvedSamplingStrategy.name,
    'renderThreshold': report.processingReport.renderThreshold,
    'totalDurationMicros': report.totalDuration.inMicroseconds,
    'processingDurationMicros':
        report.processingReport.totalDuration.inMicroseconds,
  };

  Map<String, dynamic> _compactRuntime(ChartRuntimeDiagnostics runtime) => {
    'sourceDataPointCount': runtime.sourceDataPointCount,
    if (runtime.effectiveDataPointCount != null)
      'effectiveDataPointCount': runtime.effectiveDataPointCount,
    if (runtime.sampleInputPointCount != null)
      'sampleInputPointCount': runtime.sampleInputPointCount,
    'renderedDataPointCount': runtime.renderedDataPointCount,
    'configSampledData': runtime.configSampledData,
    'payloadChanged': runtime.payloadChanged,
    'severity': runtime.performanceSummary.severity.name,
    'recommendation': runtime.performanceSummary.recommendation.name,
    'recommendationHint': runtime.performanceSummary.recommendationHint,
    'renderedOutputRatio': runtime.performanceSummary.renderedOutputRatio,
    'renderedReductionRatio': runtime.performanceSummary.renderedReductionRatio,
    if (runtime.performanceSummary.samplingOutputRatio != null)
      'samplingOutputRatio': runtime.performanceSummary.samplingOutputRatio,
    if (runtime.performanceSummary.samplingReductionRatio != null)
      'samplingReductionRatio':
          runtime.performanceSummary.samplingReductionRatio,
    'totalBuildDurationMicros': runtime.totalBuildDuration.inMicroseconds,
  };

  Map<String, dynamic> _compactCache(ChartDataProcessingCacheStats stats) => {
    'enabled': stats.enabled,
    'size': stats.size,
    'maxEntries': stats.maxEntries,
    'currentBytes': stats.currentBytes,
    'maxBytes': stats.maxBytes,
    'lookups': stats.lookups,
    'hits': stats.hits,
    'misses': stats.misses,
    'hitRate': stats.hitRate,
    'extraction': {
      'enabled': stats.extractionCacheEnabled,
      'size': stats.extractionSize,
      'maxEntries': stats.maxExtractionEntries,
      'currentBytes': stats.extractionCurrentBytes,
      'maxBytes': stats.maxExtractionBytes,
      'lookups': stats.extractionLookups,
      'hits': stats.extractionHits,
      'misses': stats.extractionMisses,
      'hitRate': stats.extractionHitRate,
    },
  };

  static int _utf8Bytes(String value) => utf8.encode(value).length;

  double _compactReductionFromBytes(int fullBytes, int compactBytes) {
    if (fullBytes <= 0) return 0;
    return (1 - compactBytes / fullBytes).clamp(0.0, 1.0).toDouble();
  }

  PerformanceDiagnosticsExportRecommendation _exportRecommendationFromMetrics({
    required int fullBytes,
    required int compactBytes,
    required double compactReduction,
  }) {
    if (!hasRuntimeDiagnostics) {
      return PerformanceDiagnosticsExportRecommendation
          .collectRuntimeDiagnostics;
    }
    if (historyRunCount < exportHistoryConfidenceRunCount) {
      return PerformanceDiagnosticsExportRecommendation.collectMoreHistory;
    }
    if (compactBytes >= compactExportWarningBytes) {
      return PerformanceDiagnosticsExportRecommendation
          .reviewLargeCompactExport;
    }
    if (fullBytes >= fullExportWarningBytes ||
        compactReduction >= compactReductionUsefulRatio) {
      return PerformanceDiagnosticsExportRecommendation.useCompactExport;
    }
    return PerformanceDiagnosticsExportRecommendation.ready;
  }

  static PerformanceDiagnosticsExportSeverity _exportSeverityFor(
    PerformanceDiagnosticsExportRecommendation recommendation,
  ) {
    return switch (recommendation) {
      PerformanceDiagnosticsExportRecommendation.ready =>
        PerformanceDiagnosticsExportSeverity.healthy,
      PerformanceDiagnosticsExportRecommendation.collectRuntimeDiagnostics ||
      PerformanceDiagnosticsExportRecommendation.collectMoreHistory ||
      PerformanceDiagnosticsExportRecommendation.useCompactExport =>
        PerformanceDiagnosticsExportSeverity.info,
      PerformanceDiagnosticsExportRecommendation.reviewLargeCompactExport =>
        PerformanceDiagnosticsExportSeverity.warning,
    };
  }

  String _exportRecommendationHintFor(
    PerformanceDiagnosticsExportRecommendation recommendation,
  ) {
    return switch (recommendation) {
      PerformanceDiagnosticsExportRecommendation.ready =>
        'Snapshot is ready for a bug report.',
      PerformanceDiagnosticsExportRecommendation.collectRuntimeDiagnostics =>
        'Collect widget runtime diagnostics before sharing the snapshot.',
      PerformanceDiagnosticsExportRecommendation.collectMoreHistory =>
        'Collect at least $exportHistoryConfidenceRunCount runs for a steadier trend.',
      PerformanceDiagnosticsExportRecommendation.useCompactExport =>
        'Prefer compact JSON; it keeps the latest/runtime summary smaller.',
      PerformanceDiagnosticsExportRecommendation.reviewLargeCompactExport =>
        'Compact JSON is still large; reduce history or attach compact only.',
    };
  }

  static String _fingerprint(Object? value) {
    final json = const JsonEncoder().convert(value);
    var hash = 0x811c9dc5;
    for (final codeUnit in json.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}

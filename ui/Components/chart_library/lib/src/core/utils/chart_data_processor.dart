/// Pre-processes chart series data once so painters receive ready-to-use stats.
///
/// Design goals:
/// - Compute **once** at config construction, not during paint().
/// - Support large datasets via [DataSampler] / [DoubleListSampler] integration.
/// - Avoid heap waste: uses [DoubleListSampler] directly on [List<double>]
///   so data is never re-boxed back into dynamic for sampling.
/// - Provide typed results for every common chart calculation.
/// - Async entry-point [processAsync] offloads heavy work to an isolate.
library chart_data_processor;

import 'dart:math' as math;

import '../config/series.dart';
import 'data_sampler.dart';

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

/// Pre-computed statistics for a single numeric series.
class SeriesStats {
  final double min;
  final double max;
  final double sum;
  final double avg;
  final int count;

  /// Cleaned values — no NaN / null. This is the **full** list (pre-sampling)
  /// so statistical helpers (percentiles etc.) have complete data.
  final List<double> values;

  const SeriesStats({
    required this.min,
    required this.max,
    required this.sum,
    required this.avg,
    required this.count,
    required this.values,
  });

  static const SeriesStats empty = SeriesStats(
    min: 0,
    max: 0,
    sum: 0,
    avg: 0,
    count: 0,
    values: [],
  );

  // ---------- Statistical helpers ----------

  /// Value at [p]-th percentile (0–100). Uses linear interpolation.
  double percentile(double p) {
    if (values.isEmpty) return 0;
    if (values.length == 1) return values.first;
    final sorted = [...values]..sort();
    final pos = (p / 100) * (sorted.length - 1);
    final lo = pos.floor();
    final hi = pos.ceil();
    if (lo == hi) return sorted[lo];
    return sorted[lo] + (sorted[hi] - sorted[lo]) * (pos - lo);
  }

  double get q1 => percentile(25);
  double get median => percentile(50);
  double get q3 => percentile(75);
  double get iqr => q3 - q1;

  /// Standard deviation (population).
  double get stdDev {
    if (values.length < 2) return 0;
    double variance = 0;
    for (final v in values) {
      final diff = v - avg;
      variance += diff * diff;
    }
    return math.sqrt(variance / values.length);
  }
}

/// Pre-computed stats across all series in a chart.
class ChartStats {
  final double globalMin;
  final double globalMax;
  final double globalSum;
  final List<SeriesStats> perSeries;

  const ChartStats({
    required this.globalMin,
    required this.globalMax,
    required this.globalSum,
    required this.perSeries,
  });

  static const ChartStats empty = ChartStats(
    globalMin: 0,
    globalMax: 100,
    globalSum: 0,
    perSeries: [],
  );
}

/// Sampled version of a series ready for rendering.
class ProcessedSeries {
  /// Original series metadata.
  final Series series;

  /// Sampled (or full) data points — x = implicit index.
  final List<DataPoint> points;

  /// Sampled raw doubles — avoids re-extraction from points.
  final List<double> sampledValues;

  /// Pre-computed stats (on full dataset, before sampling).
  final SeriesStats stats;

  /// Whether this series was downsampled.
  bool get wasDownsampled => sampledValues.length < stats.count;

  const ProcessedSeries({
    required this.series,
    required this.points,
    required this.sampledValues,
    required this.stats,
  });
}

// ---------------------------------------------------------------------------
// ChartDataProcessor
// ---------------------------------------------------------------------------

class ChartDataProcessor {
  /// Default render threshold — above this the dataset is sampled.
  static const int defaultRenderThreshold = 500;

  // ---------------------------------------------------------------------------
  // Main synchronous entry-point
  // ---------------------------------------------------------------------------

  /// Process all series in a chart, returning [ChartStats] and per-series
  /// [ProcessedSeries] list.
  ///
  /// **Performance fix**: previously this called `_extractDoubles` then
  /// `DataSampler.fromRaw(raw.cast<dynamic>())` which re-boxed the already
  /// extracted doubles back to `dynamic`. Now we use [DoubleListSampler]
  /// directly on `List<double>` and only build [DataPoint] objects once,
  /// for the sampled subset.
  ///
  /// [renderThreshold]: max points to send to the painter per series.
  static ({ChartStats stats, List<ProcessedSeries> processed}) process(
    List<Series> series, {
    int renderThreshold = defaultRenderThreshold,
    SamplingStrategy? samplingStrategy,
    // Optional viewport culling — only process indices in [startIndex..endIndex].
    int? startIndex,
    int? endIndex,
  }) {
    if (series.isEmpty) {
      return (stats: ChartStats.empty, processed: const []);
    }

    final List<ProcessedSeries> processed = [];
    double globalMin = double.infinity;
    double globalMax = double.negativeInfinity;
    double globalSum = 0;

    for (final s in series) {
      // 1. Extract clean doubles once — O(n).
      final raw = _extractDoubles(s.data ?? const []);

      // 2. Optionally cull to visible viewport window.
      final List<double> windowed = _applyWindow(raw, startIndex, endIndex);

      // 3. Compute stats on the full (windowed) data — O(n).
      final stats = _computeStats(windowed);

      if (stats.min < globalMin) globalMin = stats.min;
      if (stats.max > globalMax) globalMax = stats.max;
      globalSum += stats.sum;

      // 4. Sample directly on List<double> — no re-boxing.
      final List<double> sampled = DoubleListSampler.auto(
        windowed,
        renderThreshold,
        forceStrategy: samplingStrategy,
      );

      // 5. Build DataPoints only for the sampled subset — much smaller.
      final points = DataSampler.fromDoubles(sampled);

      processed.add(ProcessedSeries(
        series: s,
        points: points,
        sampledValues: sampled,
        stats: stats,
      ));
    }

    final chartStats = ChartStats(
      globalMin: globalMin.isFinite ? globalMin : 0,
      globalMax: globalMax.isFinite ? globalMax : 100,
      globalSum: globalSum,
      perSeries: processed.map((p) => p.stats).toList(),
    );

    return (stats: chartStats, processed: processed);
  }

  // ---------------------------------------------------------------------------
  // Stacked series helpers
  // ---------------------------------------------------------------------------

  /// Compute cumulative (stacked) values per category index.
  ///
  /// Returns `result[seriesIdx][dataIdx]` = stacked value.
  static List<List<double>> computeStackedValues(List<Series> series) {
    if (series.isEmpty) return const [];

    int len = 0;
    for (final s in series) {
      final l = s.data?.length ?? 0;
      if (l > len) len = l;
    }

    final List<double> posAccum = List.filled(len, 0.0);
    final List<double> negAccum = List.filled(len, 0.0);
    final List<List<double>> result = [];

    for (final s in series) {
      final data = s.data;
      final row = List<double>.filled(len, 0.0);
      for (int i = 0; i < len; i++) {
        final v = _toDouble(data != null && i < data.length ? data[i] : null) ?? 0;
        if (v >= 0) {
          row[i] = posAccum[i] + v;
          posAccum[i] += v;
        } else {
          row[i] = negAccum[i] + v;
          negAccum[i] += v;
        }
      }
      result.add(row);
    }
    return result;
  }

  /// Max stacked value across all categories.
  static double maxStackedValue(List<Series> series) {
    if (series.isEmpty) return 100;
    final stacked = computeStackedValues(series);
    double max = double.negativeInfinity;
    for (final row in stacked) {
      for (final v in row) {
        if (v > max) max = v;
      }
    }
    return max.isFinite ? max : 100;
  }

  // ---------------------------------------------------------------------------
  // Normalisation helpers
  // ---------------------------------------------------------------------------

  /// Map [value] from [srcMin..srcMax] to [dstMin..dstMax].
  static double normalize(
    double value,
    double srcMin,
    double srcMax,
    double dstMin,
    double dstMax,
  ) {
    if (srcMax == srcMin) return dstMin;
    return dstMin + (value - srcMin) / (srcMax - srcMin) * (dstMax - dstMin);
  }

  /// Generate evenly-spaced Y-axis ticks for a [min..max] range.
  ///
  /// Returns exactly [tickCount] values including min and max, rounded to
  /// a "nice" step using `log10`-based magnitude (no string tricks).
  static List<double> niceYTicks(double min, double max, {int tickCount = 5}) {
    if (min == max) return List.filled(tickCount, min);
    final step = _niceStep((max - min) / (tickCount - 1));
    final niceMin = (min / step).floor() * step;
    return List.generate(tickCount, (i) => niceMin + i * step);
  }

  /// Compute a "nice" round step value for axis ticks.
  ///
  /// FIX: replaced the original broken string-length magnitude heuristic
  /// with a proper log10 calculation from `dart:math`.
  static double _niceStep(double roughStep) {
    if (roughStep <= 0) return 1;
    final double mag = math.pow(10, (math.log(roughStep) / math.ln10).floor()).toDouble();
    final double norm = roughStep / mag;
    final double nice;
    if (norm <= 1.0) {
      nice = 1;
    } else if (norm <= 2.0) {
      nice = 2;
    } else if (norm <= 5.0) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * mag;
  }

  // ---------------------------------------------------------------------------
  // Percentile helpers (for box-plot, violin, etc.)
  // ---------------------------------------------------------------------------

  /// Compute standard five-number summary for [values].
  static ({double min, double q1, double median, double q3, double max})
      fiveNumberSummary(List<double> values) {
    if (values.isEmpty) return (min: 0, q1: 0, median: 0, q3: 0, max: 0);
    final sorted = [...values]..sort();
    return (
      min: sorted.first,
      q1: _percentileFromSorted(sorted, 25),
      median: _percentileFromSorted(sorted, 50),
      q3: _percentileFromSorted(sorted, 75),
      max: sorted.last,
    );
  }

  static double _percentileFromSorted(List<double> sorted, double p) {
    if (sorted.length == 1) return sorted.first;
    final pos = (p / 100) * (sorted.length - 1);
    final lo = pos.floor();
    final hi = pos.ceil();
    if (lo == hi) return sorted[lo];
    return sorted[lo] + (sorted[hi] - sorted[lo]) * (pos - lo);
  }

  // ---------------------------------------------------------------------------
  // Histogram binning
  // ---------------------------------------------------------------------------

  /// Compute histogram bins for [values] into [binCount] equal-width buckets.
  ///
  /// Returns list of (binStart, binEnd, count) records.
  static List<({double start, double end, int count})> histogram(
    List<double> values, {
    int binCount = 10,
    double? forcedMin,
    double? forcedMax,
  }) {
    if (values.isEmpty) return const [];
    double min = forcedMin ?? values.reduce((a, b) => a < b ? a : b);
    double max = forcedMax ?? values.reduce((a, b) => a > b ? a : b);
    if (min == max) {
      max = min + 1;
    }
    final double width = (max - min) / binCount;
    final counts = List<int>.filled(binCount, 0);
    for (final v in values) {
      int bin = ((v - min) / width).floor();
      if (bin >= binCount) bin = binCount - 1;
      if (bin < 0) bin = 0;
      counts[bin]++;
    }
    return List.generate(binCount, (i) => (
      start: min + i * width,
      end: min + (i + 1) * width,
      count: counts[i],
    ));
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  static List<double> _applyWindow(
      List<double> data, int? startIndex, int? endIndex) {
    if (startIndex == null && endIndex == null) return data;
    final start = (startIndex ?? 0).clamp(0, data.length);
    final end = (endIndex ?? data.length).clamp(start, data.length);
    return data.sublist(start, end);
  }

  static SeriesStats _computeStats(List<double> values) {
    if (values.isEmpty) return SeriesStats.empty;
    double min = values.first, max = values.first, sum = 0;
    for (final v in values) {
      if (v < min) min = v;
      if (v > max) max = v;
      sum += v;
    }
    return SeriesStats(
      min: min,
      max: max,
      sum: sum,
      avg: sum / values.length,
      count: values.length,
      values: values,
    );
  }

  static List<double> _extractDoubles(List<dynamic> raw) {
    final List<double> result = List.filled(raw.length, 0.0, growable: false);
    int writeIdx = 0;
    for (final item in raw) {
      final v = _toDouble(item);
      if (v != null) result[writeIdx++] = v;
    }
    return writeIdx == raw.length ? result : result.sublist(0, writeIdx);
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is Map) {
      final v = value['value'];
      if (v is num) return v.toDouble();
    }
    return null;
  }
}

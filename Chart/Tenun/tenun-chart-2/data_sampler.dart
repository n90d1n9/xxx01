/// Efficient data sampling utilities for large datasets.
///
/// Provides:
///  - [LTTBSampler]       — Largest-Triangle-Three-Buckets (visually-accurate)
///  - [MinMaxSampler]     — Keeps local min/max per bucket (good for candlestick / precise peaks)
///  - [NthPointSampler]   — Fast uniform decimation for non-critical views
///  - [DoubleListSampler] — Operates directly on List<double> — avoids DataPoint allocation
///
/// All samplers work on [List<DataPoint>] or raw [List<double>].
library chart_data_sampler;

// ---------------------------------------------------------------------------
// DataPoint — 2D data point used across all samplers
// ---------------------------------------------------------------------------

/// A 2-D data point used across all samplers.
class DataPoint {
  final double x;
  final double y;
  const DataPoint(this.x, this.y);

  @override
  String toString() => 'DataPoint($x, $y)';
}

// ---------------------------------------------------------------------------
// LTTB — Largest-Triangle-Three-Buckets
// Reference: Sveinn Steinarsson (2013) https://skemman.is/handle/1946/15343
//
// BUG FIX (v2): The original nextRangeStart was incorrectly set to rangeStart
// (same bucket). It must point to the START of the NEXT bucket so the
// reference point (avgX/avgY) is computed from the correct future window.
// ---------------------------------------------------------------------------

class LTTBSampler {
  /// Down-sample [data] to at most [threshold] points using the LTTB algorithm.
  ///
  /// Returns the original list when `data.length <= threshold`.
  static List<DataPoint> sample(List<DataPoint> data, int threshold) {
    final int length = data.length;
    if (threshold >= length || threshold <= 2) {
      return threshold <= 2 ? _edgePoints(data) : List<DataPoint>.from(data);
    }

    final List<DataPoint> sampled = List.filled(threshold, data.first);
    // Always include the first point.
    sampled[0] = data.first;

    final double bucketSize = (length - 2) / (threshold - 2);
    int a = 0; // Previously selected point index.

    for (int i = 0; i < threshold - 2; i++) {
      // Current bucket range.
      final int rangeStart = ((i + 1) * bucketSize + 1).floor();
      final int rangeEnd =
          (((i + 2) * bucketSize + 1).floor()).clamp(0, length - 1);

      // FIXED: next bucket starts at rangeEnd+1 (not rangeStart).
      final int nextRangeStart = rangeEnd;
      final int nextRangeEnd =
          (((i + 3) * bucketSize + 1).floor()).clamp(0, length);

      // Average point of the NEXT bucket used as look-ahead reference.
      double avgX = 0, avgY = 0;
      int avgCount = 0;
      for (int j = nextRangeStart; j < nextRangeEnd; j++) {
        avgX += data[j].x;
        avgY += data[j].y;
        avgCount++;
      }
      if (avgCount > 0) {
        avgX /= avgCount;
        avgY /= avgCount;
      }

      // Find the point in the current bucket with the largest triangle area.
      final DataPoint pointA = data[a];
      double maxArea = -1;
      int maxAreaIdx = rangeStart;

      for (int j = rangeStart; j <= rangeEnd; j++) {
        if (j >= length) break;
        final double area = ((pointA.x - avgX) * (data[j].y - pointA.y) -
                    (pointA.x - data[j].x) * (avgY - pointA.y))
                .abs() *
            0.5;
        if (area > maxArea) {
          maxArea = area;
          maxAreaIdx = j;
        }
      }

      sampled[i + 1] = data[maxAreaIdx];
      a = maxAreaIdx;
    }

    // Always include the last point.
    sampled[threshold - 1] = data.last;
    return sampled;
  }

  /// Sample from raw y-values, generating synthetic x = index.
  static List<DataPoint> sampleRaw(List<double> yValues, int threshold) {
    final points = List<DataPoint>.generate(
      yValues.length,
      (i) => DataPoint(i.toDouble(), yValues[i]),
      growable: false,
    );
    return sample(points, threshold);
  }

  static List<DataPoint> _edgePoints(List<DataPoint> data) {
    if (data.isEmpty) return [];
    if (data.length == 1) return [data.first];
    return [data.first, data.last];
  }
}

// ---------------------------------------------------------------------------
// MinMax sampler — retains local peaks and valleys per bucket
// ---------------------------------------------------------------------------

class MinMaxSampler {
  /// Down-sample [data] to ~[threshold] points by keeping local min & max.
  ///
  /// Each bucket contributes up to 2 points (min + max), so the result
  /// length is approximately `threshold` but may vary slightly.
  static List<DataPoint> sample(List<DataPoint> data, int threshold) {
    if (threshold >= data.length || threshold <= 2) return data;

    final int buckets = (threshold / 2).ceil();
    final double bucketSize = data.length / buckets;
    final List<DataPoint> result = List.filled(buckets * 2, data.first, growable: true);
    int writeIdx = 0;

    for (int b = 0; b < buckets; b++) {
      final int start = (b * bucketSize).floor();
      final int end = ((b + 1) * bucketSize).floor().clamp(0, data.length);

      DataPoint? minPt, maxPt;
      for (int i = start; i < end; i++) {
        final pt = data[i];
        if (minPt == null || pt.y < minPt.y) minPt = pt;
        if (maxPt == null || pt.y > maxPt.y) maxPt = pt;
      }
      if (minPt != null && maxPt != null) {
        if (minPt.x <= maxPt.x) {
          result[writeIdx++] = minPt;
          if (minPt != maxPt) result[writeIdx++] = maxPt;
        } else {
          result[writeIdx++] = maxPt;
          if (minPt != maxPt) result[writeIdx++] = minPt;
        }
      }
    }
    return result.sublist(0, writeIdx);
  }
}

// ---------------------------------------------------------------------------
// Nth-point sampler — O(n) uniform decimation
// ---------------------------------------------------------------------------

class NthPointSampler {
  static List<DataPoint> sample(List<DataPoint> data, int threshold) {
    if (threshold >= data.length) return data;
    final int step = (data.length / threshold).ceil();
    final capacity = (data.length / step).ceil() + 1;
    final List<DataPoint> result = List.filled(capacity, data.first, growable: false);
    int writeIdx = 0;
    for (int i = 0; i < data.length; i += step) {
      result[writeIdx++] = data[i];
    }
    if (result[writeIdx - 1] != data.last) {
      if (writeIdx < capacity) result[writeIdx++] = data.last;
    }
    return result.sublist(0, writeIdx);
  }
}

// ---------------------------------------------------------------------------
// DoubleListSampler — operates on raw doubles, avoids DataPoint allocation
// for the 95% case where x = implicit index.
// ---------------------------------------------------------------------------

/// Samples [List<double>] directly, without allocating [DataPoint] objects.
///
/// Use this path inside [ChartDataProcessor] to avoid the:
///   _extractDoubles → DataSampler.fromRaw (re-box) → sample → unbox
/// round-trip that was previously wasting heap.
class DoubleListSampler {
  /// LTTB on raw doubles. Returns indices of selected points.
  static List<int> lttbIndices(List<double> data, int threshold) {
    final int n = data.length;
    if (threshold >= n || threshold <= 2) {
      if (n == 0) return [];
      if (n == 1) return [0];
      return [0, n - 1];
    }

    final List<int> selected = List.filled(threshold, 0);
    selected[0] = 0;

    final double bucketSize = (n - 2) / (threshold - 2);
    int a = 0;

    for (int i = 0; i < threshold - 2; i++) {
      final int rangeStart = ((i + 1) * bucketSize + 1).floor();
      final int rangeEnd = (((i + 2) * bucketSize + 1).floor()).clamp(0, n - 1);

      // FIXED: look-ahead from next bucket.
      final int nextStart = rangeEnd;
      final int nextEnd = (((i + 3) * bucketSize + 1).floor()).clamp(0, n);

      double avgY = 0;
      double avgX = 0;
      int cnt = 0;
      for (int j = nextStart; j < nextEnd; j++) {
        avgX += j;
        avgY += data[j];
        cnt++;
      }
      if (cnt > 0) {
        avgX /= cnt;
        avgY /= cnt;
      }

      final double ax = a.toDouble();
      final double ay = data[a];
      double maxArea = -1;
      int maxIdx = rangeStart;
      for (int j = rangeStart; j <= rangeEnd; j++) {
        if (j >= n) break;
        final double area = ((ax - avgX) * (data[j] - ay) -
                    (ax - j) * (avgY - ay))
                .abs() *
            0.5;
        if (area > maxArea) {
          maxArea = area;
          maxIdx = j;
        }
      }
      selected[i + 1] = maxIdx;
      a = maxIdx;
    }
    selected[threshold - 1] = n - 1;
    return selected;
  }

  /// Returns sampled doubles from LTTB indices.
  static List<double> lttb(List<double> data, int threshold) {
    if (data.length <= threshold) return data;
    final indices = lttbIndices(data, threshold);
    return [for (final i in indices) data[i]];
  }

  /// Returns sampled doubles keeping local min/max per bucket.
  static List<double> minMax(List<double> data, int threshold) {
    if (data.length <= threshold) return data;
    final int buckets = (threshold / 2).ceil();
    final double bucketSize = data.length / buckets;
    final result = <double>[];
    for (int b = 0; b < buckets; b++) {
      final int start = (b * bucketSize).floor();
      final int end = ((b + 1) * bucketSize).floor().clamp(0, data.length);
      double? minV, maxV;
      int minI = start, maxI = start;
      for (int i = start; i < end; i++) {
        final v = data[i];
        if (minV == null || v < minV) {
          minV = v;
          minI = i;
        }
        if (maxV == null || v > maxV) {
          maxV = v;
          maxI = i;
        }
      }
      if (minV != null && maxV != null) {
        if (minI <= maxI) {
          result.add(minV);
          if (minI != maxI) result.add(maxV);
        } else {
          result.add(maxV);
          if (minI != maxI) result.add(minV);
        }
      }
    }
    return result;
  }

  /// Returns every Nth point.
  static List<double> nth(List<double> data, int threshold) {
    if (data.length <= threshold) return data;
    final int step = (data.length / threshold).ceil();
    final result = <double>[];
    for (int i = 0; i < data.length; i += step) {
      result.add(data[i]);
    }
    if (result.last != data.last) result.add(data.last);
    return result;
  }

  /// Auto-selects strategy. Same thresholds as [DataSampler.auto].
  static List<double> auto(
    List<double> data,
    int threshold, {
    SamplingStrategy? forceStrategy,
  }) {
    if (data.length <= threshold) return data;
    final strategy = forceStrategy ??
        (data.length <= 5000
            ? SamplingStrategy.lttb
            : data.length <= 50000
                ? SamplingStrategy.minMax
                : SamplingStrategy.nth);
    switch (strategy) {
      case SamplingStrategy.lttb:
        return lttb(data, threshold);
      case SamplingStrategy.minMax:
        return minMax(data, threshold);
      case SamplingStrategy.nth:
        return nth(data, threshold);
    }
  }
}

// ---------------------------------------------------------------------------
// SamplingStrategy enum — shared across all samplers
// ---------------------------------------------------------------------------

enum SamplingStrategy { lttb, minMax, nth }

// ---------------------------------------------------------------------------
// DataSampler — convenience wrapper (DataPoint-based API)
// ---------------------------------------------------------------------------

class DataSampler {
  /// Automatically samples [data] to [threshold] points.
  ///
  /// Strategy selection:
  /// - ≤ 5 000 pts → LTTB (best visual accuracy)
  /// - ≤ 50 000 pts → MinMax (fast, keeps peaks)
  /// - > 50 000 pts → Nth-point (fastest)
  static List<DataPoint> auto(
    List<DataPoint> data,
    int threshold, {
    SamplingStrategy? forceStrategy,
  }) {
    if (data.length <= threshold) return data;

    final strategy = forceStrategy ??
        (data.length <= 5000
            ? SamplingStrategy.lttb
            : data.length <= 50000
                ? SamplingStrategy.minMax
                : SamplingStrategy.nth);

    switch (strategy) {
      case SamplingStrategy.lttb:
        return LTTBSampler.sample(data, threshold);
      case SamplingStrategy.minMax:
        return MinMaxSampler.sample(data, threshold);
      case SamplingStrategy.nth:
        return NthPointSampler.sample(data, threshold);
    }
  }

  /// Convert raw numeric series data to [DataPoint] list.
  static List<DataPoint> fromRaw(List<dynamic> raw) {
    final List<DataPoint> pts = List.filled(raw.length, const DataPoint(0, 0), growable: false);
    int writeIdx = 0;
    for (int i = 0; i < raw.length; i++) {
      final v = raw[i];
      if (v is num) pts[writeIdx++] = DataPoint(i.toDouble(), v.toDouble());
    }
    return writeIdx == raw.length ? pts : pts.sublist(0, writeIdx);
  }

  /// Convert [List<double>] to [DataPoint] list with index-based x values.
  static List<DataPoint> fromDoubles(List<double> values) {
    return List<DataPoint>.generate(
      values.length,
      (i) => DataPoint(i.toDouble(), values[i]),
      growable: false,
    );
  }
}

/// Axis scale configuration for chart rendering.
///
/// Provides a strongly-typed config layer between JSON/config and the
/// chart painters so that any chart type can request a specific scale
/// without coupling to the painter implementation.
///
/// Supported scales:
///  - [AxisScaleType.linear]   — default numeric axis
///  - [AxisScaleType.log]      — logarithmic (base configurable)
///  - [AxisScaleType.time]     — DateTime-based axis
///  - [AxisScaleType.category] — discrete string categories
///  - [AxisScaleType.percent]  — 0–100 normalised axis
library chart_axis_config;

import 'dart:math' as math;

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum AxisScaleType { linear, log, time, category, percent }

enum AxisPosition { left, right, top, bottom }

// ---------------------------------------------------------------------------
// ChartAxisConfig
// ---------------------------------------------------------------------------

/// Describes one axis on a chart (X or Y).
class ChartAxisConfig {
  /// Axis scaling algorithm.
  final AxisScaleType scaleType;

  /// Where this axis is rendered.
  final AxisPosition position;

  /// Human-readable axis label (optional).
  final String? label;

  /// Override minimum value. If null, computed from data.
  final double? min;

  /// Override maximum value. If null, computed from data.
  final double? max;

  /// Number of tick marks. Ignored for [AxisScaleType.category].
  final int tickCount;

  /// If [scaleType] is [AxisScaleType.log], the logarithm base (default 10).
  final double logBase;

  /// Discrete category labels, ordered. Required when
  /// [scaleType] == [AxisScaleType.category].
  final List<String>? categories;

  /// Custom tick formatter. If null, a sensible default is used.
  final String Function(double value)? tickFormatter;

  /// Custom tick formatter for DateTime ticks (used with [AxisScaleType.time]).
  final String Function(DateTime dt)? timeFormatter;

  /// Whether to show the axis line.
  final bool showAxisLine;

  /// Whether to show tick marks.
  final bool showTicks;

  /// Whether to show grid lines projected from this axis.
  final bool showGrid;

  /// Whether to show axis label text.
  final bool showLabels;

  /// Whether to invert the axis direction.
  final bool inverted;

  const ChartAxisConfig({
    this.scaleType = AxisScaleType.linear,
    this.position = AxisPosition.left,
    this.label,
    this.min,
    this.max,
    this.tickCount = 5,
    this.logBase = 10,
    this.categories,
    this.tickFormatter,
    this.timeFormatter,
    this.showAxisLine = true,
    this.showTicks = true,
    this.showGrid = true,
    this.showLabels = true,
    this.inverted = false,
  });

  // ---------- Convenience factories ----------

  const ChartAxisConfig.linear({
    AxisPosition position = AxisPosition.left,
    double? min,
    double? max,
    int tickCount = 5,
    String? label,
    bool showGrid = true,
  }) : this(
          scaleType: AxisScaleType.linear,
          position: position,
          min: min,
          max: max,
          tickCount: tickCount,
          label: label,
          showGrid: showGrid,
        );

  const ChartAxisConfig.log({
    AxisPosition position = AxisPosition.left,
    double? min,
    double? max,
    double logBase = 10,
    String? label,
  }) : this(
          scaleType: AxisScaleType.log,
          position: position,
          min: min,
          max: max,
          logBase: logBase,
          label: label,
        );

  const ChartAxisConfig.category({
    AxisPosition position = AxisPosition.bottom,
    required List<String> categories,
    String? label,
    bool showGrid = false,
  }) : this(
          scaleType: AxisScaleType.category,
          position: position,
          categories: categories,
          label: label,
          showGrid: showGrid,
        );

  const ChartAxisConfig.time({
    AxisPosition position = AxisPosition.bottom,
    double? min,
    double? max,
    int tickCount = 6,
    String? label,
  }) : this(
          scaleType: AxisScaleType.time,
          position: position,
          min: min,
          max: max,
          tickCount: tickCount,
          label: label,
        );

  const ChartAxisConfig.percent({
    AxisPosition position = AxisPosition.left,
    String? label,
  }) : this(
          scaleType: AxisScaleType.percent,
          position: position,
          min: 0,
          max: 100,
          label: label,
        );

  // ---------- Scale helpers ----------

  /// Convert a raw data value to [0..1] normalised.
  ///
  /// For [AxisScaleType.log], values ≤ 0 are clamped to a tiny positive.
  double normalize(double value, double dataMin, double dataMax) {
    final lo = min ?? dataMin;
    final hi = max ?? dataMax;
    if (hi == lo) return 0.5;

    switch (scaleType) {
      case AxisScaleType.linear:
      case AxisScaleType.time:
      case AxisScaleType.percent:
        return ((value - lo) / (hi - lo)).clamp(0.0, 1.0);

      case AxisScaleType.log:
        final logLo = math.log(lo.clamp(1e-10, double.infinity)) / math.log(logBase);
        final logHi = math.log(hi.clamp(1e-10, double.infinity)) / math.log(logBase);
        final logV = math.log(value.clamp(1e-10, double.infinity)) / math.log(logBase);
        if (logHi == logLo) return 0.5;
        return ((logV - logLo) / (logHi - logLo)).clamp(0.0, 1.0);

      case AxisScaleType.category:
        final cats = categories ?? const [];
        if (cats.isEmpty) return 0;
        final idx = value.round().clamp(0, cats.length - 1);
        return idx / (cats.length - 1);
    }
  }

  /// Generate tick values in data space.
  List<double> computeTicks(double dataMin, double dataMax) {
    final lo = min ?? dataMin;
    final hi = max ?? dataMax;

    switch (scaleType) {
      case AxisScaleType.linear:
      case AxisScaleType.time:
      case AxisScaleType.percent:
        return _linearTicks(lo, hi, tickCount);

      case AxisScaleType.log:
        return _logTicks(lo, hi, logBase);

      case AxisScaleType.category:
        final cats = categories ?? const [];
        return List.generate(cats.length, (i) => i.toDouble());
    }
  }

  /// Format a tick value as a display string.
  String formatTick(double value) {
    if (tickFormatter != null) return tickFormatter!(value);
    switch (scaleType) {
      case AxisScaleType.percent:
        return '${value.toStringAsFixed(0)}%';
      case AxisScaleType.log:
        // Display as power: 10^n
        return _formatLogTick(value, logBase);
      case AxisScaleType.category:
        final cats = categories ?? const [];
        final idx = value.round();
        return (idx >= 0 && idx < cats.length) ? cats[idx] : '';
      case AxisScaleType.time:
        if (timeFormatter != null) {
          return timeFormatter!(DateTime.fromMillisecondsSinceEpoch(value.round()));
        }
        return _formatTimeTick(value);
      default:
        return _formatNumber(value);
    }
  }

  // ---------- Internal ----------

  static List<double> _linearTicks(double lo, double hi, int count) {
    if (lo == hi) return List.filled(count, lo);
    final step = _niceStep((hi - lo) / (count - 1));
    final niceMin = (lo / step).floor() * step;
    return List.generate(count, (i) => niceMin + i * step);
  }

  static List<double> _logTicks(double lo, double hi, double base) {
    if (lo <= 0) lo = 1e-10;
    final logLo = (math.log(lo) / math.log(base)).ceil();
    final logHi = (math.log(hi) / math.log(base)).ceil();
    return List.generate(
      (logHi - logLo + 1).clamp(0, 20),
      (i) => math.pow(base, logLo + i).toDouble(),
    );
  }

  static double _niceStep(double rough) {
    if (rough <= 0) return 1;
    final mag =
        math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    final norm = rough / mag;
    if (norm <= 1) return mag;
    if (norm <= 2) return 2 * mag;
    if (norm <= 5) return 5 * mag;
    return 10 * mag;
  }

  static String _formatLogTick(double value, double base) {
    if (base == 10) {
      final exp = math.log(value) / math.ln10;
      if ((exp - exp.roundToDouble()).abs() < 0.001) {
        return '10^${exp.round()}';
      }
    }
    return _formatNumber(value);
  }

  static String _formatTimeTick(double ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms.round());
    return '${dt.month}/${dt.day}';
  }

  static String _formatNumber(double v) {
    if (v.abs() >= 1e9) return '${(v / 1e9).toStringAsFixed(1)}B';
    if (v.abs() >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (v.abs() >= 1e3) return '${(v / 1e3).toStringAsFixed(1)}K';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  // ---------- JSON ----------

  factory ChartAxisConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ChartAxisConfig();
    final scaleStr = json['scale']?.toString().toLowerCase() ?? 'linear';
    final scale = switch (scaleStr) {
      'log' => AxisScaleType.log,
      'time' => AxisScaleType.time,
      'category' => AxisScaleType.category,
      'percent' => AxisScaleType.percent,
      _ => AxisScaleType.linear,
    };
    final posStr = json['position']?.toString().toLowerCase() ?? 'left';
    final pos = switch (posStr) {
      'right' => AxisPosition.right,
      'top' => AxisPosition.top,
      'bottom' => AxisPosition.bottom,
      _ => AxisPosition.left,
    };
    return ChartAxisConfig(
      scaleType: scale,
      position: pos,
      label: json['label']?.toString(),
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      tickCount: (json['tickCount'] as int?) ?? 5,
      logBase: (json['logBase'] as num?)?.toDouble() ?? 10,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'] as List)
          : null,
      showAxisLine: json['showAxisLine'] as bool? ?? true,
      showTicks: json['showTicks'] as bool? ?? true,
      showGrid: json['showGrid'] as bool? ?? true,
      showLabels: json['showLabels'] as bool? ?? true,
      inverted: json['inverted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'scale': scaleType.name,
        'position': position.name,
        if (label != null) 'label': label,
        if (min != null) 'min': min,
        if (max != null) 'max': max,
        'tickCount': tickCount,
        'logBase': logBase,
        if (categories != null) 'categories': categories,
        'showAxisLine': showAxisLine,
        'showTicks': showTicks,
        'showGrid': showGrid,
        'showLabels': showLabels,
        'inverted': inverted,
      };
}

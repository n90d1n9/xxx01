/// Gauge chart — arc speedometer with colored bands and needle.
///
/// Supports arc gauges (partial circle), full circle gauges,
/// multiple qualitative bands (green/yellow/red), target markers,
/// and animated needle sweep.
///
/// JSON:
/// ```json
/// {
///   "type": "gauge",
///   "min": 0, "max": 100,
///   "value": 72,
///   "label": "Score",
///   "unit": "%",
///   "startAngle": 220, "endAngle": -40,
///   "bands": [
///     { "from": 0,  "to": 40,  "color": "#F44336" },
///     { "from": 40, "to": 70,  "color": "#FF9800" },
///     { "from": 70, "to": 100, "color": "#4CAF50" }
///   ]
/// }
/// ```
library gauge_chart;

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/config/base_config.dart';
import '../core/config/chart_type.dart';
import '../core/config/chart_theme.dart';
import '../core/config/title.dart';
import '../core/config/tooltip.dart';
import '../core/config/legend.dart';
import '../core/config/grid.dart';
import '../core/config/chart_model.dart';
import '../core/painters/chart_painter_base.dart';
import '../core/utils/chart_cache.dart';

// ─────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────

class GaugeBand {
  final double from;
  final double to;
  final Color color;

  const GaugeBand({required this.from, required this.to, required this.color});

  factory GaugeBand.fromJson(Map<String, dynamic> j) => GaugeBand(
        from: (j['from'] as num?)?.toDouble() ?? 0,
        to: (j['to'] as num?)?.toDouble() ?? 100,
        color: colorCache.resolve(j['color']?.toString() ?? '#4CAF50'),
      );
}

class GaugePointer {
  final double value;
  final String? label;
  final Color color;

  const GaugePointer({required this.value, this.label, this.color = Colors.black54});

  factory GaugePointer.fromJson(Map<String, dynamic> j) => GaugePointer(
        value: (j['value'] as num?)?.toDouble() ?? 0,
        label: j['label']?.toString(),
        color: colorCache.resolve(j['color']?.toString() ?? '#000000'),
      );
}

// ─────────────────────────────────────────────────────────
// Config
// ─────────────────────────────────────────────────────────

class GaugeChartConfig extends BaseChartConfig {
  final double value;
  final double min;
  final double max;
  final String? label;
  final String? unit;
  final double startAngleDeg; // 220 = lower left
  final double endAngleDeg;   // -40 = lower right
  final double trackWidth;    // arc thickness fraction of radius
  final List<GaugeBand> bands;
  final List<GaugePointer> pointers; // additional target markers
  final bool showNeedle;
  final bool showTicks;
  final bool showValue;
  final Color? valueColor;
  final ChartTheme theme;

  GaugeChartConfig({
    required this.value,
    this.min = 0,
    this.max = 100,
    this.label,
    this.unit,
    this.startAngleDeg = 220,
    this.endAngleDeg = -40,
    this.trackWidth = 0.18,
    this.bands = const [],
    this.pointers = const [],
    this.showNeedle = true,
    this.showTicks = true,
    this.showValue = true,
    this.valueColor,
    this.theme = ChartTheme.light,
    super.title,
    super.tooltip,
    super.legend,
    super.toolbox,
    super.grid,
  }) : super(type: ChartType.gauge, series: const []);

  @override
  Widget buildChart() => GaugeChartWidget(config: this);

  factory GaugeChartConfig.fromJson(Map<String, dynamic> json) {
    // Value can come from series or top-level
    double value = (json['value'] as num?)?.toDouble() ?? 0;
    final raw = json['series'] as List? ?? [];
    if (raw.isNotEmpty) {
      final s = raw.first as Map<String, dynamic>;
      final data = s['data'] as List? ?? [];
      if (data.isNotEmpty) value = (data.first as num?)?.toDouble() ?? value;
    }

    return GaugeChartConfig(
      value: value,
      min: (json['min'] as num?)?.toDouble() ?? 0,
      max: (json['max'] as num?)?.toDouble() ?? 100,
      label: json['label']?.toString(),
      unit: json['unit']?.toString(),
      startAngleDeg: (json['startAngle'] as num?)?.toDouble() ?? 220,
      endAngleDeg: (json['endAngle'] as num?)?.toDouble() ?? -40,
      trackWidth: (json['trackWidth'] as num?)?.toDouble() ?? 0.18,
      bands: (json['bands'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(GaugeBand.fromJson)
          .toList(),
      pointers: (json['pointers'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(GaugePointer.fromJson)
          .toList(),
      showNeedle: json['showNeedle'] as bool? ?? true,
      showTicks: json['showTicks'] as bool? ?? true,
      showValue: json['showValue'] as bool? ?? true,
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'gauge',
        'value': value,
        'min': min,
        'max': max,
        if (label != null) 'label': label,
        if (unit != null) 'unit': unit,
        'startAngle': startAngleDeg,
        'endAngle': endAngleDeg,
      };
}

// ─────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────

class GaugeChartWidget extends StatefulWidget {
  final GaugeChartConfig config;
  const GaugeChartWidget({super.key, required this.config});

  @override
  State<GaugeChartWidget> createState() => _GaugeState();
}

class _GaugeState extends State<GaugeChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  late Animation<double> _valueTween;

  GaugeChartConfig get cfg => widget.config;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _valueTween = _ctrl.drive(CurveTween(curve: Curves.easeOutCubic));
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant GaugeChartWidget old) {
    super.didUpdateWidget(old);
    if (old.config.value != widget.config.value) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (cfg.title?.text != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Text(cfg.title!.text!,
              style: cfg.theme.typography.titleStyle.copyWith(color: cfg.theme.titleColor)),
        ),
      Expanded(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: _GaugePainter(
              config: cfg,
              animValue: cfg.min + (cfg.value - cfg.min) * _valueTween.value,
              needleProgress: _anim.value,
            ),
          ),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────

class _GaugePainter extends ChartPainterBase {
  final GaugeChartConfig config;
  final double animValue;
  final double needleProgress;

  _GaugePainter({
    required this.config,
    required this.animValue,
    required this.needleProgress,
  }) : super(theme: config.theme);

  @override
  bool shouldRepaintChart(covariant _GaugePainter old) =>
      old.animValue != animValue || old.needleProgress != needleProgress;

  double get _startRad => config.startAngleDeg * math.pi / 180;
  double get _endRad => config.endAngleDeg * math.pi / 180;
  double get _sweepRad {
    double sw = _endRad - _startRad;
    if (sw >= 0) sw -= math.pi * 2;
    return sw; // always negative (clockwise)
  }

  double _valueToAngle(double v) {
    final t = ((v - config.min) / (config.max - config.min)).clamp(0.0, 1.0);
    return _startRad + _sweepRad * t;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.52;
    final radius = math.min(cx, size.height * 0.52) * 0.85;
    final trackW = radius * config.trackWidth;
    final innerR = radius - trackW;

    // ── background arc (track) ──
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius - trackW / 2),
      _startRad,
      _sweepRad,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackW
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x22000000)
        ..isAntiAlias = true,
    );

    // ── coloured bands ──
    if (config.bands.isNotEmpty) {
      for (final band in config.bands) {
        final a1 = _valueToAngle(band.from);
        final a2 = _valueToAngle(band.to);
        final sw = a2 - a1;
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius - trackW / 2),
          a1, sw, false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = trackW
            ..color = band.color
            ..isAntiAlias = true,
        );
      }
    } else {
      // Default: single coloured progress arc
      final pct = ((animValue - config.min) / (config.max - config.min)).clamp(0.0, 1.0);
      final progressColor = theme.palette.colorObjectAt(0);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius - trackW / 2),
        _startRad,
        _sweepRad * pct,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackW
          ..strokeCap = StrokeCap.round
          ..color = progressColor
          ..isAntiAlias = true,
      );
    }

    // ── tick marks ──
    if (config.showTicks) {
      const numTicks = 10;
      for (int i = 0; i <= numTicks; i++) {
        final t = i / numTicks;
        final angle = _startRad + _sweepRad * t;
        final major = i % 2 == 0;
        final outerPt = Offset(cx + radius * math.cos(angle), cy + radius * math.sin(angle));
        final innerPt = Offset(
            cx + (innerR - (major ? 8 : 4)) * math.cos(angle),
            cy + (innerR - (major ? 8 : 4)) * math.sin(angle));
        canvas.drawLine(outerPt, innerPt,
            paintCache.stroke(theme.axisColor, major ? 1.5 : 1.0));
        if (major) {
          final v = config.min + (config.max - config.min) * t;
          final tp = textPainterCache.get(
            _fmt(v),
            theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 9),
          );
          final labelR = innerR - 18;
          tp.paint(canvas, Offset(
              cx + labelR * math.cos(angle) - tp.width / 2,
              cy + labelR * math.sin(angle) - tp.height / 2));
        }
      }
    }

    // ── extra pointers (target markers) ──
    for (final ptr in config.pointers) {
      final angle = _valueToAngle(ptr.value);
      final outerR2 = radius + 4;
      final innerR2 = innerR + 2;
      canvas.drawLine(
        Offset(cx + innerR2 * math.cos(angle), cy + innerR2 * math.sin(angle)),
        Offset(cx + outerR2 * math.cos(angle), cy + outerR2 * math.sin(angle)),
        paintCache.stroke(ptr.color, 3),
      );
    }

    // ── needle ──
    if (config.showNeedle) {
      final angle = _valueToAngle(animValue);
      final needleLen = innerR * 0.85;
      final tailLen = 14.0;
      canvas.drawLine(
        Offset(cx - tailLen * math.cos(angle), cy - tailLen * math.sin(angle)),
        Offset(cx + needleLen * needleProgress * math.cos(angle),
               cy + needleLen * needleProgress * math.sin(angle)),
        Paint()
          ..color = const Color(0xDD2C2C2C)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true,
      );
      // Hub circle
      canvas.drawCircle(Offset(cx, cy), 7,
          Paint()..color = const Color(0xFF2C2C2C)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(cx, cy), 5,
          Paint()..color = Colors.white..style = PaintingStyle.fill);
    }

    // ── centre value text ──
    if (config.showValue) {
      final display = '${_fmt(animValue)}${config.unit ?? ''}';
      final tp = textPainterCache.get(
        display,
        theme.typography.titleStyle.copyWith(
            color: config.valueColor ?? theme.titleColor,
            fontSize: 22,
            fontWeight: FontWeight.w700),
      );
      tp.paint(canvas, Offset(cx - tp.width / 2, cy + radius * 0.22));
      if (config.label != null) {
        final ltp = textPainterCache.get(
          config.label!,
          theme.typography.axisLabelStyle
              .copyWith(color: theme.axisLabelColor, fontSize: 12),
        );
        ltp.paint(canvas, Offset(cx - ltp.width / 2, cy + radius * 0.22 + 28));
      }
    }

    // ── min / max labels ──
    _drawEdgeLabel(canvas, cx, cy, radius, _startRad, _fmt(config.min));
    _drawEdgeLabel(canvas, cx, cy, radius, _endRad, _fmt(config.max));
  }

  void _drawEdgeLabel(Canvas canvas, double cx, double cy, double radius,
      double angle, String text) {
    final tp = textPainterCache.get(
      text,
      theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 9),
    );
    final r = radius + 10;
    tp.paint(canvas, Offset(cx + r * math.cos(angle) - tp.width / 2,
        cy + r * math.sin(angle) - tp.height / 2));
  }

  String _fmt(double v) => v == v.roundToDouble()
      ? v.toStringAsFixed(0)
      : v.toStringAsFixed(1);
}

/// Sparkline — minimal inline trend chart with no axes or labels.
/// Designed to be embedded inside table cells, KPI cards, or list items.
/// Supports line, area, and bar sparklines with optional end-dot and
/// high/low markers.
///
/// JSON:
/// ```json
/// { "type": "sparkline", "sparklineType": "area",
///   "series": [{ "data": [42, 55, 38, 67, 72, 58, 81] }] }
/// ```
library sparkline_chart;

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/config/base_config.dart';
import '../core/config/chart_type.dart';
import '../core/config/chart_theme.dart';
import '../core/config/series.dart';
import '../core/config/title.dart';
import '../core/config/tooltip.dart';
import '../core/config/legend.dart';
import '../core/config/grid.dart';
import '../core/config/chart_model.dart';
import '../core/painters/chart_painter_base.dart';
import '../core/utils/chart_cache.dart';

enum SparklineType { line, area, bar }

class SparklineChartConfig extends BaseChartConfig {
  final SparklineType sparklineType;
  final bool showEndDot;
  final bool showHighLow;
  final double strokeWidth;
  final double fillOpacity;
  final ChartTheme theme;

  SparklineChartConfig({
    required List<Series> super.series,
    this.theme = ChartTheme.light,
    this.sparklineType = SparklineType.line,
    this.showEndDot = true,
    this.showHighLow = false,
    this.strokeWidth = 2.0,
    this.fillOpacity = 0.2,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.sparkline);

  @override
  Widget buildChart() => SparklineWidget(config: this);

  factory SparklineChartConfig.fromJson(Map<String, dynamic> json) {
    final seriesList = (json['series'] as List? ?? []).whereType<Map<String,dynamic>>().map(Series.fromJson).toList();
    final typeStr = json['sparklineType']?.toString().toLowerCase() ?? 'line';
    return SparklineChartConfig(
      series: seriesList,
      sparklineType: typeStr == 'area' ? SparklineType.area : typeStr == 'bar' ? SparklineType.bar : SparklineType.line,
      showEndDot: json['showEndDot'] as bool? ?? true,
      showHighLow: json['showHighLow'] as bool? ?? false,
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2.0,
      fillOpacity: (json['fillOpacity'] as num?)?.toDouble() ?? 0.2,
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'sparkline'};
}

class SparklineWidget extends StatefulWidget {
  final SparklineChartConfig config;
  const SparklineWidget({super.key, required this.config});
  @override State<SparklineWidget> createState() => _SparklineState();
}

class _SparklineState extends State<SparklineWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  SparklineChartConfig get cfg => widget.config;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => RepaintBoundary(child: CustomPaint(
    size: Size.infinite,
    painter: _SparklinePainter(config: cfg, progress: _anim.value),
  ));
}

class _SparklinePainter extends ChartPainterBase {
  final SparklineChartConfig config;
  final double progress;

  _SparklinePainter({required this.config, required this.progress}) : super(theme: config.theme);

  @override bool shouldRepaintChart(covariant _SparklinePainter old) => old.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (config.series.isEmpty) return;
    final data = (config.series.first.data ?? []).map((v) => (v as num?)?.toDouble() ?? 0.0).toList();
    if (data.length < 2) return;

    final n = data.length;
    const pad = 3.0;
    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = (maxV - minV).clamp(1.0, double.infinity);
    final color = theme.palette.colorObjectAt(0);

    Offset pt(int i) {
      final x = pad + i / (n - 1) * (size.width - pad * 2);
      final y = size.height - pad - ((data[i] - minV) / range) * (size.height - pad * 2);
      return Offset(x, y);
    }

    if (config.sparklineType == SparklineType.bar) {
      final barW = (size.width - pad * 2) / n * 0.75;
      for (int i = 0; i < n; i++) {
        final frac = (data[i] - minV) / range * progress;
        final h = frac * (size.height - pad * 2);
        final x = pad + i / n * (size.width - pad * 2);
        canvas.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - pad - h, barW, h), const Radius.circular(1)),
          Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true);
      }
      return;
    }

    // Line / area
    final visible = (n * progress).round().clamp(1, n);
    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (int i = 1; i < visible; i++) path.lineTo(pt(i).dx, pt(i).dy);

    if (config.sparklineType == SparklineType.area) {
      final fill = Path.from(path)
        ..lineTo(pt(visible - 1).dx, size.height - pad)
        ..lineTo(pt(0).dx, size.height - pad)
        ..close();
      canvas.drawPath(fill, Paint()
        ..color = color.withOpacity(config.fillOpacity)
        ..style = PaintingStyle.fill..isAntiAlias = true);
    }
    canvas.drawPath(path, Paint()
      ..color = color..style = PaintingStyle.stroke
      ..strokeWidth = config.strokeWidth..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round..isAntiAlias = true);

    // End dot
    if (config.showEndDot && visible > 0) {
      final last = pt(visible - 1);
      canvas.drawCircle(last, 3.5, Paint()..color = color..style = PaintingStyle.fill);
      canvas.drawCircle(last, 3.5, paintCache.stroke(Colors.white, 1.5));
    }

    // High/low markers
    if (config.showHighLow) {
      int hiIdx = 0, loIdx = 0;
      for (int i = 1; i < n; i++) {
        if (data[i] > data[hiIdx]) hiIdx = i;
        if (data[i] < data[loIdx]) loIdx = i;
      }
      canvas.drawCircle(pt(hiIdx), 4, Paint()..color = const Color(0xFF4CAF50)..style = PaintingStyle.fill);
      canvas.drawCircle(pt(loIdx), 4, Paint()..color = const Color(0xFFF44336)..style = PaintingStyle.fill);
    }
  }
}

/// Remaining chart types — completes the full requested set.
///
/// Charts in this file:
///   • [RainfallChartConfig]       — bar chart styled as rainfall with wave top
///   • [MultiXAxesChartConfig]     — line chart with two independent X axes
///   • [LineStyleItemConfig]       — line with per-series dash/dot/width styles
///   • [LargeScaleAreaConfig]      — performance-optimised area (LTTB downsampled)
///   • [AreaTimeAxisConfig]        — area/line chart with DateTime-based X axis
///   • [PolarLineChartConfig]      — line on polar coordinates (two value axes)
///   • [CustomizedPieConfig]       — pie with per-slice custom styles & explode
///   • [PieLabelAlignConfig]       — pie with polyline-aligned external labels
///   • [PieSpecialLabelConfig]     — pie with custom per-slice label widgets
library remaining_charts;

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
import '../core/utils/chart_data_processor.dart';
import '../core/utils/data_sampler.dart';
import '../core/utils/chart_cache.dart';

// ─── shared helpers ────────────────────────────────────────────────────────

Path _smoothLine(List<Offset> pts, {double t = 0.4}) {
  if (pts.isEmpty) return Path();
  final p = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (int i = 0; i < pts.length - 1; i++) {
    final p0 = pts[i], p1 = pts[i + 1];
    final cp = (p1.dx - p0.dx) * t;
    p.cubicTo(p0.dx + cp, p0.dy, p1.dx - cp, p1.dy, p1.dx, p1.dy);
  }
  return p;
}

void _yGrid(Canvas c, ChartViewport vp, List<double> ticks,
    ChartPainterBase p, String Function(double) fmt) {
  for (final t in ticks) {
    final y = vp.toCanvasY(t);
    if (y < vp.top || y > vp.bottom) continue;
    c.drawLine(Offset(vp.left, y), Offset(vp.right, y),
        p.paintCache.stroke(p.theme.gridColor, 0.5));
    final tp = p.textPainterCache.get(fmt(t),
        p.theme.typography.axisLabelStyle.copyWith(
            color: p.theme.axisLabelColor, fontSize: 9),
        align: TextAlign.right, maxWidth: 46);
    tp.paint(c, Offset(vp.left - tp.width - 4, y - tp.height / 2));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. RAINFALL CHART
// ═══════════════════════════════════════════════════════════════════════════
/// Bar chart styled to look like rainfall — thin bars with a wavy top
/// representing rain drops.  Each series can optionally overlay a line
/// for temperature / secondary metric.
///
/// JSON:
/// ```json
/// { "type": "rainfall",
///   "categories": ["Jan","Feb","Mar","Apr","May","Jun"],
///   "series": [
///     { "name": "Precipitation (mm)", "data": [18,28,42,76,95,60],
///       "itemStyle": {"color": "#5b8ff9"} },
///     { "name": "Temp (°C)", "type": "line",
///       "data": [12,14,18,23,27,29], "color": "#f6bd16" }
///   ]}
/// ```
class RainfallChartConfig extends BaseChartConfig {
  final List<String> categories;
  final double barWidthRatio;
  final bool showLine;          // overlay line for secondary series
  final ChartTheme theme;

  RainfallChartConfig({
    required this.categories,
    required List<Series> super.series,
    this.theme = ChartTheme.light,
    this.barWidthRatio = 0.45,
    this.showLine = true,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.rainfall);

  @override Widget buildChart() => _RainfallWidget(config: this);

  factory RainfallChartConfig.fromJson(Map<String, dynamic> j) {
    final cats = (j['categories'] as List? ?? []).map((e) => e.toString()).toList();
    final s = (j['series'] as List? ?? [])
        .whereType<Map<String, dynamic>>().map(Series.fromJson).toList();
    return RainfallChartConfig(
      categories: cats, series: s,
      barWidthRatio: (j['barWidthRatio'] as num?)?.toDouble() ?? 0.45,
      showLine: j['showLine'] as bool? ?? true,
      title:   j['title']   != null ? TitlesData.fromJson(j['title'])     : null,
      tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
      legend:  j['legend']  != null ? ChartLegend.fromJson(j['legend'])   : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'rainfall'};
}

class _RainfallWidget extends StatefulWidget {
  final RainfallChartConfig config;
  const _RainfallWidget({required this.config});
  @override State<_RainfallWidget> createState() => _RainfallState();
}

class _RainfallState extends State<_RainfallWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  RainfallChartConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _RainfallPainter(cfg: cfg, progress: _anim.value),
    ))),
    _buildLegend(),
  ]);

  Widget _buildLegend() => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Wrap(spacing: 12, alignment: WrapAlignment.center,
      children: cfg.series.asMap().entries.map((e) {
        final color = cfg.theme.seriesColor(e.key, explicitColor: e.value.color);
        final isLine = e.value.type == 'line';
        return Row(mainAxisSize: MainAxisSize.min, children: [
          isLine
            ? Container(width: 16, height: 2, color: color)
            : Container(width: 10, height: 10, color: color),
          const SizedBox(width: 4),
          Text(e.value.name ?? 'S${e.key+1}',
              style: cfg.theme.typography.legendStyle
                  .copyWith(color: cfg.theme.legendTextColor)),
        ]);
      }).toList()));
}

class _RainfallPainter extends ChartPainterBase {
  final RainfallChartConfig cfg;
  final double progress;
  _RainfallPainter({required this.cfg, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _RainfallPainter o) => o.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    final n = cfg.categories.length;
    if (n == 0 || cfg.series.isEmpty) return;
    const padL = 52.0, padR = 48.0, padT = 24.0, padB = 28.0;
    final plotW = size.width - padL - padR;
    final plotH = size.height - padT - padB;
    final slotW = plotW / n;

    // Separate bar and line series
    final barSeries = cfg.series.where((s) => s.type != 'line').toList();
    final lineSeries = cfg.showLine
        ? cfg.series.where((s) => s.type == 'line').toList() : <Series>[];

    // Bar Y range (left axis)
    double barMax = 0;
    for (final s in barSeries) {
      for (final v in s.data ?? []) {
        final d = (v as num).toDouble(); if (d > barMax) barMax = d;
      }
    }
    barMax = barMax * 1.15 + 1;

    // Line Y range (right axis)
    double lineMin = double.infinity, lineMax = double.negativeInfinity;
    for (final s in lineSeries) {
      for (final v in s.data ?? []) {
        final d = (v as num).toDouble();
        if (d < lineMin) lineMin = d; if (d > lineMax) lineMax = d;
      }
    }
    if (lineMin == double.infinity) { lineMin = 0; lineMax = 100; }
    final linePad = (lineMax - lineMin) * 0.15;
    lineMin -= linePad; lineMax += linePad;

    // Grid + left axis (bar)
    final barTicks = ChartDataProcessor.niceYTicks(0, barMax);
    for (final t in barTicks) {
      final y = padT + plotH * (1 - t / barMax);
      canvas.drawLine(Offset(padL, y), Offset(padL + plotW, y),
          paintCache.stroke(theme.gridColor, 0.5));
      final tp = textPainterCache.get(t.toStringAsFixed(0),
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 9),
          align: TextAlign.right, maxWidth: 46);
      tp.paint(canvas, Offset(padL - tp.width - 4, y - tp.height / 2));
    }

    // Right axis (line)
    if (lineSeries.isNotEmpty) {
      final lineTicks = ChartDataProcessor.niceYTicks(lineMin, lineMax);
      for (final t in lineTicks) {
        final y = padT + plotH * (1 - (t - lineMin) / (lineMax - lineMin));
        final tp = textPainterCache.get(t.toStringAsFixed(0),
            theme.typography.axisLabelStyle.copyWith(
                color: theme.seriesColor(barSeries.length), fontSize: 9));
        tp.paint(canvas, Offset(padL + plotW + 6, y - tp.height / 2));
      }
    }

    // Bars with wave top
    for (int si = 0; si < barSeries.length; si++) {
      final s = barSeries[si];
      final color = theme.seriesColor(si, explicitColor: s.color);
      final barW = slotW * cfg.barWidthRatio / barSeries.length;

      for (int ci = 0; ci < n; ci++) {
        final d = s.data;
        if (d == null || ci >= d.length) continue;
        final val = (d[ci] as num).toDouble();
        final barH = (val / barMax) * plotH * progress;
        final cx = padL + (ci + 0.5) * slotW;
        final barX = cx - (slotW * cfg.barWidthRatio) / 2 + si * barW;
        final barTop = padT + plotH - barH;

        // Bar body
        canvas.drawRect(Rect.fromLTWH(barX, barTop, barW - 2, barH),
            Paint()..color = color.withOpacity(0.75)..style = PaintingStyle.fill..isAntiAlias = true);

        // Wave top (sinusoidal bump)
        if (barH > 8) {
          final waveH = math.min(barH * 0.12, 6.0);
          final wavePath = Path();
          wavePath.moveTo(barX, barTop);
          for (int wi = 0; wi <= 20; wi++) {
            final wx = barX + (barW - 2) * wi / 20;
            final wy = barTop - waveH * math.sin(wi / 20 * math.pi * 2);
            if (wi == 0) wavePath.moveTo(wx, wy); else wavePath.lineTo(wx, wy);
          }
          wavePath.lineTo(barX + barW - 2, barTop);
          wavePath.close();
          canvas.drawPath(wavePath,
              Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true);
        }
      }
    }

    // Line series overlay
    for (int si = 0; si < lineSeries.length; si++) {
      final s = lineSeries[si];
      final color = theme.seriesColor(barSeries.length + si, explicitColor: s.color);
      final pts = <Offset>[];
      for (int ci = 0; ci < n; ci++) {
        final d = s.data;
        if (d == null || ci >= d.length) continue;
        final val = (d[ci] as num).toDouble();
        final y = padT + plotH * (1 - (val - lineMin) / (lineMax - lineMin) * progress);
        pts.add(Offset(padL + (ci + 0.5) * slotW, y));
      }
      if (pts.length >= 2) {
        canvas.drawPath(_smoothLine(pts),
            paintCache.stroke(color, 2.2)..isAntiAlias = true);
        for (final p in pts) {
          canvas.drawCircle(p, 4,
              Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true);
          canvas.drawCircle(p, 4,
              Paint()..color = Colors.white..style = PaintingStyle.stroke
                ..strokeWidth = 1.5..isAntiAlias = true);
        }
      }
    }

    // X labels
    for (int i = 0; i < n; i++) {
      final tp = textPainterCache.get(cfg.categories[i],
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 9.5));
      tp.paint(canvas, Offset(padL + (i + 0.5) * slotW - tp.width / 2, padT + plotH + 4));
    }
    canvas.drawLine(Offset(padL, padT + plotH), Offset(padL + plotW, padT + plotH), axisPaint);
    canvas.drawLine(Offset(padL, padT), Offset(padL, padT + plotH), axisPaint);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. MULTIPLE X AXES
// ═══════════════════════════════════════════════════════════════════════════
/// Two independent X-axis lines with their own category sets, rendered
/// one above the other on the plot area.  Each series is bound to either
/// xAxis 0 (bottom) or xAxis 1 (top).
///
/// JSON:
/// ```json
/// { "type": "multiXAxes",
///   "xAxes": [
///     { "label": "Month (2023)", "categories": ["Jan","Feb","Mar","Apr"] },
///     { "label": "Week",         "categories": ["W1","W2","W3","W4","W5","W6","W7","W8","W9","W10","W11","W12"] }
///   ],
///   "series": [
///     { "name": "Monthly Sales", "xAxisIndex": 0, "data": [820,932,901,934] },
///     { "name": "Weekly Visits", "xAxisIndex": 1, "data": [220,182,191,234,290,330,310,123,442,321,90,149] }
///   ]}
/// ```
class XAxisDef {
  final String label;
  final List<String> categories;
  const XAxisDef({required this.label, required this.categories});
  factory XAxisDef.fromJson(Map<String, dynamic> j) => XAxisDef(
    label: j['label']?.toString() ?? '',
    categories: (j['categories'] as List? ?? []).map((e) => e.toString()).toList(),
  );
}

class MultiXAxesChartConfig extends BaseChartConfig {
  final List<XAxisDef> xAxes;
  final ChartTheme theme;

  MultiXAxesChartConfig({
    required this.xAxes,
    required List<Series> super.series,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.multiXAxes);

  @override Widget buildChart() => _MultiXWidget(config: this);

  factory MultiXAxesChartConfig.fromJson(Map<String, dynamic> j) {
    final axes = (j['xAxes'] as List? ?? [])
        .whereType<Map<String, dynamic>>().map(XAxisDef.fromJson).toList();
    final s = (j['series'] as List? ?? [])
        .whereType<Map<String, dynamic>>().map(Series.fromJson).toList();
    return MultiXAxesChartConfig(xAxes: axes, series: s,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
        legend: j['legend'] != null ? ChartLegend.fromJson(j['legend']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'multiXAxes'};
}

class _MultiXWidget extends StatefulWidget {
  final MultiXAxesChartConfig config;
  const _MultiXWidget({required this.config});
  @override State<_MultiXWidget> createState() => _MultiXState();
}

class _MultiXState extends State<_MultiXWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  MultiXAxesChartConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _MultiXPainter(cfg: cfg, progress: _anim.value),
    ))),
    _buildLegend(),
  ]);

  Widget _buildLegend() => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Wrap(spacing: 12, alignment: WrapAlignment.center,
      children: cfg.series.asMap().entries.map((e) {
        final color = cfg.theme.seriesColor(e.key, explicitColor: e.value.color);
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 14, height: 2, color: color),
          const SizedBox(width: 4),
          Text(e.value.name ?? 'S${e.key+1}',
              style: cfg.theme.typography.legendStyle
                  .copyWith(color: cfg.theme.legendTextColor)),
        ]);
      }).toList()));
}

class _MultiXPainter extends ChartPainterBase {
  final MultiXAxesChartConfig cfg;
  final double progress;
  _MultiXPainter({required this.cfg, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _MultiXPainter o) => o.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (cfg.xAxes.isEmpty || cfg.series.isEmpty) return;
    const padL = 52.0, padR = 12.0, padT = 28.0, padB = 28.0;
    final plotW = size.width - padL - padR;
    final plotH = size.height - padT - padB;

    // Compute combined Y range
    final allVals = cfg.series.expand((s) =>
        (s.data ?? []).map((v) => (v as num).toDouble())).toList();
    if (allVals.isEmpty) return;
    double yMin = allVals.reduce(math.min), yMax = allVals.reduce(math.max);
    final yPad = (yMax - yMin) * 0.12;
    yMin -= yPad; yMax += yPad;

    final vp = ChartViewport(left: padL, top: padT, right: padL + plotW, bottom: padT + plotH,
        dataMinX: 0, dataMaxX: 1, dataMinY: yMin, dataMaxY: yMax);

    final ticks = ChartDataProcessor.niceYTicks(yMin, yMax);
    _yGrid(canvas, vp, ticks, this, (t) => t.toStringAsFixed(0));

    for (int si = 0; si < cfg.series.length; si++) {
      final s = cfg.series[si];
      final axisIdx = (s.xAxisIndex ?? 0).clamp(0, cfg.xAxes.length - 1);
      final axis = cfg.xAxes[axisIdx];
      final n = axis.categories.length;
      if (n == 0) continue;
      final color = theme.seriesColor(si, explicitColor: s.color);
      final vals = (s.data ?? []).map((v) => (v as num).toDouble()).toList();
      final pts = List.generate(math.min(vals.length, n), (i) {
        final animY = yMin + (vals[i] - yMin) * progress;
        return Offset(padL + i / (n - 1) * plotW, vp.toCanvasY(animY));
      });
      if (pts.length >= 2) {
        canvas.drawPath(_smoothLine(pts), paintCache.stroke(color, 2.0)..isAntiAlias = true);
        for (final p in pts) {
          canvas.drawCircle(p, 3, Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true);
        }
      }

      // Axis labels (bottom for axis 0, top for axis 1)
      final isTop = axisIdx == 1;
      for (int i = 0; i < n; i++) {
        if (i % math.max(1, (n / 8).round()) != 0 && i != n - 1) continue;
        final x = padL + i / (n - 1) * plotW;
        final tp = textPainterCache.get(axis.categories[i],
            theme.typography.axisLabelStyle.copyWith(color: color.withOpacity(0.8), fontSize: 8.5));
        final y = isTop ? padT - tp.height - 2 : padT + plotH + 4;
        tp.paint(canvas, Offset(x - tp.width / 2, y));
      }
      // Axis label text
      final axLbl = textPainterCache.get(axis.label,
          theme.typography.axisLabelStyle.copyWith(color: color, fontSize: 9,
              fontWeight: FontWeight.w600));
      final lblY = isTop ? 2.0 : size.height - axLbl.height - 1;
      axLbl.paint(canvas, Offset(padL, lblY));
    }

    canvas.drawLine(Offset(padL, padT + plotH), Offset(padL + plotW, padT + plotH), axisPaint);
    canvas.drawLine(Offset(padL, padT), Offset(padL, padT + plotH), axisPaint);
    canvas.drawLine(Offset(padL, padT), Offset(padL + plotW, padT), axisPaint);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. LINE STYLE & ITEM STYLE
// ═══════════════════════════════════════════════════════════════════════════
/// Line chart where each series has configurable dash pattern, line width,
/// dot shape (circle/square/diamond), dot size, and opacity.
///
/// JSON:
/// ```json
/// { "type": "lineStyleItem",
///   "categories": ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"],
///   "series": [
///     { "name":"Solid",   "data":[820,932,901,934,1290,1330,1320],
///       "lineStyle":{"type":"solid","width":2},
///       "itemStyle":{"shape":"circle","size":6} },
///     { "name":"Dashed",  "data":[620,732,701,734,1090,1130,1120],
///       "lineStyle":{"type":"dashed","width":2,"dash":[8,4]},
///       "itemStyle":{"shape":"square","size":7} },
///     { "name":"Dotted",  "data":[420,532,501,534,890,930,920],
///       "lineStyle":{"type":"dotted","width":1.5},
///       "itemStyle":{"shape":"diamond","size":8} }
///   ]}
/// ```
class LineStyleSpec {
  final String type;     // 'solid' | 'dashed' | 'dotted'
  final double width;
  final List<double> dash;
  const LineStyleSpec({this.type = 'solid', this.width = 2.0,
      this.dash = const [8, 4]});
  factory LineStyleSpec.fromJson(Map<String, dynamic> j) => LineStyleSpec(
    type: j['type']?.toString() ?? 'solid',
    width: (j['width'] as num?)?.toDouble() ?? 2.0,
    dash: (j['dash'] as List? ?? [8, 4]).map<double>((v) => (v as num).toDouble()).toList(),
  );
}

class ItemStyleSpec {
  final String shape;   // 'circle' | 'square' | 'diamond'
  final double size;
  const ItemStyleSpec({this.shape = 'circle', this.size = 5.0});
  factory ItemStyleSpec.fromJson(Map<String, dynamic> j) => ItemStyleSpec(
    shape: j['shape']?.toString() ?? 'circle',
    size: (j['size'] as num?)?.toDouble() ?? 5.0,
  );
}

class LineStyleSeries {
  final String? name, color;
  final List<double> data;
  final LineStyleSpec lineStyle;
  final ItemStyleSpec itemStyle;
  const LineStyleSeries({this.name, this.color, required this.data,
      this.lineStyle = const LineStyleSpec(),
      this.itemStyle = const ItemStyleSpec()});

  factory LineStyleSeries.fromJson(Map<String, dynamic> j) => LineStyleSeries(
    name: j['name']?.toString(),
    color: j['color']?.toString(),
    data: (j['data'] as List? ?? []).map<double>((v) => (v as num).toDouble()).toList(),
    lineStyle: j['lineStyle'] != null
        ? LineStyleSpec.fromJson(j['lineStyle'] as Map<String, dynamic>)
        : const LineStyleSpec(),
    itemStyle: j['itemStyle'] != null
        ? ItemStyleSpec.fromJson(j['itemStyle'] as Map<String, dynamic>)
        : const ItemStyleSpec(),
  );
}

class LineStyleItemConfig extends BaseChartConfig {
  final List<String> categories;
  final List<LineStyleSeries> styledSeries;
  final ChartTheme theme;

  LineStyleItemConfig({
    required this.categories,
    required this.styledSeries,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.lineStyleItem, series: const []);

  @override Widget buildChart() => _LineStyleWidget(config: this);

  factory LineStyleItemConfig.fromJson(Map<String, dynamic> j) {
    final cats = (j['categories'] as List? ?? []).map((e) => e.toString()).toList();
    final s = (j['series'] as List? ?? [])
        .whereType<Map<String, dynamic>>().map(LineStyleSeries.fromJson).toList();
    return LineStyleItemConfig(categories: cats, styledSeries: s,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
        legend: j['legend'] != null ? ChartLegend.fromJson(j['legend']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'lineStyleItem'};
}

class _LineStyleWidget extends StatefulWidget {
  final LineStyleItemConfig config;
  const _LineStyleWidget({required this.config});
  @override State<_LineStyleWidget> createState() => _LineStyleState();
}

class _LineStyleState extends State<_LineStyleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  LineStyleItemConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _LineStylePainter(cfg: cfg, progress: _anim.value),
    ))),
    _buildLegend(),
  ]);

  Widget _buildLegend() => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Wrap(spacing: 14, alignment: WrapAlignment.center,
      children: cfg.styledSeries.asMap().entries.map((e) {
        final color = cfg.theme.seriesColor(e.key, explicitColor: e.value.color);
        final ls = e.value.lineStyle;
        return Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 22, height: 14, child: CustomPaint(
            painter: _LegendLinePainter(color: color, ls: ls))),
          const SizedBox(width: 4),
          Text(e.value.name ?? 'S${e.key+1}',
              style: cfg.theme.typography.legendStyle
                  .copyWith(color: cfg.theme.legendTextColor)),
        ]);
      }).toList()));
}

class _LegendLinePainter extends CustomPainter {
  final Color color;
  final LineStyleSpec ls;
  _LegendLinePainter({required this.color, required this.ls});
  @override bool shouldRepaint(_) => false;
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = ls.width
        ..style = PaintingStyle.stroke..isAntiAlias = true;
    if (ls.type == 'dashed') {
      double x = 0;
      bool on = true;
      while (x < size.width) {
        final segLen = on ? ls.dash[0] : ls.dash[1];
        if (on) canvas.drawLine(Offset(x, size.height / 2),
            Offset(math.min(x + segLen, size.width), size.height / 2), paint);
        x += segLen; on = !on;
      }
    } else if (ls.type == 'dotted') {
      double x = 0;
      while (x < size.width) {
        canvas.drawCircle(Offset(x, size.height / 2), ls.width / 2, paint..style = PaintingStyle.fill);
        x += ls.width * 3;
      }
    } else {
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    }
  }
}

class _LineStylePainter extends ChartPainterBase {
  final LineStyleItemConfig cfg;
  final double progress;
  _LineStylePainter({required this.cfg, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _LineStylePainter o) => o.progress != progress;

  void _drawItem(Canvas canvas, Offset p, ItemStyleSpec is_, Color color) {
    final r = is_.size / 2;
    final paint = Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true;
    switch (is_.shape) {
      case 'square':
        canvas.drawRect(Rect.fromCenter(center: p, width: is_.size, height: is_.size), paint);
      case 'diamond':
        final path = Path()
          ..moveTo(p.dx, p.dy - r)..lineTo(p.dx + r, p.dy)
          ..lineTo(p.dx, p.dy + r)..lineTo(p.dx - r, p.dy)..close();
        canvas.drawPath(path, paint);
      default:
        canvas.drawCircle(p, r, paint);
        canvas.drawCircle(p, r, Paint()..color = Colors.white
            ..style = PaintingStyle.stroke..strokeWidth = 1.5..isAntiAlias = true);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = cfg.categories.length;
    if (n == 0 || cfg.styledSeries.isEmpty) return;
    const padL = 52.0, padR = 12.0, padT = 16.0, padB = 28.0;
    final plotW = size.width - padL - padR;
    final plotH = size.height - padT - padB;

    final allVals = cfg.styledSeries.expand((s) => s.data).toList();
    if (allVals.isEmpty) return;
    double yMin = allVals.reduce(math.min), yMax = allVals.reduce(math.max);
    final yPad = (yMax - yMin) * 0.12;
    yMin -= yPad; yMax += yPad;
    final vp = ChartViewport(left: padL, top: padT, right: padL + plotW, bottom: padT + plotH,
        dataMinX: 0, dataMaxX: (n - 1).toDouble(), dataMinY: yMin, dataMaxY: yMax);

    final ticks = ChartDataProcessor.niceYTicks(yMin, yMax);
    _yGrid(canvas, vp, ticks, this, (t) => t.toStringAsFixed(0));

    for (int si = 0; si < cfg.styledSeries.length; si++) {
      final s = cfg.styledSeries[si];
      final color = theme.seriesColor(si, explicitColor: s.color);
      final pts = List.generate(math.min(s.data.length, n), (i) {
        final animY = yMin + (s.data[i] - yMin) * progress;
        return Offset(vp.toCanvasX(i.toDouble()), vp.toCanvasY(animY));
      });
      if (pts.length < 2) continue;

      // Draw line with style
      final linePaint = Paint()..color = color..strokeWidth = s.lineStyle.width
          ..style = PaintingStyle.stroke..isAntiAlias = true..strokeCap = StrokeCap.round;
      if (s.lineStyle.type == 'dashed') {
        drawDashedLine(canvas, pts.first, pts.last, linePaint);
        for (int i = 0; i < pts.length - 1; i++) {
          drawDashedLine(canvas, pts[i], pts[i + 1], linePaint);
        }
      } else if (s.lineStyle.type == 'dotted') {
        for (int i = 0; i < pts.length - 1; i++) {
          drawDashedLine(canvas, pts[i], pts[i + 1],
              Paint()..color = color..strokeWidth = s.lineStyle.width
                ..style = PaintingStyle.stroke..isAntiAlias = true);
        }
      } else {
        canvas.drawPath(_smoothLine(pts), linePaint);
      }

      for (final p in pts) _drawItem(canvas, p, s.itemStyle, color);
    }

    for (int i = 0; i < n; i++) {
      if (i % math.max(1, (n / 8).round()) == 0 || i == n - 1) {
        final tp = textPainterCache.get(cfg.categories[i],
            theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 9));
        tp.paint(canvas, Offset(vp.toCanvasX(i.toDouble()) - tp.width / 2, padT + plotH + 4));
      }
    }
    canvas.drawLine(Offset(padL, padT + plotH), Offset(padL + plotW, padT + plotH), axisPaint);
    canvas.drawLine(Offset(padL, padT), Offset(padL, padT + plotH), axisPaint);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. LARGE SCALE AREA CHART  (LTTB downsampled for performance)
// ═══════════════════════════════════════════════════════════════════════════
class LargeScaleAreaConfig extends BaseChartConfig {
  final List<double> xData;
  final List<double> yData;
  final int targetPoints;    // LTTB target (default 500)
  final String? seriesName, seriesColor;
  final double fillOpacity;
  final ChartTheme theme;

  LargeScaleAreaConfig({
    required this.xData,
    required this.yData,
    this.targetPoints = 500,
    this.seriesName,
    this.seriesColor,
    this.fillOpacity = 0.25,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.largeScaleArea, series: const []);

  @override Widget buildChart() => _LargeScaleWidget(config: this);

  factory LargeScaleAreaConfig.fromJson(Map<String, dynamic> j) {
    final x = (j['xData'] as List? ?? []).map<double>((v) => (v as num).toDouble()).toList();
    final y = (j['yData'] as List? ?? []).map<double>((v) => (v as num).toDouble()).toList();
    return LargeScaleAreaConfig(xData: x, yData: y,
        targetPoints: (j['targetPoints'] as num?)?.toInt() ?? 500,
        seriesName: j['seriesName']?.toString(),
        seriesColor: j['seriesColor']?.toString(),
        fillOpacity: (j['fillOpacity'] as num?)?.toDouble() ?? 0.25,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'largeScaleArea'};
}

class _LargeScaleWidget extends StatefulWidget {
  final LargeScaleAreaConfig config;
  const _LargeScaleWidget({required this.config});
  @override State<_LargeScaleWidget> createState() => _LargeScaleState();
}

class _LargeScaleState extends State<_LargeScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  late List<Offset> _downsampled;
  LargeScaleAreaConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    // Pre-downsample once
    final raw = List.generate(
        math.min(cfg.xData.length, cfg.yData.length),
        (i) => Offset(cfg.xData[i], cfg.yData[i]));
    _downsampled = DataSampler.lttb(raw, cfg.targetPoints);

    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _LargeScalePainter(cfg: cfg, pts: _downsampled, progress: _anim.value),
    ))),
    Padding(padding: const EdgeInsets.only(bottom: 4),
      child: Text('${cfg.xData.length} pts → ${_downsampled.length} rendered (LTTB)',
          style: cfg.theme.typography.axisLabelStyle.copyWith(
              color: cfg.theme.axisLabelColor.withOpacity(0.5), fontSize: 8.5))),
  ]);
}

class _LargeScalePainter extends ChartPainterBase {
  final LargeScaleAreaConfig cfg;
  final List<Offset> pts;
  final double progress;
  _LargeScalePainter({required this.cfg, required this.pts, required this.progress})
      : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _LargeScalePainter o) => o.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.isEmpty) return;
    const padL = 52.0, padR = 12.0, padT = 16.0, padB = 24.0;
    final plotW = size.width - padL - padR;
    final plotH = size.height - padT - padB;

    final xMin = pts.map((p) => p.dx).reduce(math.min);
    final xMax = pts.map((p) => p.dx).reduce(math.max);
    double yMin = pts.map((p) => p.dy).reduce(math.min);
    double yMax = pts.map((p) => p.dy).reduce(math.max);
    final yPad = (yMax - yMin) * 0.1;
    yMin -= yPad; yMax += yPad;
    final vp = ChartViewport(left: padL, top: padT, right: padL + plotW, bottom: padT + plotH,
        dataMinX: xMin, dataMaxX: xMax, dataMinY: yMin, dataMaxY: yMax);

    final ticks = ChartDataProcessor.niceYTicks(yMin, yMax);
    _yGrid(canvas, vp, ticks, this, (t) => t.toStringAsFixed(1));

    Color color;
    try { color = cfg.seriesColor != null
        ? colorCache.resolve(cfg.seriesColor!) : theme.seriesColor(0); }
    catch (_) { color = theme.seriesColor(0); }

    // Clamp visible points based on progress
    final visCount = (pts.length * progress).round().clamp(1, pts.length);
    final visPts = pts.take(visCount).map((p) => vp.toCanvas(p.dx, p.dy)).toList();

    if (visPts.length < 2) return;

    final linePath = Path()..moveTo(visPts.first.dx, visPts.first.dy);
    for (int i = 1; i < visPts.length; i++) linePath.lineTo(visPts[i].dx, visPts[i].dy);

    final areaPath = Path.from(linePath)
      ..lineTo(visPts.last.dx, padT + plotH)
      ..lineTo(visPts.first.dx, padT + plotH)
      ..close();

    canvas.drawPath(areaPath,
        Paint()..color = color.withOpacity(cfg.fillOpacity)..style = PaintingStyle.fill..isAntiAlias = true);
    canvas.drawPath(linePath, paintCache.stroke(color, 1.5)..isAntiAlias = true);

    canvas.drawLine(Offset(padL, padT + plotH), Offset(padL + plotW, padT + plotH), axisPaint);
    canvas.drawLine(Offset(padL, padT), Offset(padL, padT + plotH), axisPaint);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 5. AREA CHART WITH TIME AXIS  (DateTime-based X)
// ═══════════════════════════════════════════════════════════════════════════
class TimePoint {
  final DateTime time;
  final double value;
  const TimePoint({required this.time, required this.value});
  factory TimePoint.fromJson(Map<String, dynamic> j) => TimePoint(
    time: DateTime.parse(j['time']?.toString() ?? DateTime.now().toIso8601String()),
    value: (j['value'] as num).toDouble(),
  );
}

class AreaTimeAxisConfig extends BaseChartConfig {
  final List<TimePoint> points;
  final String? seriesName, seriesColor;
  final double fillOpacity;
  final bool showLine;
  final ChartTheme theme;

  AreaTimeAxisConfig({
    required this.points,
    this.seriesName, this.seriesColor,
    this.fillOpacity = 0.3,
    this.showLine = true,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.areaTimeAxis, series: const []);

  @override Widget buildChart() => _AreaTimeWidget(config: this);

  factory AreaTimeAxisConfig.fromJson(Map<String, dynamic> j) {
    final pts = (j['points'] as List? ?? [])
        .whereType<Map<String, dynamic>>().map(TimePoint.fromJson).toList();
    return AreaTimeAxisConfig(points: pts,
        seriesName: j['seriesName']?.toString(),
        seriesColor: j['seriesColor']?.toString(),
        fillOpacity: (j['fillOpacity'] as num?)?.toDouble() ?? 0.3,
        showLine: j['showLine'] as bool? ?? true,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'areaTimeAxis'};
}

class _AreaTimeWidget extends StatefulWidget {
  final AreaTimeAxisConfig config;
  const _AreaTimeWidget({required this.config});
  @override State<_AreaTimeWidget> createState() => _AreaTimeState();
}

class _AreaTimeState extends State<_AreaTimeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  AreaTimeAxisConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _AreaTimePainter(cfg: cfg, progress: _anim.value),
    ))),
  ]);
}

class _AreaTimePainter extends ChartPainterBase {
  final AreaTimeAxisConfig cfg;
  final double progress;
  _AreaTimePainter({required this.cfg, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _AreaTimePainter o) => o.progress != progress;

  String _fmtTime(DateTime t, Duration span) {
    if (span.inDays > 365) return '${t.year}';
    if (span.inDays > 30)  return '${t.month}/${t.year.toString().substring(2)}';
    if (span.inDays > 1)   return '${t.month}/${t.day}';
    return '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (cfg.points.isEmpty) return;
    const padL = 52.0, padR = 12.0, padT = 16.0, padB = 28.0;
    final plotW = size.width - padL - padR;
    final plotH = size.height - padT - padB;

    final tMin = cfg.points.first.time.millisecondsSinceEpoch.toDouble();
    final tMax = cfg.points.last.time.millisecondsSinceEpoch.toDouble();
    final span = cfg.points.last.time.difference(cfg.points.first.time);
    double yMin = cfg.points.map((p) => p.value).reduce(math.min);
    double yMax = cfg.points.map((p) => p.value).reduce(math.max);
    final yPad = (yMax - yMin) * 0.1;
    yMin -= yPad; yMax += yPad;

    final vp = ChartViewport(left: padL, top: padT, right: padL + plotW, bottom: padT + plotH,
        dataMinX: tMin, dataMaxX: tMax, dataMinY: yMin, dataMaxY: yMax);

    final ticks = ChartDataProcessor.niceYTicks(yMin, yMax);
    _yGrid(canvas, vp, ticks, this, (t) => t.toStringAsFixed(1));

    Color color;
    try { color = cfg.seriesColor != null
        ? colorCache.resolve(cfg.seriesColor!) : theme.seriesColor(0); }
    catch (_) { color = theme.seriesColor(0); }

    final visPts = cfg.points.map((p) => Offset(
        vp.toCanvasX(p.time.millisecondsSinceEpoch.toDouble()),
        vp.toCanvasY(yMin + (p.value - yMin) * progress))).toList();

    final linePath = _smoothLine(visPts);
    final areaPath = Path.from(linePath)
      ..lineTo(visPts.last.dx, padT + plotH)
      ..lineTo(visPts.first.dx, padT + plotH)
      ..close();

    canvas.drawPath(areaPath,
        Paint()..shader = LinearGradient(
            colors: [color.withOpacity(cfg.fillOpacity), color.withOpacity(0.02)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter)
            .createShader(Rect.fromLTWH(padL, padT, plotW, plotH))
          ..style = PaintingStyle.fill..isAntiAlias = true);

    if (cfg.showLine) {
      canvas.drawPath(linePath, paintCache.stroke(color, 1.8)..isAntiAlias = true);
    }

    // Time axis ticks (auto-pick ~6 labels)
    final nLabels = 6;
    for (int i = 0; i <= nLabels; i++) {
      final t = cfg.points.first.time.add(span * i / nLabels);
      final x = vp.toCanvasX(t.millisecondsSinceEpoch.toDouble());
      final tp = textPainterCache.get(_fmtTime(t, span),
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 8.5));
      tp.paint(canvas, Offset(x - tp.width / 2, padT + plotH + 4));
    }

    canvas.drawLine(Offset(padL, padT + plotH), Offset(padL + plotW, padT + plotH), axisPaint);
    canvas.drawLine(Offset(padL, padT), Offset(padL, padT + plotH), axisPaint);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 6. POLAR LINE  (two value-axes on polar coordinates)
// ═══════════════════════════════════════════════════════════════════════════
class PolarLineChartConfig extends BaseChartConfig {
  final List<String> categories;  // angular labels
  final ChartTheme theme;

  PolarLineChartConfig({
    required this.categories,
    required List<Series> super.series,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.polarLine);

  @override Widget buildChart() => _PolarLineWidget(config: this);

  factory PolarLineChartConfig.fromJson(Map<String, dynamic> j) {
    final cats = (j['categories'] as List? ?? []).map((e) => e.toString()).toList();
    final s = (j['series'] as List? ?? [])
        .whereType<Map<String, dynamic>>().map(Series.fromJson).toList();
    return PolarLineChartConfig(categories: cats, series: s,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
        legend: j['legend'] != null ? ChartLegend.fromJson(j['legend']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'polarLine'};
}

class _PolarLineWidget extends StatefulWidget {
  final PolarLineChartConfig config;
  const _PolarLineWidget({required this.config});
  @override State<_PolarLineWidget> createState() => _PolarLineState();
}

class _PolarLineState extends State<_PolarLineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  PolarLineChartConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _PolarLinePainter(cfg: cfg, progress: _anim.value),
    ))),
    _buildLegend(),
  ]);

  Widget _buildLegend() => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Wrap(spacing: 12, alignment: WrapAlignment.center,
      children: cfg.series.asMap().entries.map((e) {
        final color = cfg.theme.seriesColor(e.key, explicitColor: e.value.color);
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 14, height: 2, color: color),
          const SizedBox(width: 4),
          Text(e.value.name ?? 'S${e.key+1}',
              style: cfg.theme.typography.legendStyle
                  .copyWith(color: cfg.theme.legendTextColor)),
        ]);
      }).toList()));
}

class _PolarLinePainter extends ChartPainterBase {
  final PolarLineChartConfig cfg;
  final double progress;
  _PolarLinePainter({required this.cfg, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _PolarLinePainter o) => o.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (cfg.categories.isEmpty || cfg.series.isEmpty) return;
    final cx = size.width / 2, cy = size.height / 2;
    final maxR = math.min(cx, cy) * 0.72;
    final n = cfg.categories.length;

    // Radial grid rings
    for (int ring = 1; ring <= 4; ring++) {
      canvas.drawCircle(Offset(cx, cy), maxR * ring / 4,
          paintCache.stroke(theme.gridColor, 0.5));
    }

    // Spokes
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / n;
      canvas.drawLine(Offset(cx, cy),
          Offset(cx + maxR * math.cos(angle), cy + maxR * math.sin(angle)),
          paintCache.stroke(theme.gridColor, 0.5));
      // Label
      final labelR = maxR + 14;
      final tp = textPainterCache.get(cfg.categories[i],
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 9));
      tp.paint(canvas, Offset(cx + labelR * math.cos(angle) - tp.width / 2,
          cy + labelR * math.sin(angle) - tp.height / 2));
    }

    // Each series = a closed polygon on the polar grid
    for (int si = 0; si < cfg.series.length; si++) {
      final s = cfg.series[si];
      final vals = (s.data ?? []).map((v) => (v as num).toDouble()).toList();
      if (vals.isEmpty) continue;
      final maxVal = vals.reduce(math.max) + 0.001;
      final color = theme.seriesColor(si, explicitColor: s.color);

      final pts = <Offset>[];
      for (int i = 0; i < n; i++) {
        final v = i < vals.length ? vals[i] : 0.0;
        final r = v / maxVal * maxR * progress;
        final angle = -math.pi / 2 + i * 2 * math.pi / n;
        pts.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
      }
      pts.add(pts.first); // close

      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
      path.close();

      canvas.drawPath(path,
          Paint()..color = color.withOpacity(0.18)..style = PaintingStyle.fill..isAntiAlias = true);
      canvas.drawPath(path, paintCache.stroke(color, 2.0)..isAntiAlias = true);

      // Dots
      for (final p in pts.take(pts.length - 1)) {
        canvas.drawCircle(p, 4, Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true);
        canvas.drawCircle(p, 4, Paint()..color = Colors.white..style = PaintingStyle.stroke
            ..strokeWidth = 1.5..isAntiAlias = true);
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 7. CUSTOMIZED PIE  (per-slice custom styles + individual explode)
// ═══════════════════════════════════════════════════════════════════════════
class CustomPieSlice {
  final String name;
  final double value;
  final String? color, borderColor;
  final double borderWidth, explode;
  final bool selected;
  const CustomPieSlice({required this.name, required this.value,
      this.color, this.borderColor, this.borderWidth = 0,
      this.explode = 0, this.selected = false});
  factory CustomPieSlice.fromJson(Map<String, dynamic> j) => CustomPieSlice(
    name: j['name']?.toString() ?? '',
    value: (j['value'] as num).toDouble(),
    color: j['color']?.toString(),
    borderColor: j['borderColor']?.toString(),
    borderWidth: (j['borderWidth'] as num?)?.toDouble() ?? 0,
    explode: (j['explode'] as num?)?.toDouble() ?? 0,
    selected: j['selected'] as bool? ?? false,
  );
}

class CustomizedPieConfig extends BaseChartConfig {
  final List<CustomPieSlice> slices;
  final double padAngle;
  final bool showLabels;
  final ChartTheme theme;

  CustomizedPieConfig({
    required this.slices,
    this.theme = ChartTheme.light,
    this.padAngle = 0.02,
    this.showLabels = true,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.customizedPie, series: const []);

  @override Widget buildChart() => _CustomPieWidget(config: this);

  factory CustomizedPieConfig.fromJson(Map<String, dynamic> j) {
    final slices = (j['slices'] as List? ??
        (j['series'] as List? ?? []).expand((s) =>
            (s is Map ? s['data'] as List? ?? [] : [])).toList())
        .whereType<Map<String, dynamic>>().map(CustomPieSlice.fromJson).toList();
    return CustomizedPieConfig(slices: slices,
        padAngle: (j['padAngle'] as num?)?.toDouble() ?? 0.02,
        showLabels: j['showLabels'] as bool? ?? true,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
        legend: j['legend'] != null ? ChartLegend.fromJson(j['legend']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'customizedPie'};
}

class _CustomPieWidget extends StatefulWidget {
  final CustomizedPieConfig config;
  const _CustomPieWidget({required this.config});
  @override State<_CustomPieWidget> createState() => _CustomPieState();
}

class _CustomPieState extends State<_CustomPieWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  CustomizedPieConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _CustomPiePainter(cfg: cfg, progress: _anim.value),
    ))),
  ]);
}

class _CustomPiePainter extends ChartPainterBase {
  final CustomizedPieConfig cfg;
  final double progress;
  _CustomPiePainter({required this.cfg, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _CustomPiePainter o) => o.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (cfg.slices.isEmpty) return;
    final cx = size.width / 2, cy = size.height / 2;
    final maxExplode = cfg.slices.map((s) => s.explode).fold(0.0, math.max);
    final r = math.min(cx, cy) * 0.75 - maxExplode;
    final total = cfg.slices.fold(0.0, (a, s) => a + s.value);
    if (total == 0) return;

    double start = -math.pi / 2;
    for (int i = 0; i < cfg.slices.length; i++) {
      final s = cfg.slices[i];
      final sweep = s.value / total * 2 * math.pi * progress;
      final midAngle = start + sweep / 2;
      final explode = s.explode + (s.selected ? 8.0 : 0.0);
      final oc = Offset(cx + explode * math.cos(midAngle),
                        cy + explode * math.sin(midAngle));

      Color fill;
      try { fill = s.color != null ? colorCache.resolve(s.color!) : theme.palette.colorObjectAt(i); }
      catch (_) { fill = theme.palette.colorObjectAt(i); }

      final path = Path()
        ..moveTo(oc.dx, oc.dy)
        ..arcTo(Rect.fromCircle(center: oc, radius: r),
            start + cfg.padAngle / 2, sweep - cfg.padAngle, false)
        ..close();

      canvas.drawPath(path,
          Paint()..color = fill..style = PaintingStyle.fill..isAntiAlias = true);

      if (s.borderWidth > 0) {
        Color bc;
        try { bc = s.borderColor != null ? colorCache.resolve(s.borderColor!) : Colors.white; }
        catch (_) { bc = Colors.white; }
        canvas.drawPath(path, paintCache.stroke(bc, s.borderWidth)..isAntiAlias = true);
      }

      if (cfg.showLabels && sweep > 0.2) {
        final lr = r * 0.65;
        final lx = oc.dx + lr * math.cos(midAngle);
        final ly = oc.dy + lr * math.sin(midAngle);
        final pct = '${(s.value / total * 100).toStringAsFixed(0)}%';
        final tp = textPainterCache.get(pct,
            theme.typography.dataLabelStyle.copyWith(
                color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700));
        tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
      }
      start += sweep;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 8. PIE LABEL ALIGN  (polyline to right-aligned labels)
// ═══════════════════════════════════════════════════════════════════════════
class PieLabelAlignConfig extends BaseChartConfig {
  final List<PieSlice2> slices;
  final double padAngle;
  final ChartTheme theme;

  PieLabelAlignConfig({
    required this.slices,
    this.theme = ChartTheme.light,
    this.padAngle = 0.02,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.pieLabelAlign, series: const []);

  @override Widget buildChart() => _PieLabelAlignWidget(config: this);

  factory PieLabelAlignConfig.fromJson(Map<String, dynamic> j) {
    final slices = (j['slices'] as List? ??
        (j['series'] as List? ?? []).expand((s) =>
            (s is Map ? s['data'] as List? ?? [] : [])).toList())
        .whereType<Map<String, dynamic>>().map(PieSlice2.fromJson).toList();
    return PieLabelAlignConfig(slices: slices,
        padAngle: (j['padAngle'] as num?)?.toDouble() ?? 0.02,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'pieLabelAlign'};
}

class PieSlice2 {
  final String name;
  final double value;
  final String? color;
  const PieSlice2({required this.name, required this.value, this.color});
  factory PieSlice2.fromJson(Map<String, dynamic> j) => PieSlice2(
    name: j['name']?.toString() ?? '',
    value: (j['value'] as num).toDouble(),
    color: j['color']?.toString(),
  );
}

class _PieLabelAlignWidget extends StatefulWidget {
  final PieLabelAlignConfig config;
  const _PieLabelAlignWidget({required this.config});
  @override State<_PieLabelAlignWidget> createState() => _PieLAState();
}

class _PieLAState extends State<_PieLabelAlignWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  PieLabelAlignConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _PieLAPainter(cfg: cfg, progress: _anim.value),
    ))),
  ]);
}

class _PieLAPainter extends ChartPainterBase {
  final PieLabelAlignConfig cfg;
  final double progress;
  _PieLAPainter({required this.cfg, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _PieLAPainter o) => o.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (cfg.slices.isEmpty) return;
    final cx = size.width / 2, cy = size.height / 2;
    final r = math.min(cx, cy) * 0.5;  // small pie, lots of label room
    final total = cfg.slices.fold(0.0, (a, s) => a + s.value);
    if (total == 0) return;

    // First pass: compute label positions
    final labelData = <({Offset anchor, Offset elbow, bool isRight, String text, Color color})>[];
    double start = -math.pi / 2;
    for (int i = 0; i < cfg.slices.length; i++) {
      final s = cfg.slices[i];
      final sweep = s.value / total * 2 * math.pi * progress;
      final mid = start + sweep / 2;
      Color color;
      try { color = s.color != null ? colorCache.resolve(s.color!) : theme.palette.colorObjectAt(i); }
      catch (_) { color = theme.palette.colorObjectAt(i); }

      final anchor = Offset(cx + r * math.cos(mid), cy + r * math.sin(mid));
      final elbow  = Offset(cx + (r + 24) * math.cos(mid), cy + (r + 24) * math.sin(mid));
      final isRight = math.cos(mid) >= 0;
      final pct = '${(s.value / total * 100).toStringAsFixed(1)}%';
      labelData.add((anchor: anchor, elbow: elbow, isRight: isRight,
          text: '${s.name}  $pct', color: color));

      // Draw slice
      final path = Path()
        ..moveTo(cx, cy)
        ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: r),
            start + cfg.padAngle / 2, sweep - cfg.padAngle, false)
        ..close();
      canvas.drawPath(path,
          Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true);
      start += sweep;
    }

    // Align labels: left labels sorted top→bottom on left edge, right on right
    const edgeX = 12.0, elbowEndX = 16.0;
    final rightLabels = labelData.where((l) => l.isRight).toList()
      ..sort((a, b) => a.elbow.dy.compareTo(b.elbow.dy));
    final leftLabels  = labelData.where((l) => !l.isRight).toList()
      ..sort((a, b) => a.elbow.dy.compareTo(b.elbow.dy));

    void drawLabel(({Offset anchor, Offset elbow, bool isRight, String text, Color color}) ld, double alignedY) {
      final tp = textPainterCache.get(ld.text,
          theme.typography.axisLabelStyle.copyWith(color: ld.color, fontSize: 9.5));
      final endX = ld.isRight ? size.width - edgeX - tp.width : edgeX;
      final p3 = Offset(ld.isRight ? endX + tp.width : endX, alignedY);
      // Polyline: arc edge → elbow → horizontal to edge
      canvas.drawLine(ld.anchor, ld.elbow, paintCache.stroke(ld.color, 1.0));
      canvas.drawLine(ld.elbow, p3, paintCache.stroke(ld.color, 1.0));
      canvas.drawLine(p3, Offset(p3.dx + (ld.isRight ? elbowEndX : -elbowEndX), p3.dy),
          paintCache.stroke(ld.color, 1.0));
      tp.paint(canvas, Offset(endX, alignedY - tp.height / 2));
    }

    for (int i = 0; i < rightLabels.length; i++) {
      final spacing = math.max(14.0, (size.height - 32) / math.max(rightLabels.length, 1));
      drawLabel(rightLabels[i], 16 + i * spacing);
    }
    for (int i = 0; i < leftLabels.length; i++) {
      final spacing = math.max(14.0, (size.height - 32) / math.max(leftLabels.length, 1));
      drawLabel(leftLabels[i], 16 + i * spacing);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 9. PIE SPECIAL LABEL  (custom rich label per slice rendered with Flutter)
// ═══════════════════════════════════════════════════════════════════════════
class SpecialLabelSlice {
  final String name;
  final double value;
  final String? color;
  final String? emoji;      // optional emoji/icon shown in label
  final String? subLabel;   // secondary line in label
  const SpecialLabelSlice({required this.name, required this.value,
      this.color, this.emoji, this.subLabel});
  factory SpecialLabelSlice.fromJson(Map<String, dynamic> j) => SpecialLabelSlice(
    name: j['name']?.toString() ?? '',
    value: (j['value'] as num).toDouble(),
    color: j['color']?.toString(),
    emoji: j['emoji']?.toString(),
    subLabel: j['subLabel']?.toString(),
  );
}

class PieSpecialLabelConfig extends BaseChartConfig {
  final List<SpecialLabelSlice> slices;
  final double innerRadiusRatio;
  final double padAngle;
  final ChartTheme theme;

  PieSpecialLabelConfig({
    required this.slices,
    this.theme = ChartTheme.light,
    this.innerRadiusRatio = 0.45,
    this.padAngle = 0.03,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.pieSpecialLabel, series: const []);

  @override Widget buildChart() => _PieSpecialWidget(config: this);

  factory PieSpecialLabelConfig.fromJson(Map<String, dynamic> j) {
    final slices = (j['slices'] as List? ??
        (j['series'] as List? ?? []).expand((s) =>
            (s is Map ? s['data'] as List? ?? [] : [])).toList())
        .whereType<Map<String, dynamic>>().map(SpecialLabelSlice.fromJson).toList();
    return PieSpecialLabelConfig(slices: slices,
        innerRadiusRatio: (j['innerRadiusRatio'] as num?)?.toDouble() ?? 0.45,
        padAngle: (j['padAngle'] as num?)?.toDouble() ?? 0.03,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'pieSpecialLabel'};
}

class _PieSpecialWidget extends StatefulWidget {
  final PieSpecialLabelConfig config;
  const _PieSpecialWidget({required this.config});
  @override State<_PieSpecialWidget> createState() => _PieSpecialState();
}

class _PieSpecialState extends State<_PieSpecialWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  PieSpecialLabelConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (cfg.title?.text != null)
        Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
              .copyWith(color: cfg.theme.titleColor))),
      Expanded(child: LayoutBuilder(builder: (ctx, con) {
        final size = Size(con.maxWidth, con.maxHeight);
        final cx = size.width / 2, cy = size.height / 2;
        final r = math.min(cx, cy) * 0.55;
        final innerR = r * cfg.innerRadiusRatio;
        final total = cfg.slices.fold(0.0, (a, s) => a + s.value);

        // Build label overlays
        final labels = <Widget>[];
        if (_anim.value > 0.6) {
          double start = -math.pi / 2;
          for (int i = 0; i < cfg.slices.length; i++) {
            final s = cfg.slices[i];
            final sweep = total > 0 ? s.value / total * 2 * math.pi * _anim.value : 0;
            final mid = start + sweep / 2;
            Color color;
            try { color = s.color != null ? colorCache.resolve(s.color!) : cfg.theme.palette.colorObjectAt(i); }
            catch (_) { color = cfg.theme.palette.colorObjectAt(i); }
            final lr = (r + innerR) / 2;
            final lx = cx + lr * math.cos(mid);
            final ly = cy + lr * math.sin(mid);
            if (sweep > 0.25) {
              labels.add(Positioned(
                left: lx - 30, top: ly - 24, width: 60, height: 48,
                child: Opacity(opacity: ((_anim.value - 0.6) / 0.4).clamp(0, 1),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (s.emoji != null) Text(s.emoji!, style: const TextStyle(fontSize: 14)),
                    Text('${(s.value / total * 100).toStringAsFixed(0)}%',
                        textAlign: TextAlign.center,
                        style: cfg.theme.typography.dataLabelStyle.copyWith(
                            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    if (s.subLabel != null) Text(s.subLabel!,
                        textAlign: TextAlign.center,
                        style: cfg.theme.typography.axisLabelStyle.copyWith(
                            color: Colors.white70, fontSize: 8)),
                  ]),
                ),
              ));
            }
            start += sweep;
          }
        }

        return Stack(children: [
          RepaintBoundary(child: CustomPaint(
            size: Size.infinite,
            painter: _PieSpecialPainter(cfg: cfg, progress: _anim.value),
          )),
          ...labels,
        ]);
      })),
      // Bottom legend
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Wrap(spacing: 10, runSpacing: 4, alignment: WrapAlignment.center,
          children: cfg.slices.asMap().entries.map((e) {
            Color color;
            try { color = e.value.color != null
                ? colorCache.resolve(e.value.color!) : cfg.theme.palette.colorObjectAt(e.key); }
            catch (_) { color = cfg.theme.palette.colorObjectAt(e.key); }
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(e.value.name, style: cfg.theme.typography.legendStyle
                  .copyWith(color: cfg.theme.legendTextColor)),
            ]);
          }).toList()),
      ),
    ]);
  }
}

class _PieSpecialPainter extends ChartPainterBase {
  final PieSpecialLabelConfig cfg;
  final double progress;
  _PieSpecialPainter({required this.cfg, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _PieSpecialPainter o) => o.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (cfg.slices.isEmpty) return;
    final cx = size.width / 2, cy = size.height / 2;
    final r = math.min(cx, cy) * 0.55;
    final innerR = r * cfg.innerRadiusRatio;
    final total = cfg.slices.fold(0.0, (a, s) => a + s.value);
    if (total == 0) return;

    double start = -math.pi / 2;
    for (int i = 0; i < cfg.slices.length; i++) {
      final s = cfg.slices[i];
      final sweep = s.value / total * 2 * math.pi * progress;
      Color color;
      try { color = s.color != null ? colorCache.resolve(s.color!) : theme.palette.colorObjectAt(i); }
      catch (_) { color = theme.palette.colorObjectAt(i); }

      final path = Path()
        ..moveTo(cx + innerR * math.cos(start + cfg.padAngle / 2),
                 cy + innerR * math.sin(start + cfg.padAngle / 2))
        ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: r),
            start + cfg.padAngle / 2, sweep - cfg.padAngle, false)
        ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: innerR),
            start + sweep - cfg.padAngle / 2, -(sweep - cfg.padAngle), false)
        ..close();

      canvas.drawPath(path,
          Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true);
      canvas.drawPath(path,
          Paint()..color = theme.backgroundColor..style = PaintingStyle.stroke
            ..strokeWidth = 1.0..isAntiAlias = true);
      start += sweep;
    }
  }
}

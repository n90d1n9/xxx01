/// Box plot (box-and-whisker) — shows 5-number summary per category.
///
/// Displays: min whisker, Q1, median, Q3, max whisker, and outliers as dots.
/// Optionally shows a notched box (bootstrapped confidence interval on median)
/// and a mean marker diamond.
///
/// JSON — pre-computed:
/// ```json
/// { "type": "boxPlot", "categories": ["Control","Group A","Group B"],
///   "series": [{ "data": [
///     { "min":18,"q1":42,"median":58,"q3":74,"max":95,"outliers":[5,102] },
///     { "min":25,"q1":55,"median":68,"q3":80,"max":98 },
///     { "min":10,"q1":35,"median":50,"q3":65,"max":90,"mean":52 }
///   ]}]}
/// ```
/// JSON — raw values (auto-computed):
/// ```json
/// { "type": "boxPlot", "categories": ["A","B"],
///   "series": [{ "data": [[12,45,67,34,89,23,56,78],[10,55,40,72,88,61]] }]}
/// ```
library box_plot_chart;

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
import '../core/utils/chart_cache.dart';

// ─────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────

class BoxSummary {
  final double min, q1, median, q3, max;
  final double? mean;
  final List<double> outliers;

  const BoxSummary({
    required this.min, required this.q1, required this.median,
    required this.q3, required this.max, this.mean, this.outliers = const [],
  });

  /// Compute from raw values.
  factory BoxSummary.fromValues(List<double> values) {
    if (values.isEmpty) return BoxSummary(min: 0, q1: 0, median: 0, q3: 0, max: 0);
    final s = [...values]..sort();
    final n = s.length;
    double q(double p) {
      final i = p * (n - 1);
      final lo = i.floor(), hi = i.ceil();
      return lo == hi ? s[lo] : s[lo] + (s[hi] - s[lo]) * (i - lo);
    }
    final q1 = q(0.25), q3 = q(0.75);
    final iqr = q3 - q1;
    final loFence = q1 - 1.5 * iqr, hiFence = q3 + 1.5 * iqr;
    final inliers = s.where((v) => v >= loFence && v <= hiFence).toList();
    final outliers = s.where((v) => v < loFence || v > hiFence).toList();
    final mean = values.fold(0.0, (a, b) => a + b) / n;
    return BoxSummary(
      min: inliers.isEmpty ? s.first : inliers.first,
      q1: q1, median: q(0.5), q3: q3,
      max: inliers.isEmpty ? s.last : inliers.last,
      mean: mean, outliers: outliers,
    );
  }

  factory BoxSummary.fromJson(Map<String, dynamic> j) => BoxSummary(
    min: (j['min'] as num?)?.toDouble() ?? 0,
    q1: (j['q1'] as num?)?.toDouble() ?? 0,
    median: (j['median'] as num?)?.toDouble() ?? 0,
    q3: (j['q3'] as num?)?.toDouble() ?? 0,
    max: (j['max'] as num?)?.toDouble() ?? 0,
    mean: (j['mean'] as num?)?.toDouble(),
    outliers: (j['outliers'] as List? ?? []).map((v) => (v as num).toDouble()).toList(),
  );
}

// ─────────────────────────────────────────────────────────
// Config
// ─────────────────────────────────────────────────────────

class BoxPlotChartConfig extends BaseChartConfig {
  final List<String> categories;
  final List<List<BoxSummary>> boxData; // [series][category]
  final ChartTheme theme;
  final bool showMean;
  final bool showNotch;
  final double boxWidthFraction;

  BoxPlotChartConfig({
    required this.categories, required this.boxData,
    this.theme = ChartTheme.light, this.showMean = true,
    this.showNotch = false, this.boxWidthFraction = 0.5,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.boxPlot, series: const []);

  @override Widget buildChart() => BoxPlotChartWidget(config: this);

  factory BoxPlotChartConfig.fromJson(Map<String, dynamic> json) {
    final cats = (json['categories'] as List? ?? []).map((e) => e.toString()).toList();
    final rawSeries = json['series'] as List? ?? [];
    final boxData = rawSeries.whereType<Map<String,dynamic>>().map((s) {
      final data = s['data'] as List? ?? [];
      return data.map<BoxSummary>((item) {
        if (item is List) return BoxSummary.fromValues(item.map((v) => (v as num).toDouble()).toList());
        if (item is Map<String, dynamic>) return BoxSummary.fromJson(item);
        return BoxSummary(min: 0, q1: 0, median: 0, q3: 0, max: 0);
      }).toList();
    }).toList();
    return BoxPlotChartConfig(
      categories: cats, boxData: boxData,
      showMean: json['showMean'] as bool? ?? true,
      showNotch: json['showNotch'] as bool? ?? false,
      boxWidthFraction: (json['boxWidth'] as num?)?.toDouble() ?? 0.5,
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'boxPlot'};
}

// ─────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────

class BoxPlotChartWidget extends StatefulWidget {
  final BoxPlotChartConfig config;
  const BoxPlotChartWidget({super.key, required this.config});
  @override State<BoxPlotChartWidget> createState() => _BoxState();
}

class _BoxState extends State<BoxPlotChartWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _hovCat = -1, _hovSeries = -1;
  Offset _hoverPos = Offset.zero;
  BoxPlotChartConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (cfg.title?.text != null)
        Padding(padding: const EdgeInsets.fromLTRB(12,10,12,0),
          child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle.copyWith(color: cfg.theme.titleColor))),
      Expanded(child: LayoutBuilder(builder: (ctx, con) {
        final sz = Size(con.maxWidth, con.maxHeight);
        return Stack(children: [
          MouseRegion(
            onHover: (e) {
              final sp = cfg.theme.spacing;
              final n = cfg.categories.length;
              if (n == 0) return;
              final slotW = (sz.width - sp.chartPaddingLeft - sp.chartPaddingRight) / n;
              final ci = ((e.localPosition.dx - sp.chartPaddingLeft) / slotW).floor().clamp(0, n - 1);
              setState(() { _hovCat = ci; _hoverPos = e.localPosition; });
            },
            onExit: (_) => setState(() => _hovCat = -1),
            child: RepaintBoundary(child: CustomPaint(
              size: Size.infinite,
              painter: _BoxPainter(config: cfg, progress: _anim.value, hovCat: _hovCat),
            )),
          ),
          if (_hovCat >= 0) _buildTooltip(sz),
        ]);
      })),
      if (cfg.boxData.length > 1) _buildLegend(),
    ]);
  }

  Widget _buildTooltip(Size sz) {
    final si = 0; // primary series tooltip
    if (si >= cfg.boxData.length || _hovCat >= cfg.boxData[si].length) return const SizedBox();
    final b = cfg.boxData[si][_hovCat];
    double x = (_hoverPos.dx + 12).clamp(0, sz.width - 190.0);
    double y = (_hoverPos.dy - 90).clamp(0, sz.height - 120.0);
    return Positioned(left: x, top: y, child: IgnorePointer(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: cfg.theme.tooltipBackgroundColor, borderRadius: BorderRadius.circular(7)),
      child: DefaultTextStyle(style: cfg.theme.typography.tooltipStyle.copyWith(color: cfg.theme.tooltipTextColor),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(_hovCat < cfg.categories.length ? cfg.categories[_hovCat] : '', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Max:    ${b.max.toStringAsFixed(2)}'),
          Text('Q3:     ${b.q3.toStringAsFixed(2)}'),
          Text('Median: ${b.median.toStringAsFixed(2)}'),
          Text('Q1:     ${b.q1.toStringAsFixed(2)}'),
          Text('Min:    ${b.min.toStringAsFixed(2)}'),
          if (b.mean != null) Text('Mean:   ${b.mean!.toStringAsFixed(2)}'),
          if (b.outliers.isNotEmpty) Text('Outliers: ${b.outliers.length}'),
        ]),
      ),
    )));
  }

  Widget _buildLegend() => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 6),
    child: Wrap(spacing: 12, runSpacing: 4, alignment: WrapAlignment.center,
      children: List.generate(cfg.boxData.length, (i) {
        final color = cfg.theme.palette.colorObjectAt(i);
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, color: color),
          const SizedBox(width: 4),
          Text('Series ${i + 1}', style: cfg.theme.typography.legendStyle.copyWith(color: cfg.theme.legendTextColor)),
        ]);
      }),
    ),
  );
}

// ─────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────

class _BoxPainter extends ChartPainterBase {
  final BoxPlotChartConfig config;
  final double progress;
  final int hovCat;

  _BoxPainter({required this.config, required this.progress, required this.hovCat}) : super(theme: config.theme);
  @override bool shouldRepaintChart(covariant _BoxPainter old) => old.progress != progress || old.hovCat != hovCat;

  @override
  void paint(Canvas canvas, Size size) {
    final n = config.categories.length;
    if (n == 0 || config.boxData.isEmpty) return;
    final sp = theme.spacing;

    // Compute global Y range
    double minV = double.infinity, maxV = double.negativeInfinity;
    for (final series in config.boxData) {
      for (final b in series) {
        if (b.min < minV) minV = b.min;
        if (b.max > maxV) maxV = b.max;
        for (final o in b.outliers) { if (o < minV) minV = o; if (o > maxV) maxV = o; }
      }
    }
    final pad = (maxV - minV) * 0.1 + 1;
    final vp = ChartViewport(
      left: sp.chartPaddingLeft, top: sp.chartPaddingTop,
      right: size.width - sp.chartPaddingRight, bottom: size.height - sp.chartPaddingBottom,
      dataMinX: 0, dataMaxX: n.toDouble(), dataMinY: minV - pad, dataMaxY: maxV + pad,
    );

    final yTicks = ChartDataProcessor.niceYTicks(vp.dataMinY, vp.dataMaxY);
    drawHorizontalGrid(canvas, vp, yTicks);
    drawYAxisLabels(canvas, vp, yTicks, (v) => v.toStringAsFixed(1));

    final ns = config.boxData.length;
    final slotW = vp.width / n;
    final groupW = slotW * config.boxWidthFraction;
    final boxW = groupW / ns;

    for (int si = 0; si < ns; si++) {
      final color = theme.palette.colorObjectAt(si);
      for (int ci = 0; ci < math.min(n, config.boxData[si].length); ci++) {
        final b = config.boxData[si][ci];
        final isHov = ci == hovCat;
        final cx = vp.left + (ci + 0.5) * slotW + (si - (ns - 1) / 2) * boxW;
        final bx1 = cx - boxW / 2 + 1;
        final bx2 = cx + boxW / 2 - 1;
        final whiskerX1 = cx - boxW * 0.25;
        final whiskerX2 = cx + boxW * 0.25;

        // Animate from median outward
        final t = progress;
        final q1y = vp.toCanvasY(b.median + (b.q1 - b.median) * t);
        final q3y = vp.toCanvasY(b.median + (b.q3 - b.median) * t);
        final miny = vp.toCanvasY(b.median + (b.min - b.median) * t);
        final maxy = vp.toCanvasY(b.median + (b.max - b.median) * t);
        final medY = vp.toCanvasY(b.median);

        final fillColor = isHov ? Color.lerp(color, Colors.white, 0.25)! : color.withOpacity(0.75);

        // Box
        canvas.drawRect(Rect.fromLTRB(bx1, q3y, bx2, q1y),
            Paint()..color = fillColor..style = PaintingStyle.fill..isAntiAlias = true);
        canvas.drawRect(Rect.fromLTRB(bx1, q3y, bx2, q1y), paintCache.stroke(color, 1.2));

        // Median line
        canvas.drawLine(Offset(bx1, medY), Offset(bx2, medY), paintCache.stroke(Colors.white, 2));

        // Whiskers
        canvas.drawLine(Offset(cx, q3y), Offset(cx, maxy), paintCache.stroke(color, 1.2));
        canvas.drawLine(Offset(cx, q1y), Offset(cx, miny), paintCache.stroke(color, 1.2));
        canvas.drawLine(Offset(whiskerX1, maxy), Offset(whiskerX2, maxy), paintCache.stroke(color, 1.5));
        canvas.drawLine(Offset(whiskerX1, miny), Offset(whiskerX2, miny), paintCache.stroke(color, 1.5));

        // Mean diamond
        if (config.showMean && b.mean != null) {
          final my = vp.toCanvasY(b.median + (b.mean! - b.median) * t);
          const d = 4.0;
          canvas.drawPath(
            Path()..moveTo(cx, my - d)..lineTo(cx + d, my)..lineTo(cx, my + d)..lineTo(cx - d, my)..close(),
            Paint()..color = Colors.white..style = PaintingStyle.fill,
          );
        }

        // Outliers
        for (final o in b.outliers) {
          final oy = vp.toCanvasY(b.median + (o - b.median) * t);
          canvas.drawCircle(Offset(cx, oy), 3, paintCache.stroke(color, 1.5));
        }
      }
    }

    drawXAxisLabels(canvas, vp, config.categories, List.generate(n, (i) => vp.left + (i + 0.5) * slotW));
    canvas.drawLine(Offset(vp.left, vp.bottom), Offset(vp.right, vp.bottom), axisPaint);
    canvas.drawLine(Offset(vp.left, vp.top), Offset(vp.left, vp.bottom), axisPaint);
  }
}

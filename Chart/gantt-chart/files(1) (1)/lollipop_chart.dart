/// Lollipop chart — dot at value with a thin stem to the baseline.
/// Cleaner than a bar chart for sparse or widely-spread comparisons.
/// Supports horizontal and vertical orientation, multiple series (grouped),
/// and target-line marker per item.
///
/// JSON:
/// ```json
/// {
///   "type": "lollipop",
///   "categories": ["Mon","Tue","Wed","Thu","Fri"],
///   "horizontal": false,
///   "series": [
///     { "name": "Actual", "data": [42, 67, 55, 80, 73] },
///     { "name": "Target", "data": [60, 60, 60, 60, 60], "markerOnly": true }
///   ]
/// }
/// ```
library lollipop_chart;

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

class LollipopChartConfig extends BaseChartConfig {
  final List<String> categories;
  final bool horizontal;
  final double dotRadius;
  final double stemWidth;
  final ChartTheme theme;

  LollipopChartConfig({
    required this.categories,
    required List<Series> super.series,
    this.theme = ChartTheme.light,
    this.horizontal = false,
    this.dotRadius = 7,
    this.stemWidth = 2,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.lollipop);

  @override
  Widget buildChart() => LollipopChartWidget(config: this);

  factory LollipopChartConfig.fromJson(Map<String, dynamic> json) {
    final cats = (json['categories'] as List? ?? []).map((e) => e.toString()).toList();
    final seriesList = (json['series'] as List? ?? []).whereType<Map<String, dynamic>>().map(Series.fromJson).toList();
    return LollipopChartConfig(
      categories: cats, series: seriesList,
      horizontal: json['horizontal'] as bool? ?? false,
      dotRadius: (json['dotRadius'] as num?)?.toDouble() ?? 7,
      stemWidth: (json['stemWidth'] as num?)?.toDouble() ?? 2,
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'lollipop'};
}

class LollipopChartWidget extends StatefulWidget {
  final LollipopChartConfig config;
  const LollipopChartWidget({super.key, required this.config});
  @override State<LollipopChartWidget> createState() => _LollipopState();
}

class _LollipopState extends State<LollipopChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _hovIdx = -1;
  Offset _hoverPos = Offset.zero;

  LollipopChartConfig get cfg => widget.config;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
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
            onHover: (e) => setState(() { _hovIdx = _hitTest(e.localPosition, sz); _hoverPos = e.localPosition; }),
            onExit: (_) => setState(() => _hovIdx = -1),
            child: RepaintBoundary(child: CustomPaint(
              size: Size.infinite,
              painter: _LollipopPainter(config: cfg, progress: _anim.value, hovIdx: _hovIdx),
            )),
          ),
          if (_hovIdx >= 0) _buildTooltip(sz),
        ]);
      })),
      if (cfg.series.length > 1) _buildLegend(),
    ]);
  }

  int _hitTest(Offset pos, Size sz) {
    final sp = cfg.theme.spacing;
    final n = cfg.categories.length;
    if (n == 0) return -1;
    if (cfg.horizontal) {
      final slotH = (sz.height - sp.chartPaddingTop - sp.chartPaddingBottom) / n;
      final idx = ((pos.dy - sp.chartPaddingTop) / slotH).floor();
      return idx.clamp(0, n-1);
    } else {
      final slotW = (sz.width - sp.chartPaddingLeft - sp.chartPaddingRight) / n;
      final idx = ((pos.dx - sp.chartPaddingLeft) / slotW).floor();
      return idx.clamp(0, n-1);
    }
  }

  Widget _buildTooltip(Size sz) {
    final cat = _hovIdx < cfg.categories.length ? cfg.categories[_hovIdx] : '';
    double x = (_hoverPos.dx + 12).clamp(0, sz.width - 180.0);
    double y = (_hoverPos.dy - 55).clamp(0, sz.height - 90.0);
    return Positioned(left: x, top: y, child: IgnorePointer(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: cfg.theme.tooltipBackgroundColor, borderRadius: BorderRadius.circular(7)),
      child: DefaultTextStyle(style: cfg.theme.typography.tooltipStyle.copyWith(color: cfg.theme.tooltipTextColor),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
          ...cfg.series.asMap().entries.map((e) {
            final data = e.value.data ?? [];
            final v = _hovIdx < data.length ? (data[_hovIdx] as num?)?.toDouble() ?? 0 : 0.0;
            return Text('${e.value.name ?? "S${e.key+1}"}: ${v.toStringAsFixed(1)}');
          }),
        ]),
      ),
    )));
  }

  Widget _buildLegend() => Padding(
    padding: const EdgeInsets.only(top:4, bottom:6),
    child: Wrap(spacing: 12, runSpacing:4, alignment: WrapAlignment.center,
      children: cfg.series.asMap().entries.map((e) {
        final color = cfg.theme.seriesColor(e.key, explicitColor: e.value.itemStyle?.color);
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width:10, height:10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width:4),
          Text(e.value.name ?? 'S${e.key+1}',
            style: cfg.theme.typography.legendStyle.copyWith(color: cfg.theme.legendTextColor)),
        ]);
      }).toList()),
  );
}

class _LollipopPainter extends ChartPainterBase {
  final LollipopChartConfig config;
  final double progress;
  final int hovIdx;

  _LollipopPainter({required this.config, required this.progress, required this.hovIdx})
      : super(theme: config.theme);

  @override bool shouldRepaintChart(covariant _LollipopPainter old) =>
      old.progress != progress || old.hovIdx != hovIdx;

  @override
  void paint(Canvas canvas, Size size) {
    final n = config.categories.length;
    if (n == 0 || config.series.isEmpty) return;
    final sp = theme.spacing;

    double maxVal = 0;
    for (final s in config.series) {
      for (final v in s.data ?? []) {
        final d = (v as num?)?.toDouble() ?? 0;
        if (d > maxVal) maxVal = d;
      }
    }
    maxVal = maxVal == 0 ? 100 : maxVal;

    final vp = ChartViewport(
      left: sp.chartPaddingLeft, top: sp.chartPaddingTop,
      right: size.width - sp.chartPaddingRight, bottom: size.height - sp.chartPaddingBottom,
      dataMinX: 0, dataMaxX: n.toDouble(), dataMinY: 0, dataMaxY: maxVal * 1.15,
    );

    final yTicks = ChartDataProcessor.niceYTicks(0, maxVal);
    drawHorizontalGrid(canvas, vp, yTicks);
    drawYAxisLabels(canvas, vp, yTicks, (v) => v.toStringAsFixed(0));

    final ns = config.series.length;
    final slotW = vp.width / n;
    final groupW = slotW * 0.7;

    for (int si = 0; si < config.series.length; si++) {
      final s = config.series[si];
      final color = theme.seriesColor(si, explicitColor: s.itemStyle?.color);
      final data = s.data ?? [];

      for (int i = 0; i < n; i++) {
        final v = i < data.length ? (data[i] as num?)?.toDouble() ?? 0 : 0.0;
        final isHov = i == hovIdx;
        final r = isHov ? config.dotRadius + 2 : config.dotRadius;

        if (config.horizontal) {
          final cy = vp.top + (i + 0.5) * (vp.height / n);
          final cx = vp.left + (v / maxVal) * vp.width * progress;
          canvas.drawLine(Offset(vp.left, cy), Offset(cx, cy),
              paintCache.stroke(color.withOpacity(0.4), config.stemWidth));
          canvas.drawCircle(Offset(cx, cy), r, Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true);
          canvas.drawCircle(Offset(cx, cy), r, paintCache.stroke(Colors.white, 1.5));
        } else {
          // Offset multiple series
          final cx = vp.left + (i + 0.5) * slotW + (si - (ns - 1) / 2) * (groupW / ns);
          final cy = vp.toCanvasY(v * progress);
          canvas.drawLine(Offset(cx, vp.bottom), Offset(cx, cy),
              paintCache.stroke(color.withOpacity(0.4), config.stemWidth));
          canvas.drawCircle(Offset(cx, cy), r, Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true);
          canvas.drawCircle(Offset(cx, cy), r, paintCache.stroke(Colors.white, 1.5));
        }
      }
    }

    if (config.horizontal) {
      drawYAxisLabels(canvas, vp, yTicks, (v) => v.toStringAsFixed(0));
      // row labels on left
      final labelStyle = theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor);
      for (int i = 0; i < n; i++) {
        final cy = vp.top + (i + 0.5) * (vp.height / n);
        final tp = textPainterCache.get(config.categories[i], labelStyle, maxWidth: sp.chartPaddingLeft - 4, align: TextAlign.right);
        tp.paint(canvas, Offset(vp.left - tp.width - 4, cy - tp.height / 2));
      }
    } else {
      drawXAxisLabels(canvas, vp, config.categories, List.generate(n, (i) => vp.left + (i + 0.5) * slotW));
    }

    canvas.drawLine(Offset(vp.left, vp.bottom), Offset(vp.right, vp.bottom), axisPaint);
    canvas.drawLine(Offset(vp.left, vp.top), Offset(vp.left, vp.bottom), axisPaint);
  }
}

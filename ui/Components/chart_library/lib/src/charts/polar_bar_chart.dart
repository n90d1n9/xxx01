/// Polar bar chart — circular bar chart where each category is a radial slice.
///
/// Also known as a "nightingale rose" or "coxcomb" chart.
/// Bar length is proportional to value. Multiple series stack radially.
///
/// JSON:
/// ```json
/// {
///   "type": "polarBar",
///   "categories": ["Jan","Feb","Mar","Apr","May","Jun"],
///   "series": [
///     { "name": "Revenue", "data": [120, 200, 150, 80, 170, 110] },
///     { "name": "Costs",   "data": [60,  90,  70, 50, 80,  55] }
///   ]
/// }
/// ```
library polar_bar_chart;

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

// ─────────────────────────────────────────────────────────
// Config
// ─────────────────────────────────────────────────────────

class PolarBarChartConfig extends BaseChartConfig {
  final List<String> categories;
  final ChartTheme theme;
  final bool showLabels;
  final bool stacked;
  final double innerRadiusFraction;
  final double startAngleDeg;

  PolarBarChartConfig({
    required this.categories,
    required List<Series> super.series,
    this.theme = ChartTheme.light,
    this.showLabels = true,
    this.stacked = false,
    this.innerRadiusFraction = 0.2,
    this.startAngleDeg = -90,
  }) : super(type: ChartType.polarBar);

  @override
  Widget buildChart() => PolarBarChartWidget(config: this);

  factory PolarBarChartConfig.fromJson(Map<String, dynamic> json) {
    final cats = (json['categories'] as List? ?? []).map((e) => e.toString()).toList();
    final seriesList = (json['series'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Series.fromJson)
        .toList();
    return PolarBarChartConfig(
      categories: cats,
      series: seriesList,
      showLabels: json['showLabels'] as bool? ?? true,
      stacked: json['stacked'] as bool? ?? false,
      innerRadiusFraction: (json['innerRadius'] as num?)?.toDouble() ?? 0.2,
      startAngleDeg: (json['startAngle'] as num?)?.toDouble() ?? -90,
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'polarBar'};
}

// ─────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────

class PolarBarChartWidget extends StatefulWidget {
  final PolarBarChartConfig config;
  const PolarBarChartWidget({super.key, required this.config});

  @override
  State<PolarBarChartWidget> createState() => _PolarBarState();
}

class _PolarBarState extends State<PolarBarChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _hovCat = -1;
  Offset _hoverPos = Offset.zero;

  PolarBarChartConfig get cfg => widget.config;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  int _hitTest(Offset pos, Size sz) {
    final cx = sz.width / 2, cy = sz.height / 2;
    final dx = pos.dx - cx, dy = pos.dy - cy;
    final r = math.sqrt(dx * dx + dy * dy);
    final angle = math.atan2(dy, dx);
    final n = cfg.categories.length;
    if (n == 0) return -1;
    final sliceAngle = 2 * math.pi / n;
    final startRad = cfg.startAngleDeg * math.pi / 180;
    final maxR = math.min(cx, cy) * 0.82;
    final innerR = maxR * cfg.innerRadiusFraction;
    if (r < innerR || r > maxR + 4) return -1;
    // Normalize angle
    double a = angle - startRad;
    while (a < 0) a += math.pi * 2;
    while (a >= math.pi * 2) a -= math.pi * 2;
    return (a / sliceAngle).floor().clamp(0, n - 1);
  }

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
        child: LayoutBuilder(builder: (ctx, con) {
          final sz = Size(con.maxWidth, con.maxHeight);
          return Stack(children: [
            MouseRegion(
              onHover: (e) => setState(() {
                _hovCat = _hitTest(e.localPosition, sz);
                _hoverPos = e.localPosition;
              }),
              onExit: (_) => setState(() => _hovCat = -1),
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _PolarBarPainter(
                    config: cfg,
                    progress: _anim.value,
                    hovCat: _hovCat,
                  ),
                ),
              ),
            ),
            if (_hovCat >= 0) _buildTooltip(sz),
          ]);
        }),
      ),
      if (cfg.legend?.show != false && cfg.series.length > 1) _buildLegend(),
    ]);
  }

  Widget _buildTooltip(Size sz) {
    final cat = cfg.categories[_hovCat];
    double x = (_hoverPos.dx + 14).clamp(0, sz.width - 180.0);
    double y = (_hoverPos.dy - 60).clamp(0, sz.height - 100.0);
    return Positioned(
      left: x, top: y,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
              color: cfg.theme.tooltipBackgroundColor,
              borderRadius: BorderRadius.circular(7)),
          child: DefaultTextStyle(
            style: cfg.theme.typography.tooltipStyle.copyWith(color: cfg.theme.tooltipTextColor),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
              ...cfg.series.asMap().entries.map((e) {
                final val = _hovCat < (e.value.data?.length ?? 0)
                    ? e.value.data![_hovCat]
                    : '-';
                return Text('${e.value.name ?? "Series ${e.key + 1}"}: $val');
              }),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 2),
      child: Wrap(
        spacing: 14, runSpacing: 4,
        alignment: WrapAlignment.center,
        children: cfg.series.asMap().entries.map((e) {
          final color = cfg.theme.seriesColor(e.key, explicitColor: e.value.itemStyle?.color);
          return Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10, color: color),
            const SizedBox(width: 4),
            Text(e.value.name ?? 'Series ${e.key + 1}',
                style: cfg.theme.typography.legendStyle.copyWith(color: cfg.theme.legendTextColor)),
          ]);
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────

class _PolarBarPainter extends ChartPainterBase {
  final PolarBarChartConfig config;
  final double progress;
  final int hovCat;

  _PolarBarPainter({
    required this.config,
    required this.progress,
    required this.hovCat,
  }) : super(theme: config.theme);

  @override
  bool shouldRepaintChart(covariant _PolarBarPainter old) =>
      old.progress != progress || old.hovCat != hovCat;

  @override
  void paint(Canvas canvas, Size size) {
    final n = config.categories.length;
    if (n == 0 || config.series.isEmpty) return;

    final cx = size.width / 2, cy = size.height / 2;
    final maxR = math.min(cx, cy) * 0.82;
    final innerR = maxR * config.innerRadiusFraction;
    final startRad = config.startAngleDeg * math.pi / 180;
    final sliceAngle = 2 * math.pi / n;
    final gap = sliceAngle * 0.04;

    // compute max value for scaling
    double maxVal = 1;
    for (final s in config.series) {
      for (final v in s.data ?? []) {
        final d = (v as num?)?.toDouble() ?? 0;
        if (d > maxVal) maxVal = d;
      }
    }

    // ── web rings ──
    for (int ring = 4; ring >= 1; ring--) {
      final ringR = innerR + (maxR - innerR) * ring / 4;
      canvas.drawCircle(Offset(cx, cy), ringR, paintCache.stroke(theme.gridColor, 0.6));
    }
    // Axis lines
    for (int i = 0; i < n; i++) {
      final angle = startRad + i * sliceAngle;
      canvas.drawLine(
          Offset(cx, cy),
          Offset(cx + maxR * math.cos(angle), cy + maxR * math.sin(angle)),
          paintCache.stroke(theme.gridColor, 0.8));
    }

    // ── bars ──
    for (int i = 0; i < n; i++) {
      final baseAngle = startRad + i * sliceAngle;
      final isHov = i == hovCat;
      double innerCur = innerR;

      for (int s = 0; s < config.series.length; s++) {
        final data = config.series[s].data ?? [];
        final val = i < data.length ? (data[i] as num).toDouble() : 0.0;
        final color = theme.seriesColor(s, explicitColor: config.series[s].itemStyle?.color);

        final outerCur = innerCur + (val / maxVal) * (maxR - innerR) * progress;
        final path = Path()
          ..addArc(
              Rect.fromCircle(center: Offset(cx, cy), radius: outerCur),
              baseAngle + gap,
              sliceAngle - gap * 2)
          ..lineTo(
              cx + innerCur * math.cos(baseAngle + sliceAngle - gap),
              cy + innerCur * math.sin(baseAngle + sliceAngle - gap))
          ..addArc(
              Rect.fromCircle(center: Offset(cx, cy), radius: innerCur),
              baseAngle + sliceAngle - gap,
              -(sliceAngle - gap * 2))
          ..close();

        canvas.drawPath(
          path,
          Paint()
            ..color = isHov ? Color.lerp(color, Colors.white, 0.2)! : color.withOpacity(0.88)
            ..style = PaintingStyle.fill
            ..isAntiAlias = true,
        );
        canvas.drawPath(path, paintCache.stroke(Colors.white.withOpacity(0.35), 0.8));

        if (config.stacked) {
          innerCur = outerCur;
        } else {
          innerCur = innerR; // reset for grouped
        }
      }

      // ── category label ──
      if (config.showLabels) {
        final midAngle = baseAngle + sliceAngle / 2;
        final labelR = maxR + 14;
        final lx = cx + labelR * math.cos(midAngle);
        final ly = cy + labelR * math.sin(midAngle);
        final tp = textPainterCache.get(
          config.categories[i],
          theme.typography.axisLabelStyle.copyWith(
              color: isHov ? theme.titleColor : theme.axisLabelColor,
              fontSize: 10,
              fontWeight: isHov ? FontWeight.w600 : FontWeight.w400),
          maxWidth: 60,
          align: TextAlign.center,
        );
        tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
      }
    }
  }
}

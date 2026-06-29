/// Radar chart (spider / web chart) — multi-axis radial comparison.
///
/// Each axis radiates from the centre. Multiple series are drawn as filled
/// polygons overlaid on the same web. Supports hover tooltip and entrance animation.
///
/// JSON:
/// ```json
/// {
///   "type": "radar",
///   "axes": [
///     { "name": "Speed",    "max": 100 },
///     { "name": "Power",    "max": 100 },
///     { "name": "Range",    "max": 100 },
///     { "name": "Defense",  "max": 100 },
///     { "name": "Agility",  "max": 100 }
///   ],
///   "series": [
///     { "name": "Unit A", "data": [80, 65, 55, 70, 90] },
///     { "name": "Unit B", "data": [40, 85, 70, 50, 60] }
///   ]
/// }
/// ```
library radar_chart;

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
// Data model
// ─────────────────────────────────────────────────────────

class RadarAxis {
  final String name;
  final double max;
  final double min;

  const RadarAxis({required this.name, this.max = 100, this.min = 0});

  factory RadarAxis.fromJson(Map<String, dynamic> j) => RadarAxis(
        name: j['name']?.toString() ?? '',
        max: (j['max'] as num?)?.toDouble() ?? 100,
        min: (j['min'] as num?)?.toDouble() ?? 0,
      );
}

// ─────────────────────────────────────────────────────────
// Config
// ─────────────────────────────────────────────────────────

class RadarChartConfig extends BaseChartConfig {
  final List<RadarAxis> axes;
  final bool filled;
  final bool showLabels;
  final bool showDots;
  final int webLevels;
  final double fillOpacity;
  final double startAngleDeg;
  final ChartTheme theme;

  RadarChartConfig({
    required this.axes,
    required List<Series> super.series,
    this.theme = ChartTheme.light,
    this.filled = true,
    this.showLabels = true,
    this.showDots = true,
    this.webLevels = 4,
    this.fillOpacity = 0.22,
    this.startAngleDeg = -90,
  }) : super(type: ChartType.radar);

  @override
  Widget buildChart() => RadarChartWidget(config: this);

  factory RadarChartConfig.fromJson(Map<String, dynamic> json) {
    final axes = (json['axes'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(RadarAxis.fromJson)
        .toList();
    final seriesList = (json['series'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Series.fromJson)
        .toList();

    return RadarChartConfig(
      axes: axes,
      series: seriesList,
      filled: json['filled'] as bool? ?? true,
      showLabels: json['showLabels'] as bool? ?? true,
      showDots: json['showDots'] as bool? ?? true,
      webLevels: (json['webLevels'] as int?) ?? 4,
      fillOpacity: (json['fillOpacity'] as num?)?.toDouble() ?? 0.22,
      startAngleDeg: (json['startAngle'] as num?)?.toDouble() ?? -90,
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'radar'};
}

// ─────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────

class RadarChartWidget extends StatefulWidget {
  final RadarChartConfig config;
  const RadarChartWidget({super.key, required this.config});

  @override
  State<RadarChartWidget> createState() => _RadarState();
}

class _RadarState extends State<RadarChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _hovSeries = -1;
  Offset _hoverPos = Offset.zero;

  RadarChartConfig get cfg => widget.config;

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

  int _hitTest(Offset pos, double cx, double cy, double r) {
    for (int s = 0; s < cfg.series.length; s++) {
      final pts = _seriesPoints(s, cx, cy, r);
      if (_inPolygon(pos, pts)) return s;
    }
    return -1;
  }

  List<Offset> _seriesPoints(int s, double cx, double cy, double r) {
    final data = cfg.series[s].data ?? [];
    return List.generate(cfg.axes.length, (i) {
      final val = i < data.length ? (data[i] as num).toDouble() : 0.0;
      final axis = cfg.axes[i];
      final frac = ((val - axis.min) / (axis.max - axis.min)).clamp(0.0, 1.0);
      final angle = cfg.startAngleDeg * math.pi / 180 + i * 2 * math.pi / cfg.axes.length;
      return Offset(cx + r * frac * math.cos(angle), cy + r * frac * math.sin(angle));
    });
  }

  bool _inPolygon(Offset pt, List<Offset> poly) {
    bool inside = false;
    int j = poly.length - 1;
    for (int i = 0; i < poly.length; j = i++) {
      final xi = poly[i].dx, yi = poly[i].dy;
      final xj = poly[j].dx, yj = poly[j].dy;
      if (((yi > pt.dy) != (yj > pt.dy)) &&
          (pt.dx < (xj - xi) * (pt.dy - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
    }
    return inside;
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
          final cx = sz.width / 2, cy = (sz.height - 32) / 2;
          final r = math.min(cx, cy) * 0.72;
          return Stack(children: [
            MouseRegion(
              onHover: (e) => setState(() {
                _hovSeries = _hitTest(e.localPosition, cx, cy, r);
                _hoverPos = e.localPosition;
              }),
              onExit: (_) => setState(() => _hovSeries = -1),
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _RadarPainter(
                    config: cfg,
                    progress: _anim.value,
                    hovSeries: _hovSeries,
                  ),
                ),
              ),
            ),
            if (_hovSeries >= 0) _buildTooltip(sz, r, cx, cy),
          ]);
        }),
      ),
      if (cfg.legend?.show != false && cfg.series.length > 1) _buildLegend(),
    ]);
  }

  Widget _buildTooltip(Size sz, double r, double cx, double cy) {
    final s = cfg.series[_hovSeries];
    final data = s.data ?? [];
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
              Text(s.name ?? 'Series ${_hovSeries + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              ...List.generate(math.min(cfg.axes.length, data.length), (i) =>
                  Text('${cfg.axes[i].name}: ${data[i]}'),
              ),
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
          final color = cfg.theme.seriesColor(e.key,
              explicitColor: e.value.itemStyle?.color);
          return Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10,
                decoration: BoxDecoration(color: color.withOpacity(0.8), shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(e.value.name ?? 'Series ${e.key + 1}',
                style: cfg.theme.typography.legendStyle
                    .copyWith(color: cfg.theme.legendTextColor)),
          ]);
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────

class _RadarPainter extends ChartPainterBase {
  final RadarChartConfig config;
  final double progress;
  final int hovSeries;

  _RadarPainter({
    required this.config,
    required this.progress,
    required this.hovSeries,
  }) : super(theme: config.theme);

  @override
  bool shouldRepaintChart(covariant _RadarPainter old) =>
      old.progress != progress || old.hovSeries != hovSeries;

  @override
  void paint(Canvas canvas, Size size) {
    if (config.axes.isEmpty) return;
    final n = config.axes.length;
    final cx = size.width / 2, cy = (size.height - 32) / 2;
    final r = math.min(cx, cy) * 0.72;
    final startRad = config.startAngleDeg * math.pi / 180;

    // ── web background ──
    for (int level = config.webLevels; level >= 1; level--) {
      final frac = level / config.webLevels;
      final pts = List.generate(n, (i) {
        final angle = startRad + i * 2 * math.pi / n;
        return Offset(cx + r * frac * math.cos(angle), cy + r * frac * math.sin(angle));
      });
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < n; i++) path.lineTo(pts[i].dx, pts[i].dy);
      path.close();
      canvas.drawPath(path, paintCache.fill(theme.gridColor));
      canvas.drawPath(path, paintCache.stroke(theme.gridColor.withOpacity(2), 0.8));
    }

    // ── axis lines ──
    for (int i = 0; i < n; i++) {
      final angle = startRad + i * 2 * math.pi / n;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
        paintCache.stroke(theme.gridColor.withOpacity(1.5), 1),
      );
    }

    // ── series ──
    for (int s = config.series.length - 1; s >= 0; s--) {
      _drawSeries(canvas, s, cx, cy, r, startRad, n);
    }

    // ── axis labels ──
    if (config.showLabels) {
      for (int i = 0; i < n; i++) {
        final angle = startRad + i * 2 * math.pi / n;
        final labelR = r + 18;
        final lx = cx + labelR * math.cos(angle);
        final ly = cy + labelR * math.sin(angle);
        final tp = textPainterCache.get(
          config.axes[i].name,
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 10),
          maxWidth: 80,
          align: TextAlign.center,
        );
        tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
      }
    }
  }

  void _drawSeries(Canvas canvas, int s, double cx, double cy, double r,
      double startRad, int n) {
    final series = config.series[s];
    final data = series.data ?? [];
    final color = theme.seriesColor(s, explicitColor: series.itemStyle?.color);
    final isHov = s == hovSeries;

    final pts = List.generate(n, (i) {
      final val = i < data.length ? (data[i] as num).toDouble() : 0.0;
      final axis = config.axes[i];
      final frac = ((val - axis.min) / (axis.max - axis.min)).clamp(0.0, 1.0) * progress;
      final angle = startRad + i * 2 * math.pi / n;
      return Offset(cx + r * frac * math.cos(angle), cy + r * frac * math.sin(angle));
    });

    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
    path.close();

    if (config.filled) {
      final opacity = isHov ? config.fillOpacity * 2 : config.fillOpacity;
      canvas.drawPath(path, Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true);
    }

    canvas.drawPath(path, paintCache.stroke(color.withOpacity(isHov ? 1 : 0.85), isHov ? 2.5 : 1.8));

    if (config.showDots) {
      for (final pt in pts) {
        canvas.drawCircle(pt, isHov ? 5 : 3.5, Paint()..color = color..style = PaintingStyle.fill);
        canvas.drawCircle(pt, isHov ? 5 : 3.5, paintCache.stroke(Colors.white, 1.2));
      }
    }
  }
}

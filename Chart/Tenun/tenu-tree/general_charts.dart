/// General Charts — 5 specialised chart types.
///
/// Charts:
///   • [TableChartConfig]       — sortable, scrollable data table with colour bands
///   • [ThemeRiverConfig]       — stacked flowing stream / ThemeRiver chart
///   • [PictorialBarConfig]     — bar chart using repeated SVG-like symbol shapes
///   • [MatrixChartConfig]      — correlation / adjacency matrix with colour cells
///   • [ChordChartConfig]       — chord diagram (flows between categories)
library general_charts;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../core/config/base_config.dart';
import '../core/config/chart_type.dart';
import '../core/config/chart_theme.dart';
import '../core/config/title.dart';
import '../core/config/tooltip.dart';
import '../core/config/legend.dart';
import '../core/config/chart_model.dart';
import '../core/painters/chart_painter_base.dart';
import '../core/utils/chart_cache.dart';
import '../core/utils/chart_data_processor.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 1. TABLE CHART
// ═══════════════════════════════════════════════════════════════════════════
/// Rich data table with sortable columns, alternating row bands,
/// optional column-level colour scale bars, and sticky header.
///
/// JSON:
/// ```json
/// { "type": "table",
///   "columns": [
///     { "key": "name",    "label": "Country",  "type": "string" },
///     { "key": "gdp",     "label": "GDP $B",   "type": "number", "colorBar": true },
///     { "key": "pop",     "label": "Pop M",    "type": "number" }
///   ],
///   "rows": [
///     { "name": "USA",    "gdp": 25000, "pop": 331 },
///     { "name": "China",  "gdp": 17700, "pop": 1440 },
///     { "name": "Germany","gdp": 4100,  "pop": 83  }
///   ]}
/// ```
class TableColumn {
  final String key, label;
  final String type;       // 'string' | 'number' | 'percent' | 'date'
  final bool colorBar;     // show mini bar in cell
  final double? width;

  const TableColumn({
    required this.key, required this.label,
    this.type = 'string', this.colorBar = false, this.width,
  });

  factory TableColumn.fromJson(Map<String, dynamic> j) => TableColumn(
    key: j['key']?.toString() ?? '',
    label: j['label']?.toString() ?? '',
    type: j['type']?.toString() ?? 'string',
    colorBar: j['colorBar'] as bool? ?? false,
    width: (j['width'] as num?)?.toDouble(),
  );
}

class TableChartConfig extends BaseChartConfig {
  final List<TableColumn> columns;
  final List<Map<String, dynamic>> rows;
  final bool striped, sortable, sticky;
  final double rowHeight;
  final ChartTheme theme;

  TableChartConfig({
    required this.columns, required this.rows,
    this.striped = true, this.sortable = true, this.sticky = true,
    this.rowHeight = 36,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.table, series: const []);

  @override Widget buildChart() => _TableWidget(config: this);

  factory TableChartConfig.fromJson(Map<String, dynamic> j) {
    final cols = (j['columns'] as List? ?? [])
        .whereType<Map<String, dynamic>>().map(TableColumn.fromJson).toList();
    final rows = (j['rows'] as List? ?? [])
        .whereType<Map<String, dynamic>>().toList();
    return TableChartConfig(
      columns: cols, rows: rows,
      striped: j['striped'] as bool? ?? true,
      sortable: j['sortable'] as bool? ?? true,
      sticky: j['sticky'] as bool? ?? true,
      rowHeight: (j['rowHeight'] as num?)?.toDouble() ?? 36,
      title: j['title'] != null ? TitlesData.fromJson(j['title']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'table'};
}

class _TableWidget extends StatefulWidget {
  final TableChartConfig config;
  const _TableWidget({required this.config});
  @override State<_TableWidget> createState() => _TableState();
}

class _TableState extends State<_TableWidget> {
  String? _sortKey;
  bool _sortAsc = true;
  TableChartConfig get cfg => widget.config;

  List<Map<String, dynamic>> get _sorted {
    if (_sortKey == null) return cfg.rows;
    final col = cfg.columns.firstWhere((c) => c.key == _sortKey,
        orElse: () => cfg.columns.first);
    final rows = [...cfg.rows];
    rows.sort((a, b) {
      final av = a[_sortKey], bv = b[_sortKey];
      int cmp;
      if (col.type == 'number' || col.type == 'percent') {
        final an = (av as num?)?.toDouble() ?? 0;
        final bn = (bv as num?)?.toDouble() ?? 0;
        cmp = an.compareTo(bn);
      } else {
        cmp = av.toString().compareTo(bv.toString());
      }
      return _sortAsc ? cmp : -cmp;
    });
    return rows;
  }

  // Precompute column max values for colour bars
  Map<String, double> _colMax() {
    final m = <String, double>{};
    for (final col in cfg.columns) {
      if (!col.colorBar) continue;
      double mx = 0;
      for (final r in cfg.rows) {
        final v = (r[col.key] as num?)?.toDouble() ?? 0;
        if (v > mx) mx = v;
      }
      m[col.key] = mx;
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final t = cfg.theme;
    final colMax = _colMax();
    final rows = _sorted;

    Widget header() => Container(
      color: t.seriesColor(0).withOpacity(0.9),
      child: Row(
        children: cfg.columns.map((col) => Expanded(
          flex: col.width != null ? (col.width! * 10).toInt() : 10,
          child: InkWell(
            onTap: cfg.sortable ? () => setState(() {
              if (_sortKey == col.key) _sortAsc = !_sortAsc;
              else { _sortKey = col.key; _sortAsc = true; }
            }) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(children: [
                Expanded(child: Text(col.label,
                    style: t.typography.axisLabelStyle.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11))),
                if (cfg.sortable) Icon(
                  _sortKey == col.key
                      ? (_sortAsc ? Icons.arrow_upward : Icons.arrow_downward)
                      : Icons.unfold_more,
                  color: Colors.white70, size: 14),
              ]),
            ),
          ),
        )).toList(),
      ),
    );

    return Column(children: [
      if (cfg.title?.text != null)
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Align(alignment: Alignment.centerLeft,
            child: Text(cfg.title!.text!, style: t.typography.titleStyle
                .copyWith(color: t.titleColor)))),
      if (cfg.sticky) header(),
      Expanded(child: SingleChildScrollView(
        child: Column(children: [
          if (!cfg.sticky) header(),
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            final bg = cfg.striped && i.isOdd
                ? t.gridColor.withOpacity(0.18)
                : t.backgroundColor;
            return Container(
              height: cfg.rowHeight,
              color: bg,
              child: Row(
                children: cfg.columns.map((col) {
                  final val = row[col.key];
                  final numVal = (val as num?)?.toDouble() ?? 0;
                  final maxVal = colMax[col.key] ?? 1;
                  return Expanded(
                    flex: col.width != null ? (col.width! * 10).toInt() : 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: col.colorBar && col.type == 'number'
                          ? Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(numVal.toStringAsFixed(numVal < 10 ? 2 : 0),
                                  style: t.typography.axisLabelStyle.copyWith(
                                      color: t.titleColor, fontSize: 10)),
                              const SizedBox(height: 2),
                              ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(
                                value: maxVal > 0 ? numVal / maxVal : 0,
                                backgroundColor: t.gridColor.withOpacity(0.2),
                                color: t.seriesColor(0).withOpacity(0.7),
                                minHeight: 4,
                              )),
                            ])
                          : Text(col.type == 'number' ? numVal.toStringAsFixed(numVal < 10 ? 2 : 0) : val.toString(),
                              style: t.typography.axisLabelStyle.copyWith(
                                  color: t.titleColor, fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ]),
      )),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. THEME RIVER
// ═══════════════════════════════════════════════════════════════════════════
/// Stacked stream graph where each series flows like a river over time.
/// The baseline shifts to minimise wiggles (Streamgraph / ThemeRiver layout).
///
/// JSON:
/// ```json
/// { "type": "themeRiver",
///   "categories": ["2020","2021","2022","2023","2024"],
///   "series": [
///     { "name": "Topic A", "data": [80,  92, 110, 130, 105] },
///     { "name": "Topic B", "data": [50,  68,  90, 100, 120] },
///     { "name": "Topic C", "data": [30,  40,  50,  80,  90] }
///   ]}
/// ```
class ThemeRiverConfig extends BaseChartConfig {
  final List<String> categories;
  final bool showLabels;
  final ChartTheme theme;

  ThemeRiverConfig({
    required this.categories,
    required List<Series> super.series,
    this.showLabels = true,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.themeRiver);

  @override Widget buildChart() => _ThemeRiverWidget(config: this);

  factory ThemeRiverConfig.fromJson(Map<String, dynamic> j) {
    final cats = (j['categories'] as List? ?? []).map((e) => e.toString()).toList();
    final s = (j['series'] as List? ?? [])
        .whereType<Map<String, dynamic>>().map(Series.fromJson).toList();
    return ThemeRiverConfig(categories: cats, series: s,
        showLabels: j['showLabels'] as bool? ?? true,
        title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
        legend:  j['legend'] != null ? ChartLegend.fromJson(j['legend']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'themeRiver'};
}

class _ThemeRiverWidget extends StatefulWidget {
  final ThemeRiverConfig config;
  const _ThemeRiverWidget({required this.config});
  @override State<_ThemeRiverWidget> createState() => _TRState();
}

class _TRState extends State<_ThemeRiverWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  ThemeRiverConfig get cfg => widget.config;
  int _hovSeries = -1;

  @override void initState() {
    super.initState();
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
    Expanded(child: MouseRegion(
      onHover: (e) {
        // simple hover detection – find nearest series stream
      },
      onExit: (_) => setState(() => _hovSeries = -1),
      child: RepaintBoundary(child: CustomPaint(
        size: Size.infinite,
        painter: _TRPainter(cfg: cfg, progress: _anim.value, hovSeries: _hovSeries),
      )),
    )),
    _buildLegend(),
  ]);

  Widget _buildLegend() => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Wrap(spacing: 12, alignment: WrapAlignment.center,
      children: cfg.series.asMap().entries.map((e) {
        final color = cfg.theme.seriesColor(e.key, explicitColor: e.value.color);
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 12, height: 8, decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Text(e.value.name ?? 'S${e.key+1}', style: cfg.theme.typography.legendStyle
              .copyWith(color: cfg.theme.legendTextColor)),
        ]);
      }).toList()));
}

class _TRPainter extends ChartPainterBase {
  final ThemeRiverConfig cfg;
  final double progress;
  final int hovSeries;
  _TRPainter({required this.cfg, required this.progress, required this.hovSeries})
      : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _TRPainter o) =>
      o.progress != progress || o.hovSeries != hovSeries;

  @override
  void paint(Canvas canvas, Size size) {
    final n = cfg.categories.length;
    if (n < 2 || cfg.series.isEmpty) return;
    const padL = 10.0, padR = 10.0, padT = 16.0, padB = 26.0;
    final pw = size.width - padL - padR;
    final ph = size.height - padT - padB;
    final k = cfg.series.length;

    // Build value matrix [series][category]
    final vals = List.generate(k, (si) {
      final d = cfg.series[si].data ?? [];
      return List.generate(n, (ci) => ci < d.length ? (d[ci] as num).toDouble() : 0.0);
    });

    // Total at each column
    final totals = List.generate(n, (ci) => vals.fold(0.0, (s, v) => s + v[ci]));
    final maxTotal = totals.reduce(math.max);
    if (maxTotal == 0) return;

    // Streamgraph baseline: center everything
    final baselines = List.generate(n, (ci) {
      final t = totals[ci];
      return (maxTotal - t) / 2; // silhouette centering
    });

    final xOf = (int ci) => padL + ci / (n - 1) * pw;
    final yOf = (double v, int ci) =>
        padT + ph - (baselines[ci] + v) / maxTotal * ph * progress;

    // Draw streams from back to front
    for (int si = k - 1; si >= 0; si--) {
      final color = theme.seriesColor(si, explicitColor: cfg.series[si].color);
      final isHov = si == hovSeries;

      // Compute upper and lower boundaries
      final tops = <double>[], bots = <double>[];
      for (int ci = 0; ci < n; ci++) {
        double acc = baselines[ci];
        for (int sj = k - 1; sj > si; sj--) acc += vals[sj][ci];
        bots.add(padT + ph - acc / maxTotal * ph * progress);
        tops.add(padT + ph - (acc + vals[si][ci]) / maxTotal * ph * progress);
      }

      // Build closed bezier path
      final path = Path();
      path.moveTo(xOf(0), tops[0]);
      for (int ci = 0; ci < n - 1; ci++) {
        final mx = (xOf(ci) + xOf(ci + 1)) / 2;
        path.cubicTo(mx, tops[ci], mx, tops[ci + 1], xOf(ci + 1), tops[ci + 1]);
      }
      for (int ci = n - 1; ci > 0; ci--) {
        final mx = (xOf(ci) + xOf(ci - 1)) / 2;
        path.cubicTo(mx, bots[ci], mx, bots[ci - 1], xOf(ci - 1), bots[ci - 1]);
      }
      path.close();

      canvas.drawPath(path, Paint()
        ..color = isHov ? color : color.withOpacity(0.82)
        ..style = PaintingStyle.fill..isAntiAlias = true);
      canvas.drawPath(path, Paint()
        ..color = theme.backgroundColor.withOpacity(0.4)
        ..style = PaintingStyle.stroke..strokeWidth = 0.8..isAntiAlias = true);

      // Mid-stream label
      if (cfg.showLabels && progress > 0.9) {
        final midCi = n ~/ 2;
        final mx = xOf(midCi);
        final my = (tops[midCi] + bots[midCi]) / 2;
        final tp = textPainterCache.get(cfg.series[si].name ?? '',
            theme.typography.dataLabelStyle.copyWith(
                color: Colors.white.withOpacity(0.9), fontSize: 9.5, fontWeight: FontWeight.w600));
        tp.paint(canvas, Offset(mx - tp.width / 2, my - tp.height / 2));
      }
    }

    // X axis labels
    for (int i = 0; i < n; i++) {
      if (i % math.max(1, (n / 6).round()) == 0 || i == n - 1) {
        final tp = textPainterCache.get(cfg.categories[i],
            theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 9));
        tp.paint(canvas, Offset(xOf(i) - tp.width / 2, padT + ph + 4));
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. PICTORIAL BAR
// ═══════════════════════════════════════════════════════════════════════════
/// Bar chart where bars are represented by stacked/clipped symbols.
/// Built-in symbols: circle, star, triangle, diamond, arrow, person.
/// Each unit count = one symbol drawn; fractional last symbol is clipped.
///
/// JSON:
/// ```json
/// { "type": "pictorialBar",
///   "symbol": "circle",
///   "symbolSize": 18,
///   "categories": ["Mon","Tue","Wed","Thu","Fri"],
///   "series": [{ "name": "Sales", "data": [3.5, 5, 2, 4, 6] }] }
/// ```
class PictorialBarConfig extends BaseChartConfig {
  final List<String> categories;
  final String symbol;      // 'circle'|'star'|'triangle'|'diamond'|'arrow'|'person'
  final double symbolSize;
  final double symbolGap;
  final ChartTheme theme;

  PictorialBarConfig({
    required this.categories,
    required List<Series> super.series,
    this.symbol = 'circle',
    this.symbolSize = 16,
    this.symbolGap = 3,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.pictorialBar);

  @override Widget buildChart() => _PBWidget(config: this);

  factory PictorialBarConfig.fromJson(Map<String, dynamic> j) {
    final cats = (j['categories'] as List? ?? []).map((e) => e.toString()).toList();
    final s = (j['series'] as List? ?? [])
        .whereType<Map<String, dynamic>>().map(Series.fromJson).toList();
    return PictorialBarConfig(categories: cats, series: s,
        symbol: j['symbol']?.toString() ?? 'circle',
        symbolSize: (j['symbolSize'] as num?)?.toDouble() ?? 16,
        symbolGap: (j['symbolGap'] as num?)?.toDouble() ?? 3,
        title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
        legend:  j['legend'] != null ? ChartLegend.fromJson(j['legend']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'pictorialBar'};
}

class _PBWidget extends StatefulWidget {
  final PictorialBarConfig config;
  const _PBWidget({required this.config});
  @override State<_PBWidget> createState() => _PBState();
}

class _PBState extends State<_PBWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  PictorialBarConfig get cfg => widget.config;

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
      Padding(padding: const EdgeInsets.fromLTRB(12,10,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _PBPainter(cfg: cfg, progress: _anim.value),
    ))),
  ]);
}

class _PBPainter extends ChartPainterBase {
  final PictorialBarConfig cfg;
  final double progress;
  _PBPainter({required this.cfg, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _PBPainter o) => o.progress != progress;

  Path _symbolPath(String sym, Offset c, double r) {
    switch (sym) {
      case 'star':
        final p = Path();
        for (int i = 0; i < 5; i++) {
          final a = -math.pi / 2 + i * 2 * math.pi / 5;
          final b = a + math.pi / 5;
          final op = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
          final ip = Offset(c.dx + r * 0.4 * math.cos(b), c.dy + r * 0.4 * math.sin(b));
          if (i == 0) p.moveTo(op.dx, op.dy); else p.lineTo(op.dx, op.dy);
          p.lineTo(ip.dx, ip.dy);
        }
        return p..close();
      case 'triangle':
        return Path()
          ..moveTo(c.dx, c.dy - r)
          ..lineTo(c.dx + r, c.dy + r)
          ..lineTo(c.dx - r, c.dy + r)
          ..close();
      case 'diamond':
        return Path()
          ..moveTo(c.dx, c.dy - r)
          ..lineTo(c.dx + r, c.dy)
          ..lineTo(c.dx, c.dy + r)
          ..lineTo(c.dx - r, c.dy)
          ..close();
      case 'arrow':
        return Path()
          ..moveTo(c.dx, c.dy - r)
          ..lineTo(c.dx + r, c.dy + r * 0.3)
          ..lineTo(c.dx, c.dy)
          ..lineTo(c.dx - r, c.dy + r * 0.3)
          ..close();
      case 'person':
        final p = Path();
        p.addOval(Rect.fromCircle(center: Offset(c.dx, c.dy - r * 0.45), radius: r * 0.35));
        p.moveTo(c.dx - r * 0.5, c.dy + r);
        p.quadraticBezierTo(c.dx, c.dy + r * 0.1, c.dx + r * 0.5, c.dy + r);
        return p;
      default: // circle
        return Path()..addOval(Rect.fromCircle(center: c, radius: r));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = cfg.categories.length;
    if (n == 0 || cfg.series.isEmpty) return;
    const padL = 12.0, padR = 12.0, padT = 12.0, padB = 24.0;
    final pw = size.width - padL - padR;
    final ph = size.height - padT - padB;
    final slotW = pw / n;

    final allVals = cfg.series.expand((s) =>
        (s.data ?? []).map((v) => (v as num).toDouble())).toList();
    if (allVals.isEmpty) return;
    final maxVal = allVals.reduce(math.max);

    final step = cfg.symbolSize + cfg.symbolGap;
    final maxSymbols = (ph / step).floor() + 1;

    for (int si = 0; si < cfg.series.length; si++) {
      final s = cfg.series[si];
      final color = theme.seriesColor(si, explicitColor: s.color);

      for (int ci = 0; ci < n; ci++) {
        final d = s.data;
        if (d == null || ci >= d.length) continue;
        final val = (d[ci] as num).toDouble() * progress;
        final full = val.floor();
        final frac = val - full;
        final cx = padL + (ci + 0.5) * slotW;

        for (int sym = 0; sym < math.min(full + 1, maxSymbols); sym++) {
          final y = padT + ph - sym * step - cfg.symbolSize / 2;
          if (y < padT) break;
          final alpha = sym < full ? 1.0 : frac;
          final path = _symbolPath(cfg.symbol,
              Offset(cx, y), cfg.symbolSize / 2);
          // Clip fractional last symbol
          canvas.save();
          if (sym == full && frac < 1.0) {
            final clipH = cfg.symbolSize * frac;
            canvas.clipRect(Rect.fromLTWH(
                cx - cfg.symbolSize, y - cfg.symbolSize / 2 + cfg.symbolSize * (1 - frac),
                cfg.symbolSize * 2, clipH));
          }
          canvas.drawPath(path,
              Paint()..color = color.withOpacity(0.85 * alpha)
                ..style = PaintingStyle.fill..isAntiAlias = true);
          canvas.restore();
        }
      }
    }

    // X labels
    for (int i = 0; i < n; i++) {
      final tp = textPainterCache.get(cfg.categories[i],
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 9.5));
      tp.paint(canvas, Offset(padL + (i + 0.5) * slotW - tp.width / 2, padT + ph + 4));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. MATRIX CHART
// ═══════════════════════════════════════════════════════════════════════════
/// Adjacency / correlation matrix with colour-coded cells.
/// Supports symmetric and asymmetric matrices.
///
/// JSON:
/// ```json
/// { "type": "matrix",
///   "labels": ["A","B","C","D"],
///   "data": [
///     [1.0,  0.8, 0.2, 0.5],
///     [0.8,  1.0, 0.4, 0.3],
///     [0.2,  0.4, 1.0, 0.9],
///     [0.5,  0.3, 0.9, 1.0]
///   ],
///   "colorScale": "blues" }
/// ```
class MatrixChartConfig extends BaseChartConfig {
  final List<String> labels;
  final List<List<double>> data;
  final String colorScale;    // 'blues'|'reds'|'diverging'|'greens'
  final bool showValues;
  final bool showDiagonal;
  final ChartTheme theme;

  MatrixChartConfig({
    required this.labels, required this.data,
    this.colorScale = 'blues',
    this.showValues = true, this.showDiagonal = true,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.matrix, series: const []);

  @override Widget buildChart() => _MatrixWidget(config: this);

  factory MatrixChartConfig.fromJson(Map<String, dynamic> j) {
    final labels = (j['labels'] as List? ?? []).map((e) => e.toString()).toList();
    final data = (j['data'] as List? ?? []).map<List<double>>((row) =>
        (row as List).map<double>((v) => (v as num).toDouble()).toList()).toList();
    return MatrixChartConfig(labels: labels, data: data,
        colorScale: j['colorScale']?.toString() ?? 'blues',
        showValues: j['showValues'] as bool? ?? true,
        showDiagonal: j['showDiagonal'] as bool? ?? true,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'matrix'};
}

class _MatrixWidget extends StatefulWidget {
  final MatrixChartConfig config;
  const _MatrixWidget({required this.config});
  @override State<_MatrixWidget> createState() => _MxState();
}

class _MxState extends State<_MatrixWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  MatrixChartConfig get cfg => widget.config;
  ({int r, int c})? _hov;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12,10,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      return MouseRegion(
        onHover: (e) {
          const pad = 52.0;
          final n = cfg.labels.length;
          if (n == 0) return;
          final cellSz = (math.min(sz.width, sz.height) - pad) / n;
          final ci = ((e.localPosition.dx - pad) / cellSz).floor();
          final ri = ((e.localPosition.dy - pad) / cellSz).floor();
          if (ri >= 0 && ri < n && ci >= 0 && ci < n)
            setState(() => _hov = (r: ri, c: ci));
          else setState(() => _hov = null);
        },
        onExit: (_) => setState(() => _hov = null),
        child: RepaintBoundary(child: CustomPaint(
          size: Size.infinite,
          painter: _MxPainter(cfg: cfg, progress: _anim.value, hov: _hov),
        )),
      );
    })),
  ]);
}

class _MxPainter extends ChartPainterBase {
  final MatrixChartConfig cfg;
  final double progress;
  final ({int r, int c})? hov;
  _MxPainter({required this.cfg, required this.progress, this.hov}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _MxPainter o) =>
      o.progress != progress || o.hov != hov;

  Color _scale(double t) {
    t = (t * progress).clamp(0.0, 1.0);
    switch (cfg.colorScale) {
      case 'reds': return Color.lerp(const Color(0xFFFFF9C4), const Color(0xFFB71C1C), t)!;
      case 'greens': return Color.lerp(const Color(0xFFE8F5E9), const Color(0xFF1B5E20), t)!;
      case 'diverging':
        if (t < 0.5) return Color.lerp(const Color(0xFFC62828), const Color(0xFFF5F5F5), t * 2)!;
        return Color.lerp(const Color(0xFFF5F5F5), const Color(0xFF1565C0), (t - 0.5) * 2)!;
      default: // blues
        return Color.lerp(const Color(0xFFE3F2FD), const Color(0xFF1565C0), t)!;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = cfg.labels.length;
    if (n == 0 || cfg.data.isEmpty) return;
    const pad = 52.0;
    final cellSz = (math.min(size.width, size.height) - pad) / n;

    // Find global min/max
    double lo = double.infinity, hi = double.negativeInfinity;
    for (final row in cfg.data)
      for (final v in row) { if (v < lo) lo = v; if (v > hi) hi = v; }
    final range = (hi - lo).clamp(0.001, double.infinity);

    // Cells
    for (int ri = 0; ri < n; ri++) {
      for (int ci = 0; ci < n; ci++) {
        if (!cfg.showDiagonal && ri == ci) continue;
        final v = ri < cfg.data.length && ci < cfg.data[ri].length
            ? cfg.data[ri][ci] : 0.0;
        final t = (v - lo) / range;
        final fill = _scale(t);
        final rect = Rect.fromLTWH(pad + ci * cellSz, pad + ri * cellSz, cellSz, cellSz);
        final isHov = hov?.r == ri && hov?.c == ci;
        canvas.drawRect(rect,
            Paint()..color = isHov ? Color.lerp(fill, Colors.white, 0.3)! : fill
              ..style = PaintingStyle.fill..isAntiAlias = true);
        canvas.drawRect(rect,
            Paint()..color = theme.backgroundColor..style = PaintingStyle.stroke..strokeWidth = 1);

        if (cfg.showValues && cellSz > 28) {
          final luminance = fill.computeLuminance();
          final tc = luminance > 0.4 ? Colors.black87 : Colors.white;
          final str = v.toStringAsFixed(v == v.truncate() ? 0 : 1);
          final tp = textPainterCache.get(str,
              theme.typography.dataLabelStyle.copyWith(color: tc, fontSize: 8.5));
          tp.paint(canvas, Offset(rect.center.dx - tp.width / 2,
              rect.center.dy - tp.height / 2));
        }
      }
    }

    // Axis labels
    for (int i = 0; i < n; i++) {
      final label = i < cfg.labels.length ? cfg.labels[i] : '$i';
      // Left
      final tp = textPainterCache.get(label,
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 9),
          maxWidth: pad - 4, align: TextAlign.right);
      tp.paint(canvas, Offset(pad - tp.width - 4,
          pad + i * cellSz + cellSz / 2 - tp.height / 2));
      // Top (rotated)
      canvas.save();
      canvas.translate(pad + i * cellSz + cellSz / 2, pad - 4);
      canvas.rotate(-math.pi / 4);
      final tp2 = textPainterCache.get(label,
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 9));
      tp2.paint(canvas, Offset(-tp2.width / 2, -tp2.height));
      canvas.restore();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 5. CHORD CHART
// ═══════════════════════════════════════════════════════════════════════════
/// Chord diagram: circular arcs on the periphery connected by Bézier
/// chord ribbons whose width encodes flow magnitude.
///
/// JSON:
/// ```json
/// { "type": "chord",
///   "labels": ["NY","LA","Chicago","Houston"],
///   "matrix": [
///     [0,   400, 200, 100],
///     [400, 0,   150, 80 ],
///     [200, 150, 0,   300],
///     [100, 80,  300, 0  ]
///   ]}
/// ```
class ChordChartConfig extends BaseChartConfig {
  final List<String> labels;
  final List<List<double>> matrix;   // flows[from][to]
  final double padAngle;
  final ChartTheme theme;

  ChordChartConfig({
    required this.labels, required this.matrix,
    this.padAngle = 0.04,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.chord, series: const []);

  @override Widget buildChart() => _ChordWidget(config: this);

  factory ChordChartConfig.fromJson(Map<String, dynamic> j) {
    final labels = (j['labels'] as List? ?? []).map((e) => e.toString()).toList();
    final matrix = (j['matrix'] as List? ?? []).map<List<double>>((row) =>
        (row as List).map<double>((v) => (v as num).toDouble()).toList()).toList();
    return ChordChartConfig(labels: labels, matrix: matrix,
        padAngle: (j['padAngle'] as num?)?.toDouble() ?? 0.04,
        title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
        legend:  j['legend'] != null ? ChartLegend.fromJson(j['legend']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'chord'};
}

class _ChordWidget extends StatefulWidget {
  final ChordChartConfig config;
  const _ChordWidget({required this.config});
  @override State<_ChordWidget> createState() => _ChordState();
}

class _ChordState extends State<_ChordWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _hov = -1;
  ChordChartConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12,10,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _ChordPainter(cfg: cfg, progress: _anim.value, hov: _hov),
    ))),
    _buildLegend(),
  ]);

  Widget _buildLegend() => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Wrap(spacing: 12, alignment: WrapAlignment.center,
      children: cfg.labels.asMap().entries.map((e) {
        final color = cfg.theme.seriesColor(e.key);
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(
              color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(e.value, style: cfg.theme.typography.legendStyle
              .copyWith(color: cfg.theme.legendTextColor)),
        ]);
      }).toList()));
}

class _ChordPainter extends ChartPainterBase {
  final ChordChartConfig cfg;
  final double progress;
  final int hov;
  _ChordPainter({required this.cfg, required this.progress, required this.hov})
      : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _ChordPainter o) =>
      o.progress != progress || o.hov != hov;

  @override
  void paint(Canvas canvas, Size size) {
    final n = cfg.labels.length;
    if (n < 2) return;
    final cx = size.width / 2, cy = size.height / 2;
    final outerR = math.min(cx, cy) * 0.72;
    final innerR = outerR * 0.88;

    // Row totals for proportional arcs
    final totals = List.generate(n, (i) =>
        i < cfg.matrix.length ? cfg.matrix[i].fold(0.0, (s, v) => s + v) : 0.0);
    final grand = totals.fold(0.0, (s, v) => s + v);
    if (grand == 0) return;

    final fullArc = 2 * math.pi - n * cfg.padAngle;

    // Arc start/end angles for each group
    final arcStarts = <double>[], arcEnds = <double>[];
    double angle = -math.pi / 2;
    for (int i = 0; i < n; i++) {
      arcStarts.add(angle);
      final sweep = totals[i] / grand * fullArc * progress;
      arcEnds.add(angle + sweep);
      angle += sweep + cfg.padAngle;
    }

    // Draw chord ribbons
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        if (i >= cfg.matrix.length || j >= cfg.matrix[i].length) continue;
        final flow = cfg.matrix[i][j] + (j < cfg.matrix.length && i < cfg.matrix[j].length ? cfg.matrix[j][i] : 0);
        if (flow == 0) continue;
        final iColor = theme.seriesColor(i);
        final jColor = theme.seriesColor(j);

        // Chord: cubic bezier from mid of arc-i to mid of arc-j
        final iMid = (arcStarts[i] + arcEnds[i]) / 2;
        final jMid = (arcStarts[j] + arcEnds[j]) / 2;
        final p0 = Offset(cx + innerR * math.cos(iMid), cy + innerR * math.sin(iMid));
        final p1 = Offset(cx + innerR * math.cos(jMid), cy + innerR * math.sin(jMid));

        final chordPath = Path()
          ..moveTo(p0.dx, p0.dy)
          ..cubicTo(cx * 0.5 + cx * 0.5 * math.cos(iMid),
                    cy * 0.5 + cy * 0.5 * math.sin(iMid),
                    cx * 0.5 + cx * 0.5 * math.cos(jMid),
                    cy * 0.5 + cy * 0.5 * math.sin(jMid),
                    p1.dx, p1.dy)
          ..cubicTo(cx * 0.3 + cx * 0.7 * math.cos(jMid),
                    cy * 0.3 + cy * 0.7 * math.sin(jMid),
                    cx * 0.3 + cx * 0.7 * math.cos(iMid),
                    cy * 0.3 + cy * 0.7 * math.sin(iMid),
                    p0.dx, p0.dy)
          ..close();

        final chordFill = Paint()
          ..shader = LinearGradient(
              colors: [iColor.withOpacity(0.5), jColor.withOpacity(0.5)],
              begin: Alignment(math.cos(iMid), math.sin(iMid)),
              end: Alignment(math.cos(jMid), math.sin(jMid)))
            .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: innerR))
          ..style = PaintingStyle.fill..isAntiAlias = true;
        canvas.drawPath(chordPath, chordFill);
      }
    }

    // Draw outer arcs (segments)
    for (int i = 0; i < n; i++) {
      if (arcStarts.length <= i) break;
      final color = theme.seriesColor(i);
      final isHov = i == hov;
      final sweep = arcEnds[i] - arcStarts[i];
      if (sweep <= 0) continue;

      final arcPath = Path()
        ..moveTo(cx + innerR * math.cos(arcStarts[i]), cy + innerR * math.sin(arcStarts[i]))
        ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: outerR), arcStarts[i], sweep, false)
        ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: innerR), arcEnds[i], -sweep, false)
        ..close();

      canvas.drawPath(arcPath, Paint()
        ..color = isHov ? Color.lerp(color, Colors.white, 0.25)! : color
        ..style = PaintingStyle.fill..isAntiAlias = true);

      // Label
      final midAngle = (arcStarts[i] + arcEnds[i]) / 2;
      final lr = outerR + 14;
      final tp = textPainterCache.get(cfg.labels[i],
          theme.typography.axisLabelStyle.copyWith(
              color: theme.titleColor, fontSize: 10, fontWeight: FontWeight.w600));
      tp.paint(canvas, Offset(cx + lr * math.cos(midAngle) - tp.width / 2,
          cy + lr * math.sin(midAngle) - tp.height / 2));
    }
  }
}

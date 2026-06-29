/// Three compact chart implementations:
///   1. `HeatmapChartConfig`     — 2-D color-encoded matrix
///   2. `CalendarChartConfig`    — GitHub-style activity calendar heatmap
///   3. `ParallelChartConfig`    — parallel coordinates plot
library heatmap_calendar_parallel;

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

// ═══════════════════════════════════════════════════════════
// 1. HEATMAP
// ═══════════════════════════════════════════════════════════

/// JSON:
/// ```json
/// { "type": "heatmap",
///   "xLabels": ["Mon","Tue","Wed","Thu","Fri"],
///   "yLabels": ["Morning","Afternoon","Evening"],
///   "series": [{ "data": [
///     [12,18,9,15,22],
///     [8,14,20,11,17],
///     [5,10,16,8,13]
///   ]}]}
/// ```
class HeatmapChartConfig extends BaseChartConfig {
  final List<String> xLabels, yLabels;
  final List<List<double>> data; // [row][col]
  final Color lowColor, highColor;
  final bool showValues;
  final ChartTheme theme;

  HeatmapChartConfig({
    required this.xLabels, required this.yLabels, required this.data,
    this.theme = ChartTheme.light,
    this.lowColor = const Color(0xFFE3F2FD),
    this.highColor = const Color(0xFF0D47A1),
    this.showValues = true,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.heatmap, series: const []);

  @override Widget buildChart() => HeatmapChartWidget(config: this);

  factory HeatmapChartConfig.fromJson(Map<String, dynamic> json) {
    final xl = (json['xLabels'] as List? ?? []).map((e) => e.toString()).toList();
    final yl = (json['yLabels'] as List? ?? []).map((e) => e.toString()).toList();
    final raw = json['series'] as List? ?? [];
    final data = raw.isEmpty ? <List<double>>[]
        : ((raw.first as Map<String,dynamic>)['data'] as List? ?? [])
            .map<List<double>>((row) => (row as List? ?? []).map((v) => (v as num?)?.toDouble() ?? 0.0).toList())
            .toList();
    Color? c(String? k) { try { return colorCache.resolve(k ?? ''); } catch (_) { return null; } }
    return HeatmapChartConfig(
      xLabels: xl, yLabels: yl, data: data,
      showValues: json['showValues'] as bool? ?? true,
      lowColor: c(json['lowColor']?.toString()) ?? const Color(0xFFE3F2FD),
      highColor: c(json['highColor']?.toString()) ?? const Color(0xFF0D47A1),
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'heatmap'};
}

class HeatmapChartWidget extends StatefulWidget {
  final HeatmapChartConfig config;
  const HeatmapChartWidget({super.key, required this.config});
  @override State<HeatmapChartWidget> createState() => _HeatmapState();
}

class _HeatmapState extends State<HeatmapChartWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _hovRow = -1, _hovCol = -1;
  Offset _hoverPos = Offset.zero;
  HeatmapChartConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12,10,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle.copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      return Stack(children: [
        MouseRegion(
          onHover: (e) {
            const padL = 60.0, padT = 24.0;
            final cols = cfg.xLabels.length, rows = cfg.yLabels.length;
            if (cols == 0 || rows == 0) return;
            final cW = (sz.width - padL - 8) / cols;
            final rH = (sz.height - padT - 8) / rows;
            setState(() {
              _hovCol = ((e.localPosition.dx - padL) / cW).floor().clamp(0, cols - 1);
              _hovRow = ((e.localPosition.dy - padT) / rH).floor().clamp(0, rows - 1);
              _hoverPos = e.localPosition;
            });
          },
          onExit: (_) => setState(() { _hovRow = -1; _hovCol = -1; }),
          child: RepaintBoundary(child: CustomPaint(
            size: Size.infinite,
            painter: _HeatmapPainter(config: cfg, progress: _anim.value, hovRow: _hovRow, hovCol: _hovCol),
          )),
        ),
        if (_hovRow >= 0 && _hovCol >= 0) _buildTooltip(sz),
      ]);
    })),
  ]);

  Widget _buildTooltip(Size sz) {
    final val = _hovRow < cfg.data.length && _hovCol < (cfg.data[_hovRow].length) ? cfg.data[_hovRow][_hovCol] : 0.0;
    double x = (_hoverPos.dx + 12).clamp(0, sz.width - 170.0);
    double y = (_hoverPos.dy - 55).clamp(0, sz.height - 70.0);
    return Positioned(left: x, top: y, child: IgnorePointer(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: cfg.theme.tooltipBackgroundColor, borderRadius: BorderRadius.circular(7)),
      child: DefaultTextStyle(style: cfg.theme.typography.tooltipStyle.copyWith(color: cfg.theme.tooltipTextColor),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('${_hovRow < cfg.yLabels.length ? cfg.yLabels[_hovRow] : ""} / ${_hovCol < cfg.xLabels.length ? cfg.xLabels[_hovCol] : ""}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Value: ${val.toStringAsFixed(1)}'),
        ]),
      ),
    )));
  }
}

class _HeatmapPainter extends ChartPainterBase {
  final HeatmapChartConfig config;
  final double progress;
  final int hovRow, hovCol;

  _HeatmapPainter({required this.config, required this.progress, required this.hovRow, required this.hovCol})
      : super(theme: config.theme);
  @override bool shouldRepaintChart(covariant _HeatmapPainter old) =>
      old.progress != progress || old.hovRow != hovRow || old.hovCol != hovCol;

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 60.0, padT = 24.0, padR = 8.0, padB = 8.0;
    final cols = config.xLabels.length, rows = config.yLabels.length;
    if (cols == 0 || rows == 0 || config.data.isEmpty) return;

    double lo = double.infinity, hi = double.negativeInfinity;
    for (final row in config.data) for (final v in row) { if (v < lo) lo = v; if (v > hi) hi = v; }
    final range = (hi - lo).clamp(1.0, 1e18);

    final cW = (size.width - padL - padR) / cols;
    final rH = (size.height - padT - padB) / rows;

    for (int r = 0; r < rows; r++) {
      if (r >= config.data.length) break;
      for (int c = 0; c < cols; c++) {
        if (c >= config.data[r].length) break;
        final v = config.data[r][c];
        final t = ((v - lo) / range * progress).clamp(0.0, 1.0);
        final color = Color.lerp(config.lowColor, config.highColor, t)!;
        final isHov = r == hovRow && c == hovCol;
        final rect = Rect.fromLTWH(padL + c * cW + 1, padT + r * rH + 1, cW - 2, rH - 2);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)),
            Paint()..color = isHov ? Color.lerp(color, Colors.white, 0.25)! : color..style = PaintingStyle.fill);
        if (config.showValues && cW > 24 && rH > 16) {
          final tp = textPainterCache.get(v.toStringAsFixed(0),
              theme.typography.axisLabelStyle.copyWith(
                  color: t > 0.6 ? Colors.white : Colors.black87, fontSize: 9),
              align: TextAlign.center, maxWidth: cW - 4);
          tp.paint(canvas, Offset(padL + c * cW + cW / 2 - tp.width / 2, padT + r * rH + rH / 2 - tp.height / 2));
        }
      }
    }
    // X labels
    for (int c = 0; c < cols; c++) {
      final tp = textPainterCache.get(config.xLabels[c],
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 9), maxWidth: cW);
      tp.paint(canvas, Offset(padL + c * cW + cW / 2 - tp.width / 2, 4));
    }
    // Y labels
    for (int r = 0; r < rows; r++) {
      final tp = textPainterCache.get(config.yLabels[r],
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor), maxWidth: padL - 4, align: TextAlign.right);
      tp.paint(canvas, Offset(padL - tp.width - 4, padT + r * rH + rH / 2 - tp.height / 2));
    }
  }
}

// ═══════════════════════════════════════════════════════════
// 2. CALENDAR HEATMAP
// ═══════════════════════════════════════════════════════════

/// GitHub-style activity calendar.
/// JSON:
/// ```json
/// { "type": "calendar", "year": 2024,
///   "series": [{ "data": [
///     { "date": "2024-01-15", "value": 4 },
///     { "date": "2024-03-22", "value": 7 }
///   ]}]}
/// ```
class CalendarChartConfig extends BaseChartConfig {
  final int year;
  final Map<String, double> dateValues; // "yyyy-MM-dd" -> value
  final Color emptyColor;
  final Color maxColor;
  final ChartTheme theme;

  CalendarChartConfig({
    required this.year, required this.dateValues,
    this.theme = ChartTheme.light,
    this.emptyColor = const Color(0xFFEEEEEE),
    this.maxColor = const Color(0xFF1B5E20),
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.calendar, series: const []);

  @override Widget buildChart() => CalendarChartWidget(config: this);

  factory CalendarChartConfig.fromJson(Map<String, dynamic> json) {
    final raw = json['series'] as List? ?? [];
    final Map<String, double> dv = {};
    if (raw.isNotEmpty) {
      for (final item in (raw.first as Map<String,dynamic>)['data'] as List? ?? []) {
        if (item is Map<String,dynamic>) dv[item['date'].toString()] = (item['value'] as num?)?.toDouble() ?? 0;
      }
    }
    Color? c(String? k) { try { return colorCache.resolve(k ?? ''); } catch (_) { return null; } }
    return CalendarChartConfig(
      year: (json['year'] as int?) ?? DateTime.now().year,
      dateValues: dv,
      emptyColor: c(json['emptyColor']?.toString()) ?? const Color(0xFFEEEEEE),
      maxColor: c(json['maxColor']?.toString()) ?? const Color(0xFF1B5E20),
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'calendar'};
}

class CalendarChartWidget extends StatefulWidget {
  final CalendarChartConfig config;
  const CalendarChartWidget({super.key, required this.config});
  @override State<CalendarChartWidget> createState() => _CalState();
}

class _CalState extends State<CalendarChartWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  String? _hovDate;
  Offset _hoverPos = Offset.zero;
  CalendarChartConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12,10,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle.copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      return Stack(children: [
        MouseRegion(
          onHover: (e) {
            const padL = 28.0, padT = 20.0;
            final cellSize = (sz.width - padL) / 54;
            final col = ((e.localPosition.dx - padL) / cellSize).floor();
            final row = ((e.localPosition.dy - padT) / cellSize).floor();
            if (col >= 0 && row >= 0 && row < 7) {
              final jan1 = DateTime(cfg.year, 1, 1);
              final jan1Dow = jan1.weekday % 7; // 0=Sun
              final dayIdx = col * 7 + row - jan1Dow;
              if (dayIdx >= 0) {
                final d = jan1.add(Duration(days: dayIdx));
                if (d.year == cfg.year) {
                  final ds = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
                  setState(() { _hovDate = ds; _hoverPos = e.localPosition; });
                  return;
                }
              }
            }
            setState(() => _hovDate = null);
          },
          onExit: (_) => setState(() => _hovDate = null),
          child: RepaintBoundary(child: CustomPaint(
            size: Size.infinite,
            painter: _CalPainter(config: cfg, progress: _anim.value, hovDate: _hovDate),
          )),
        ),
        if (_hovDate != null) _buildTooltip(sz),
      ]);
    })),
  ]);

  Widget _buildTooltip(Size sz) {
    final val = cfg.dateValues[_hovDate] ?? 0.0;
    double x = (_hoverPos.dx + 12).clamp(0, sz.width - 160.0);
    double y = (_hoverPos.dy - 50).clamp(0, sz.height - 60.0);
    return Positioned(left: x, top: y, child: IgnorePointer(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: cfg.theme.tooltipBackgroundColor, borderRadius: BorderRadius.circular(7)),
      child: DefaultTextStyle(style: cfg.theme.typography.tooltipStyle.copyWith(color: cfg.theme.tooltipTextColor),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(_hovDate!, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Value: ${val.toStringAsFixed(0)}'),
        ]),
      ),
    )));
  }
}

class _CalPainter extends ChartPainterBase {
  final CalendarChartConfig config;
  final double progress;
  final String? hovDate;

  _CalPainter({required this.config, required this.progress, this.hovDate}) : super(theme: config.theme);
  @override bool shouldRepaintChart(covariant _CalPainter old) => old.progress != progress || old.hovDate != hovDate;

  @override
  void paint(Canvas canvas, Size size) {
    const padL = 28.0, padT = 20.0;
    final cellSize = (size.width - padL) / 54;
    final gap = cellSize * 0.12;
    final r = cellSize * 0.25;
    final maxVal = config.dateValues.values.fold(0.0, math.max).clamp(1.0, 1e18);

    final jan1 = DateTime(config.year, 1, 1);
    final jan1Dow = jan1.weekday % 7;

    // Month labels
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    for (int m = 0; m < 12; m++) {
      final d = DateTime(config.year, m + 1, 1);
      final dayOfYear = d.difference(jan1).inDays;
      final week = (dayOfYear + jan1Dow) ~/ 7;
      final tp = textPainterCache.get(months[m], theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 9));
      tp.paint(canvas, Offset(padL + week * cellSize + 2, 4));
    }

    // Day labels
    const days = ['S','M','T','W','T','F','S'];
    for (int d = 0; d < 7; d++) {
      final tp = textPainterCache.get(days[d], theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 8));
      tp.paint(canvas, Offset(2, padT + d * cellSize + cellSize / 2 - tp.height / 2));
    }

    // Cells
    for (int week = 0; week < 53; week++) {
      for (int dow = 0; dow < 7; dow++) {
        final dayIdx = week * 7 + dow - jan1Dow;
        if (dayIdx < 0) continue;
        final date = jan1.add(Duration(days: dayIdx));
        if (date.year != config.year) continue;
        final ds = '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
        final val = config.dateValues[ds] ?? 0.0;
        final t = (val / maxVal * progress).clamp(0.0, 1.0);
        final isHov = ds == hovDate;
        final color = val == 0 ? config.emptyColor : Color.lerp(config.emptyColor, config.maxColor, t)!;
        final x = padL + week * cellSize + gap / 2;
        final y = padT + dow * cellSize + gap / 2;
        final sz = cellSize - gap;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, sz, sz), Radius.circular(r)),
            Paint()..color = isHov ? Color.lerp(color, Colors.white, 0.3)! : color..style = PaintingStyle.fill);
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════
// 3. PARALLEL COORDINATES
// ═══════════════════════════════════════════════════════════

/// Parallel coordinates — each axis is one dimension, each line is one record.
/// JSON:
/// ```json
/// { "type": "parallel",
///   "axes": ["Price","Miles","HP","Weight","MPG"],
///   "series": [{
///     "name": "Sedan",
///     "data": [[25000,45000,150,3200,32],[32000,12000,180,3500,28]]
///   }]}
/// ```
class ParallelChartConfig extends BaseChartConfig {
  final List<String> axes;
  final double lineOpacity;
  final ChartTheme theme;

  ParallelChartConfig({
    required this.axes,
    required List<Series> super.series,
    this.theme = ChartTheme.light,
    this.lineOpacity = 0.5,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.parallel);

  @override Widget buildChart() => ParallelChartWidget(config: this);

  factory ParallelChartConfig.fromJson(Map<String, dynamic> json) {
    final axes = (json['axes'] as List? ?? []).map((e) => e.toString()).toList();
    final s = (json['series'] as List? ?? []).whereType<Map<String,dynamic>>().map(Series.fromJson).toList();
    return ParallelChartConfig(
      axes: axes, series: s,
      lineOpacity: (json['lineOpacity'] as num?)?.toDouble() ?? 0.5,
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'parallel'};
}

class ParallelChartWidget extends StatefulWidget {
  final ParallelChartConfig config;
  const ParallelChartWidget({super.key, required this.config});
  @override State<ParallelChartWidget> createState() => _ParallelState();
}

class _ParallelState extends State<ParallelChartWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  ParallelChartConfig get cfg => widget.config;

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
      Padding(padding: const EdgeInsets.fromLTRB(12,10,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle.copyWith(color: cfg.theme.titleColor))),
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _ParallelPainter(config: cfg, progress: _anim.value),
    ))),
    if (cfg.series.length > 1) Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Wrap(spacing: 12, runSpacing: 4, alignment: WrapAlignment.center,
        children: cfg.series.asMap().entries.map((e) {
          final color = cfg.theme.seriesColor(e.key, explicitColor: e.value.itemStyle?.color);
          return Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 14, height: 2, color: color),
            const SizedBox(width: 4),
            Text(e.value.name ?? 'S${e.key+1}',
              style: cfg.theme.typography.legendStyle.copyWith(color: cfg.theme.legendTextColor)),
          ]);
        }).toList()),
    ),
  ]);
}

class _ParallelPainter extends ChartPainterBase {
  final ParallelChartConfig config;
  final double progress;

  _ParallelPainter({required this.config, required this.progress}) : super(theme: config.theme);
  @override bool shouldRepaintChart(covariant _ParallelPainter old) => old.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    final nAxes = config.axes.length;
    if (nAxes < 2) return;
    const padL = 16.0, padR = 16.0, padT = 24.0, padB = 32.0;
    final chartW = size.width - padL - padR;
    final chartH = size.height - padT - padB;

    // Compute per-axis min/max
    final mins = List<double>.filled(nAxes, double.infinity);
    final maxs = List<double>.filled(nAxes, double.negativeInfinity);
    for (final s in config.series) {
      for (final row in s.data ?? []) {
        final vals = row is List ? row : [row];
        for (int a = 0; a < math.min(nAxes, vals.length); a++) {
          final v = (vals[a] as num?)?.toDouble() ?? 0;
          if (v < mins[a]) mins[a] = v;
          if (v > maxs[a]) maxs[a] = v;
        }
      }
    }

    final axisXs = List.generate(nAxes, (i) => padL + i / (nAxes - 1) * chartW);

    // Draw axis lines
    for (int a = 0; a < nAxes; a++) {
      canvas.drawLine(Offset(axisXs[a], padT), Offset(axisXs[a], padT + chartH), axisPaint);
      final tp = textPainterCache.get(config.axes[a],
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 10), align: TextAlign.center, maxWidth: 60);
      tp.paint(canvas, Offset(axisXs[a] - tp.width / 2, padT + chartH + 4));
      // Min/Max labels
      final minTp = textPainterCache.get(mins[a].toStringAsFixed(0),
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 8));
      final maxTp = textPainterCache.get(maxs[a].toStringAsFixed(0),
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 8));
      maxTp.paint(canvas, Offset(axisXs[a] - maxTp.width / 2, padT - 14));
      minTp.paint(canvas, Offset(axisXs[a] - minTp.width / 2, padT + chartH + 16));
    }

    // Draw lines
    for (int si = 0; si < config.series.length; si++) {
      final s = config.series[si];
      final color = theme.seriesColor(si, explicitColor: s.itemStyle?.color);
      for (final row in s.data ?? []) {
        final vals = row is List ? row : [row];
        final pts = <Offset>[];
        for (int a = 0; a < math.min(nAxes, vals.length); a++) {
          final v = (vals[a] as num?)?.toDouble() ?? 0;
          final range = (maxs[a] - mins[a]).clamp(1e-9, 1e18);
          final t = ((v - mins[a]) / range * progress).clamp(0.0, 1.0);
          pts.add(Offset(axisXs[a], padT + chartH - t * chartH));
        }
        if (pts.length < 2) continue;
        final path = Path()..moveTo(pts[0].dx, pts[0].dy);
        for (int p = 1; p < pts.length; p++) path.lineTo(pts[p].dx, pts[p].dy);
        canvas.drawPath(path, paintCache.stroke(color.withOpacity(config.lineOpacity), 1.2));
      }
    }
  }
}

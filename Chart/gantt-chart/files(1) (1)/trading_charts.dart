/// Trading charts: Kagi, Renko, and MACD.
///
/// All three are designed for financial time-series data and follow the
/// same ChartPainterBase patterns used throughout the library.
library trading_charts;

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
import '../core/utils/chart_data_processor.dart';
import '../core/utils/chart_cache.dart';

// ═══════════════════════════════════════════════════════════
// 1. KAGI CHART
// ═══════════════════════════════════════════════════════════

/// Kagi chart — price-reversal lines ignoring time axis.
/// Thin lines (Yin) = falling price; thick lines (Yang) = rising.
/// Reversal threshold = % change that triggers direction flip.
///
/// JSON:
/// ```json
/// { "type": "kagi", "reversalPct": 4,
///   "series": [{ "data": [150,152,148,155,151,160,158,165,162,170] }]}
/// ```
class KagiChartConfig extends BaseChartConfig {
  final List<double> prices;
  final double reversalPct; // % threshold before reversal
  final Color yangColor, yinColor;
  final ChartTheme theme;

  KagiChartConfig({
    required this.prices, this.reversalPct = 4,
    this.yangColor = const Color(0xFF26A69A), this.yinColor = const Color(0xFFEF5350),
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.kagi, series: const []);

  @override Widget buildChart() => KagiChartWidget(config: this);

  factory KagiChartConfig.fromJson(Map<String, dynamic> json) {
    final raw = json['series'] as List? ?? [];
    final prices = raw.isEmpty ? <double>[]
        : ((raw.first as Map<String,dynamic>)['data'] as List? ?? [])
            .map((v) => (v as num).toDouble()).toList();
    Color? c(String? k) { try { return colorCache.resolve(k ?? ''); } catch (_) { return null; } }
    return KagiChartConfig(
      prices: prices,
      reversalPct: (json['reversalPct'] as num?)?.toDouble() ?? 4,
      yangColor: c(json['yangColor']?.toString()) ?? const Color(0xFF26A69A),
      yinColor:  c(json['yinColor']?.toString())  ?? const Color(0xFFEF5350),
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'kagi'};
}

// ── Kagi line builder ──
class _KagiLine { final double from, to; final bool isYang; const _KagiLine(this.from, this.to, this.isYang); }

List<_KagiLine> _buildKagi(List<double> prices, double pct) {
  if (prices.length < 2) return [];
  final lines = <_KagiLine>[];
  double anchor = prices.first;
  bool rising = prices[1] > prices.first;

  for (int i = 1; i < prices.length; i++) {
    final p = prices[i];
    final change = (p - anchor) / anchor * 100;
    if (rising) {
      if (p > anchor) { anchor = p; continue; }
      if (change <= -pct) { lines.add(_KagiLine(prices[i > 1 ? i - 1 : 0], anchor, true)); anchor = p; rising = false; }
    } else {
      if (p < anchor) { anchor = p; continue; }
      if (change >= pct) { lines.add(_KagiLine(prices[i > 1 ? i - 1 : 0], anchor, false)); anchor = p; rising = true; }
    }
  }
  lines.add(_KagiLine(lines.isNotEmpty ? lines.last.to : prices.first, anchor, rising));
  return lines;
}

class KagiChartWidget extends StatefulWidget {
  final KagiChartConfig config;
  const KagiChartWidget({super.key, required this.config});
  @override State<KagiChartWidget> createState() => _KagiState();
}

class _KagiState extends State<KagiChartWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  KagiChartConfig get cfg => widget.config;

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
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _KagiPainter(config: cfg, progress: _anim.value),
    ))),
  ]);
}

class _KagiPainter extends ChartPainterBase {
  final KagiChartConfig config;
  final double progress;

  _KagiPainter({required this.config, required this.progress}) : super(theme: config.theme);
  @override bool shouldRepaintChart(covariant _KagiPainter old) => old.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    final lines = _buildKagi(config.prices, config.reversalPct);
    if (lines.isEmpty) return;
    final sp = theme.spacing;

    final allVals = [...config.prices];
    final yMin = allVals.reduce(math.min);
    final yMax = allVals.reduce(math.max);
    final pad = (yMax - yMin) * 0.08;
    final vp = ChartViewport(
      left: sp.chartPaddingLeft, top: sp.chartPaddingTop,
      right: size.width - sp.chartPaddingRight, bottom: size.height - sp.chartPaddingBottom,
      dataMinX: 0, dataMaxX: lines.length.toDouble(), dataMinY: yMin - pad, dataMaxY: yMax + pad,
    );

    final yTicks = ChartDataProcessor.niceYTicks(vp.dataMinY, vp.dataMaxY, count: 5);
    drawHorizontalGrid(canvas, vp, yTicks);
    drawYAxisLabels(canvas, vp, yTicks, (v) => v.toStringAsFixed(2));

    final colW = vp.width / lines.length;
    final visible = (lines.length * progress).ceil();

    for (int i = 0; i < visible; i++) {
      final line = lines[i];
      final x = vp.left + (i + 0.5) * colW;
      final color = line.isYang ? config.yangColor : config.yinColor;
      final sw = line.isYang ? 3.0 : 1.5;
      final y1 = vp.toCanvasY(line.from);
      final y2 = vp.toCanvasY(line.to);

      canvas.drawLine(Offset(x, y1), Offset(x, y2), paintCache.stroke(color, sw));

      // Horizontal connector to next line
      if (i + 1 < visible) {
        final nx = vp.left + (i + 1.5) * colW;
        canvas.drawLine(Offset(x, y2), Offset(nx, y2), paintCache.stroke(color, sw));
      }
    }

    canvas.drawLine(Offset(vp.left, vp.bottom), Offset(vp.right, vp.bottom), axisPaint);
    canvas.drawLine(Offset(vp.left, vp.top), Offset(vp.left, vp.bottom), axisPaint);
  }
}

// ═══════════════════════════════════════════════════════════
// 2. RENKO CHART
// ═══════════════════════════════════════════════════════════

/// Renko — fixed-size price bricks, ignores time.
/// JSON:
/// ```json
/// { "type": "renko", "brickSize": 2,
///   "series": [{ "data": [100,101,103,106,104,108,107,112,110,115] }]}
/// ```
class RenkoChartConfig extends BaseChartConfig {
  final List<double> prices;
  final double brickSize;
  final Color upColor, downColor;
  final ChartTheme theme;

  RenkoChartConfig({
    required this.prices, required this.brickSize,
    this.upColor = const Color(0xFF26A69A), this.downColor = const Color(0xFFEF5350),
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.renko, series: const []);

  @override Widget buildChart() => RenkoChartWidget(config: this);

  factory RenkoChartConfig.fromJson(Map<String, dynamic> json) {
    final raw = json['series'] as List? ?? [];
    final prices = raw.isEmpty ? <double>[]
        : ((raw.first as Map<String,dynamic>)['data'] as List? ?? [])
            .map((v) => (v as num).toDouble()).toList();
    Color? c(String? k) { try { return colorCache.resolve(k ?? ''); } catch (_) { return null; } }
    return RenkoChartConfig(
      prices: prices,
      brickSize: (json['brickSize'] as num?)?.toDouble() ?? 1,
      upColor:   c(json['upColor']?.toString())   ?? const Color(0xFF26A69A),
      downColor: c(json['downColor']?.toString())  ?? const Color(0xFFEF5350),
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'renko'};
}

class _RenkoBrick { final double bottom, top; final bool isUp; const _RenkoBrick(this.bottom, this.top, this.isUp); }

List<_RenkoBrick> _buildRenko(List<double> prices, double brickSize) {
  if (prices.isEmpty) return [];
  final bricks = <_RenkoBrick>[];
  double anchor = prices.first;
  for (int i = 1; i < prices.length; i++) {
    final p = prices[i];
    while (p >= anchor + brickSize) {
      bricks.add(_RenkoBrick(anchor, anchor + brickSize, true));
      anchor += brickSize;
    }
    while (p <= anchor - brickSize) {
      bricks.add(_RenkoBrick(anchor - brickSize, anchor, false));
      anchor -= brickSize;
    }
  }
  return bricks;
}

class RenkoChartWidget extends StatefulWidget {
  final RenkoChartConfig config;
  const RenkoChartWidget({super.key, required this.config});
  @override State<RenkoChartWidget> createState() => _RenkoState();
}

class _RenkoState extends State<RenkoChartWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  RenkoChartConfig get cfg => widget.config;

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
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _RenkoPainter(config: cfg, progress: _anim.value),
    ))),
  ]);
}

class _RenkoPainter extends ChartPainterBase {
  final RenkoChartConfig config;
  final double progress;

  _RenkoPainter({required this.config, required this.progress}) : super(theme: config.theme);
  @override bool shouldRepaintChart(covariant _RenkoPainter old) => old.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    final bricks = _buildRenko(config.prices, config.brickSize);
    if (bricks.isEmpty) return;
    final sp = theme.spacing;

    final yMin = bricks.map((b) => b.bottom).reduce(math.min);
    final yMax = bricks.map((b) => b.top).reduce(math.max);
    final pad = (yMax - yMin) * 0.05;
    final vp = ChartViewport(
      left: sp.chartPaddingLeft, top: sp.chartPaddingTop,
      right: size.width - sp.chartPaddingRight, bottom: size.height - sp.chartPaddingBottom,
      dataMinX: 0, dataMaxX: bricks.length.toDouble(), dataMinY: yMin - pad, dataMaxY: yMax + pad,
    );

    final yTicks = ChartDataProcessor.niceYTicks(vp.dataMinY, vp.dataMaxY, count: 5);
    drawHorizontalGrid(canvas, vp, yTicks);
    drawYAxisLabels(canvas, vp, yTicks, (v) => v.toStringAsFixed(2));

    final brickW = vp.width / bricks.length;
    final visible = (bricks.length * progress).ceil();

    for (int i = 0; i < visible; i++) {
      final b = bricks[i];
      final x = vp.left + i * brickW;
      final y1 = vp.toCanvasY(b.top);
      final y2 = vp.toCanvasY(b.bottom);
      final color = b.isUp ? config.upColor : config.downColor;
      canvas.drawRect(Rect.fromLTRB(x + 1, y1, x + brickW - 1, y2),
          Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true);
      canvas.drawRect(Rect.fromLTRB(x + 1, y1, x + brickW - 1, y2),
          paintCache.stroke(Colors.white.withOpacity(0.3), 0.5));
    }
    canvas.drawLine(Offset(vp.left, vp.bottom), Offset(vp.right, vp.bottom), axisPaint);
    canvas.drawLine(Offset(vp.left, vp.top), Offset(vp.left, vp.bottom), axisPaint);
  }
}

// ═══════════════════════════════════════════════════════════
// 3. MACD
// ═══════════════════════════════════════════════════════════

/// MACD chart — MACD line, signal line, histogram, and optional price pane.
/// JSON:
/// ```json
/// { "type": "macd", "fast": 12, "slow": 26, "signal": 9,
///   "series": [{ "data": [150,151,153,149,152,158,155,162,160,165,163,170] }]}
/// ```
class MacdChartConfig extends BaseChartConfig {
  final List<double> prices;
  final int fast, slow, signal;
  final Color macdColor, signalColor, bullHistColor, bearHistColor;
  final ChartTheme theme;

  MacdChartConfig({
    required this.prices, this.fast = 12, this.slow = 26, this.signal = 9,
    this.macdColor = const Color(0xFF2196F3),
    this.signalColor = const Color(0xFFFF9800),
    this.bullHistColor = const Color(0xFF26A69A),
    this.bearHistColor = const Color(0xFFEF5350),
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.macd, series: const []);

  @override Widget buildChart() => MacdChartWidget(config: this);

  factory MacdChartConfig.fromJson(Map<String, dynamic> json) {
    final raw = json['series'] as List? ?? [];
    final prices = raw.isEmpty ? <double>[]
        : ((raw.first as Map<String,dynamic>)['data'] as List? ?? [])
            .map((v) => (v as num).toDouble()).toList();
    return MacdChartConfig(
      prices: prices,
      fast: (json['fast'] as int?) ?? 12,
      slow: (json['slow'] as int?) ?? 26,
      signal: (json['signal'] as int?) ?? 9,
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'macd'};
}

// ── EMA helper ──
List<double> _ema(List<double> data, int period) {
  if (data.length < period) return [];
  final k = 2.0 / (period + 1);
  final result = <double>[];
  double ema = data.take(period).fold(0.0, (a, b) => a + b) / period;
  for (int i = period - 1; i < data.length; i++) {
    if (i == period - 1) { result.add(ema); continue; }
    ema = data[i] * k + ema * (1 - k);
    result.add(ema);
  }
  return result;
}

({List<double> macd, List<double> sig, List<double> hist}) _calcMacd(
    List<double> prices, int fast, int slow, int signal) {
  final f = _ema(prices, fast);
  final s = _ema(prices, slow);
  final offset = slow - fast;
  final macd = List.generate(math.min(f.length, s.length), (i) => f[i + offset] - s[i]);
  final sig = _ema(macd, signal);
  final sigOffset = signal - 1;
  final hist = List.generate(math.min(macd.length, sig.length), (i) => macd[i + sigOffset] - sig[i]);
  return (macd: macd, sig: sig, hist: hist);
}

class MacdChartWidget extends StatefulWidget {
  final MacdChartConfig config;
  const MacdChartWidget({super.key, required this.config});
  @override State<MacdChartWidget> createState() => _MacdState();
}

class _MacdState extends State<MacdChartWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  MacdChartConfig get cfg => widget.config;

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
    Expanded(child: RepaintBoundary(child: CustomPaint(
      size: Size.infinite,
      painter: _MacdPainter(config: cfg, progress: _anim.value),
    ))),
    Padding(padding: const EdgeInsets.only(bottom: 4),
      child: Wrap(spacing: 12, children: [
        _LegendDot(color: cfg.macdColor, label: 'MACD (${cfg.fast},${cfg.slow})', theme: cfg.theme),
        _LegendDot(color: cfg.signalColor, label: 'Signal (${cfg.signal})', theme: cfg.theme),
        _LegendDot(color: cfg.bullHistColor, label: 'Histogram', theme: cfg.theme),
      ])),
  ]);
}

class _LegendDot extends StatelessWidget {
  final Color color; final String label; final ChartTheme theme;
  const _LegendDot({required this.color, required this.label, required this.theme});
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(label, style: theme.typography.legendStyle.copyWith(color: theme.legendTextColor)),
  ]);
}

class _MacdPainter extends ChartPainterBase {
  final MacdChartConfig config;
  final double progress;

  _MacdPainter({required this.config, required this.progress}) : super(theme: config.theme);
  @override bool shouldRepaintChart(covariant _MacdPainter old) => old.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (config.prices.length < config.slow + config.signal) {
      // Not enough data
      final tp = textPainterCache.get('Not enough data for MACD',
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor));
      tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2));
      return;
    }

    final m = _calcMacd(config.prices, config.fast, config.slow, config.signal);
    if (m.hist.isEmpty) return;
    final sp = theme.spacing;

    final allVals = [...m.macd, ...m.sig, ...m.hist];
    final yMin = allVals.reduce(math.min);
    final yMax = allVals.reduce(math.max);
    final pad = math.max((yMax - yMin) * 0.1, 0.001);

    final n = m.hist.length;
    final vp = ChartViewport(
      left: sp.chartPaddingLeft, top: sp.chartPaddingTop,
      right: size.width - sp.chartPaddingRight, bottom: size.height - sp.chartPaddingBottom,
      dataMinX: 0, dataMaxX: n.toDouble(), dataMinY: yMin - pad, dataMaxY: yMax + pad,
    );

    final yTicks = ChartDataProcessor.niceYTicks(vp.dataMinY, vp.dataMaxY, count: 4);
    drawHorizontalGrid(canvas, vp, yTicks);
    drawYAxisLabels(canvas, vp, yTicks, (v) => v.toStringAsFixed(3));

    final zero = vp.toCanvasY(0);
    canvas.drawLine(Offset(vp.left, zero), Offset(vp.right, zero),
        paintCache.stroke(theme.axisColor.withOpacity(0.5), 1));

    final barW = vp.width / n;
    final visible = (n * progress).ceil();

    // Histogram
    for (int i = 0; i < visible; i++) {
      final h = m.hist[i];
      final color = h >= 0 ? config.bullHistColor : config.bearHistColor;
      final by = vp.toCanvasY(h * progress);
      canvas.drawRect(Rect.fromLTRB(vp.left + i * barW + 1, math.min(by, zero), vp.left + (i+1) * barW - 1, math.max(by, zero)),
          Paint()..color = color.withOpacity(0.6)..style = PaintingStyle.fill..isAntiAlias = true);
    }

    // MACD line
    final macdOffset = m.macd.length - n;
    Path? macdPath;
    for (int i = 0; i < visible && i + macdOffset < m.macd.length; i++) {
      final cx = vp.left + (i + 0.5) * barW;
      final cy = vp.toCanvasY(m.macd[i + macdOffset] * progress);
      if (macdPath == null) macdPath = Path()..moveTo(cx, cy); else macdPath.lineTo(cx, cy);
    }
    if (macdPath != null) canvas.drawPath(macdPath, paintCache.stroke(config.macdColor, 1.8));

    // Signal line
    Path? sigPath;
    for (int i = 0; i < visible && i < m.sig.length; i++) {
      final cx = vp.left + (i + 0.5) * barW;
      final cy = vp.toCanvasY(m.sig[i] * progress);
      if (sigPath == null) sigPath = Path()..moveTo(cx, cy); else sigPath.lineTo(cx, cy);
    }
    if (sigPath != null) canvas.drawPath(sigPath, paintCache.stroke(config.signalColor, 1.8));

    canvas.drawLine(Offset(vp.left, vp.bottom), Offset(vp.right, vp.bottom), axisPaint);
    canvas.drawLine(Offset(vp.left, vp.top), Offset(vp.left, vp.bottom), axisPaint);
  }
}

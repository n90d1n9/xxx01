/// Candlestick & OHLC charts — financial price action charts.
///
/// `candlestick` — traditional Japanese candlestick (body + wicks).
/// `ohlc`        — OHLC bar chart (tick marks on a vertical line).
/// Both support an optional volume histogram in a sub-pane below.
///
/// JSON:
/// ```json
/// { "type": "candlestick",
///   "showVolume": true,
///   "series": [{ "data": [
///     { "date":"2024-01-02","open":150.2,"high":153.8,"low":149.1,"close":152.5,"volume":8234000 },
///     { "date":"2024-01-03","open":152.5,"high":155.1,"low":151.0,"close":151.8,"volume":9120000 }
///   ]}]}
/// ```
library candlestick_ohlc_chart;

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

// ─────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────

class OhlcBar {
  final String date;
  final double open, high, low, close;
  final double? volume;
  bool get isBullish => close >= open;

  const OhlcBar({
    required this.date, required this.open, required this.high,
    required this.low, required this.close, this.volume,
  });

  factory OhlcBar.fromJson(Map<String, dynamic> j) => OhlcBar(
    date: j['date']?.toString() ?? '',
    open:  (j['open']  as num).toDouble(),
    high:  (j['high']  as num).toDouble(),
    low:   (j['low']   as num).toDouble(),
    close: (j['close'] as num).toDouble(),
    volume: (j['volume'] as num?)?.toDouble(),
  );
}

// ─────────────────────────────────────────────────────────
// Config  (shared for both candlestick + ohlc)
// ─────────────────────────────────────────────────────────

class CandlestickChartConfig extends BaseChartConfig {
  final List<OhlcBar> bars;
  final bool showVolume;
  final Color bullColor;
  final Color bearColor;
  final double volumePaneFraction; // fraction of height for volume pane
  final ChartTheme theme;

  CandlestickChartConfig({
    required this.bars,
    required ChartType type,
    this.theme = ChartTheme.light,
    this.showVolume = true,
    this.bullColor = const Color(0xFF26A69A),
    this.bearColor = const Color(0xFFEF5350),
    this.volumePaneFraction = 0.22,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: type, series: const []);

  @override Widget buildChart() => CandlestickChartWidget(config: this);

  static CandlestickChartConfig fromJson(Map<String, dynamic> json, ChartType type) {
    final raw = json['series'] as List? ?? [];
    final bars = raw.isEmpty ? <OhlcBar>[]
        : ((raw.first as Map<String, dynamic>)['data'] as List? ?? [])
            .whereType<Map<String, dynamic>>().map(OhlcBar.fromJson).toList();
    Color? c(String? k) { try { return colorCache.resolve(k ?? ''); } catch (_) { return null; } }
    return CandlestickChartConfig(
      bars: bars, type: type,
      showVolume: json['showVolume'] as bool? ?? true,
      bullColor: c(json['bullColor']?.toString()) ?? const Color(0xFF26A69A),
      bearColor: c(json['bearColor']?.toString()) ?? const Color(0xFFEF5350),
      volumePaneFraction: (json['volumePaneFraction'] as num?)?.toDouble() ?? 0.22,
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }

  factory CandlestickChartConfig.fromJsonCandlestick(Map<String, dynamic> j) =>
      CandlestickChartConfig.fromJson(j, ChartType.candlestick);
  factory CandlestickChartConfig.fromJsonOhlc(Map<String, dynamic> j) =>
      CandlestickChartConfig.fromJson(j, ChartType.ohlc);

  @override Map<String, dynamic> toJson() => {'type': type == ChartType.ohlc ? 'ohlc' : 'candlestick'};
}

// ─────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────

class CandlestickChartWidget extends StatefulWidget {
  final CandlestickChartConfig config;
  const CandlestickChartWidget({super.key, required this.config});
  @override State<CandlestickChartWidget> createState() => _CandleState();
}

class _CandleState extends State<CandlestickChartWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _hovIdx = -1;
  Offset _hoverPos = Offset.zero;
  double _scrollOffset = 0;
  double _zoom = 1.0;

  CandlestickChartConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
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
          GestureDetector(
            onScaleUpdate: (d) => setState(() {
              _zoom = (_zoom * d.scale).clamp(0.5, 8.0);
            }),
            onHorizontalDragUpdate: (d) => setState(() {
              _scrollOffset = (_scrollOffset + d.delta.dx).clamp(-sz.width * 2, 0);
            }),
            child: MouseRegion(
              onHover: (e) {
                final sp = cfg.theme.spacing;
                final visN = cfg.bars.length;
                final barW = (sz.width - sp.chartPaddingLeft - sp.chartPaddingRight) / math.max(1, visN) * _zoom;
                final i = ((e.localPosition.dx - sp.chartPaddingLeft - _scrollOffset) / barW).floor();
                setState(() { _hovIdx = i.clamp(0, visN - 1); _hoverPos = e.localPosition; });
              },
              onExit: (_) => setState(() => _hovIdx = -1),
              child: RepaintBoundary(child: CustomPaint(
                size: Size.infinite,
                painter: _CandlePainter(
                  config: cfg, progress: _anim.value,
                  hovIdx: _hovIdx, scrollOffset: _scrollOffset, zoom: _zoom,
                ),
              )),
            ),
          ),
          if (_hovIdx >= 0 && _hovIdx < cfg.bars.length) _buildTooltip(sz),
        ]);
      })),
    ]);
  }

  Widget _buildTooltip(Size sz) {
    final b = cfg.bars[_hovIdx];
    final chg = b.close - b.open;
    final pct = b.open != 0 ? (chg / b.open * 100).toStringAsFixed(2) : '0.00';
    final sign = chg >= 0 ? '+' : '';
    double x = (_hoverPos.dx + 12).clamp(0, sz.width - 200.0);
    double y = (_hoverPos.dy - 90).clamp(0, sz.height - 120.0);
    return Positioned(left: x, top: y, child: IgnorePointer(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: cfg.theme.tooltipBackgroundColor, borderRadius: BorderRadius.circular(7)),
      child: DefaultTextStyle(style: cfg.theme.typography.tooltipStyle.copyWith(color: cfg.theme.tooltipTextColor),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(b.date, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('O: ${b.open.toStringAsFixed(2)}   H: ${b.high.toStringAsFixed(2)}'),
          Text('L: ${b.low.toStringAsFixed(2)}    C: ${b.close.toStringAsFixed(2)}'),
          Text('$sign${chg.toStringAsFixed(2)} ($sign$pct%)',
              style: TextStyle(color: b.isBullish ? cfg.bullColor : cfg.bearColor)),
          if (b.volume != null) Text('Vol: ${_fmtVol(b.volume!)}'),
        ]),
      ),
    )));
  }

  String _fmtVol(double v) => v >= 1e9 ? '${(v/1e9).toStringAsFixed(1)}B'
      : v >= 1e6 ? '${(v/1e6).toStringAsFixed(1)}M' : '${(v/1e3).toStringAsFixed(0)}K';
}

// ─────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────

class _CandlePainter extends ChartPainterBase {
  final CandlestickChartConfig config;
  final double progress, scrollOffset, zoom;
  final int hovIdx;

  _CandlePainter({
    required this.config, required this.progress,
    required this.hovIdx, required this.scrollOffset, required this.zoom,
  }) : super(theme: config.theme);

  @override bool shouldRepaintChart(covariant _CandlePainter old) =>
      old.progress != progress || old.hovIdx != hovIdx || old.scrollOffset != scrollOffset || old.zoom != zoom;

  @override
  void paint(Canvas canvas, Size size) {
    final bars = config.bars;
    if (bars.isEmpty) return;
    final sp = theme.spacing;
    final isOhlc = config.type == ChartType.ohlc;

    final priceH = config.showVolume ? size.height * (1 - config.volumePaneFraction) : size.height;
    final volH = size.height - priceH;

    double lo = bars.map((b) => b.low).reduce(math.min);
    double hi = bars.map((b) => b.high).reduce(math.max);
    final priceVp = ChartViewport(
      left: sp.chartPaddingLeft, top: sp.chartPaddingTop,
      right: size.width - sp.chartPaddingRight, bottom: priceH - 24,
      dataMinX: 0, dataMaxX: bars.length.toDouble(),
      dataMinY: lo - (hi - lo) * 0.05, dataMaxY: hi + (hi - lo) * 0.05,
    );

    final yTicks = ChartDataProcessor.niceYTicks(priceVp.dataMinY, priceVp.dataMaxY, count: 5);
    drawHorizontalGrid(canvas, priceVp, yTicks);
    drawYAxisLabels(canvas, priceVp, yTicks, (v) => v.toStringAsFixed(2));

    final barW = priceVp.width / bars.length * zoom;
    final bodyW = barW * 0.65;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(priceVp.left, priceVp.top, priceVp.width, priceVp.height));

    for (int i = 0; i < bars.length; i++) {
      final b = bars[i];
      final cx = priceVp.left + (i + 0.5) * barW + scrollOffset;
      if (cx < priceVp.left - barW || cx > priceVp.right + barW) continue;

      final color = b.isBullish ? config.bullColor : config.bearColor;
      final isHov = i == hovIdx;
      final fc = isHov ? Color.lerp(color, Colors.white, 0.2)! : color;

      final openY  = priceVp.toCanvasY(b.open);
      final closeY = priceVp.toCanvasY(b.close);
      final highY  = priceVp.toCanvasY(b.high - (b.high - priceVp.dataMinY) * (1 - progress) * 0.5);
      final lowY   = priceVp.toCanvasY(b.low + (priceVp.dataMaxY - b.low) * (1 - progress) * 0.5);

      // Wick
      canvas.drawLine(Offset(cx, highY), Offset(cx, lowY), paintCache.stroke(fc, 1));

      if (isOhlc) {
        canvas.drawLine(Offset(cx - bodyW/2, openY), Offset(cx, openY), paintCache.stroke(fc, 1.5));
        canvas.drawLine(Offset(cx, closeY), Offset(cx + bodyW/2, closeY), paintCache.stroke(fc, 1.5));
      } else {
        final topY = math.min(openY, closeY);
        final botY = math.max(openY, closeY);
        final h = math.max(1.0, botY - topY);
        canvas.drawRect(Rect.fromLTWH(cx - bodyW/2, topY, bodyW, h),
            Paint()..color = fc..style = PaintingStyle.fill..isAntiAlias = true);
      }
    }
    canvas.restore();

    // Volume pane
    if (config.showVolume && volH > 10) {
      final hasVol = bars.any((b) => b.volume != null);
      if (hasVol) {
        final maxVol = bars.map((b) => b.volume ?? 0).reduce(math.max);
        final volVp = ChartViewport(
          left: priceVp.left, top: priceH + 4,
          right: priceVp.right, bottom: size.height - 4,
          dataMinX: 0, dataMaxX: bars.length.toDouble(),
          dataMinY: 0, dataMaxY: maxVol,
        );
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(volVp.left, volVp.top, volVp.width, volVp.height));
        for (int i = 0; i < bars.length; i++) {
          final b = bars[i];
          final vol = b.volume ?? 0;
          final cx = volVp.left + (i + 0.5) * barW + scrollOffset;
          if (cx < volVp.left - barW || cx > volVp.right + barW) continue;
          final h = (vol / maxVol * (volVp.bottom - volVp.top) * progress).clamp(0.0, volVp.height);
          canvas.drawRect(Rect.fromLTWH(cx - bodyW/2, volVp.bottom - h, bodyW, h),
              Paint()..color = (b.isBullish ? config.bullColor : config.bearColor).withOpacity(0.5)
                ..style = PaintingStyle.fill);
        }
        canvas.restore();
        canvas.drawLine(Offset(priceVp.left, priceH), Offset(priceVp.right, priceH),
            paintCache.stroke(theme.gridColor, 1));
      }
    }

    // X labels (dates, show every Nth)
    final step = math.max(1, (bars.length / 8).round());
    final xLabels = <String>[], xPos = <double>[];
    for (int i = 0; i < bars.length; i += step) {
      xLabels.add(bars[i].date.length > 7 ? bars[i].date.substring(5) : bars[i].date);
      xPos.add(priceVp.left + (i + 0.5) * barW + scrollOffset);
    }
    drawXAxisLabels(canvas, priceVp, xLabels, xPos);
    canvas.drawLine(Offset(priceVp.left, priceVp.bottom), Offset(priceVp.right, priceVp.bottom), axisPaint);
    canvas.drawLine(Offset(priceVp.left, priceVp.top), Offset(priceVp.left, priceVp.bottom), axisPaint);
  }
}

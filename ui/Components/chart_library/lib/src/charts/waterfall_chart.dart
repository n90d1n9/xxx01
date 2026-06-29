/// Waterfall chart — shows cumulative effect of sequential positive/negative values.
///
/// Also known as a bridge chart. Each bar floats at its running-total position.
/// Items can be tagged as "total" to show a full bar (e.g. opening/closing values).
///
/// JSON:
/// ```json
/// {
///   "type": "waterfall",
///   "series": [{
///     "data": [
///       { "name": "Opening",  "value": 500,  "type": "total"    },
///       { "name": "Revenue",  "value": 320                       },
///       { "name": "Returns",  "value": -80                       },
///       { "name": "OpEx",     "value": -150                      },
///       { "name": "Tax",      "value": -45                       },
///       { "name": "Closing",  "value": 545,  "type": "total"    }
///     ]
///   }]
/// }
/// ```
library waterfall_chart;

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

enum WaterfallItemType { increase, decrease, total }

class WaterfallItem {
  final String name;
  final double value;
  final WaterfallItemType itemType;
  final String? color;

  const WaterfallItem({
    required this.name,
    required this.value,
    this.itemType = WaterfallItemType.increase,
    this.color,
  });

  factory WaterfallItem.fromJson(Map<String, dynamic> j) {
    final v = (j['value'] as num?)?.toDouble() ?? 0;
    final typeStr = j['type']?.toString().toLowerCase();
    WaterfallItemType t;
    if (typeStr == 'total') {
      t = WaterfallItemType.total;
    } else if (v < 0) {
      t = WaterfallItemType.decrease;
    } else {
      t = WaterfallItemType.increase;
    }
    return WaterfallItem(
      name: j['name']?.toString() ?? '',
      value: v,
      itemType: t,
      color: j['color']?.toString(),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Config
// ─────────────────────────────────────────────────────────

class WaterfallChartConfig extends BaseChartConfig {
  final List<WaterfallItem> items;
  final ChartTheme theme;
  final bool showConnectors;
  final bool showLabels;
  final bool showRunningTotal;
  final Color increaseColor;
  final Color decreaseColor;
  final Color totalColor;
  final double barWidthFraction;

  WaterfallChartConfig({
    required this.items,
    this.theme = ChartTheme.light,
    this.showConnectors = true,
    this.showLabels = true,
    this.showRunningTotal = false,
    this.increaseColor = const Color(0xFF4CAF50),
    this.decreaseColor = const Color(0xFFF44336),
    this.totalColor = const Color(0xFF2196F3),
    this.barWidthFraction = 0.65,
    super.title,
    super.tooltip,
    super.legend,
    super.toolbox,
    super.grid,
  }) : super(type: ChartType.waterfall, series: const []);

  @override
  Widget buildChart() => WaterfallChartWidget(config: this);

  factory WaterfallChartConfig.fromJson(Map<String, dynamic> json) {
    final raw = json['series'] as List? ?? [];
    final items = raw.isEmpty
        ? <WaterfallItem>[]
        : ((raw.first as Map<String, dynamic>)['data'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(WaterfallItem.fromJson)
            .toList();

    Color? _col(String? k) {
      if (k == null) return null;
      try { return colorCache.resolve(k); } catch (_) { return null; }
    }

    return WaterfallChartConfig(
      items: items,
      showConnectors: json['showConnectors'] as bool? ?? true,
      showLabels: json['showLabels'] as bool? ?? true,
      showRunningTotal: json['showRunningTotal'] as bool? ?? false,
      increaseColor: _col(json['increaseColor']?.toString()) ?? const Color(0xFF4CAF50),
      decreaseColor: _col(json['decreaseColor']?.toString()) ?? const Color(0xFFF44336),
      totalColor: _col(json['totalColor']?.toString()) ?? const Color(0xFF2196F3),
      barWidthFraction: (json['barWidthFraction'] as num?)?.toDouble() ?? 0.65,
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'waterfall'};
}

// ─────────────────────────────────────────────────────────
// Computed item (running totals)
// ─────────────────────────────────────────────────────────

class _Computed {
  final WaterfallItem item;
  final double base;  // bottom of bar in data space
  final double top;   // top of bar in data space
  _Computed({required this.item, required this.base, required this.top});
}

List<_Computed> _compute(List<WaterfallItem> items) {
  final result = <_Computed>[];
  double running = 0;
  for (final item in items) {
    if (item.itemType == WaterfallItemType.total) {
      result.add(_Computed(item: item, base: 0, top: item.value));
      running = item.value;
    } else {
      final base = running;
      running += item.value;
      final top = running;
      result.add(_Computed(
        item: item,
        base: item.value >= 0 ? base : top,
        top: item.value >= 0 ? top : base,
      ));
    }
  }
  return result;
}

// ─────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────

class WaterfallChartWidget extends StatefulWidget {
  final WaterfallChartConfig config;
  const WaterfallChartWidget({super.key, required this.config});

  @override
  State<WaterfallChartWidget> createState() => _WaterfallState();
}

class _WaterfallState extends State<WaterfallChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _hoveredIndex = -1;
  Offset _hoverPos = Offset.zero;

  WaterfallChartConfig get cfg => widget.config;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final computed = _compute(cfg.items);

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
                _hoveredIndex = _hitTest(e.localPosition, sz, computed);
                _hoverPos = e.localPosition;
              }),
              onExit: (_) => setState(() => _hoveredIndex = -1),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => setState(() =>
                    _hoveredIndex = _hitTest(d.localPosition, sz, computed)),
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _WaterfallPainter(
                      config: cfg,
                      computed: computed,
                      progress: _anim.value,
                      hoveredIndex: _hoveredIndex,
                    ),
                  ),
                ),
              ),
            ),
            if (_hoveredIndex >= 0)
              _buildTooltip(sz, computed),
          ]);
        }),
      ),
    ]);
  }

  int _hitTest(Offset pos, Size sz, List<_Computed> computed) {
    final sp = cfg.theme.spacing;
    final vp = _makeVp(sz, computed, sp);
    final slotW = vp.width / computed.length;
    final barW = slotW * cfg.barWidthFraction;
    for (int i = 0; i < computed.length; i++) {
      final c = computed[i];
      final cx = vp.left + (i + 0.5) * slotW;
      final y1 = vp.toCanvasY(c.top);
      final y2 = vp.toCanvasY(c.base);
      if (pos.dx >= cx - barW / 2 && pos.dx <= cx + barW / 2 &&
          pos.dy >= math.min(y1, y2) && pos.dy <= math.max(y1, y2)) return i;
    }
    return -1;
  }

  ChartViewport _makeVp(Size sz, List<_Computed> computed, ChartSpacing sp) {
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final c in computed) {
      if (c.base < minY) minY = c.base;
      if (c.top > maxY) maxY = c.top;
    }
    final pad = (maxY - minY) * 0.12 + 1;
    return ChartViewport(
      left: sp.chartPaddingLeft, top: sp.chartPaddingTop,
      right: sz.width - sp.chartPaddingRight,
      bottom: sz.height - sp.chartPaddingBottom,
      dataMinX: 0, dataMaxX: computed.length.toDouble(),
      dataMinY: (minY - pad).clamp(double.negativeInfinity, 0),
      dataMaxY: maxY + pad,
    );
  }

  Widget _buildTooltip(Size sz, List<_Computed> computed) {
    final c = computed[_hoveredIndex];
    final sign = c.item.value >= 0 ? '+' : '';
    double x = (_hoverPos.dx + 14).clamp(0, sz.width - 180.0);
    double y = (_hoverPos.dy - 60).clamp(0, sz.height - 90.0);
    return Positioned(
      left: x, top: y,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
              color: cfg.theme.tooltipBackgroundColor,
              borderRadius: BorderRadius.circular(7)),
          child: DefaultTextStyle(
            style: cfg.theme.typography.tooltipStyle
                .copyWith(color: cfg.theme.tooltipTextColor),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(c.item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('$sign${c.item.value.toStringAsFixed(0)}'),
              Text('Running total: ${c.top.toStringAsFixed(0)}'),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────

class _WaterfallPainter extends ChartPainterBase {
  final WaterfallChartConfig config;
  final List<_Computed> computed;
  final double progress;
  final int hoveredIndex;

  _WaterfallPainter({
    required this.config,
    required this.computed,
    required this.progress,
    required this.hoveredIndex,
  }) : super(theme: config.theme);

  @override
  bool shouldRepaintChart(covariant _WaterfallPainter old) =>
      old.progress != progress || old.hoveredIndex != hoveredIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (computed.isEmpty) return;
    final sp = theme.spacing;

    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final c in computed) {
      if (c.base < minY) minY = c.base;
      if (c.top > maxY) maxY = c.top;
    }
    final pad = (maxY - minY) * 0.12 + 1;
    final vp = ChartViewport(
      left: sp.chartPaddingLeft, top: sp.chartPaddingTop,
      right: size.width - sp.chartPaddingRight,
      bottom: size.height - sp.chartPaddingBottom,
      dataMinX: 0, dataMaxX: computed.length.toDouble(),
      dataMinY: (minY - pad).clamp(double.negativeInfinity, 0),
      dataMaxY: maxY + pad,
    );

    final yTicks = ChartDataProcessor.niceYTicks(vp.dataMinY, vp.dataMaxY);
    drawHorizontalGrid(canvas, vp, yTicks);
    drawYAxisLabels(canvas, vp, yTicks, (v) => v.toStringAsFixed(0));

    // Zero line
    if (vp.dataMinY < 0) {
      final zy = vp.toCanvasY(0);
      canvas.drawLine(Offset(vp.left, zy), Offset(vp.right, zy),
          paintCache.stroke(theme.axisColor, 1.5));
    }

    final slotW = vp.width / computed.length;
    final barW = slotW * config.barWidthFraction;

    double? prevBarRight;
    double? prevBarTopY;

    for (int i = 0; i < computed.length; i++) {
      final c = computed[i];
      final cx = vp.left + (i + 0.5) * slotW;
      final x1 = cx - barW / 2;
      final topData = c.top;
      final baseData = c.base;

      // Animated bar height
      final topY = vp.toCanvasY(topData);
      final baseY = vp.toCanvasY(baseData);
      final barH = (baseY - topY).abs() * progress;
      final barTop = math.min(topY, baseY);

      Color color;
      if (c.item.color != null) {
        color = colorCache.resolve(c.item.color!);
      } else {
        color = switch (c.item.itemType) {
          WaterfallItemType.increase => config.increaseColor,
          WaterfallItemType.decrease => config.decreaseColor,
          WaterfallItemType.total    => config.totalColor,
        };
      }
      final isHov = i == hoveredIndex;
      if (isHov) color = Color.lerp(color, Colors.white, 0.2)!;

      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x1, barTop, barW, barH),
        const Radius.circular(3),
      );
      canvas.drawRRect(rr, Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true);
      canvas.drawRRect(rr, paintCache.stroke(Colors.white.withOpacity(0.3), 0.8));

      // Connector line to next bar
      if (config.showConnectors && i < computed.length - 1) {
        final connY = vp.toCanvasY(c.item.itemType == WaterfallItemType.total ? c.top : c.top);
        canvas.drawLine(
          Offset(x1 + barW, connY),
          Offset(x1 + slotW, connY),
          paintCache.stroke(theme.axisColor.withOpacity(0.5), 1),
        );
      }

      // Label above bar
      if (config.showLabels) {
        final sign = c.item.value >= 0 && c.item.itemType != WaterfallItemType.total ? '+' : '';
        final label = '$sign${c.item.value.toStringAsFixed(0)}';
        final tp = textPainterCache.get(
          label,
          theme.typography.axisLabelStyle.copyWith(color: color, fontSize: 9.5),
        );
        tp.paint(canvas, Offset(cx - tp.width / 2, barTop - tp.height - 2));
      }

      // X-axis label
      final labelTp = textPainterCache.get(
        c.item.name,
        theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor),
        maxWidth: slotW - 4,
        align: TextAlign.center,
      );
      labelTp.paint(canvas, Offset(cx - labelTp.width / 2, vp.bottom + 4));
    }

    // Axes
    canvas.drawLine(Offset(vp.left, vp.bottom), Offset(vp.right, vp.bottom), axisPaint);
    canvas.drawLine(Offset(vp.left, vp.top), Offset(vp.left, vp.bottom), axisPaint);
  }
}

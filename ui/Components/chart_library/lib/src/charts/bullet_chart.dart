/// Bullet chart — compact KPI bar showing actual vs target with qualitative bands.
///
/// Originally designed by Stephen Few as a replacement for dashboard gauges.
/// Shows: (1) qualitative bands (poor/satisfactory/good), (2) actual value bar,
/// (3) target/comparative measure marker.
///
/// JSON:
/// ```json
/// {
///   "type": "bullet",
///   "series": [{
///     "data": [
///       { "label": "Revenue",  "value": 270, "target": 300, "max": 400,
///         "bands": [{"to":200,"color":"#F44336"},{"to":280,"color":"#FF9800"},{"to":400,"color":"#4CAF50"}] },
///       { "label": "Margin",   "value": 23,  "target": 25,  "max": 35 },
///       { "label": "Customers","value": 1850,"target": 2000,"max": 2500}
///     ]
///   }]
/// }
/// ```
library bullet_chart;

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
import '../core/utils/chart_cache.dart';

// ─────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────

class BulletBand {
  final double from;
  final double to;
  final Color color;
  const BulletBand({required this.from, required this.to, required this.color});
  factory BulletBand.fromJson(Map<String, dynamic> j) => BulletBand(
    from: (j['from'] as num?)?.toDouble() ?? 0,
    to: (j['to'] as num?)?.toDouble() ?? 100,
    color: colorCache.resolve(j['color']?.toString() ?? '#CCCCCC'),
  );
}

class BulletItem {
  final String label;
  final double value;
  final double target;
  final double max;
  final List<BulletBand> bands;
  const BulletItem({
    required this.label, required this.value, required this.target, required this.max,
    this.bands = const [],
  });
  factory BulletItem.fromJson(Map<String, dynamic> j) => BulletItem(
    label: j['label']?.toString() ?? '',
    value: (j['value'] as num?)?.toDouble() ?? 0,
    target: (j['target'] as num?)?.toDouble() ?? 0,
    max: (j['max'] as num?)?.toDouble() ?? 100,
    bands: (j['bands'] as List? ?? []).whereType<Map<String,dynamic>>().map(BulletBand.fromJson).toList(),
  );
}

// ─────────────────────────────────────────────────────────
// Config
// ─────────────────────────────────────────────────────────

class BulletChartConfig extends BaseChartConfig {
  final List<BulletItem> items;
  final ChartTheme theme;
  final double barHeightFraction;
  final bool showLabels;
  final bool showValues;

  BulletChartConfig({
    required this.items,
    this.theme = ChartTheme.light,
    this.barHeightFraction = 0.35,
    this.showLabels = true,
    this.showValues = true,
    super.title, super.tooltip, super.legend, super.toolbox, super.grid,
  }) : super(type: ChartType.bullet, series: const []);

  @override
  Widget buildChart() => BulletChartWidget(config: this);

  factory BulletChartConfig.fromJson(Map<String, dynamic> json) {
    final raw = json['series'] as List? ?? [];
    final items = raw.isEmpty ? <BulletItem>[]
        : ((raw.first as Map<String, dynamic>)['data'] as List? ?? [])
            .whereType<Map<String, dynamic>>().map(BulletItem.fromJson).toList();
    return BulletChartConfig(
      items: items,
      showLabels: json['showLabels'] as bool? ?? true,
      showValues: json['showValues'] as bool? ?? true,
      barHeightFraction: (json['barHeightFraction'] as num?)?.toDouble() ?? 0.35,
      title: json['title'] != null ? TitlesData.fromJson(json['title']) : null,
      tooltip: json['tooltip'] != null ? ChartTooltip.fromJson(json['tooltip']) : null,
      legend: json['legend'] != null ? ChartLegend.fromJson(json['legend']) : null,
      toolbox: json['toolbox'] != null ? ChartToolbox.fromJson(json['toolbox']) : null,
      grid: json['grid'] != null ? GridData.fromJson(json['grid']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'bullet'};
}

// ─────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────

class BulletChartWidget extends StatefulWidget {
  final BulletChartConfig config;
  const BulletChartWidget({super.key, required this.config});
  @override State<BulletChartWidget> createState() => _BulletState();
}

class _BulletState extends State<BulletChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _hovIdx = -1;
  Offset _hoverPos = Offset.zero;

  BulletChartConfig get cfg => widget.config;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
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
            onHover: (e) => setState(() {
              final rowH = sz.height / cfg.items.length;
              _hovIdx = ((e.localPosition.dy) / rowH).floor().clamp(0, cfg.items.length - 1);
              _hoverPos = e.localPosition;
            }),
            onExit: (_) => setState(() => _hovIdx = -1),
            child: RepaintBoundary(child: CustomPaint(
              size: Size.infinite,
              painter: _BulletPainter(config: cfg, progress: _anim.value, hovIdx: _hovIdx),
            )),
          ),
          if (_hovIdx >= 0) _buildTooltip(sz),
        ]);
      })),
    ]);
  }

  Widget _buildTooltip(Size sz) {
    final item = cfg.items[_hovIdx];
    final pct = (item.value / item.max * 100).toStringAsFixed(1);
    final tpct = (item.target / item.max * 100).toStringAsFixed(1);
    double x = (_hoverPos.dx + 12).clamp(0, sz.width - 200.0);
    double y = (_hoverPos.dy - 70).clamp(0, sz.height - 100.0);
    return Positioned(left: x, top: y, child: IgnorePointer(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: cfg.theme.tooltipBackgroundColor, borderRadius: BorderRadius.circular(7)),
      child: DefaultTextStyle(style: cfg.theme.typography.tooltipStyle.copyWith(color: cfg.theme.tooltipTextColor),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(item.label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Actual:  ${item.value.toStringAsFixed(0)} ($pct%)'),
          Text('Target:  ${item.target.toStringAsFixed(0)} ($tpct%)'),
          Text('vs Target: ${((item.value / item.target - 1) * 100).toStringAsFixed(1)}%'),
        ]),
      ),
    )));
  }
}

// ─────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────

class _BulletPainter extends ChartPainterBase {
  final BulletChartConfig config;
  final double progress;
  final int hovIdx;

  _BulletPainter({required this.config, required this.progress, required this.hovIdx})
      : super(theme: config.theme);

  @override bool shouldRepaintChart(covariant _BulletPainter old) =>
      old.progress != progress || old.hovIdx != hovIdx;

  @override
  void paint(Canvas canvas, Size size) {
    if (config.items.isEmpty) return;
    const labelW = 90.0, padR = 16.0, padV = 8.0;
    final n = config.items.length;
    final rowH = (size.height - padV * 2) / n;

    for (int i = 0; i < n; i++) {
      final item = config.items[i];
      final isHov = i == hovIdx;
      final rowY = padV + i * rowH;
      final chartX = labelW;
      final chartW = size.width - labelW - padR;
      final barH = rowH * config.barHeightFraction;
      final barY = rowY + (rowH - barH) / 2;

      // Background bands
      final hasBands = item.bands.isNotEmpty;
      if (hasBands) {
        for (final band in item.bands) {
          final x1 = chartX + (band.from / item.max) * chartW;
          final x2 = chartX + (band.to / item.max) * chartW;
          canvas.drawRect(Rect.fromLTWH(x1, rowY + rowH * 0.1, x2 - x1, rowH * 0.8),
              Paint()..color = band.color.withOpacity(0.3)..style = PaintingStyle.fill);
        }
      } else {
        // Default 3-band grey gradient
        for (int b = 0; b < 3; b++) {
          final x1 = chartX + b / 3 * chartW;
          final bw = chartW / 3;
          canvas.drawRect(Rect.fromLTWH(x1, rowY + rowH * 0.1, bw, rowH * 0.8),
              Paint()..color = Color.lerp(const Color(0xFFE0E0E0), const Color(0xFF9E9E9E), b / 2)!.withOpacity(0.4)
                ..style = PaintingStyle.fill);
        }
      }

      // Actual bar
      final actualW = (item.value / item.max * chartW * progress).clamp(0.0, chartW);
      final barColor = isHov
          ? Color.lerp(theme.palette.colorObjectAt(0), Colors.white, 0.2)!
          : theme.palette.colorObjectAt(0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(chartX, barY, actualW, barH), const Radius.circular(2)),
        Paint()..color = barColor..style = PaintingStyle.fill..isAntiAlias = true,
      );

      // Target marker (vertical line)
      final targetX = chartX + (item.target / item.max * chartW).clamp(0.0, chartW);
      canvas.drawLine(
        Offset(targetX, rowY + rowH * 0.15),
        Offset(targetX, rowY + rowH * 0.85),
        paintCache.stroke(const Color(0xFF1A1A1A), 3),
      );

      // Label
      if (config.showLabels) {
        final tp = textPainterCache.get(item.label,
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 11),
          maxWidth: labelW - 4, align: TextAlign.right);
        tp.paint(canvas, Offset(labelW - tp.width - 4, rowY + rowH / 2 - tp.height / 2));
      }

      // Value label
      if (config.showValues) {
        final vtp = textPainterCache.get(item.value.toStringAsFixed(0),
          theme.typography.axisLabelStyle.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600));
        if (actualW > vtp.width + 6) {
          vtp.paint(canvas, Offset(chartX + actualW - vtp.width - 4, barY + barH / 2 - vtp.height / 2));
        }
      }
    }
  }
}

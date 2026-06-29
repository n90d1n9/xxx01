/// Treemap Variants — 3 specialised treemap chart types.
///
/// Charts:
///   • [TreemapSunburstMorphConfig]  — animated morph between treemap and sunburst
///   • [TreemapGradientConfig]       — treemap with per-node value-driven gradient fill
///   • [TreemapParentLabelsConfig]   — treemap that shows sticky parent (group) labels
///
/// All share the squarified layout algorithm from the base treemap chart.
/// Data model: [TreemapNode] (name, value, children, color — same as base).
library treemap_variants;

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../core/config/base_config.dart';
import '../core/config/chart_type.dart';
import '../core/config/chart_theme.dart';
import '../core/config/title.dart';
import '../core/config/tooltip.dart';
import '../core/config/legend.dart';
import '../core/config/chart_model.dart';
import '../core/painters/chart_painter_base.dart';
import '../core/utils/chart_cache.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SHARED: TreemapNode model (self-contained — no import from base treemap)
// ═══════════════════════════════════════════════════════════════════════════

class TreemapNodeV2 {
  final String name;
  final double value;
  final List<TreemapNodeV2> children;
  final String? color;

  const TreemapNodeV2({
    required this.name,
    required this.value,
    this.children = const [],
    this.color,
  });

  bool get isLeaf => children.isEmpty;

  double get totalValue => isLeaf
      ? value
      : children.fold(0.0, (s, c) => s + c.totalValue);

  factory TreemapNodeV2.fromJson(Map<String, dynamic> j) {
    final ch = (j['children'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TreemapNodeV2.fromJson)
        .toList();
    return TreemapNodeV2(
      name: j['name']?.toString() ?? '',
      value: (j['value'] as num?)?.toDouble() ??
          ch.fold(0.0, (s, c) => s + c.value),
      children: ch,
      color: j['color']?.toString(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED: Squarified layout
// ═══════════════════════════════════════════════════════════════════════════

class _LR {
  final TreemapNodeV2 node;
  final Rect rect;
  final int depth;
  final TreemapNodeV2? parent;
  const _LR(this.node, this.rect, this.depth, [this.parent]);
}

List<_LR> _squarify(
    List<TreemapNodeV2> nodes, Rect bounds, int depth, [TreemapNodeV2? parent]) {
  if (nodes.isEmpty || bounds.width < 1 || bounds.height < 1) return const [];

  final sorted = [...nodes]..sort((a, b) => b.value.compareTo(a.value));
  final total = sorted.fold(0.0, (s, n) => s + n.value);
  if (total == 0) return const [];

  final result = <_LR>[];
  final area = bounds.width * bounds.height;
  final scale = area / total;
  Rect rem = bounds;
  int start = 0;

  while (start < sorted.length) {
    int end = start + 1;
    double rowSum = sorted[start].value * scale;
    while (end < sorted.length) {
      final newSum = rowSum + sorted[end].value * scale;
      if (_worstAspect(sorted, start, end - 1, rowSum, rem) <
          _worstAspect(sorted, start, end, newSum, rem) &&
          end > start + 1) break;
      rowSum = newSum;
      end++;
    }

    final isH = rem.width >= rem.height;
    final rowH = rowSum / (isH ? rem.width : rem.height);
    double pos = isH ? rem.left : rem.top;

    for (int i = start; i < end; i++) {
      final nodeArea = sorted[i].value * scale;
      final len = rowH == 0 ? 0 : nodeArea / rowH;
      late Rect r;
      if (isH) {
        r = Rect.fromLTWH(pos, rem.top, len, rowH);
        pos += len;
      } else {
        r = Rect.fromLTWH(rem.left, pos, rowH, len);
        pos += len;
      }
      result.add(_LR(sorted[i], r, depth, parent));
      if (!sorted[i].isLeaf) {
        result.addAll(
            _squarify(sorted[i].children, r.deflate(1), depth + 1, sorted[i]));
      }
    }

    if (isH) {
      rem = Rect.fromLTRB(rem.left, rem.top + rowH, rem.right, rem.bottom);
    } else {
      rem = Rect.fromLTRB(rem.left + rowH, rem.top, rem.right, rem.bottom);
    }
    start = end;
  }
  return result;
}

double _worstAspect(List<TreemapNodeV2> nodes, int s, int e, double rowSum, Rect b) {
  final isH = b.width >= b.height;
  final rowH = rowSum / (isH ? b.width : b.height);
  if (rowH == 0) return double.infinity;
  double worst = 0;
  for (int i = s; i <= e && i < nodes.length; i++) {
    final len = nodes[i].value * (b.width * b.height) / rowSum;
    final r = rowH > len ? rowH / len : len / rowH;
    if (r > worst) worst = r;
  }
  return worst;
}

// Sunburst layout helpers (for morph target)
class _SunArc {
  final TreemapNodeV2 node;
  final double startAngle, sweepAngle;
  final double innerR, outerR;
  final int depth;
  final Color color;
  const _SunArc(this.node, this.startAngle, this.sweepAngle,
      this.innerR, this.outerR, this.depth, this.color);
}

List<_SunArc> _buildSunArcs(
    List<TreemapNodeV2> nodes, double startAngle, double sweepAngle,
    double innerR, double outerR, int depth, ChartTheme theme, int colorOffset) {
  final result = <_SunArc>[];
  final total = nodes.fold(0.0, (s, n) => s + n.value);
  if (total == 0) return result;
  double angle = startAngle;
  for (int i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    final sw = n.value / total * sweepAngle;
    Color c;
    try {
      c = n.color != null ? colorCache.resolve(n.color!) : theme.palette.colorObjectAt(colorOffset + i);
    } catch (_) {
      c = theme.palette.colorObjectAt(colorOffset + i);
    }
    result.add(_SunArc(n, angle, sw, innerR, outerR, depth, c));
    if (n.children.isNotEmpty) {
      result.addAll(_buildSunArcs(
          n.children, angle, sw, outerR, outerR + (outerR - innerR) * 0.6,
          depth + 1, theme, colorOffset + i));
    }
    angle += sw;
  }
  return result;
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. TREEMAP ↔ SUNBURST MORPH
// ═══════════════════════════════════════════════════════════════════════════
/// Animated morph between a squarified treemap (morphT = 0) and a
/// sunburst chart (morphT = 1). Each leaf node interpolates its geometry
/// between a rectangle and a wedge arc. A toggle button drives the animation.
///
/// JSON:
/// ```json
/// { "type": "treemapSunburstMorph",
///   "series": [{ "data": [
///     { "name": "A", "value": 40, "children": [
///       { "name": "A1", "value": 25 }, { "name": "A2", "value": 15 }
///     ]},
///     { "name": "B", "value": 35 },
///     { "name": "C", "value": 25 }
///   ]}]}
/// ```
class TreemapSunburstMorphConfig extends BaseChartConfig {
  final List<TreemapNodeV2> nodes;
  final Duration morphDuration;
  final ChartTheme theme;

  TreemapSunburstMorphConfig({
    required this.nodes,
    this.morphDuration = const Duration(milliseconds: 900),
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.treemapSunburstMorph, series: const []);

  @override Widget buildChart() => _TSMorphWidget(config: this);

  factory TreemapSunburstMorphConfig.fromJson(Map<String, dynamic> j) {
    final raw = j['series'] is List && (j['series'] as List).isNotEmpty
        ? ((j['series'] as List).first as Map)['data'] as List? ?? []
        : j['nodes'] as List? ?? [];
    final nodes = raw.whereType<Map<String, dynamic>>()
        .map(TreemapNodeV2.fromJson).toList();
    return TreemapSunburstMorphConfig(nodes: nodes,
        title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'treemapSunburstMorph'};
}

class _TSMorphWidget extends StatefulWidget {
  final TreemapSunburstMorphConfig config;
  const _TSMorphWidget({required this.config});
  @override State<_TSMorphWidget> createState() => _TSMorphState();
}

class _TSMorphState extends State<_TSMorphWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _isSunburst = false;

  TreemapSunburstMorphConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: cfg.morphDuration);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
    _ctrl.addListener(() => setState(() {}));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _toggle() {
    if (_isSunburst) { _ctrl.reverse(); }
    else { _ctrl.forward(); }
    _isSunburst = !_isSunburst;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (cfg.title?.text != null)
        Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
              .copyWith(color: cfg.theme.titleColor))),
      Expanded(child: RepaintBoundary(child: CustomPaint(
        size: Size.infinite,
        painter: _TSMorphPainter(cfg: cfg, morphT: _anim.value),
      ))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          onTap: _toggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
            decoration: BoxDecoration(
                color: cfg.theme.seriesColor(0),
                borderRadius: BorderRadius.circular(22)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_isSunburst ? Icons.grid_view : Icons.pie_chart_outline,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(_isSunburst ? 'Switch to Treemap' : 'Switch to Sunburst',
                  style: cfg.theme.typography.axisLabelStyle.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
          ),
        )),
    ]);
  }
}

class _TSMorphPainter extends ChartPainterBase {
  final TreemapSunburstMorphConfig cfg;
  final double morphT;
  _TSMorphPainter({required this.cfg, required this.morphT})
      : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _TSMorphPainter o) =>
      o.morphT != morphT;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    if (cfg.nodes.isEmpty) return;

    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
    final treeLayout = _squarify(cfg.nodes, bounds, 0);
    // Only leaf cells
    final leaves = treeLayout.where((lr) => lr.node.isLeaf).toList();

    // Sunburst arcs for all nodes (including branches)
    final cx = size.width / 2, cy = size.height / 2;
    final maxR = math.min(cx, cy) * 0.88;
    final ringW = maxR / math.max(1, _maxDepth(cfg.nodes) + 1);
    final sunArcs = _buildSunArcs(cfg.nodes, -math.pi / 2, 2 * math.pi,
        0, ringW, 0, theme, 0);

    // Build color map: leaf name → color (from treemap palette)
    final total = cfg.nodes.fold(0.0, (s, n) => s + n.value);
    final colorMap = <String, Color>{};
    for (int i = 0; i < leaves.length; i++) {
      final lr = leaves[i];
      Color c;
      try { c = lr.node.color != null ? colorCache.resolve(lr.node.color!) : theme.palette.colorObjectAt(i); }
      catch (_) { c = theme.palette.colorObjectAt(i); }
      colorMap[lr.node.name] = c;
    }

    // Draw: each leaf morphs rect → wedge
    for (final lr in leaves) {
      final color = colorMap[lr.node.name] ?? theme.seriesColor(0);
      // Find matching sunburst arc
      final arc = _findArc(sunArcs, lr.node.name);

      if (arc == null || morphT < 0.01) {
        // Pure treemap
        final rr = RRect.fromRectAndRadius(lr.rect, Radius.circular(morphT * 4));
        canvas.drawRRect(rr, Paint()..color = color..style = PaintingStyle.fill..isAntiAlias = true);
        canvas.drawRRect(rr, Paint()..color = theme.backgroundColor..style = PaintingStyle.stroke
            ..strokeWidth = 1.5..isAntiAlias = true);
        _drawLabel(canvas, lr.node.name, lr.rect, color);
      } else if (morphT > 0.99) {
        // Pure sunburst wedge
        _paintArc(canvas, cx, cy, arc, color, 1.0);
        _drawArcLabel(canvas, cx, cy, arc, lr.node.name, color);
      } else {
        // Cross-fade: fade treemap out, fade sunburst in
        final opacity1 = (1 - morphT * 2).clamp(0.0, 1.0);
        final opacity2 = ((morphT - 0.5) * 2).clamp(0.0, 1.0);

        if (opacity1 > 0) {
          final rr = RRect.fromRectAndRadius(lr.rect, Radius.circular(morphT * 4));
          canvas.drawRRect(rr, Paint()..color = color.withOpacity(opacity1)
              ..style = PaintingStyle.fill..isAntiAlias = true);
          canvas.drawRRect(rr, Paint()..color = theme.backgroundColor.withOpacity(opacity1)
              ..style = PaintingStyle.stroke..strokeWidth = 1.5..isAntiAlias = true);
        }
        if (opacity2 > 0) {
          _paintArc(canvas, cx, cy, arc, color, opacity2);
          if (opacity2 > 0.5) {
            _drawArcLabel(canvas, cx, cy, arc, lr.node.name, color);
          }
        }
      }
    }
  }

  int _maxDepth(List<TreemapNodeV2> nodes, [int d = 0]) {
    int max = d;
    for (final n in nodes) {
      if (n.children.isNotEmpty) {
        final cd = _maxDepth(n.children, d + 1);
        if (cd > max) max = cd;
      }
    }
    return max;
  }

  _SunArc? _findArc(List<_SunArc> arcs, String name) {
    for (final a in arcs) if (a.node.name == name) return a;
    return null;
  }

  void _paintArc(Canvas canvas, double cx, double cy,
      _SunArc arc, Color color, double opacity) {
    final path = Path()
      ..moveTo(cx + arc.innerR * math.cos(arc.startAngle),
               cy + arc.innerR * math.sin(arc.startAngle))
      ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: arc.outerR),
          arc.startAngle, arc.sweepAngle, false)
      ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: arc.innerR),
          arc.startAngle + arc.sweepAngle, -arc.sweepAngle, false)
      ..close();
    canvas.drawPath(path,
        Paint()..color = color.withOpacity(opacity)..style = PaintingStyle.fill..isAntiAlias = true);
    canvas.drawPath(path,
        Paint()..color = theme.backgroundColor.withOpacity(opacity)..style = PaintingStyle.stroke
          ..strokeWidth = 1.2..isAntiAlias = true);
  }

  void _drawLabel(Canvas canvas, String name, Rect rect, Color bg) {
    if (rect.width < 36 || rect.height < 18) return;
    final luminance = bg.computeLuminance();
    final tc = luminance > 0.35 ? Colors.black87 : Colors.white;
    final tp = textPainterCache.get(name,
        theme.typography.dataLabelStyle.copyWith(
            color: tc, fontSize: 9.5, fontWeight: FontWeight.w600),
        maxWidth: rect.width - 8);
    canvas.save();
    canvas.clipRect(rect);
    tp.paint(canvas, Offset(rect.left + 4, rect.top + 4));
    canvas.restore();
  }

  void _drawArcLabel(Canvas canvas, double cx, double cy,
      _SunArc arc, String name, Color color) {
    if (arc.sweepAngle.abs() < 0.2) return;
    final midR = (arc.innerR + arc.outerR) / 2;
    final midA = arc.startAngle + arc.sweepAngle / 2;
    final lx = cx + midR * math.cos(midA);
    final ly = cy + midR * math.sin(midA);
    final luminance = color.computeLuminance();
    final tc = luminance > 0.35 ? Colors.black87 : Colors.white;
    final tp = textPainterCache.get(name,
        theme.typography.dataLabelStyle.copyWith(color: tc, fontSize: 8.5));
    tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. TREEMAP WITH GRADIENT MAPPING
// ═══════════════════════════════════════════════════════════════════════════
/// Treemap where each cell's fill is a gradient mapped from its value
/// through a configurable multi-stop colour scale. Two modes:
///   • 'linear'   — gradient fills cell top-to-bottom
///   • 'radial'   — gradient radiates from cell centre
/// Optionally can use a single global value range or per-group ranges.
///
/// JSON:
/// ```json
/// { "type": "treemapGradient",
///   "colorScale": ["#1565C0","#42A5F5","#E3F2FD"],
///   "gradientMode": "linear",
///   "series": [{ "data": [
///     { "name":"Alpha","value":80,"children":[
///       {"name":"A1","value":50},{"name":"A2","value":30}]},
///     { "name":"Beta","value":60 }
///   ]}]}
/// ```
class TreemapGradientConfig extends BaseChartConfig {
  final List<TreemapNodeV2> nodes;
  final List<String> colorScale;   // hex stops low→high
  final String gradientMode;       // 'linear' | 'radial'
  final bool showLabels, showValues;
  final ChartTheme theme;

  TreemapGradientConfig({
    required this.nodes,
    this.colorScale = const ['#1565C0', '#42A5F5', '#E3F2FD'],
    this.gradientMode = 'linear',
    this.showLabels = true,
    this.showValues = true,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.treemapGradient, series: const []);

  @override Widget buildChart() => _TGradWidget(config: this);

  factory TreemapGradientConfig.fromJson(Map<String, dynamic> j) {
    final raw = j['series'] is List && (j['series'] as List).isNotEmpty
        ? ((j['series'] as List).first as Map)['data'] as List? ?? []
        : j['nodes'] as List? ?? [];
    final nodes = raw.whereType<Map<String, dynamic>>()
        .map(TreemapNodeV2.fromJson).toList();
    return TreemapGradientConfig(
      nodes: nodes,
      colorScale: (j['colorScale'] as List? ?? ['#1565C0', '#42A5F5', '#E3F2FD'])
          .map((e) => e.toString()).toList(),
      gradientMode: j['gradientMode']?.toString() ?? 'linear',
      showLabels: j['showLabels'] as bool? ?? true,
      showValues: j['showValues'] as bool? ?? true,
      title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
      tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'treemapGradient'};
}

class _TGradWidget extends StatefulWidget {
  final TreemapGradientConfig config;
  const _TGradWidget({required this.config});
  @override State<_TGradWidget> createState() => _TGradState();
}

class _TGradState extends State<_TGradWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  String? _hovered;
  Offset _hovPos = Offset.zero;

  TreemapGradientConfig get cfg => widget.config;

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
      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      final bounds = Rect.fromLTWH(0, 0, sz.width, sz.height);
      final layout = _squarify(cfg.nodes, bounds, 0);
      return Stack(children: [
        MouseRegion(
          onHover: (e) {
            final hit = layout.where((lr) => lr.node.isLeaf && lr.rect.contains(e.localPosition)).firstOrNull;
            if (hit?.node.name != _hovered) setState(() { _hovered = hit?.node.name; _hovPos = e.localPosition; });
          },
          onExit: (_) => setState(() => _hovered = null),
          child: RepaintBoundary(child: CustomPaint(
            size: Size.infinite,
            painter: _TGradPainter(cfg: cfg, progress: _anim.value, hovered: _hovered),
          )),
        ),
        if (_hovered != null) _tooltip(sz, layout),
      ]);
    })),
    _buildColorBar(),
  ]);

  Widget _tooltip(Size sz, List<_LR> layout) {
    final lr = layout.firstWhere((lr) => lr.node.name == _hovered, orElse: () => _LR(TreemapNodeV2(name:'', value:0), Rect.zero, 0));
    return Positioned(left: (_hovPos.dx + 12).clamp(0, sz.width - 160),
        top: (_hovPos.dy - 44).clamp(0, sz.height - 60),
      child: IgnorePointer(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: cfg.theme.tooltipBackgroundColor,
            borderRadius: BorderRadius.circular(7),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)]),
        child: Text('${lr.node.name}\n${lr.node.value.toStringAsFixed(1)}',
            style: cfg.theme.typography.tooltipStyle
                .copyWith(color: cfg.theme.tooltipTextColor)),
      )));
  }

  Widget _buildColorBar() {
    final stops = cfg.colorScale.map((h) {
      try { return colorCache.resolve(h); } catch (_) { return Colors.blue; }
    }).toList();
    if (stops.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(children: [
        Text('Low ', style: cfg.theme.typography.axisLabelStyle
            .copyWith(color: cfg.theme.axisLabelColor, fontSize: 8.5)),
        Expanded(child: Container(height: 8,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: stops),
                borderRadius: BorderRadius.circular(4)))),
        Text(' High', style: cfg.theme.typography.axisLabelStyle
            .copyWith(color: cfg.theme.axisLabelColor, fontSize: 8.5)),
      ]));
  }
}

class _TGradPainter extends ChartPainterBase {
  final TreemapGradientConfig cfg;
  final double progress;
  final String? hovered;

  _TGradPainter({required this.cfg, required this.progress, this.hovered})
      : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _TGradPainter o) =>
      o.progress != progress || o.hovered != hovered;

  // Resolve colour scale
  List<Color> get _stops => cfg.colorScale.map((h) {
    try { return colorCache.resolve(h); } catch (_) { return Colors.blue; }
  }).toList();

  Color _scaleColor(double t) {
    final stops = _stops;
    if (stops.isEmpty) return Colors.blue;
    t = t.clamp(0.0, 1.0);
    final s = t * (stops.length - 1);
    final lo = s.floor().clamp(0, stops.length - 2);
    return Color.lerp(stops[lo], stops[lo + 1], s - lo)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    if (cfg.nodes.isEmpty) return;

    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
    final layout = _squarify(cfg.nodes, bounds, 0);
    final leaves = layout.where((lr) => lr.node.isLeaf).toList();
    if (leaves.isEmpty) return;

    final maxVal = leaves.map((lr) => lr.node.value).reduce(math.max).clamp(1.0, 1e18);
    final minVal = leaves.map((lr) => lr.node.value).reduce(math.min);
    final range = (maxVal - minVal).clamp(1.0, 1e18);

    for (int i = 0; i < leaves.length; i++) {
      final lr = leaves[i];
      final t = ((lr.node.value - minVal) / range * progress).clamp(0.0, 1.0);
      final isHov = lr.node.name == hovered;

      // Build gradient shader
      final lo = _scaleColor(t);
      final hi = Color.lerp(_scaleColor(t), Colors.white, 0.4)!;
      final rect = lr.rect.deflate(isHov ? 0 : 0);
      final shader = cfg.gradientMode == 'radial'
          ? RadialGradient(center: Alignment.center,
              colors: [hi, lo]).createShader(rect)
          : LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: isHov ? [hi.withRed(255), lo] : [hi, lo]).createShader(rect);

      final rr = RRect.fromRectAndRadius(rect, const Radius.circular(3));
      canvas.drawRRect(rr,
          Paint()..shader = shader..style = PaintingStyle.fill..isAntiAlias = true);
      canvas.drawRRect(rr,
          Paint()..color = theme.backgroundColor..style = PaintingStyle.stroke
            ..strokeWidth = isHov ? 2.5 : 1.0..isAntiAlias = true);

      // Labels
      if (cfg.showLabels && rect.width > 40 && rect.height > 20) {
        final luminance = lo.computeLuminance();
        final tc = luminance > 0.35 ? Colors.black87 : Colors.white;
        final tp = textPainterCache.get(lr.node.name,
            theme.typography.dataLabelStyle.copyWith(
                color: tc, fontSize: 9.5, fontWeight: FontWeight.w600),
            maxWidth: rect.width - 8);
        canvas.save();
        canvas.clipRect(rect);
        tp.paint(canvas, Offset(rect.left + 4, rect.top + 4));
        if (cfg.showValues && rect.height > 36) {
          final vtp = textPainterCache.get(lr.node.value.toStringAsFixed(0),
              theme.typography.dataLabelStyle.copyWith(color: tc.withOpacity(0.75), fontSize: 9),
              maxWidth: rect.width - 8);
          vtp.paint(canvas, Offset(rect.left + 4, rect.top + 4 + tp.height + 2));
        }
        canvas.restore();
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. TREEMAP SHOW PARENT LABELS
// ═══════════════════════════════════════════════════════════════════════════
/// Treemap that renders sticky parent-level labels across the top of each
/// group rectangle, even when children are visible inside. Two label styles:
///   • header bar  — coloured band at top of parent with name + value
///   • floating    — name label centred over the group, subtly clipped
///
/// JSON:
/// ```json
/// { "type": "treemapParentLabels",
///   "labelMode": "header",
///   "series": [{ "data": [
///     { "name":"Electronics","value":200,
///       "children":[{"name":"TV","value":80},{"name":"Phone","value":120}]},
///     { "name":"Clothing","value":150,
///       "children":[{"name":"Tops","value":90},{"name":"Bottoms","value":60}]}
///   ]}]}
/// ```
class TreemapParentLabelsConfig extends BaseChartConfig {
  final List<TreemapNodeV2> nodes;
  final String labelMode;   // 'header' | 'floating'
  final double headerHeight;
  final bool showChildLabels, showValues;
  final ChartTheme theme;

  TreemapParentLabelsConfig({
    required this.nodes,
    this.labelMode = 'header',
    this.headerHeight = 22,
    this.showChildLabels = true,
    this.showValues = true,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.treemapParentLabels, series: const []);

  @override Widget buildChart() => _TParentWidget(config: this);

  factory TreemapParentLabelsConfig.fromJson(Map<String, dynamic> j) {
    final raw = j['series'] is List && (j['series'] as List).isNotEmpty
        ? ((j['series'] as List).first as Map)['data'] as List? ?? []
        : j['nodes'] as List? ?? [];
    final nodes = raw.whereType<Map<String, dynamic>>()
        .map(TreemapNodeV2.fromJson).toList();
    return TreemapParentLabelsConfig(
      nodes: nodes,
      labelMode: j['labelMode']?.toString() ?? 'header',
      headerHeight: (j['headerHeight'] as num?)?.toDouble() ?? 22,
      showChildLabels: j['showChildLabels'] as bool? ?? true,
      showValues: j['showValues'] as bool? ?? true,
      title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
      tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'treemapParentLabels'};
}

class _TParentWidget extends StatefulWidget {
  final TreemapParentLabelsConfig config;
  const _TParentWidget({required this.config});
  @override State<_TParentWidget> createState() => _TParentState();
}

class _TParentState extends State<_TParentWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  String? _hovered;
  Offset _hovPos = Offset.zero;

  TreemapParentLabelsConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
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
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      final bounds = Rect.fromLTWH(0, 0, sz.width, sz.height);
      final layout = _squarify(cfg.nodes, bounds, 0);
      return Stack(children: [
        MouseRegion(
          onHover: (e) {
            final hit = layout.where((lr) => lr.node.isLeaf && lr.rect.contains(e.localPosition)).firstOrNull;
            if (hit?.node.name != _hovered) setState(() { _hovered = hit?.node.name; _hovPos = e.localPosition; });
          },
          onExit: (_) => setState(() => _hovered = null),
          child: RepaintBoundary(child: CustomPaint(
            size: Size.infinite,
            painter: _TParentPainter(cfg: cfg, progress: _anim.value, hovered: _hovered, layout: layout),
          )),
        ),
        if (_hovered != null) _tooltip(sz, layout),
      ]);
    })),
  ]);

  Widget _tooltip(Size sz, List<_LR> layout) {
    final lr = layout.firstWhere((lr) => lr.node.name == _hovered, orElse: () => _LR(TreemapNodeV2(name:'', value:0), Rect.zero, 0));
    return Positioned(left: (_hovPos.dx + 12).clamp(0, sz.width - 160),
        top: (_hovPos.dy - 44).clamp(0, sz.height - 60),
      child: IgnorePointer(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: cfg.theme.tooltipBackgroundColor,
            borderRadius: BorderRadius.circular(7),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)]),
        child: Text('${lr.node.name}\n${lr.node.value.toStringAsFixed(1)}',
            style: cfg.theme.typography.tooltipStyle
                .copyWith(color: cfg.theme.tooltipTextColor)),
      )));
  }
}

class _TParentPainter extends ChartPainterBase {
  final TreemapParentLabelsConfig cfg;
  final double progress;
  final String? hovered;
  final List<_LR> layout;

  _TParentPainter({required this.cfg, required this.progress,
      this.hovered, required this.layout}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _TParentPainter o) =>
      o.progress != progress || o.hovered != hovered;

  Color _contrast(Color bg) =>
      bg.computeLuminance() > 0.35 ? Colors.black87 : Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    if (layout.isEmpty) return;

    // Collect parent (branch) rects at depth 0
    final parents = layout.where((lr) => !lr.node.isLeaf && lr.depth == 0).toList();
    final leaves  = layout.where((lr) =>  lr.node.isLeaf).toList();

    // ── Draw leaf cells ──────────────────────────────────────────
    for (int i = 0; i < leaves.length; i++) {
      final lr = leaves[i];
      final isHov = lr.node.name == hovered;

      // Find parent to compute color family
      final parentLR = parents.firstWhere(
          (p) => p.rect.overlaps(lr.rect) && p.rect != lr.rect,
          orElse: () => _LR(lr.node, lr.rect, 0));
      final parentIdx = parents.indexOf(parentLR).clamp(0, 100);

      Color base;
      try {
        base = lr.node.color != null
            ? colorCache.resolve(lr.node.color!)
            : theme.palette.colorObjectAt(parentIdx);
      } catch (_) {
        base = theme.palette.colorObjectAt(parentIdx);
      }

      // Vary lightness per child using index within group
      final childIdx = leaves.where((l) => l.parent?.name == lr.parent?.name).toList().indexOf(lr);
      final shade = Color.lerp(base, Colors.white, childIdx * 0.12)!;
      final fill = isHov ? Color.lerp(shade, Colors.white, 0.25)! : shade;

      // Shrink top for header space
      final cellRect = cfg.labelMode == 'header' && lr.depth > 0
          ? lr.rect
          : lr.rect;

      final rr = RRect.fromRectAndRadius(cellRect, const Radius.circular(2));
      canvas.drawRRect(rr, Paint()..color = fill.withOpacity(progress)
          ..style = PaintingStyle.fill..isAntiAlias = true);
      canvas.drawRRect(rr, Paint()..color = theme.backgroundColor
          ..style = PaintingStyle.stroke..strokeWidth = isHov ? 2.5 : 1.0..isAntiAlias = true);

      // Child label
      if (cfg.showChildLabels && cellRect.width > 32 && cellRect.height > 18) {
        final tc = _contrast(fill);
        final tp = textPainterCache.get(lr.node.name,
            theme.typography.dataLabelStyle.copyWith(
                color: tc, fontSize: 9, fontWeight: FontWeight.w500),
            maxWidth: cellRect.width - 6);
        canvas.save();
        canvas.clipRect(cellRect);
        tp.paint(canvas, Offset(cellRect.left + 3, cellRect.top + 3));
        if (cfg.showValues && cellRect.height > 32) {
          final vtp = textPainterCache.get(lr.node.value.toStringAsFixed(0),
              theme.typography.dataLabelStyle.copyWith(
                  color: tc.withOpacity(0.7), fontSize: 8.5),
              maxWidth: cellRect.width - 6);
          vtp.paint(canvas, Offset(cellRect.left + 3, cellRect.top + 3 + tp.height + 2));
        }
        canvas.restore();
      }
    }

    // ── Draw parent labels ────────────────────────────────────────
    for (int pi = 0; pi < parents.length; pi++) {
      final p = parents[pi];
      Color parentColor;
      try {
        parentColor = p.node.color != null
            ? colorCache.resolve(p.node.color!)
            : theme.palette.colorObjectAt(pi);
      } catch (_) {
        parentColor = theme.palette.colorObjectAt(pi);
      }
      final darkColor = Color.lerp(parentColor, Colors.black, 0.4)!;

      if (cfg.labelMode == 'header') {
        // Sticky header bar across top of parent rect
        final headerRect = Rect.fromLTWH(
            p.rect.left, p.rect.top, p.rect.width, cfg.headerHeight);
        final rr = RRect.fromRectAndCorners(headerRect,
            topLeft: const Radius.circular(3), topRight: const Radius.circular(3));
        canvas.drawRRect(rr,
            Paint()..color = darkColor.withOpacity(0.88 * progress)
              ..style = PaintingStyle.fill..isAntiAlias = true);

        // Parent name in header
        final labelText = cfg.showValues
            ? '${p.node.name}  ${p.node.value.toStringAsFixed(0)}'
            : p.node.name;
        final tp = textPainterCache.get(labelText,
            theme.typography.dataLabelStyle.copyWith(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
            maxWidth: headerRect.width - 8);
        canvas.save();
        canvas.clipRect(headerRect);
        tp.paint(canvas, Offset(
            headerRect.left + 6,
            headerRect.top + (cfg.headerHeight - tp.height) / 2));
        canvas.restore();

        // Top border of parent (full outline)
        canvas.drawRRect(
          RRect.fromRectAndRadius(p.rect, const Radius.circular(3)),
          Paint()..color = darkColor.withOpacity(0.7)
            ..style = PaintingStyle.stroke..strokeWidth = 1.8..isAntiAlias = true,
        );
      } else {
        // Floating label centred over parent group
        if (p.rect.width < 50 || p.rect.height < 30) continue;
        final labelText = p.node.name;
        final tp = textPainterCache.get(labelText,
            theme.typography.dataLabelStyle.copyWith(
                color: darkColor.withOpacity(progress),
                fontSize: 11, fontWeight: FontWeight.w700),
            maxWidth: p.rect.width - 16, align: TextAlign.center);
        // Semi-transparent pill background
        final bgRect = Rect.fromCenter(
            center: Offset(p.rect.center.dx, p.rect.top + 18),
            width: tp.width + 16, height: tp.height + 8);
        canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(12)),
            Paint()..color = Colors.white.withOpacity(0.75 * progress)..style = PaintingStyle.fill);
        tp.paint(canvas, Offset(bgRect.left + 8, bgRect.top + 4));
        // Outer border
        canvas.drawRRect(
          RRect.fromRectAndRadius(p.rect.deflate(0.5), const Radius.circular(3)),
          Paint()..color = darkColor.withOpacity(0.5 * progress)
            ..style = PaintingStyle.stroke..strokeWidth = 1.5,
        );
      }
    }
  }
}

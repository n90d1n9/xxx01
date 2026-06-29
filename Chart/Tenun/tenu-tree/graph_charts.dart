/// Graph Charts — 9 graph/network visualization variants.
///
/// All share [GraphNode] / [GraphEdge] data models.
/// Charts:
///   • [LesMiserablesGraphConfig]     — community-colored force graph (Les Misérables)
///   • [ForceLayoutGraphConfig]       — generic configurable force-directed layout
///   • [SimpleGraphConfig]            — static positioned graph (no physics)
///   • [CartesianGraphConfig]         — graph overlaid on X/Y Cartesian axes
///   • [OverlapLabelGraphConfig]      — force graph with overlap-hidden labels
///   • [LifeExpectancyGraphConfig]    — animated bubble/graph life-expectancy timeline
///   • [DynamicGraphConfig]           — live-updating streaming graph
///   • [CalendarGraphConfig]          — nodes placed on a calendar grid
///   • [WebkitDepGraphConfig]         — hierarchical dependency (DAG) graph
library graph_charts;

import 'dart:math' as math;
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
import '../core/utils/chart_data_processor.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SHARED: Data models
// ═══════════════════════════════════════════════════════════════════════════

class GraphNode {
  final String id, name;
  double x, y;          // normalised [0,1] or canvas coords after layout
  double vx = 0, vy = 0; // velocity for force layout
  final double size;
  final String? color, category, group;
  final double? value;

  GraphNode({
    required this.id, required this.name,
    this.x = 0, this.y = 0,
    this.size = 10,
    this.color, this.category, this.group, this.value,
  });

  factory GraphNode.fromJson(Map<String, dynamic> j) => GraphNode(
    id: j['id']?.toString() ?? j['name']?.toString() ?? '',
    name: j['name']?.toString() ?? j['id']?.toString() ?? '',
    x: (j['x'] as num?)?.toDouble() ?? 0,
    y: (j['y'] as num?)?.toDouble() ?? 0,
    size: (j['size'] as num?)?.toDouble() ?? (j['symbolSize'] as num?)?.toDouble() ?? 10,
    color: j['color']?.toString(),
    category: j['category']?.toString(),
    group: j['group']?.toString(),
    value: (j['value'] as num?)?.toDouble(),
  );
}

class GraphEdge {
  final String source, target;
  final double value;
  final String? label, color;
  const GraphEdge({
    required this.source, required this.target,
    this.value = 1, this.label, this.color,
  });
  factory GraphEdge.fromJson(Map<String, dynamic> j) => GraphEdge(
    source: j['source']?.toString() ?? '',
    target: j['target']?.toString() ?? '',
    value: (j['value'] as num?)?.toDouble() ?? 1,
    label: j['label']?.toString(),
    color: j['color']?.toString(),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED: Force-directed layout engine
// ═══════════════════════════════════════════════════════════════════════════

class _ForceEngine {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  double repulsion;
  double attraction;
  double damping;

  _ForceEngine(this.nodes, this.edges, {
    this.repulsion = 80,
    this.attraction = 0.06,
    this.damping = 0.85,
  });

  // Random init if x/y not set
  void initRandom(Size size, [int seed = 42]) {
    final rng = math.Random(seed);
    for (final n in nodes) {
      if (n.x == 0 && n.y == 0) {
        n.x = size.width * 0.1 + rng.nextDouble() * size.width * 0.8;
        n.y = size.height * 0.1 + rng.nextDouble() * size.height * 0.8;
      }
    }
  }

  void step(Size size) {
    final nodeMap = {for (final n in nodes) n.id: n};

    // Repulsion
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final a = nodes[i], b = nodes[j];
        final dx = b.x - a.x, dy = b.y - a.y;
        final dist = math.sqrt(dx * dx + dy * dy).clamp(0.5, 500.0);
        final force = repulsion / (dist * dist);
        final fx = dx / dist * force, fy = dy / dist * force;
        a.vx -= fx; a.vy -= fy;
        b.vx += fx; b.vy += fy;
      }
    }

    // Attraction along edges
    for (final e in edges) {
      final a = nodeMap[e.source], b = nodeMap[e.target];
      if (a == null || b == null) continue;
      final dx = b.x - a.x, dy = b.y - a.y;
      final dist = math.sqrt(dx * dx + dy * dy).clamp(0.1, 500.0);
      final force = dist * attraction;
      final fx = dx / dist * force, fy = dy / dist * force;
      a.vx += fx; a.vy += fy;
      b.vx -= fx; b.vy -= fy;
    }

    // Center gravity
    final cx = size.width / 2, cy = size.height / 2;
    for (final n in nodes) {
      n.vx += (cx - n.x) * 0.008;
      n.vy += (cy - n.y) * 0.008;
      n.vx *= damping; n.vy *= damping;
      n.x += n.vx; n.y += n.vy;
      n.x = n.x.clamp(20.0, size.width - 20);
      n.y = n.y.clamp(20.0, size.height - 20);
    }
  }

  void runN(int n, Size size) {
    for (int i = 0; i < n; i++) step(size);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED: Graph painter base
// ═══════════════════════════════════════════════════════════════════════════

void _paintGraph(
    Canvas canvas,
    List<GraphNode> nodes,
    List<GraphEdge> edges,
    ChartPainterBase base, {
    bool showLabels = true,
    bool hideOverlappedLabels = false,
    bool showEdgeLabels = false,
    double edgeWidth = 1.2,
    String? hoveredId,
    Map<String, int>? categoryColorIndex,
}) {
  final theme = base.theme;
  final nodeMap = {for (final n in nodes) n.id: n};
  final maxEdgeVal = edges.isEmpty ? 1.0
      : edges.map((e) => e.value).reduce(math.max).clamp(1.0, 1e9);

  // Edges
  for (final e in edges) {
    final a = nodeMap[e.source], b = nodeMap[e.target];
    if (a == null || b == null) continue;
    final isHov = hoveredId == e.source || hoveredId == e.target;
    Color ec;
    try { ec = e.color != null ? base.colorCache.resolve(e.color!) : theme.axisColor.withOpacity(0.3); }
    catch (_) { ec = theme.axisColor.withOpacity(0.3); }
    final w = edgeWidth * 0.5 + (e.value / maxEdgeVal) * edgeWidth * 1.5;
    canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y),
        base.paintCache.stroke(isHov ? ec.withOpacity(0.9) : ec, w)..isAntiAlias = true);

    if (showEdgeLabels && e.label != null) {
      final mid = Offset((a.x + b.x) / 2, (a.y + b.y) / 2);
      final tp = base.textPainterCache.get(e.label!,
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 8));
      tp.paint(canvas, Offset(mid.dx - tp.width / 2, mid.dy - tp.height / 2));
    }
  }

  // Nodes
  final usedLabelRects = <Rect>[];
  for (int i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    final isHov = n.id == hoveredId;
    int colorIdx = i;
    if (categoryColorIndex != null && n.category != null) {
      colorIdx = categoryColorIndex[n.category] ?? i;
    }
    Color nc;
    try {
      nc = n.color != null ? base.colorCache.resolve(n.color!) : theme.seriesColor(colorIdx);
    } catch (_) {
      nc = theme.seriesColor(colorIdx);
    }

    final r = n.size / 2 * (isHov ? 1.25 : 1.0);
    final pos = Offset(n.x, n.y);

    // Glow for hovered
    if (isHov) {
      canvas.drawCircle(pos, r + 4,
          Paint()..color = nc.withOpacity(0.25)..style = PaintingStyle.fill..isAntiAlias = true);
    }
    canvas.drawCircle(pos, r,
        Paint()..color = nc..style = PaintingStyle.fill..isAntiAlias = true);
    canvas.drawCircle(pos, r,
        Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.stroke
          ..strokeWidth = 1.2..isAntiAlias = true);

    // Label
    if (showLabels && (isHov || n.size >= 8)) {
      final tp = base.textPainterCache.get(n.name,
          theme.typography.axisLabelStyle.copyWith(
              color: theme.titleColor, fontSize: 8.5 + (n.size > 20 ? 2.0 : 0.0)));
      final lr = Rect.fromLTWH(pos.dx + r + 3, pos.dy - tp.height / 2, tp.width, tp.height);

      bool skip = false;
      if (hideOverlappedLabels && !isHov) {
        for (final used in usedLabelRects) {
          if (lr.overlaps(used.inflate(2))) { skip = true; break; }
        }
      }
      if (!skip) {
        tp.paint(canvas, Offset(lr.left, lr.top));
        usedLabelRects.add(lr);
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. LES MISÉRABLES GRAPH
// ═══════════════════════════════════════════════════════════════════════════
/// Force-directed graph pre-styled with community colouring.
/// Loads character data from JSON; each node's `category` drives colour.
///
/// JSON:
/// ```json
/// { "type": "lesMiserables",
///   "nodes": [
///     {"id":"Valjean","name":"Valjean","category":"protagonist","size":20},
///     {"id":"Javert","name":"Javert","category":"antagonist","size":16}
///   ],
///   "edges":[{"source":"Valjean","target":"Javert","value":5}]}
/// ```
class LesMiserablesGraphConfig extends BaseChartConfig {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final int iterations;
  final ChartTheme theme;

  LesMiserablesGraphConfig({
    required this.nodes, required this.edges,
    this.iterations = 200,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.lesMiserables, series: const []);

  @override Widget buildChart() => _ForceGraphWidget(
    nodes: nodes.map((n) => GraphNode.fromJson(n._toMap())).toList(),
    edges: edges,
    config: this,
    categoryColored: true,
    showEdgeLabels: false,
    iterations: iterations,
    title: title?.text,
    theme: theme,
  );

  factory LesMiserablesGraphConfig.fromJson(Map<String, dynamic> j) {
    final ns = (j['nodes'] as List? ?? []).whereType<Map<String, dynamic>>().map(GraphNode.fromJson).toList();
    final es = (j['edges'] as List? ?? []).whereType<Map<String, dynamic>>().map(GraphEdge.fromJson).toList();
    return LesMiserablesGraphConfig(nodes: ns, edges: es,
        iterations: (j['iterations'] as num?)?.toInt() ?? 200,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'lesMiserables'};
}

extension _NodeMap on GraphNode {
  Map<String, dynamic> _toMap() => {'id': id, 'name': name, 'x': x, 'y': y,
      'size': size, 'color': color, 'category': category, 'value': value};
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. FORCE LAYOUT GRAPH
// ═══════════════════════════════════════════════════════════════════════════
/// Configurable force-directed graph with repulsion/attraction settings.
class ForceLayoutGraphConfig extends BaseChartConfig {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final double repulsion, attraction;
  final int iterations;
  final bool showLabels, showEdgeLabels;
  final ChartTheme theme;

  ForceLayoutGraphConfig({
    required this.nodes, required this.edges,
    this.repulsion = 80, this.attraction = 0.06,
    this.iterations = 200,
    this.showLabels = true, this.showEdgeLabels = false,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.forceGraph, series: const []);

  @override Widget buildChart() => _ForceGraphWidget(
    nodes: nodes.map((n) => GraphNode.fromJson(n._toMap())).toList(),
    edges: edges, config: this,
    repulsion: repulsion, attraction: attraction,
    iterations: iterations,
    showLabels: showLabels, showEdgeLabels: showEdgeLabels,
    title: title?.text, theme: theme,
  );

  factory ForceLayoutGraphConfig.fromJson(Map<String, dynamic> j) {
    final ns = (j['nodes'] as List? ?? []).whereType<Map<String, dynamic>>().map(GraphNode.fromJson).toList();
    final es = (j['edges'] as List? ?? []).whereType<Map<String, dynamic>>().map(GraphEdge.fromJson).toList();
    return ForceLayoutGraphConfig(nodes: ns, edges: es,
        repulsion: (j['repulsion'] as num?)?.toDouble() ?? 80,
        attraction: (j['attraction'] as num?)?.toDouble() ?? 0.06,
        iterations: (j['iterations'] as num?)?.toInt() ?? 200,
        showLabels: j['showLabels'] as bool? ?? true,
        showEdgeLabels: j['showEdgeLabels'] as bool? ?? false,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'forceGraph'};
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED: Force graph widget (reused by les-mis, force-layout, overlap)
// ═══════════════════════════════════════════════════════════════════════════
class _ForceGraphWidget extends StatefulWidget {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final BaseChartConfig config;
  final bool categoryColored, showLabels, showEdgeLabels, hideOverlappedLabels;
  final double repulsion, attraction;
  final int iterations;
  final String? title;
  final ChartTheme theme;

  const _ForceGraphWidget({
    required this.nodes, required this.edges, required this.config,
    this.categoryColored = false,
    this.showLabels = true, this.showEdgeLabels = false,
    this.hideOverlappedLabels = false,
    this.repulsion = 80, this.attraction = 0.06,
    this.iterations = 200,
    this.title, required this.theme,
  });
  @override State<_ForceGraphWidget> createState() => _FGState();
}

class _FGState extends State<_ForceGraphWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  String? _hovered;
  bool _initialized = false;
  late _ForceEngine _engine;
  Map<String, int> _catColors = {};
  Size _lastSize = Size.zero;

  @override void initState() {
    super.initState();
    _engine = _ForceEngine(widget.nodes, widget.edges,
        repulsion: widget.repulsion, attraction: widget.attraction);

    // Build category color index
    int ci = 0;
    for (final n in widget.nodes) {
      if (n.category != null && !_catColors.containsKey(n.category)) {
        _catColors[n.category!] = ci++;
      }
    }

    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _initLayout(Size size) {
    if (_initialized && _lastSize == size) return;
    _initialized = true;
    _lastSize = size;
    _engine.initRandom(size);
    _engine.runN(widget.iterations, size);
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (widget.title != null)
      Padding(padding: const EdgeInsets.fromLTRB(12,8,12,0),
        child: Text(widget.title!, style: widget.theme.typography.titleStyle
            .copyWith(color: widget.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      _initLayout(sz);
      // Run a few more steps per frame during animation
      if (_ctrl.isAnimating) _engine.runN(3, sz);
      return MouseRegion(
        onHover: (e) {
          for (final n in widget.nodes) {
            if ((Offset(n.x, n.y) - e.localPosition).distance < n.size * 0.7) {
              if (_hovered != n.id) setState(() => _hovered = n.id);
              return;
            }
          }
          if (_hovered != null) setState(() => _hovered = null);
        },
        onExit: (_) => setState(() => _hovered = null),
        child: RepaintBoundary(child: CustomPaint(
          size: Size.infinite,
          painter: _FGPainter(
            nodes: widget.nodes, edges: widget.edges,
            hoveredId: _hovered,
            categoryColored: widget.categoryColored,
            catColors: _catColors,
            showLabels: widget.showLabels,
            showEdgeLabels: widget.showEdgeLabels,
            hideOverlap: widget.hideOverlappedLabels,
            theme: widget.theme,
          ),
        )),
      );
    })),
    if (widget.categoryColored && _catColors.isNotEmpty)
      _buildCategoryLegend(),
  ]);

  Widget _buildCategoryLegend() {
    final t = widget.theme;
    return Padding(padding: const EdgeInsets.only(bottom: 4),
      child: Wrap(spacing: 10, alignment: WrapAlignment.center,
        children: _catColors.entries.map((e) => Row(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(radius: 4, backgroundColor: t.seriesColor(e.value)),
          const SizedBox(width: 4),
          Text(e.key, style: t.typography.legendStyle.copyWith(color: t.legendTextColor, fontSize: 9)),
        ])).toList()));
  }
}

class _FGPainter extends ChartPainterBase {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final String? hoveredId;
  final bool categoryColored, showLabels, showEdgeLabels, hideOverlap;
  final Map<String, int> catColors;

  _FGPainter({
    required this.nodes, required this.edges, this.hoveredId,
    required this.categoryColored, required this.catColors,
    required this.showLabels, required this.showEdgeLabels,
    required this.hideOverlap, required ChartTheme theme,
  }) : super(theme: theme);

  @override bool shouldRepaintChart(covariant _FGPainter o) =>
      o.hoveredId != hoveredId || true; // always repaint during animation

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    _paintGraph(canvas, nodes, edges, this,
        showLabels: showLabels,
        hideOverlappedLabels: hideOverlap,
        showEdgeLabels: showEdgeLabels,
        hoveredId: hoveredId,
        categoryColorIndex: categoryColored ? catColors : null);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. SIMPLE GRAPH — static positions
// ═══════════════════════════════════════════════════════════════════════════
class SimpleGraphConfig extends BaseChartConfig {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final bool showLabels, showEdgeLabels;
  final ChartTheme theme;

  SimpleGraphConfig({
    required this.nodes, required this.edges,
    this.showLabels = true, this.showEdgeLabels = true,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.simpleGraph, series: const []);

  @override Widget buildChart() => _SimpleGraphWidget(config: this);

  factory SimpleGraphConfig.fromJson(Map<String, dynamic> j) {
    final ns = (j['nodes'] as List? ?? []).whereType<Map<String, dynamic>>().map(GraphNode.fromJson).toList();
    final es = (j['edges'] as List? ?? []).whereType<Map<String, dynamic>>().map(GraphEdge.fromJson).toList();
    return SimpleGraphConfig(nodes: ns, edges: es,
        showLabels: j['showLabels'] as bool? ?? true,
        showEdgeLabels: j['showEdgeLabels'] as bool? ?? true,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null,
        tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'simpleGraph'};
}

class _SimpleGraphWidget extends StatefulWidget {
  final SimpleGraphConfig config;
  const _SimpleGraphWidget({required this.config});
  @override State<_SimpleGraphWidget> createState() => _SGState();
}

class _SGState extends State<_SimpleGraphWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  String? _hov;
  bool _init = false;
  SimpleGraphConfig get cfg => widget.config;

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
      Padding(padding: const EdgeInsets.fromLTRB(12,8,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      // Normalise positions to canvas if in [0,1] range
      if (!_init) {
        _init = true;
        final maxX = cfg.nodes.isEmpty ? 1.0 : cfg.nodes.map((n) => n.x).reduce(math.max).clamp(0.001, 1e9);
        final maxY = cfg.nodes.isEmpty ? 1.0 : cfg.nodes.map((n) => n.y).reduce(math.max).clamp(0.001, 1e9);
        final inNorm = maxX <= 1.0 && maxY <= 1.0;
        if (inNorm) {
          for (final n in cfg.nodes) {
            n.x = 20 + n.x * (sz.width - 40);
            n.y = 20 + n.y * (sz.height - 40);
          }
        }
      }
      return MouseRegion(
        onHover: (e) {
          for (final n in cfg.nodes) {
            if ((Offset(n.x, n.y) - e.localPosition).distance < n.size) {
              if (_hov != n.id) setState(() => _hov = n.id); return;
            }
          }
          if (_hov != null) setState(() => _hov = null);
        },
        onExit: (_) => setState(() => _hov = null),
        child: RepaintBoundary(child: CustomPaint(
          size: Size.infinite,
          painter: _SGPainter(cfg: cfg, hoveredId: _hov, progress: _anim.value),
        )),
      );
    })),
  ]);
}

class _SGPainter extends ChartPainterBase {
  final SimpleGraphConfig cfg;
  final String? hoveredId;
  final double progress;
  _SGPainter({required this.cfg, this.hoveredId, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _SGPainter o) =>
      o.hoveredId != hoveredId || o.progress != progress;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    _paintGraph(canvas, cfg.nodes, cfg.edges, this,
        showLabels: cfg.showLabels,
        showEdgeLabels: cfg.showEdgeLabels,
        hoveredId: hoveredId);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. GRAPH ON CARTESIAN
// ═══════════════════════════════════════════════════════════════════════════
/// Graph where node positions are X/Y data values mapped to a Cartesian axis.
///
/// JSON:
/// ```json
/// { "type": "cartesianGraph",
///   "nodes": [
///     { "id":"a","name":"Alpha","x":10,"y":20,"size":14 },
///     { "id":"b","name":"Beta","x":30,"y":50,"size":18 }
///   ],
///   "edges":[{"source":"a","target":"b"}]}
/// ```
class CartesianGraphConfig extends BaseChartConfig {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final String? xLabel, yLabel;
  final ChartTheme theme;

  CartesianGraphConfig({
    required this.nodes, required this.edges,
    this.xLabel, this.yLabel,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.cartesianGraph, series: const []);

  @override Widget buildChart() => _CartGraphWidget(config: this);

  factory CartesianGraphConfig.fromJson(Map<String, dynamic> j) {
    final ns = (j['nodes'] as List? ?? []).whereType<Map<String, dynamic>>().map(GraphNode.fromJson).toList();
    final es = (j['edges'] as List? ?? []).whereType<Map<String, dynamic>>().map(GraphEdge.fromJson).toList();
    return CartesianGraphConfig(nodes: ns, edges: es,
        xLabel: j['xLabel']?.toString(), yLabel: j['yLabel']?.toString(),
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'cartesianGraph'};
}

class _CartGraphWidget extends StatefulWidget {
  final CartesianGraphConfig config;
  const _CartGraphWidget({required this.config});
  @override State<_CartGraphWidget> createState() => _CGState();
}

class _CGState extends State<_CartGraphWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _init = false;
  String? _hov;
  CartesianGraphConfig get cfg => widget.config;

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
      Padding(padding: const EdgeInsets.fromLTRB(12,8,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      const padL = 48.0, padB = 28.0, padT = 12.0, padR = 12.0;
      if (!_init && cfg.nodes.isNotEmpty) {
        _init = true;
        double minX = cfg.nodes.map((n) => n.x).reduce(math.min);
        double maxX = cfg.nodes.map((n) => n.x).reduce(math.max);
        double minY = cfg.nodes.map((n) => n.y).reduce(math.min);
        double maxY = cfg.nodes.map((n) => n.y).reduce(math.max);
        final rangeX = (maxX - minX).clamp(0.001, 1e9);
        final rangeY = (maxY - minY).clamp(0.001, 1e9);
        final pw = sz.width - padL - padR;
        final ph = sz.height - padT - padB;
        for (final n in cfg.nodes) {
          n.x = padL + (n.x - minX) / rangeX * pw;
          n.y = padT + ph - (n.y - minY) / rangeY * ph;
        }
      }
      return MouseRegion(
        onHover: (e) {
          for (final n in cfg.nodes) {
            if ((Offset(n.x, n.y) - e.localPosition).distance < n.size) {
              if (_hov != n.id) setState(() => _hov = n.id); return;
            }
          }
          if (_hov != null) setState(() => _hov = null);
        },
        onExit: (_) => setState(() => _hov = null),
        child: RepaintBoundary(child: CustomPaint(
          size: Size.infinite,
          painter: _CGPainter(cfg: cfg, hov: _hov, progress: _anim.value),
        )),
      );
    })),
  ]);
}

class _CGPainter extends ChartPainterBase {
  final CartesianGraphConfig cfg;
  final String? hov;
  final double progress;
  _CGPainter({required this.cfg, this.hov, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _CGPainter o) =>
      o.hov != hov || o.progress != progress;
  @override
  void paint(Canvas canvas, Size size) {
    const padL = 48.0, padB = 28.0, padT = 12.0, padR = 12.0;
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    // Grid
    for (int i = 1; i < 5; i++) {
      final y = padT + (size.height - padT - padB) * i / 5;
      canvas.drawLine(Offset(padL, y), Offset(size.width - padR, y),
          paintCache.stroke(theme.gridColor, 0.5));
    }
    canvas.drawLine(Offset(padL, padT), Offset(padL, size.height - padB), axisPaint);
    canvas.drawLine(Offset(padL, size.height - padB),
        Offset(size.width - padR, size.height - padB), axisPaint);
    _paintGraph(canvas, cfg.nodes, cfg.edges, this, hoveredId: hov);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 5. HIDE OVERLAPPED LABEL GRAPH
// ═══════════════════════════════════════════════════════════════════════════
class OverlapLabelGraphConfig extends BaseChartConfig {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final int iterations;
  final ChartTheme theme;

  OverlapLabelGraphConfig({
    required this.nodes, required this.edges,
    this.iterations = 180,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.overlapLabelGraph, series: const []);

  @override Widget buildChart() => _ForceGraphWidget(
    nodes: nodes.map((n) => GraphNode.fromJson(n._toMap())).toList(),
    edges: edges, config: this,
    hideOverlappedLabels: true,
    showLabels: true,
    iterations: iterations,
    title: title?.text, theme: theme,
  );

  factory OverlapLabelGraphConfig.fromJson(Map<String, dynamic> j) {
    final ns = (j['nodes'] as List? ?? []).whereType<Map<String, dynamic>>().map(GraphNode.fromJson).toList();
    final es = (j['edges'] as List? ?? []).whereType<Map<String, dynamic>>().map(GraphEdge.fromJson).toList();
    return OverlapLabelGraphConfig(nodes: ns, edges: es,
        iterations: (j['iterations'] as num?)?.toInt() ?? 180,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'overlapLabelGraph'};
}

// ═══════════════════════════════════════════════════════════════════════════
// 6. LIFE EXPECTANCY GRAPH (animated bubble timeline)
// ═══════════════════════════════════════════════════════════════════════════
/// Animated scatter/bubble chart across years — each bubble is a country/entity,
/// sized by population, coloured by region. Play button animates year changes.
///
/// JSON:
/// ```json
/// { "type": "lifeExpectancyGraph",
///   "years": [1960, 1970, 1980],
///   "frames": [
///     [{"id":"US","name":"USA","x":68,"y":3000,"size":200,"category":"Americas"}],
///     [{"id":"US","name":"USA","x":70,"y":5000,"size":210,"category":"Americas"}]
///   ]}
/// ```
class LifeExpectancyGraphConfig extends BaseChartConfig {
  final List<int> years;
  final List<List<GraphNode>> frames;  // one list of nodes per year
  final String xLabel, yLabel;
  final ChartTheme theme;

  LifeExpectancyGraphConfig({
    required this.years, required this.frames,
    this.xLabel = 'Life Expectancy', this.yLabel = 'GDP per Capita',
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.lifeExpectancyGraph, series: const []);

  @override Widget buildChart() => _LifeExpWidget(config: this);

  factory LifeExpectancyGraphConfig.fromJson(Map<String, dynamic> j) {
    final years = (j['years'] as List? ?? []).map<int>((y) => (y as num).toInt()).toList();
    final frames = (j['frames'] as List? ?? []).map<List<GraphNode>>((f) =>
        (f as List).whereType<Map<String, dynamic>>().map(GraphNode.fromJson).toList()).toList();
    return LifeExpectancyGraphConfig(years: years, frames: frames,
        xLabel: j['xLabel']?.toString() ?? 'Life Expectancy',
        yLabel: j['yLabel']?.toString() ?? 'GDP per Capita',
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'lifeExpectancyGraph'};
}

class _LifeExpWidget extends StatefulWidget {
  final LifeExpectancyGraphConfig config;
  const _LifeExpWidget({required this.config});
  @override State<_LifeExpWidget> createState() => _LEState();
}

class _LEState extends State<_LifeExpWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _frame = 0;
  bool _playing = false;
  LifeExpectancyGraphConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _ctrl.addListener(() => setState(() {}));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _playNext() async {
    if (_playing) return;
    _playing = true;
    while (_frame < cfg.frames.length - 1) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) break;
      setState(() { _frame++; _ctrl.forward(from: 0); });
    }
    _playing = false;
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12,8,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      final nodes = _frame < cfg.frames.length ? cfg.frames[_frame] : [];
      // Normalise to canvas
      final placed = _placeNodes(nodes, sz);
      return RepaintBoundary(child: CustomPaint(
        size: Size.infinite,
        painter: _LEPainter(nodes: placed, progress: _ctrl.value,
            xLabel: cfg.xLabel, yLabel: cfg.yLabel,
            yearLabel: _frame < cfg.years.length ? '${cfg.years[_frame]}' : '',
            theme: cfg.theme),
      ));
    })),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        IconButton(icon: Icon(Icons.play_arrow, color: cfg.theme.seriesColor(0)),
            onPressed: () { _frame = 0; _playNext(); }),
        Expanded(child: Slider(
          value: _frame.toDouble(),
          min: 0, max: math.max(0, cfg.frames.length - 1).toDouble(),
          divisions: math.max(1, cfg.frames.length - 1),
          activeColor: cfg.theme.seriesColor(0),
          onChanged: (v) => setState(() { _frame = v.toInt(); _ctrl.forward(from: 0); }),
        )),
        Text(_frame < cfg.years.length ? '${cfg.years[_frame]}' : '',
            style: cfg.theme.typography.axisLabelStyle.copyWith(
                color: cfg.theme.titleColor, fontWeight: FontWeight.bold)),
      ]),
    ),
  ]);

  List<GraphNode> _placeNodes(List<GraphNode> nodes, Size sz) {
    if (nodes.isEmpty) return [];
    const padL = 56.0, padB = 32.0, padT = 12.0, padR = 12.0;
    final pw = sz.width - padL - padR, ph = sz.height - padT - padB;
    final allX = nodes.map((n) => n.x).toList();
    final allY = nodes.map((n) => n.y).toList();
    final xMin = allX.reduce(math.min), xMax = allX.reduce(math.max);
    final yMin = allY.reduce(math.min), yMax = allY.reduce(math.max);
    final xR = (xMax - xMin).clamp(0.001, 1e9);
    final yR = (yMax - yMin).clamp(0.001, 1e9);
    final maxS = nodes.map((n) => n.size).reduce(math.max).clamp(0.001, 1e9);
    return nodes.map((n) => GraphNode(
      id: n.id, name: n.name,
      x: padL + (n.x - xMin) / xR * pw,
      y: padT + ph - (n.y - yMin) / yR * ph,
      size: 4 + n.size / maxS * 24,
      color: n.color, category: n.category,
    )).toList();
  }
}

class _LEPainter extends ChartPainterBase {
  final List<GraphNode> nodes;
  final double progress;
  final String xLabel, yLabel, yearLabel;
  _LEPainter({required this.nodes, required this.progress,
      required this.xLabel, required this.yLabel, required this.yearLabel,
      required ChartTheme theme}) : super(theme: theme);
  @override bool shouldRepaintChart(covariant _LEPainter o) =>
      o.progress != progress || o.yearLabel != yearLabel;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    _paintGraph(canvas, nodes, [], this, showLabels: true);
    // Year watermark
    final tp = textPainterCache.get(yearLabel,
        theme.typography.titleStyle.copyWith(
            color: theme.gridColor.withOpacity(0.25), fontSize: 64, fontWeight: FontWeight.bold));
    tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2));
    // Axis labels
    final xtp = textPainterCache.get(xLabel,
        theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 10));
    xtp.paint(canvas, Offset(size.width / 2 - xtp.width / 2, size.height - 18));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 7. DYNAMIC GRAPH — live-streaming nodes
// ═══════════════════════════════════════════════════════════════════════════
/// Graph that appends new nodes/edges over time, simulating a live data stream.
/// Use [streamEvents] list to define the sequence of changes.
///
/// JSON:
/// ```json
/// { "type": "dynamicGraph",
///   "initialNodes": [{"id":"A","name":"A","size":12}],
///   "initialEdges": [],
///   "streamEvents": [
///     { "delay": 1000, "addNode": {"id":"B","name":"B","size":10},
///       "addEdge": {"source":"A","target":"B"} }
///   ]}
/// ```
class GraphStreamEvent {
  final int delayMs;
  final GraphNode? addNode;
  final GraphEdge? addEdge;
  const GraphStreamEvent({this.delayMs = 1000, this.addNode, this.addEdge});
  factory GraphStreamEvent.fromJson(Map<String, dynamic> j) => GraphStreamEvent(
    delayMs: (j['delay'] as num?)?.toInt() ?? 1000,
    addNode: j['addNode'] != null ? GraphNode.fromJson(j['addNode']) : null,
    addEdge: j['addEdge'] != null ? GraphEdge.fromJson(j['addEdge']) : null,
  );
}

class DynamicGraphConfig extends BaseChartConfig {
  final List<GraphNode> initialNodes;
  final List<GraphEdge> initialEdges;
  final List<GraphStreamEvent> streamEvents;
  final ChartTheme theme;

  DynamicGraphConfig({
    required this.initialNodes, required this.initialEdges,
    this.streamEvents = const [],
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.dynamicGraph, series: const []);

  @override Widget buildChart() => _DynGraphWidget(config: this);

  factory DynamicGraphConfig.fromJson(Map<String, dynamic> j) {
    final ns = (j['initialNodes'] as List? ?? []).whereType<Map<String, dynamic>>().map(GraphNode.fromJson).toList();
    final es = (j['initialEdges'] as List? ?? []).whereType<Map<String, dynamic>>().map(GraphEdge.fromJson).toList();
    final events = (j['streamEvents'] as List? ?? []).whereType<Map<String, dynamic>>().map(GraphStreamEvent.fromJson).toList();
    return DynamicGraphConfig(initialNodes: ns, initialEdges: es, streamEvents: events,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'dynamicGraph'};
}

class _DynGraphWidget extends StatefulWidget {
  final DynamicGraphConfig config;
  const _DynGraphWidget({required this.config});
  @override State<_DynGraphWidget> createState() => _DGState();
}

class _DGState extends State<_DynGraphWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<GraphNode> _nodes;
  late List<GraphEdge> _edges;
  late _ForceEngine _engine;
  bool _initialized = false;
  int _eventIdx = 0;
  DynamicGraphConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _nodes = cfg.initialNodes.map((n) => GraphNode.fromJson(n._toMap())).toList();
    _edges = [...cfg.initialEdges];
    _engine = _ForceEngine(_nodes, _edges);
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 60))
      ..addListener(() { setState(() {}); });
    _ctrl.forward();
    _scheduleEvents();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _scheduleEvents() async {
    for (int i = 0; i < cfg.streamEvents.length; i++) {
      final e = cfg.streamEvents[i];
      await Future.delayed(Duration(milliseconds: e.delayMs));
      if (!mounted) return;
      setState(() {
        if (e.addNode != null) {
          _nodes.add(e.addNode!);
          _engine = _ForceEngine(_nodes, _edges);
        }
        if (e.addEdge != null) _edges.add(e.addEdge!);
      });
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12,8,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      if (!_initialized) { _initialized = true; _engine.initRandom(sz); }
      _engine.runN(4, sz);
      return RepaintBoundary(child: CustomPaint(
        size: Size.infinite,
        painter: _DGPainter(nodes: _nodes, edges: _edges, theme: cfg.theme),
      ));
    })),
    Padding(padding: const EdgeInsets.only(bottom: 4),
      child: Text('Live graph — ${_nodes.length} nodes · ${_edges.length} edges',
          style: cfg.theme.typography.axisLabelStyle.copyWith(
              color: cfg.theme.axisLabelColor.withOpacity(0.5), fontSize: 9))),
  ]);
}

class _DGPainter extends ChartPainterBase {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  _DGPainter({required this.nodes, required this.edges, required ChartTheme theme}) : super(theme: theme);
  @override bool shouldRepaintChart(covariant _) => true;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    _paintGraph(canvas, nodes, edges, this);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 8. CALENDAR GRAPH — nodes on a calendar grid
// ═══════════════════════════════════════════════════════════════════════════
/// Nodes are positioned by date on a calendar grid (year view).
/// Edges connect nodes across dates — useful for activity / event graphs.
///
/// JSON:
/// ```json
/// { "type": "calendarGraph",
///   "year": 2024,
///   "nodes": [
///     { "id":"2024-01-15","name":"Event A","date":"2024-01-15","size":14,"value":0.8 }
///   ],
///   "edges": [{"source":"2024-01-15","target":"2024-03-20"}]}
/// ```
class CalendarGraphNode {
  final String id, name, date;
  final double size, value;
  final String? color;
  const CalendarGraphNode({required this.id, required this.name,
      required this.date, this.size = 10, this.value = 0, this.color});
  factory CalendarGraphNode.fromJson(Map<String, dynamic> j) => CalendarGraphNode(
    id: j['id']?.toString() ?? '',
    name: j['name']?.toString() ?? '',
    date: j['date']?.toString() ?? '',
    size: (j['size'] as num?)?.toDouble() ?? 10,
    value: (j['value'] as num?)?.toDouble() ?? 0,
    color: j['color']?.toString(),
  );
}

class CalendarGraphConfig extends BaseChartConfig {
  final int year;
  final List<CalendarGraphNode> nodes;
  final List<GraphEdge> edges;
  final ChartTheme theme;

  CalendarGraphConfig({
    required this.year, required this.nodes, required this.edges,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.calendarGraph, series: const []);

  @override Widget buildChart() => _CalGrWidget(config: this);

  factory CalendarGraphConfig.fromJson(Map<String, dynamic> j) {
    final ns = (j['nodes'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(CalendarGraphNode.fromJson).toList();
    final es = (j['edges'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(GraphEdge.fromJson).toList();
    return CalendarGraphConfig(
        year: (j['year'] as num?)?.toInt() ?? DateTime.now().year,
        nodes: ns, edges: es,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'calendarGraph'};
}

class _CalGrWidget extends StatefulWidget {
  final CalendarGraphConfig config;
  const _CalGrWidget({required this.config});
  @override State<_CalGrWidget> createState() => _CalGrState();
}

class _CalGrState extends State<_CalGrWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  CalendarGraphConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12,8,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      // Convert calendar nodes to GraphNodes with calendar positions
      final placed = _placeOnCalendar(cfg.nodes, cfg.year, sz);
      final gNodes = placed.map((p) => GraphNode(
        id: p.node.id, name: p.node.name,
        x: p.pos.dx, y: p.pos.dy,
        size: p.node.size, color: p.node.color, value: p.node.value,
      )).toList();
      return RepaintBoundary(child: CustomPaint(
        size: Size.infinite,
        painter: _CalGrPainter(nodes: gNodes, edges: cfg.edges,
            year: cfg.year, progress: _anim.value, theme: cfg.theme),
      ));
    })),
  ]);

  List<({CalendarGraphNode node, Offset pos})> _placeOnCalendar(
      List<CalendarGraphNode> nodes, int year, Size sz) {
    const padL = 28.0, padT = 24.0, padR = 8.0, padB = 8.0;
    final cellW = (sz.width - padL - padR) / 53;
    final cellH = (sz.height - padT - padB) / 7;
    return nodes.map((n) {
      try {
        final d = DateTime.parse(n.date);
        final jan1 = DateTime(year, 1, 1);
        final dayOfYear = d.difference(jan1).inDays;
        final week = dayOfYear ~/ 7;
        final dow = d.weekday % 7;
        final x = padL + week * cellW + cellW / 2;
        final y = padT + dow * cellH + cellH / 2;
        return (node: n, pos: Offset(x, y));
      } catch (_) {
        return (node: n, pos: Offset(sz.width / 2, sz.height / 2));
      }
    }).toList();
  }
}

class _CalGrPainter extends ChartPainterBase {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final int year;
  final double progress;
  _CalGrPainter({required this.nodes, required this.edges, required this.year,
      required this.progress, required ChartTheme theme}) : super(theme: theme);
  @override bool shouldRepaintChart(covariant _CalGrPainter o) => o.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    const padL = 28.0, padT = 24.0, padR = 8.0, padB = 8.0;
    final cellW = (size.width - padL - padR) / 53;
    final cellH = (size.height - padT - padB) / 7;

    // Calendar grid
    for (int w = 0; w < 53; w++) {
      for (int d = 0; d < 7; d++) {
        final rect = Rect.fromLTWH(
            padL + w * cellW + 1, padT + d * cellH + 1, cellW - 2, cellH - 2);
        canvas.drawRect(rect, Paint()..color = theme.gridColor.withOpacity(0.12)..style = PaintingStyle.fill);
      }
    }

    // Day of week labels
    const days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    for (int i = 0; i < 7; i++) {
      final tp = textPainterCache.get(days[i],
          theme.typography.axisLabelStyle.copyWith(color: theme.axisLabelColor, fontSize: 7.5));
      tp.paint(canvas, Offset(2, padT + i * cellH + cellH / 2 - tp.height / 2));
    }

    // Year label
    final ytp = textPainterCache.get('$year',
        theme.typography.axisLabelStyle.copyWith(
            color: theme.axisLabelColor, fontSize: 9, fontWeight: FontWeight.w600));
    ytp.paint(canvas, Offset(padL, 4));

    // Edges
    final nodeMap = {for (final n in nodes) n.id: n};
    for (final e in edges) {
      final a = nodeMap[e.source], b = nodeMap[e.target];
      if (a == null || b == null) continue;
      canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y),
          paintCache.stroke(theme.seriesColor(0).withOpacity(0.4 * progress), 1));
    }

    // Nodes
    for (int i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      Color c;
      try { c = n.color != null ? colorCache.resolve(n.color!) : theme.seriesColor(0); }
      catch (_) { c = theme.seriesColor(0); }
      final r = (n.size / 2 * progress).clamp(2.0, cellH * 0.45);
      canvas.drawCircle(Offset(n.x, n.y), r,
          Paint()..color = c.withOpacity(0.85)..style = PaintingStyle.fill..isAntiAlias = true);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 9. WEBKIT DEPENDENCY GRAPH — DAG with depth-layered layout
// ═══════════════════════════════════════════════════════════════════════════
/// Hierarchical directed acyclic graph for dependency visualisation.
/// Nodes are sorted into depth layers; edges flow left → right.
///
/// JSON:
/// ```json
/// { "type": "webkitDepGraph",
///   "nodes": [
///     {"id":"WebCore","name":"WebCore","layer":0,"size":22},
///     {"id":"JSC","name":"JavaScriptCore","layer":1,"size":18},
///     {"id":"WTF","name":"WTF","layer":2,"size":14}
///   ],
///   "edges":[{"source":"WebCore","target":"JSC"},{"source":"JSC","target":"WTF"}]}
/// ```
class DepGraphNode extends GraphNode {
  final int layer;
  DepGraphNode({
    required super.id, required super.name,
    super.size, super.color, super.category, super.value,
    this.layer = 0,
  });
  factory DepGraphNode.fromJson(Map<String, dynamic> j) {
    final n = GraphNode.fromJson(j);
    return DepGraphNode(id: n.id, name: n.name, size: n.size,
        color: n.color, category: n.category, value: n.value,
        layer: (j['layer'] as num?)?.toInt() ?? 0);
  }
}

class WebkitDepGraphConfig extends BaseChartConfig {
  final List<DepGraphNode> nodes;
  final List<GraphEdge> edges;
  final bool showArrows;
  final ChartTheme theme;

  WebkitDepGraphConfig({
    required this.nodes, required this.edges,
    this.showArrows = true,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.webkitDepGraph, series: const []);

  @override Widget buildChart() => _DepGraphWidget(config: this);

  factory WebkitDepGraphConfig.fromJson(Map<String, dynamic> j) {
    final ns = (j['nodes'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(DepGraphNode.fromJson).toList();
    final es = (j['edges'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(GraphEdge.fromJson).toList();
    return WebkitDepGraphConfig(nodes: ns, edges: es,
        showArrows: j['showArrows'] as bool? ?? true,
        title: j['title'] != null ? TitlesData.fromJson(j['title']) : null);
  }
  @override Map<String, dynamic> toJson() => {'type': 'webkitDepGraph'};
}

class _DepGraphWidget extends StatefulWidget {
  final WebkitDepGraphConfig config;
  const _DepGraphWidget({required this.config});
  @override State<_DepGraphWidget> createState() => _DGrState();
}

class _DGrState extends State<_DepGraphWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  String? _hov;
  bool _init = false;
  WebkitDepGraphConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _layout(Size sz) {
    if (_init) return;
    _init = true;
    final maxLayer = cfg.nodes.isEmpty ? 0 : cfg.nodes.map((n) => n.layer).reduce(math.max);
    final layerGroups = <int, List<DepGraphNode>>{};
    for (final n in cfg.nodes) layerGroups.putIfAbsent(n.layer, () => []).add(n);
    const padL = 24.0, padR = 24.0, padT = 20.0, padB = 20.0;
    final pw = sz.width - padL - padR;
    final ph = sz.height - padT - padB;
    final xStep = maxLayer > 0 ? pw / maxLayer : pw;
    for (final entry in layerGroups.entries) {
      final count = entry.value.length;
      final x = padL + entry.key * xStep;
      final yStep = count > 1 ? ph / (count - 1) : ph / 2;
      for (int i = 0; i < count; i++) {
        entry.value[i].x = x;
        entry.value[i].y = count == 1 ? padT + ph / 2 : padT + i * yStep;
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12,8,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      _layout(sz);
      return MouseRegion(
        onHover: (e) {
          for (final n in cfg.nodes) {
            if ((Offset(n.x, n.y) - e.localPosition).distance < n.size) {
              if (_hov != n.id) setState(() => _hov = n.id); return;
            }
          }
          if (_hov != null) setState(() => _hov = null);
        },
        onExit: (_) => setState(() => _hov = null),
        child: RepaintBoundary(child: CustomPaint(
          size: Size.infinite,
          painter: _DepGrPainter(cfg: cfg, hov: _hov,
              progress: _anim.value),
        )),
      );
    })),
  ]);
}

class _DepGrPainter extends ChartPainterBase {
  final WebkitDepGraphConfig cfg;
  final String? hov;
  final double progress;
  _DepGrPainter({required this.cfg, this.hov, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _DepGrPainter o) =>
      o.hov != hov || o.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    final nodeMap = {for (final n in cfg.nodes) n.id: n};

    // Edges with arrows
    for (final e in cfg.edges) {
      final a = nodeMap[e.source], b = nodeMap[e.target];
      if (a == null || b == null) continue;
      final isHov = hov == e.source || hov == e.target;
      final col = theme.axisColor.withOpacity(isHov ? 0.8 : 0.3);

      // Bezier
      final dx = b.x - a.x, dy = b.y - a.y;
      final path = Path()
        ..moveTo(a.x, a.y)
        ..cubicTo(a.x + dx * 0.5, a.y, a.x + dx * 0.5, b.y, b.x, b.y);
      canvas.drawPath(path, paintCache.stroke(col, 1.3)..isAntiAlias = true);

      // Arrow head
      if (cfg.showArrows) {
        final angle = math.atan2(b.y - a.y, dx);
        final tip = Offset(b.x - b.size / 2 * math.cos(angle),
                           b.y - b.size / 2 * math.sin(angle));
        const aSize = 6.0;
        final arr = Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx - aSize * math.cos(angle - 0.4),
                   tip.dy - aSize * math.sin(angle - 0.4))
          ..lineTo(tip.dx - aSize * math.cos(angle + 0.4),
                   tip.dy - aSize * math.sin(angle + 0.4))
          ..close();
        canvas.drawPath(arr, Paint()..color = col..style = PaintingStyle.fill..isAntiAlias = true);
      }
    }

    // Nodes
    for (int i = 0; i < cfg.nodes.length; i++) {
      final n = cfg.nodes[i];
      final isHov = n.id == hov;
      Color c;
      try { c = n.color != null ? colorCache.resolve(n.color!) : theme.seriesColor(n.layer); }
      catch (_) { c = theme.seriesColor(n.layer); }
      final r = n.size / 2 * progress;
      canvas.drawCircle(Offset(n.x, n.y), r,
          Paint()..color = isHov ? Color.lerp(c, Colors.white, 0.3)! : c
            ..style = PaintingStyle.fill..isAntiAlias = true);
      canvas.drawCircle(Offset(n.x, n.y), r,
          paintCache.stroke(c.withOpacity(0.6), 1.5)..isAntiAlias = true);
      // Label
      final tp = textPainterCache.get(n.name,
          theme.typography.axisLabelStyle.copyWith(
              color: theme.titleColor, fontSize: 8.5 + (isHov ? 1.5 : 0)));
      tp.paint(canvas, Offset(n.x + r + 3, n.y - tp.height / 2));
    }
  }
}

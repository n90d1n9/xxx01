/// Tree Charts — 7 collapsible/expandable hierarchical tree variants.
///
/// All share a single [TreeNodeData] model and a unified [TreeChartConfig].
/// The [direction] field controls layout orientation; [edgeStyle] controls edge rendering.
///
///   • ltr  — Left → Right  (default)
///   • rtl  — Right → Left
///   • ttb  — Top → Bottom
///   • btt  — Bottom → Top
///   • radial — Radial / polar layout
///
/// Special configs:
///   • [MultipleTreesConfig]  — multiple independent root trees side-by-side
///   • [PolylineTreeConfig]   — orthogonal (right-angle) edge connectors
///
/// All trees support tap-to-collapse/expand any subtree.
library tree_charts;

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

// ═══════════════════════════════════════════════════════════════════════════
// SHARED: Data model
// ═══════════════════════════════════════════════════════════════════════════

/// A node in a collapsible tree.
class TreeNodeData {
  final String id, name;
  final double? value;
  final String? color;
  final List<TreeNodeData> children;
  bool collapsed;

  TreeNodeData({
    required this.id,
    required this.name,
    this.value,
    this.color,
    this.children = const [],
    this.collapsed = false,
  });

  bool get isLeaf => children.isEmpty;

  factory TreeNodeData.fromJson(Map<String, dynamic> j) {
    final ch = (j['children'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TreeNodeData.fromJson)
        .toList();
    return TreeNodeData(
      id: j['id']?.toString() ?? j['name']?.toString() ?? '',
      name: j['name']?.toString() ?? '',
      value: (j['value'] as num?)?.toDouble(),
      color: j['color']?.toString(),
      children: ch,
      collapsed: j['collapsed'] as bool? ?? false,
    );
  }

  /// Deep clone for state mutation
  TreeNodeData clone() => TreeNodeData(
    id: id, name: name, value: value, color: color,
    collapsed: collapsed,
    children: children.map((c) => c.clone()).toList(),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED: Layout engine
// ═══════════════════════════════════════════════════════════════════════════

enum _TreeDir { ltr, rtl, ttb, btt, radial }

/// A positioned node in the layout pass.
class _PNode {
  final TreeNodeData data;
  final Offset pos;
  final _PNode? parent;
  _PNode(this.data, this.pos, this.parent);
}

/// Reingold-Tilford inspired tree layout. Returns flat list of [_PNode].
class _TreeLayout {
  static const double _hGap = 56.0; // horizontal gap between levels
  static const double _vGap = 36.0; // vertical gap between siblings

  /// Layout for a horizontal tree (ltr / rtl) — depth on X, breadth on Y.
  static List<_PNode> layoutHorizontal(TreeNodeData root, Size size,
      {bool flipX = false}) {
    final nodes = <_PNode>[];
    final yPositions = <String, double>{};

    // First pass: assign Y using DFS order of visible nodes
    int leafIdx = 0;
    void assignY(TreeNodeData n) {
      if (n.collapsed || n.isLeaf) {
        yPositions[n.id] = leafIdx * _vGap;
        leafIdx++;
      } else {
        for (final c in n.children) assignY(c);
        // parent Y = mean of children
        final ys = n.children.map((c) => yPositions[c.id] ?? 0).toList();
        yPositions[n.id] = (ys.reduce((a, b) => a + b)) / ys.length;
      }
    }

    assignY(root);

    final totalH = (leafIdx - 1) * _vGap;
    final offsetY = size.height / 2 - totalH / 2;

    // Second pass: assign X based on depth, build PNodes
    void buildNodes(TreeNodeData n, int depth, _PNode? par) {
      final rawY = yPositions[n.id] ?? 0;
      final y = rawY + offsetY;
      final rawX = depth * _hGap + 24;
      final x = flipX ? size.width - rawX : rawX;
      final pn = _PNode(n, Offset(x, y), par);
      nodes.add(pn);
      if (!n.collapsed) {
        for (final c in n.children) buildNodes(c, depth + 1, pn);
      }
    }

    buildNodes(root, 0, null);
    return nodes;
  }

  /// Layout for a vertical tree (ttb / btt) — depth on Y, breadth on X.
  static List<_PNode> layoutVertical(TreeNodeData root, Size size,
      {bool flipY = false}) {
    final nodes = <_PNode>[];
    final xPositions = <String, double>{};

    int leafIdx = 0;
    void assignX(TreeNodeData n) {
      if (n.collapsed || n.isLeaf) {
        xPositions[n.id] = leafIdx * _vGap;
        leafIdx++;
      } else {
        for (final c in n.children) assignX(c);
        final xs = n.children.map((c) => xPositions[c.id] ?? 0).toList();
        xPositions[n.id] = xs.reduce((a, b) => a + b) / xs.length;
      }
    }

    assignX(root);

    final totalW = (leafIdx - 1) * _vGap;
    final offsetX = size.width / 2 - totalW / 2;

    void buildNodes(TreeNodeData n, int depth, _PNode? par) {
      final rawX = xPositions[n.id] ?? 0;
      final x = rawX + offsetX;
      final rawY = depth * _hGap + 24;
      final y = flipY ? size.height - rawY : rawY;
      final pn = _PNode(n, Offset(x, y), par);
      nodes.add(pn);
      if (!n.collapsed) {
        for (final c in n.children) buildNodes(c, depth + 1, pn);
      }
    }

    buildNodes(root, 0, null);
    return nodes;
  }

  /// Radial layout — depth as radius, breadth as angle.
  static List<_PNode> layoutRadial(TreeNodeData root, Size size) {
    final nodes = <_PNode>[];
    final cx = size.width / 2, cy = size.height / 2;
    final maxR = math.min(cx, cy) * 0.88;

    int _countLeaves(TreeNodeData n) {
      if (n.collapsed || n.isLeaf) return 1;
      return n.children.fold(0, (s, c) => s + _countLeaves(c));
    }

    int _maxDepth(TreeNodeData n, [int d = 0]) {
      if (n.collapsed || n.isLeaf) return d;
      return n.children.map((c) => _maxDepth(c, d + 1)).reduce(math.max);
    }

    final totalLeaves = _countLeaves(root);
    final depth = _maxDepth(root);
    final rStep = depth > 0 ? maxR / depth : maxR;

    void buildNodes(TreeNodeData n, int d, double aStart, double aSweep, _PNode? par) {
      final r = d == 0 ? 0.0 : d * rStep;
      final aMid = aStart + aSweep / 2;
      final pos = d == 0
          ? Offset(cx, cy)
          : Offset(cx + r * math.cos(aMid), cy + r * math.sin(aMid));
      final pn = _PNode(n, pos, par);
      nodes.add(pn);
      if (!n.collapsed && !n.isLeaf) {
        double aOff = aStart;
        for (final c in n.children) {
          final leaves = _countLeaves(c);
          final cSweep = aSweep * leaves / totalLeaves;
          buildNodes(c, d + 1, aOff, cSweep, pn);
          aOff += cSweep;
        }
      }
    }

    buildNodes(root, 0, -math.pi / 2, 2 * math.pi, null);
    return nodes;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED: Tree painter (straight edges)
// ═══════════════════════════════════════════════════════════════════════════

void _paintTree(Canvas canvas, List<_PNode> nodes, ChartPainterBase base,
    {bool polyline = false, bool radial = false, double progress = 1.0}) {
  final theme = base.theme;

  // Draw edges
  for (final pn in nodes) {
    final par = pn.parent;
    if (par == null) continue;
    final p0 = par.pos;
    final p1 = pn.pos;
    final paint = base.paintCache.stroke(theme.axisColor.withOpacity(0.55), 1.2)
        ..isAntiAlias = true;

    if (polyline) {
      // Orthogonal elbow connectors
      final mx = (p0.dx + p1.dx) / 2;
      canvas.drawLine(p0, Offset(mx, p0.dy), paint);
      canvas.drawLine(Offset(mx, p0.dy), Offset(mx, p1.dy), paint);
      canvas.drawLine(Offset(mx, p1.dy), p1, paint);
    } else if (radial) {
      // Smooth bezier for radial
      final path = Path()
        ..moveTo(p0.dx, p0.dy)
        ..cubicTo(
            p0.dx + (p1.dx - p0.dx) * 0.5, p0.dy,
            p0.dx + (p1.dx - p0.dx) * 0.5, p1.dy,
            p1.dx, p1.dy);
      canvas.drawPath(path, paint);
    } else {
      // Smooth bezier
      final path = Path()
        ..moveTo(p0.dx, p0.dy)
        ..cubicTo(
            p0.dx + (p1.dx - p0.dx) * 0.55, p0.dy,
            p0.dx + (p1.dx - p0.dx) * 0.45, p1.dy,
            p1.dx, p1.dy);
      canvas.drawPath(path, paint);
    }
  }

  // Draw nodes
  for (final pn in nodes) {
    final n = pn.data;
    final pos = pn.pos;
    Color nodeColor;
    try {
      nodeColor = n.color != null
          ? base.colorCache.resolve(n.color!)
          : (n.isLeaf ? theme.seriesColor(1) : theme.seriesColor(0));
    } catch (_) {
      nodeColor = n.isLeaf ? theme.seriesColor(1) : theme.seriesColor(0);
    }

    final r = n.isLeaf ? 5.0 : 7.0;
    // Background circle
    canvas.drawCircle(pos, r + 1.5,
        Paint()..color = theme.backgroundColor..style = PaintingStyle.fill..isAntiAlias = true);
    // Filled circle
    canvas.drawCircle(pos, r,
        Paint()..color = nodeColor..style = PaintingStyle.fill..isAntiAlias = true);
    // Stroke
    canvas.drawCircle(pos, r,
        base.paintCache.stroke(nodeColor.withOpacity(0.7), 1.5)..isAntiAlias = true);

    // Collapse indicator
    if (!n.isLeaf) {
      canvas.drawCircle(pos, 3,
          Paint()..color = n.collapsed ? Colors.white : theme.backgroundColor
            ..style = PaintingStyle.fill..isAntiAlias = true);
    }

    // Label
    final tp = base.textPainterCache.get(n.name,
        theme.typography.axisLabelStyle.copyWith(
            color: theme.titleColor, fontSize: 10));
    // Position label to avoid overlap with node circle
    final lx = radial
        ? pos.dx + (pos.dx > 0 ? r + 3 : -r - tp.width - 3)
        : pos.dx + r + 4;
    final ly = pos.dy - tp.height / 2;
    tp.paint(canvas, Offset(lx, ly));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// UNIFIED: TreeChartConfig  (covers ltr / rtl / ttb / btt / radial)
// ═══════════════════════════════════════════════════════════════════════════
/// Single config covering all directional variants.
///
/// JSON:
/// ```json
/// { "type": "treeLTR",
///   "direction": "ltr",
///   "root": {
///     "id": "root", "name": "CEO",
///     "children": [
///       { "id":"a", "name":"CTO",
///         "children":[{"id":"a1","name":"DevOps"},{"id":"a2","name":"Backend"}]},
///       { "id":"b", "name":"CFO"}
///     ]
///   }}
/// ```
class TreeChartConfig extends BaseChartConfig {
  final TreeNodeData root;
  final String direction;  // 'ltr'|'rtl'|'ttb'|'btt'|'radial'
  final bool polylineEdge;
  final ChartTheme theme;

  TreeChartConfig({
    required this.root,
    this.direction = 'ltr',
    this.polylineEdge = false,
    this.theme = ChartTheme.light,
    required ChartType chartType,
    super.title, super.tooltip, super.legend,
  }) : super(type: chartType, series: const []);

  @override Widget buildChart() => TreeChartWidget(config: this);

  factory TreeChartConfig.fromJson(Map<String, dynamic> j) {
    final dir = j['direction']?.toString() ?? 'ltr';
    ChartType ct;
    switch (dir) {
      case 'rtl':    ct = ChartType.treeRTL; break;
      case 'ttb':    ct = ChartType.treeTTB; break;
      case 'btt':    ct = ChartType.treeBTT; break;
      case 'radial': ct = ChartType.treeRadial; break;
      default:       ct = ChartType.treeLTR;
    }
    final rawType = j['type']?.toString() ?? '';
    if (rawType == 'treePolyline') ct = ChartType.treePolyline;

    final root = j['root'] != null
        ? TreeNodeData.fromJson(j['root'] as Map<String, dynamic>)
        : TreeNodeData(id: 'root', name: 'Root');
    return TreeChartConfig(
      root: root, direction: dir,
      polylineEdge: j['polylineEdge'] as bool? ?? rawType == 'treePolyline',
      chartType: ct,
      title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
      tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'treeLTR', 'direction': direction};
}

class TreeChartWidget extends StatefulWidget {
  final TreeChartConfig config;
  const TreeChartWidget({super.key, required this.config});
  @override State<TreeChartWidget> createState() => _TreeState();
}

class _TreeState extends State<TreeChartWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  late TreeNodeData _root;
  Offset _pan = Offset.zero;
  double _scale = 1.0;
  Offset _panStart = Offset.zero;
  Offset _focalStart = Offset.zero;

  TreeChartConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _root = cfg.root.clone();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  _TreeDir get _dir {
    switch (cfg.direction) {
      case 'rtl':    return _TreeDir.rtl;
      case 'ttb':    return _TreeDir.ttb;
      case 'btt':    return _TreeDir.btt;
      case 'radial': return _TreeDir.radial;
      default:       return _TreeDir.ltr;
    }
  }

  List<_PNode> _buildLayout(Size size) {
    switch (_dir) {
      case _TreeDir.rtl:    return _TreeLayout.layoutHorizontal(_root, size, flipX: true);
      case _TreeDir.ttb:    return _TreeLayout.layoutVertical(_root, size);
      case _TreeDir.btt:    return _TreeLayout.layoutVertical(_root, size, flipY: true);
      case _TreeDir.radial: return _TreeLayout.layoutRadial(_root, size);
      default:              return _TreeLayout.layoutHorizontal(_root, size);
    }
  }

  void _handleTap(Offset local, Size size) {
    final nodes = _buildLayout(size);
    // Transform tap position back from pan/scale
    final transformed = (local - _pan) / _scale;
    for (final pn in nodes) {
      if ((pn.pos - transformed).distance < 14) {
        if (!pn.data.isLeaf) {
          setState(() => pn.data.collapsed = !pn.data.collapsed);
          _ctrl.forward(from: 0);
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      return GestureDetector(
        onScaleStart: (d) { _focalStart = d.focalPoint; _panStart = _pan; },
        onScaleUpdate: (d) => setState(() {
          _scale = (_scale * d.scale).clamp(0.3, 4.0);
          _pan = _panStart + (d.focalPoint - _focalStart);
        }),
        onTapDown: (d) => _handleTap(d.localPosition, sz),
        child: RepaintBoundary(child: CustomPaint(
          size: Size.infinite,
          painter: _TreePainter(
            root: _root,
            dir: _dir,
            polyline: cfg.polylineEdge,
            progress: _anim.value,
            pan: _pan,
            scale: _scale,
            theme: cfg.theme,
          ),
        )),
      );
    })),
    Padding(padding: const EdgeInsets.only(bottom: 4),
      child: Text('Tap node to collapse/expand  ·  Pinch to zoom  ·  Drag to pan',
          style: cfg.theme.typography.axisLabelStyle.copyWith(
              color: cfg.theme.axisLabelColor.withOpacity(0.45), fontSize: 8.5))),
  ]);
}

class _TreePainter extends ChartPainterBase {
  final TreeNodeData root;
  final _TreeDir dir;
  final bool polyline;
  final double progress;
  final Offset pan;
  final double scale;

  _TreePainter({
    required this.root, required this.dir,
    required this.polyline, required this.progress,
    required this.pan, required this.scale,
    required ChartTheme theme,
  }) : super(theme: theme);

  @override bool shouldRepaintChart(covariant _TreePainter o) =>
      o.progress != progress || o.pan != pan || o.scale != scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    canvas.save();
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(scale);

    List<_PNode> nodes;
    switch (dir) {
      case _TreeDir.rtl:    nodes = _TreeLayout.layoutHorizontal(root, size, flipX: true); break;
      case _TreeDir.ttb:    nodes = _TreeLayout.layoutVertical(root, size); break;
      case _TreeDir.btt:    nodes = _TreeLayout.layoutVertical(root, size, flipY: true); break;
      case _TreeDir.radial: nodes = _TreeLayout.layoutRadial(root, size); break;
      default:              nodes = _TreeLayout.layoutHorizontal(root, size);
    }

    _paintTree(canvas, nodes, this,
        polyline: polyline,
        radial: dir == _TreeDir.radial,
        progress: progress);
    canvas.restore();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MULTIPLE TREES CONFIG
// ═══════════════════════════════════════════════════════════════════════════
/// Displays several independent tree roots side-by-side in a horizontal layout.
///
/// JSON:
/// ```json
/// { "type": "multipleTrees",
///   "trees": [
///     { "root": { "id":"a", "name":"Tree A", "children": [...] } },
///     { "root": { "id":"b", "name":"Tree B", "children": [...] } }
///   ]}
/// ```
class MultipleTreesConfig extends BaseChartConfig {
  final List<TreeNodeData> roots;
  final String direction;
  final ChartTheme theme;

  MultipleTreesConfig({
    required this.roots,
    this.direction = 'ttb',
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.multipleTrees, series: const []);

  @override Widget buildChart() => _MultiTreeWidget(config: this);

  factory MultipleTreesConfig.fromJson(Map<String, dynamic> j) {
    final trees = (j['trees'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map((t) => TreeNodeData.fromJson(t['root'] as Map<String, dynamic>))
        .toList();
    return MultipleTreesConfig(
      roots: trees,
      direction: j['direction']?.toString() ?? 'ttb',
      title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
      tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
    );
  }
  @override Map<String, dynamic> toJson() => {'type': 'multipleTrees'};
}

class _MultiTreeWidget extends StatefulWidget {
  final MultipleTreesConfig config;
  const _MultiTreeWidget({required this.config});
  @override State<_MultiTreeWidget> createState() => _MTState();
}

class _MTState extends State<_MultiTreeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  late List<TreeNodeData> _roots;
  MultipleTreesConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _roots = cfg.roots.map((r) => r.clone()).toList();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      final partW = sz.width / _roots.length;
      return GestureDetector(
        onTapDown: (d) {
          final ti = (d.localPosition.dx / partW).floor().clamp(0, _roots.length - 1);
          final partSize = Size(partW, sz.height);
          final localX = d.localPosition.dx - ti * partW;
          final nodes = _TreeLayout.layoutVertical(_roots[ti], partSize);
          for (final pn in nodes) {
            if ((pn.pos - Offset(localX, d.localPosition.dy)).distance < 14) {
              if (!pn.data.isLeaf) {
                setState(() => pn.data.collapsed = !pn.data.collapsed);
                _ctrl.forward(from: 0);
              }
              return;
            }
          }
        },
        child: RepaintBoundary(child: CustomPaint(
          size: Size.infinite,
          painter: _MTresPainter(
              roots: _roots, progress: _anim.value,
              direction: cfg.direction, theme: cfg.theme),
        )),
      );
    })),
    Padding(padding: const EdgeInsets.only(bottom: 4),
      child: Text('Tap node to collapse/expand',
          style: cfg.theme.typography.axisLabelStyle.copyWith(
              color: cfg.theme.axisLabelColor.withOpacity(0.4), fontSize: 8.5))),
  ]);
}

class _MTresPainter extends ChartPainterBase {
  final List<TreeNodeData> roots;
  final double progress;
  final String direction;
  _MTresPainter({required this.roots, required this.progress,
      required this.direction, required ChartTheme theme}) : super(theme: theme);
  @override bool shouldRepaintChart(covariant _MTresPainter o) => o.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    if (roots.isEmpty) return;
    final partW = size.width / roots.length;

    for (int i = 0; i < roots.length; i++) {
      canvas.save();
      canvas.translate(i * partW, 0);
      canvas.clipRect(Rect.fromLTWH(0, 0, partW, size.height));

      final partSize = Size(partW, size.height);
      final nodes = direction == 'ltr' || direction == 'rtl'
          ? _TreeLayout.layoutHorizontal(roots[i], partSize, flipX: direction == 'rtl')
          : _TreeLayout.layoutVertical(roots[i], partSize, flipY: direction == 'btt');

      _paintTree(canvas, nodes, this, progress: progress);

      // Divider
      if (i < roots.length - 1) {
        canvas.drawLine(Offset(partW, 0), Offset(partW, size.height),
            paintCache.stroke(theme.gridColor.withOpacity(0.5), 1));
      }
      canvas.restore();
    }
  }
}

/// Geo Charts — 6 geographic visualization types.
///
/// Charts:
///   • [GeoGraphConfig]              — network graph overlaid on a geographic map
///   • [GeoChoroplethScatterConfig]  — choropleth regions + scatter points layer
///   • [GeoBeefCutsConfig]           — body/anatomy region map with labeled cuts
///   • [GeoHeatmapConfig]            — intensity heatmap on a geographic base
///   • [GeoSvgLinesConfig]           — animated arc/line connections between locations
///   • [GeoMorphConfig]              — animated morph between map view and bar chart
///
/// All charts use a built-in Mercator projection. No external dependencies.
/// Supply polygon/point data as lat/lon arrays in JSON.
library geo_charts;

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
import '../core/utils/chart_data_processor.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SHARED GEO PRIMITIVES
// ═══════════════════════════════════════════════════════════════════════════

/// Mercator projection: lon/lat → normalised [0,1] canvas coordinates.
class _Mercator {
  final double lonMin, lonMax, latMin, latMax;
  const _Mercator({
    this.lonMin = -180, this.lonMax = 180,
    this.latMin = -85,  this.latMax = 85,
  });

  /// World Mercator to canvas offset.
  Offset project(double lon, double lat, Size canvas,
      {double padL = 0, double padT = 0, double padR = 0, double padB = 0}) {
    final w = canvas.width - padL - padR;
    final h = canvas.height - padT - padB;
    final x = padL + (lon - lonMin) / (lonMax - lonMin) * w;
    final latRad = lat * math.pi / 180;
    final mercLat = math.log(math.tan(math.pi / 4 + latRad / 2));
    final latMinR = latMin * math.pi / 180;
    final mercMin = math.log(math.tan(math.pi / 4 + latMinR / 2));
    final latMaxR = latMax * math.pi / 180;
    final mercMax = math.log(math.tan(math.pi / 4 + latMaxR / 2));
    final y = padT + h * (1 - (mercLat - mercMin) / (mercMax - mercMin));
    return Offset(x, y);
  }
}

/// A geographic region (polygon + metadata).
class GeoRegion {
  final String id, name;
  final double? value;
  final String? color;
  final List<List<double>> polygon; // [[lon,lat], ...]

  const GeoRegion({
    required this.id,
    required this.name,
    this.value,
    this.color,
    required this.polygon,
  });

  factory GeoRegion.fromJson(Map<String, dynamic> j) => GeoRegion(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        value: (j['value'] as num?)?.toDouble(),
        color: j['color']?.toString(),
        polygon: (j['polygon'] as List? ?? [])
            .map<List<double>>((p) => [(p[0] as num).toDouble(), (p[1] as num).toDouble()])
            .toList(),
      );
}

/// A geographic point (lat/lon + optional metadata).
class GeoPoint {
  final double lon, lat;
  final String? name;
  final double? value;
  final String? color;

  const GeoPoint({required this.lon, required this.lat,
      this.name, this.value, this.color});

  factory GeoPoint.fromJson(Map<String, dynamic> j) => GeoPoint(
        lon: (j['lon'] ?? j['lng'] ?? j['longitude'] ?? 0).toDouble(),
        lat: (j['lat'] ?? j['latitude'] ?? 0).toDouble(),
        name: j['name']?.toString(),
        value: (j['value'] as num?)?.toDouble(),
        color: j['color']?.toString(),
      );
}

/// Color scale: maps a normalised [0,1] t-value to a [Color].
class _ColorScale {
  final List<Color> stops;
  const _ColorScale(this.stops);

  Color lerp(double t) {
    t = t.clamp(0.0, 1.0);
    if (stops.length == 1) return stops.first;
    final s = t * (stops.length - 1);
    final lo = s.floor().clamp(0, stops.length - 2);
    return Color.lerp(stops[lo], stops[lo + 1], s - lo)!;
  }

  static const blues = _ColorScale([Color(0xFFE3F2FD), Color(0xFF1565C0)]);
  static const reds  = _ColorScale([Color(0xFFFFF9C4), Color(0xFFB71C1C)]);
  static const green = _ColorScale([Color(0xFFE8F5E9), Color(0xFF1B5E20)]);
  static const heat  = _ColorScale([Color(0xFF0D47A1), Color(0xFF00BCD4),
      Color(0xFF4CAF50), Color(0xFFFFEB3B), Color(0xFFF44336)]);

  static _ColorScale fromName(String? name) {
    switch (name?.toLowerCase()) {
      case 'reds':  return reds;
      case 'green': return green;
      case 'heat':  return heat;
      default:      return blues;
    }
  }
}

/// Draw a filled polygon from a list of canvas [Offset]s.
void _drawPolygon(Canvas canvas, List<Offset> pts, Paint paint) {
  if (pts.length < 3) return;
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
  path.close();
  canvas.drawPath(path, paint);
}

/// Draw a simple grid of lat/lon reference lines.
void _drawGraticule(Canvas canvas, Size size, _Mercator proj, Paint paint) {
  // Longitude lines every 30°
  for (double lon = -180; lon <= 180; lon += 30) {
    final top = proj.project(lon, 85, size);
    final bot = proj.project(lon, -85, size);
    canvas.drawLine(top, bot, paint);
  }
  // Latitude lines every 30°
  for (double lat = -60; lat <= 60; lat += 30) {
    final left = proj.project(-180, lat, size);
    final right = proj.project(180, lat, size);
    canvas.drawLine(left, right, paint);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. GEO GRAPH — network on a map
// ═══════════════════════════════════════════════════════════════════════════
/// Network graph where nodes are placed at geographic lat/lon positions and
/// connected by straight or arc edges. Supports zoom/pan gestures.
///
/// JSON:
/// ```json
/// { "type": "geoGraph",
///   "nodes": [
///     { "id": "NYC", "name": "New York", "lon": -74.0, "lat": 40.7, "value": 120 },
///     { "id": "LAX", "name": "Los Angeles", "lon": -118.2, "lat": 34.0, "value": 90 }
///   ],
///   "edges": [
///     { "source": "NYC", "target": "LAX", "value": 42, "color": "#42A5F5" }
///   ]}
/// ```
class GeoGraphNode {
  final String id, name;
  final double lon, lat, value;
  final String? color;
  const GeoGraphNode({required this.id, required this.name,
      required this.lon, required this.lat, this.value = 1, this.color});
  factory GeoGraphNode.fromJson(Map<String, dynamic> j) => GeoGraphNode(
    id: j['id']?.toString() ?? '',
    name: j['name']?.toString() ?? '',
    lon: (j['lon'] ?? j['lng'] ?? 0).toDouble(),
    lat: (j['lat'] ?? 0).toDouble(),
    value: (j['value'] as num?)?.toDouble() ?? 1,
    color: j['color']?.toString(),
  );
}

class GeoGraphEdge {
  final String source, target;
  final double value;
  final String? color;
  const GeoGraphEdge({required this.source, required this.target,
      this.value = 1, this.color});
  factory GeoGraphEdge.fromJson(Map<String, dynamic> j) => GeoGraphEdge(
    source: j['source']?.toString() ?? '',
    target: j['target']?.toString() ?? '',
    value: (j['value'] as num?)?.toDouble() ?? 1,
    color: j['color']?.toString(),
  );
}

class GeoGraphConfig extends BaseChartConfig {
  final List<GeoGraphNode> nodes;
  final List<GeoGraphEdge> edges;
  final List<GeoRegion> regions;  // optional background regions
  final String colorScale;
  final bool showGraticule;
  final bool arcEdges;            // curved arc edges
  final ChartTheme theme;

  GeoGraphConfig({
    required this.nodes,
    this.edges = const [],
    this.regions = const [],
    this.colorScale = 'blues',
    this.showGraticule = true,
    this.arcEdges = true,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.geoGraph, series: const []);

  @override Widget buildChart() => _GeoGraphWidget(config: this);

  factory GeoGraphConfig.fromJson(Map<String, dynamic> j) => GeoGraphConfig(
    nodes: (j['nodes'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(GeoGraphNode.fromJson).toList(),
    edges: (j['edges'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(GeoGraphEdge.fromJson).toList(),
    regions: (j['regions'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(GeoRegion.fromJson).toList(),
    colorScale: j['colorScale']?.toString() ?? 'blues',
    showGraticule: j['showGraticule'] as bool? ?? true,
    arcEdges: j['arcEdges'] as bool? ?? true,
    title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
    tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
  );
  @override Map<String, dynamic> toJson() => {'type': 'geoGraph'};
}

class _GeoGraphWidget extends StatefulWidget {
  final GeoGraphConfig config;
  const _GeoGraphWidget({required this.config});
  @override State<_GeoGraphWidget> createState() => _GeoGraphState();
}

class _GeoGraphState extends State<_GeoGraphWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  // pan/zoom state
  Offset _pan = Offset.zero;
  double _scale = 1.0;
  Offset _focalStart = Offset.zero;
  Offset _panStart = Offset.zero;
  String? _hoveredNode;

  GeoGraphConfig get cfg => widget.config;

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
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      return GestureDetector(
        onScaleStart: (d) { _focalStart = d.focalPoint; _panStart = _pan; },
        onScaleUpdate: (d) => setState(() {
          _scale = (_scale * d.scale).clamp(0.5, 8.0);
          _pan = _panStart + (d.focalPoint - _focalStart);
        }),
        child: MouseRegion(
          onHover: (e) => _hitTestNode(e.localPosition, sz),
          onExit: (_) => setState(() => _hoveredNode = null),
          child: Stack(children: [
            RepaintBoundary(child: CustomPaint(
              size: Size.infinite,
              painter: _GeoGraphPainter(
                  cfg: cfg, progress: _anim.value,
                  pan: _pan, scale: _scale),
            )),
            if (_hoveredNode != null)
              _buildTooltip(sz),
          ]),
        ),
      );
    })),
    Padding(padding: const EdgeInsets.only(bottom:4),
      child: Text('Scroll/pinch to zoom · drag to pan',
          style: cfg.theme.typography.axisLabelStyle.copyWith(
              color: cfg.theme.axisLabelColor.withOpacity(0.45), fontSize: 8.5))),
  ]);

  void _hitTestNode(Offset pos, Size sz) {
    final proj = _Mercator();
    const r = 14.0;
    for (final n in cfg.nodes) {
      final p = proj.project(n.lon, n.lat, sz);
      final sp = p * _scale + _pan;
      if ((sp - pos).distance < r) {
        if (_hoveredNode != n.id) setState(() => _hoveredNode = n.id);
        return;
      }
    }
    if (_hoveredNode != null) setState(() => _hoveredNode = null);
  }

  Widget _buildTooltip(Size sz) {
    final n = cfg.nodes.firstWhere((n) => n.id == _hoveredNode,
        orElse: () => cfg.nodes.first);
    final proj = _Mercator();
    final p = proj.project(n.lon, n.lat, sz) * _scale + _pan;
    return Positioned(
      left: p.dx + 12, top: p.dy - 30,
      child: IgnorePointer(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
            color: cfg.theme.tooltipBackgroundColor,
            borderRadius: BorderRadius.circular(7),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)]),
        child: Text('${n.name}\nValue: ${n.value.toStringAsFixed(0)}',
            style: cfg.theme.typography.tooltipStyle
                .copyWith(color: cfg.theme.tooltipTextColor)),
      )),
    );
  }
}

class _GeoGraphPainter extends ChartPainterBase {
  final GeoGraphConfig cfg;
  final double progress;
  final Offset pan;
  final double scale;
  _GeoGraphPainter({required this.cfg, required this.progress,
      required this.pan, required this.scale}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _GeoGraphPainter o) =>
      o.progress != progress || o.pan != pan || o.scale != scale;

  @override
  void paint(Canvas canvas, Size size) {
    final proj = _Mercator();
    canvas.save();
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(scale);

    // Background
    canvas.drawRect(Offset.zero & size,
        Paint()..color = cfg.theme.backgroundColor);

    // Graticule
    if (cfg.showGraticule) {
      _drawGraticule(canvas, size, proj,
          paintCache.stroke(cfg.theme.gridColor.withOpacity(0.25), 0.5));
    }

    // Background regions
    final maxVal = cfg.regions.isEmpty ? 1.0
        : cfg.regions.map((r) => r.value ?? 0).fold(0.0, math.max).clamp(1.0, 1e18);
    final cs = _ColorScale.fromName(cfg.colorScale);
    for (final region in cfg.regions) {
      if (region.polygon.isEmpty) continue;
      final pts = region.polygon.map((ll) => proj.project(ll[0], ll[1], size)).toList();
      Color fill;
      if (region.color != null) {
        try { fill = colorCache.resolve(region.color!); } catch (_) { fill = cs.lerp(0.5); }
      } else {
        fill = cs.lerp((region.value ?? 0) / maxVal);
      }
      _drawPolygon(canvas, pts, Paint()..color = fill..style = PaintingStyle.fill..isAntiAlias = true);
      _drawPolygon(canvas, pts, paintCache.stroke(cfg.theme.gridColor, 0.5));
    }

    // Build node position map
    final nodePos = <String, Offset>{};
    for (final n in cfg.nodes) {
      nodePos[n.id] = proj.project(n.lon, n.lat, size);
    }

    // Edges
    final maxEdgeVal = cfg.edges.isEmpty ? 1.0
        : cfg.edges.map((e) => e.value).fold(0.0, math.max).clamp(1.0, 1e18);
    for (final edge in cfg.edges) {
      final src = nodePos[edge.source];
      final tgt = nodePos[edge.target];
      if (src == null || tgt == null) continue;
      Color ec;
      try { ec = edge.color != null ? colorCache.resolve(edge.color!) : cfg.theme.seriesColor(0); }
      catch (_) { ec = cfg.theme.seriesColor(0); }
      final width = 0.8 + 2.5 * (edge.value / maxEdgeVal);
      final paint = paintCache.stroke(ec.withOpacity(0.55 * progress), width)
          ..isAntiAlias = true;

      if (cfg.arcEdges) {
        // Quadratic bezier arc
        final mid = (src + tgt) / 2;
        final perp = Offset(-(tgt.dy - src.dy), tgt.dx - src.dx).normalized();
        final ctrl = mid + perp * ((src - tgt).distance * 0.25);
        final path = Path()..moveTo(src.dx, src.dy)..quadraticBezierTo(ctrl.dx, ctrl.dy, tgt.dx, tgt.dy);
        canvas.drawPath(path, paint);
      } else {
        canvas.drawLine(src, tgt, paint);
      }
    }

    // Nodes
    final maxNodeVal = cfg.nodes.isEmpty ? 1.0
        : cfg.nodes.map((n) => n.value).fold(0.0, math.max).clamp(1.0, 1e18);
    for (int i = 0; i < cfg.nodes.length; i++) {
      final n = cfg.nodes[i];
      final pos = nodePos[n.id]!;
      final r = (4 + 10 * (n.value / maxNodeVal)) * progress;
      Color nc;
      try { nc = n.color != null ? colorCache.resolve(n.color!) : cfg.theme.seriesColor(i); }
      catch (_) { nc = cfg.theme.seriesColor(i); }

      canvas.drawCircle(pos, r,
          Paint()..color = nc..style = PaintingStyle.fill..isAntiAlias = true);
      canvas.drawCircle(pos, r,
          Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5..isAntiAlias = true);

      if (progress > 0.6) {
        final tp = textPainterCache.get(n.name,
            theme.typography.axisLabelStyle.copyWith(
                color: theme.titleColor, fontSize: 9, fontWeight: FontWeight.w600));
        tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy + r + 2));
      }
    }
    canvas.restore();
  }
}

extension _OffsetNorm on Offset {
  Offset normalized() {
    final d = distance;
    return d == 0 ? Offset.zero : Offset(dx / d, dy / d);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. GEO CHOROPLETH + SCATTER OVERLAY
// ═══════════════════════════════════════════════════════════════════════════
/// Choropleth region map with an additional scatter point layer.
/// Both layers use independent value scales and color settings.
///
/// JSON:
/// ```json
/// { "type": "geoChoroplethScatter",
///   "regions": [{ "id":"US-CA","name":"California","value":39,"polygon":[...] }],
///   "points": [
///     { "lon":-118.2,"lat":34.0,"name":"Los Angeles","value":4 },
///     { "lon":-122.4,"lat":37.8,"name":"San Francisco","value":0.9 }
///   ],
///   "colorScale": "blues",
///   "pointColorScale": "reds" }
/// ```
class GeoChoroplethScatterConfig extends BaseChartConfig {
  final List<GeoRegion> regions;
  final List<GeoPoint> points;
  final String colorScale, pointColorScale;
  final double pointMinSize, pointMaxSize;
  final bool showGraticule;
  final ChartTheme theme;

  GeoChoroplethScatterConfig({
    required this.regions,
    this.points = const [],
    this.colorScale = 'blues',
    this.pointColorScale = 'reds',
    this.pointMinSize = 4,
    this.pointMaxSize = 18,
    this.showGraticule = false,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.geoChoroplethScatter, series: const []);

  @override Widget buildChart() => _GeoChScWidget(config: this);

  factory GeoChoroplethScatterConfig.fromJson(Map<String, dynamic> j) => GeoChoroplethScatterConfig(
    regions: (j['regions'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(GeoRegion.fromJson).toList(),
    points: (j['points'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(GeoPoint.fromJson).toList(),
    colorScale: j['colorScale']?.toString() ?? 'blues',
    pointColorScale: j['pointColorScale']?.toString() ?? 'reds',
    pointMinSize: (j['pointMinSize'] as num?)?.toDouble() ?? 4,
    pointMaxSize: (j['pointMaxSize'] as num?)?.toDouble() ?? 18,
    showGraticule: j['showGraticule'] as bool? ?? false,
    title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
    tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
  );
  @override Map<String, dynamic> toJson() => {'type': 'geoChoroplethScatter'};
}

class _GeoChScWidget extends StatefulWidget {
  final GeoChoroplethScatterConfig config;
  const _GeoChScWidget({required this.config});
  @override State<_GeoChScWidget> createState() => _GeoChScState();
}

class _GeoChScState extends State<_GeoChScWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  GeoPoint? _hovered;
  Offset _hovPos = Offset.zero;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  GeoChoroplethScatterConfig get cfg => widget.config;

  @override
  Widget build(BuildContext context) => Column(children: [
    if (cfg.title?.text != null)
      Padding(padding: const EdgeInsets.fromLTRB(12,10,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      return Stack(children: [
        MouseRegion(
          onHover: (e) => _hitTest(e.localPosition, sz),
          onExit: (_) => setState(() => _hovered = null),
          child: RepaintBoundary(child: CustomPaint(
            size: Size.infinite,
            painter: _GeoChScPainter(cfg: cfg, progress: _anim.value),
          )),
        ),
        if (_hovered != null)
          Positioned(left: (_hovPos.dx + 12).clamp(0, sz.width - 160),
              top: (_hovPos.dy - 40).clamp(0, sz.height - 60),
            child: IgnorePointer(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                  color: cfg.theme.tooltipBackgroundColor,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)]),
              child: Text('${_hovered!.name ?? ''}\n${_hovered!.value?.toStringAsFixed(1) ?? ''}',
                  style: cfg.theme.typography.tooltipStyle
                      .copyWith(color: cfg.theme.tooltipTextColor)),
            ))),
        _buildLegend(sz),
      ]);
    })),
  ]);

  void _hitTest(Offset pos, Size sz) {
    final proj = _Mercator();
    final maxVal = cfg.points.isEmpty ? 1.0
        : cfg.points.map((p) => p.value ?? 0).fold(0.0, math.max).clamp(1.0, 1e18);
    for (final p in cfg.points) {
      final cp = proj.project(p.lon, p.lat, sz);
      final r = cfg.pointMinSize + (cfg.pointMaxSize - cfg.pointMinSize) * ((p.value ?? 0) / maxVal);
      if ((cp - pos).distance < r) {
        setState(() { _hovered = p; _hovPos = pos; }); return;
      }
    }
    if (_hovered != null) setState(() => _hovered = null);
  }

  Widget _buildLegend(Size sz) {
    final cs = _ColorScale.fromName(cfg.colorScale);
    return Positioned(right: 12, bottom: 12, child: Container(
      width: 100, padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: cfg.theme.tooltipBackgroundColor.withOpacity(0.85),
          borderRadius: BorderRadius.circular(6)),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Regions', style: cfg.theme.typography.axisLabelStyle
            .copyWith(color: cfg.theme.titleColor, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(height: 8, decoration: BoxDecoration(
            gradient: LinearGradient(colors: cs.stops), borderRadius: BorderRadius.circular(2))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Low', style: cfg.theme.typography.axisLabelStyle.copyWith(fontSize: 7)),
          Text('High', style: cfg.theme.typography.axisLabelStyle.copyWith(fontSize: 7)),
        ]),
        const SizedBox(height: 6),
        Text('Points', style: cfg.theme.typography.axisLabelStyle
            .copyWith(color: cfg.theme.titleColor, fontSize: 9, fontWeight: FontWeight.bold)),
        Row(children: [
          CircleAvatar(radius: 4, backgroundColor: _ColorScale.fromName(cfg.pointColorScale).lerp(1)),
          const SizedBox(width: 4),
          Text('= high value', style: cfg.theme.typography.axisLabelStyle.copyWith(fontSize: 7)),
        ]),
      ]),
    ));
  }
}

class _GeoChScPainter extends ChartPainterBase {
  final GeoChoroplethScatterConfig cfg;
  final double progress;
  _GeoChScPainter({required this.cfg, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _GeoChScPainter o) => o.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    final proj = _Mercator();
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    if (cfg.showGraticule) {
      _drawGraticule(canvas, size, proj,
          paintCache.stroke(theme.gridColor.withOpacity(0.2), 0.4));
    }

    // Regions choropleth
    final maxRegVal = cfg.regions.isEmpty ? 1.0
        : cfg.regions.map((r) => r.value ?? 0).fold(0.0, math.max).clamp(1.0, 1e18);
    final cs = _ColorScale.fromName(cfg.colorScale);
    for (final region in cfg.regions) {
      if (region.polygon.isEmpty) continue;
      final pts = region.polygon.map((ll) => proj.project(ll[0], ll[1], size)).toList();
      Color fill;
      if (region.color != null) {
        try { fill = colorCache.resolve(region.color!); } catch (_) { fill = cs.lerp(0.5); }
      } else {
        fill = cs.lerp((region.value ?? 0) / maxRegVal * progress);
      }
      _drawPolygon(canvas, pts, Paint()..color = fill..style = PaintingStyle.fill..isAntiAlias = true);
      _drawPolygon(canvas, pts, paintCache.stroke(theme.gridColor.withOpacity(0.6), 0.5));
    }

    // Scatter points
    final maxPtVal = cfg.points.isEmpty ? 1.0
        : cfg.points.map((p) => p.value ?? 0).fold(0.0, math.max).clamp(1.0, 1e18);
    final pcs = _ColorScale.fromName(cfg.pointColorScale);
    for (final pt in cfg.points) {
      final cp = proj.project(pt.lon, pt.lat, size);
      final t = (pt.value ?? 0) / maxPtVal;
      final r = cfg.pointMinSize + (cfg.pointMaxSize - cfg.pointMinSize) * t * progress;
      Color pc;
      try { pc = pt.color != null ? colorCache.resolve(pt.color!) : pcs.lerp(t); }
      catch (_) { pc = pcs.lerp(t); }
      canvas.drawCircle(cp, r,
          Paint()..color = pc.withOpacity(0.75)..style = PaintingStyle.fill..isAntiAlias = true);
      canvas.drawCircle(cp, r,
          Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1..isAntiAlias = true);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. GEO BEEF CUTS — body/anatomy region map
// ═══════════════════════════════════════════════════════════════════════════
/// Labeled region map for any 2D outline/anatomy diagram.
/// Supply outline polygon + labeled sub-regions. Classic use-case: beef cuts,
/// body charts, building floor plans, botanical diagrams.
///
/// Coordinates are normalised [0..1] (not lat/lon — the body outline is the canvas).
///
/// JSON:
/// ```json
/// { "type": "geoBeefCuts",
///   "outline": [[0.1,0.05],[0.9,0.05],[0.9,0.95],[0.1,0.95]],
///   "regions": [
///     { "id":"chuck",  "name":"Chuck",  "value":18, "polygon":[[0.1,0.05],[0.35,0.05],[0.35,0.5],[0.1,0.5]] },
///     { "id":"rib",    "name":"Rib",    "value":10, "polygon":[[0.35,0.05],[0.55,0.05],[0.55,0.5],[0.35,0.5]] }
///   ]}
/// ```
class GeoBeefCutsConfig extends BaseChartConfig {
  final List<List<double>> outline;   // overall body outline [[x,y], ...]
  final List<GeoRegion> regions;      // sub-regions (polygon in [0..1] space)
  final String colorScale;
  final bool showLabels;
  final bool showValues;
  final ChartTheme theme;

  GeoBeefCutsConfig({
    this.outline = const [],
    required this.regions,
    this.colorScale = 'heat',
    this.showLabels = true,
    this.showValues = true,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.geoBeefCuts, series: const []);

  @override Widget buildChart() => _GeoBeefWidget(config: this);

  factory GeoBeefCutsConfig.fromJson(Map<String, dynamic> j) => GeoBeefCutsConfig(
    outline: (j['outline'] as List? ?? [])
        .map<List<double>>((p) => [(p[0] as num).toDouble(), (p[1] as num).toDouble()])
        .toList(),
    regions: (j['regions'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(GeoRegion.fromJson).toList(),
    colorScale: j['colorScale']?.toString() ?? 'heat',
    showLabels: j['showLabels'] as bool? ?? true,
    showValues: j['showValues'] as bool? ?? true,
    title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
    tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
  );
  @override Map<String, dynamic> toJson() => {'type': 'geoBeefCuts'};
}

class _GeoBeefWidget extends StatefulWidget {
  final GeoBeefCutsConfig config;
  const _GeoBeefWidget({required this.config});
  @override State<_GeoBeefWidget> createState() => _GeoBeefState();
}

class _GeoBeefState extends State<_GeoBeefWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  String? _hovered;

  GeoBeefCutsConfig get cfg => widget.config;

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
      Padding(padding: const EdgeInsets.fromLTRB(12,10,12,0),
        child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
            .copyWith(color: cfg.theme.titleColor))),
    Expanded(child: LayoutBuilder(builder: (ctx, con) {
      final sz = Size(con.maxWidth, con.maxHeight);
      return MouseRegion(
        onHover: (e) => _hitTest(e.localPosition, sz),
        onExit: (_) => setState(() => _hovered = null),
        child: RepaintBoundary(child: CustomPaint(
          size: Size.infinite,
          painter: _GeoBeefPainter(cfg: cfg, progress: _anim.value, hovered: _hovered),
        )),
      );
    })),
    _buildLegend(),
  ]);

  void _hitTest(Offset pos, Size sz) {
    const pad = 24.0;
    final w = sz.width - pad * 2, h = sz.height - pad * 2;
    for (final r in cfg.regions) {
      if (r.polygon.isEmpty) continue;
      final pts = r.polygon.map((ll) => Offset(pad + ll[0] * w, pad + ll[1] * h)).toList();
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
      path.close();
      if (path.contains(pos)) {
        if (_hovered != r.id) setState(() => _hovered = r.id);
        return;
      }
    }
    if (_hovered != null) setState(() => _hovered = null);
  }

  Widget _buildLegend() {
    final sorted = [...cfg.regions]..sort((a, b) => (b.value ?? 0).compareTo(a.value ?? 0));
    final cs = _ColorScale.fromName(cfg.colorScale);
    final maxV = sorted.isEmpty ? 1.0 : (sorted.first.value ?? 1).clamp(1.0, 1e18);
    return Padding(padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Wrap(spacing: 10, runSpacing: 4, alignment: WrapAlignment.center,
        children: sorted.take(8).map((r) {
          final t = (r.value ?? 0) / maxV;
          return Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(
                color: cs.lerp(t), shape: BoxShape.circle)),
            const SizedBox(width: 3),
            Text('${r.name}${cfg.showValues ? " (${r.value?.toStringAsFixed(0) ?? ''})" : ""}",
                style: cfg.theme.typography.legendStyle
                    .copyWith(color: cfg.theme.legendTextColor, fontSize: 9)),
          ]);
        }).toList()));
  }
}

class _GeoBeefPainter extends ChartPainterBase {
  final GeoBeefCutsConfig cfg;
  final double progress;
  final String? hovered;
  _GeoBeefPainter({required this.cfg, required this.progress, this.hovered})
      : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _GeoBeefPainter o) =>
      o.progress != progress || o.hovered != hovered;

  Offset _pt(List<double> ll, Size sz, double pad) =>
      Offset(pad + ll[0] * (sz.width - pad * 2), pad + ll[1] * (sz.height - pad * 2));

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 24.0;
    final cs = _ColorScale.fromName(cfg.colorScale);
    final maxVal = cfg.regions.isEmpty ? 1.0
        : cfg.regions.map((r) => r.value ?? 0).fold(0.0, math.max).clamp(1.0, 1e18);

    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);

    // Outer outline
    if (cfg.outline.isNotEmpty) {
      final oPts = cfg.outline.map((ll) => _pt(ll, size, pad)).toList();
      _drawPolygon(canvas, oPts, Paint()..color = theme.gridColor.withOpacity(0.15)..style = PaintingStyle.fill);
      _drawPolygon(canvas, oPts, paintCache.stroke(theme.axisColor.withOpacity(0.6), 1.5));
    }

    // Regions
    for (final region in cfg.regions) {
      if (region.polygon.isEmpty) continue;
      final pts = region.polygon.map((ll) => _pt(ll, size, pad)).toList();
      final isHov = region.id == hovered;
      final t = (region.value ?? 0) / maxVal;
      Color fill;
      try { fill = region.color != null ? colorCache.resolve(region.color!) : cs.lerp(t); }
      catch (_) { fill = cs.lerp(t); }

      _drawPolygon(canvas, pts, Paint()..color = isHov
          ? Color.lerp(fill, Colors.white, 0.35)!
          : fill.withOpacity(0.82 * progress)..style = PaintingStyle.fill..isAntiAlias = true);
      _drawPolygon(canvas, pts, paintCache.stroke(
          isHov ? theme.titleColor : theme.gridColor, isHov ? 2.0 : 0.8)..isAntiAlias = true);

      // Label at centroid
      if (cfg.showLabels) {
        final cx = pts.map((p) => p.dx).reduce((a, b) => a + b) / pts.length;
        final cy = pts.map((p) => p.dy).reduce((a, b) => a + b) / pts.length;
        final lbl = cfg.showValues
            ? '${region.name}\n${region.value?.toStringAsFixed(0) ?? ''}'
            : region.name;
        final tp = textPainterCache.get(lbl,
            theme.typography.dataLabelStyle.copyWith(
                color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w600),
            align: TextAlign.center, maxWidth: 70);
        canvas.save();
        canvas.clipPath(Path()..moveTo(pts.first.dx, pts.first.dy)
            ..let((p) { for (int i = 1; i < pts.length; i++) p.lineTo(pts[i].dx, pts[i].dy); return p; })
            ..close());
        tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
        canvas.restore();
      }
    }
  }
}

extension _PathExt on Path {
  Path let(Path Function(Path) fn) => fn(this);
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. GEO HEATMAP — intensity heat map on a map
// ═══════════════════════════════════════════════════════════════════════════
/// Renders intensity points as gaussian blobs on a geographic base map.
/// High-density areas blend into vivid hot-spots. Uses Canvas RadialGradient.
///
/// JSON:
/// ```json
/// { "type": "geoHeatmap",
///   "regions": [{ "id":"...", "polygon":[...] }],
///   "points": [
///     { "lon": -87.6, "lat": 41.8, "value": 0.9, "name": "Chicago" },
///     { "lon": -73.9, "lat": 40.7, "value": 1.0, "name": "New York"  }
///   ],
///   "radius": 40, "colorScale": "heat" }
/// ```
class GeoHeatmapConfig extends BaseChartConfig {
  final List<GeoRegion> regions;
  final List<GeoPoint> points;
  final double radius;         // heat blob radius in canvas pixels
  final double opacity;
  final String colorScale;
  final bool showGraticule;
  final ChartTheme theme;

  GeoHeatmapConfig({
    this.regions = const [],
    required this.points,
    this.radius = 40,
    this.opacity = 0.65,
    this.colorScale = 'heat',
    this.showGraticule = true,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.geoHeatmap, series: const []);

  @override Widget buildChart() => _GeoHeatmapWidget(config: this);

  factory GeoHeatmapConfig.fromJson(Map<String, dynamic> j) => GeoHeatmapConfig(
    regions: (j['regions'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(GeoRegion.fromJson).toList(),
    points: (j['points'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(GeoPoint.fromJson).toList(),
    radius: (j['radius'] as num?)?.toDouble() ?? 40,
    opacity: (j['opacity'] as num?)?.toDouble() ?? 0.65,
    colorScale: j['colorScale']?.toString() ?? 'heat',
    showGraticule: j['showGraticule'] as bool? ?? true,
    title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
    tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
  );
  @override Map<String, dynamic> toJson() => {'type': 'geoHeatmap'};
}

class _GeoHeatmapWidget extends StatefulWidget {
  final GeoHeatmapConfig config;
  const _GeoHeatmapWidget({required this.config});
  @override State<_GeoHeatmapWidget> createState() => _GeoHMState();
}

class _GeoHMState extends State<_GeoHeatmapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  GeoHeatmapConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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
      painter: _GeoHMPainter(cfg: cfg, progress: _anim.value),
    ))),
  ]);
}

class _GeoHMPainter extends ChartPainterBase {
  final GeoHeatmapConfig cfg;
  final double progress;
  _GeoHMPainter({required this.cfg, required this.progress}) : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _GeoHMPainter o) => o.progress != progress;

  @override
  void paint(Canvas canvas, Size size) {
    final proj = _Mercator();
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0D1117));

    if (cfg.showGraticule) {
      _drawGraticule(canvas, size, proj,
          paintCache.stroke(Colors.white.withOpacity(0.08), 0.4));
    }

    // Base regions (dark fill)
    for (final region in cfg.regions) {
      if (region.polygon.isEmpty) continue;
      final pts = region.polygon.map((ll) => proj.project(ll[0], ll[1], size)).toList();
      _drawPolygon(canvas, pts, Paint()..color = const Color(0xFF1E2A38)..style = PaintingStyle.fill..isAntiAlias = true);
      _drawPolygon(canvas, pts, paintCache.stroke(Colors.white.withOpacity(0.15), 0.5));
    }

    // Heat blobs
    final maxVal = cfg.points.isEmpty ? 1.0
        : cfg.points.map((p) => p.value ?? 1).fold(0.0, math.max).clamp(1.0, 1e18);
    final cs = _ColorScale.fromName(cfg.colorScale);

    canvas.saveLayer(Offset.zero & size,
        Paint()..blendMode = BlendMode.screen);
    for (final pt in cfg.points) {
      final cp = proj.project(pt.lon, pt.lat, size);
      final t = ((pt.value ?? 1) / maxVal * progress).clamp(0.0, 1.0);
      final r = cfg.radius * (0.5 + 0.5 * t);
      final hot = cs.lerp(t);
      final gradient = RadialGradient(colors: [
        hot.withOpacity(cfg.opacity * t),
        hot.withOpacity(cfg.opacity * 0.4 * t),
        Colors.transparent,
      ], stops: const [0.0, 0.4, 1.0]);
      canvas.drawCircle(cp, r,
          Paint()..shader = gradient.createShader(
              Rect.fromCircle(center: cp, radius: r))
            ..isAntiAlias = true);
    }
    canvas.restore();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 5. GEO SVG LINES — animated arc connections on a map
// ═══════════════════════════════════════════════════════════════════════════
/// Draws animated great-circle arc lines between named locations.
/// Lines are drawn with a moving dash/glow for a "flight path" effect.
///
/// JSON:
/// ```json
/// { "type": "geoSvgLines",
///   "regions": [...],
///   "connections": [
///     { "from": {"lon":-74,"lat":40.7,"name":"New York"},
///       "to":   {"lon":2.35,"lat":48.85,"name":"Paris"},
///       "value": 120, "color": "#42A5F5" }
///   ]}
/// ```
class GeoConnection {
  final GeoPoint from, to;
  final double value;
  final String? color, label;
  const GeoConnection({required this.from, required this.to,
      this.value = 1, this.color, this.label});
  factory GeoConnection.fromJson(Map<String, dynamic> j) => GeoConnection(
    from: GeoPoint.fromJson(j['from'] as Map<String, dynamic>),
    to:   GeoPoint.fromJson(j['to']   as Map<String, dynamic>),
    value: (j['value'] as num?)?.toDouble() ?? 1,
    color: j['color']?.toString(),
    label: j['label']?.toString(),
  );
}

class GeoSvgLinesConfig extends BaseChartConfig {
  final List<GeoRegion> regions;
  final List<GeoConnection> connections;
  final bool animated;
  final bool showEndpoints;
  final bool showLabels;
  final ChartTheme theme;

  GeoSvgLinesConfig({
    this.regions = const [],
    required this.connections,
    this.animated = true,
    this.showEndpoints = true,
    this.showLabels = true,
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.geoSvgLines, series: const []);

  @override Widget buildChart() => _GeoSvgLinesWidget(config: this);

  factory GeoSvgLinesConfig.fromJson(Map<String, dynamic> j) => GeoSvgLinesConfig(
    regions: (j['regions'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(GeoRegion.fromJson).toList(),
    connections: (j['connections'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(GeoConnection.fromJson).toList(),
    animated: j['animated'] as bool? ?? true,
    showEndpoints: j['showEndpoints'] as bool? ?? true,
    showLabels: j['showLabels'] as bool? ?? true,
    title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
    tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
  );
  @override Map<String, dynamic> toJson() => {'type': 'geoSvgLines'};
}

class _GeoSvgLinesWidget extends StatefulWidget {
  final GeoSvgLinesConfig config;
  const _GeoSvgLinesWidget({required this.config});
  @override State<_GeoSvgLinesWidget> createState() => _GeoSvgState();
}

class _GeoSvgState extends State<_GeoSvgLinesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  GeoSvgLinesConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2400))
      ..addListener(() => setState(() {}));
    if (cfg.animated) _ctrl.repeat(); else _ctrl.forward(from: 1.0);
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
      painter: _GeoSvgLinesPainter(cfg: cfg, animT: _ctrl.value),
    ))),
  ]);
}

class _GeoSvgLinesPainter extends ChartPainterBase {
  final GeoSvgLinesConfig cfg;
  final double animT;
  _GeoSvgLinesPainter({required this.cfg, required this.animT})
      : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _GeoSvgLinesPainter o) =>
      o.animT != animT;

  @override
  void paint(Canvas canvas, Size size) {
    final proj = _Mercator();
    canvas.drawRect(Offset.zero & size,
        Paint()..color = const Color(0xFF0D1B2A));

    // Graticule
    _drawGraticule(canvas, size, proj,
        paintCache.stroke(Colors.white.withOpacity(0.06), 0.4));

    // Regions
    for (final region in cfg.regions) {
      if (region.polygon.isEmpty) continue;
      final pts = region.polygon.map((ll) => proj.project(ll[0], ll[1], size)).toList();
      _drawPolygon(canvas, pts, Paint()..color = const Color(0xFF1A2840)..style = PaintingStyle.fill..isAntiAlias = true);
      _drawPolygon(canvas, pts, paintCache.stroke(Colors.white.withOpacity(0.12), 0.5));
    }

    // Arc connections
    final maxVal = cfg.connections.isEmpty ? 1.0
        : cfg.connections.map((c) => c.value).fold(0.0, math.max).clamp(1.0, 1e18);

    for (int ci = 0; ci < cfg.connections.length; ci++) {
      final conn = cfg.connections[ci];
      final src = proj.project(conn.from.lon, conn.from.lat, size);
      final tgt = proj.project(conn.to.lon, conn.to.lat, size);
      final t = conn.value / maxVal;
      Color lc;
      try { lc = conn.color != null ? colorCache.resolve(conn.color!) : theme.seriesColor(ci); }
      catch (_) { lc = theme.seriesColor(ci); }

      // Compute control point (arc above midpoint)
      final mid = (src + tgt) / 2;
      final dist = (tgt - src).distance;
      final arcH = dist * 0.3;
      final ctrl = Offset(mid.dx, mid.dy - arcH);

      // Static arc (dim)
      final arcPath = Path()..moveTo(src.dx, src.dy)
          ..quadraticBezierTo(ctrl.dx, ctrl.dy, tgt.dx, tgt.dy);
      canvas.drawPath(arcPath,
          paintCache.stroke(lc.withOpacity(0.2), 0.8 + t * 1.5)..isAntiAlias = true);

      // Animated travelling dash
      if (cfg.animated) {
        final phaseShift = ci * 0.2;
        final phase = ((animT + phaseShift) % 1.0);
        // Position along quadratic bezier
        final bt = phase;
        final bx = (1-bt)*(1-bt)*src.dx + 2*(1-bt)*bt*ctrl.dx + bt*bt*tgt.dx;
        final by = (1-bt)*(1-bt)*src.dy + 2*(1-bt)*bt*ctrl.dy + bt*bt*tgt.dy;
        canvas.drawCircle(Offset(bx, by), 3 + t * 3,
            Paint()..color = lc..style = PaintingStyle.fill..isAntiAlias = true);
        // Glow
        canvas.drawCircle(Offset(bx, by), 6 + t * 4,
            Paint()..color = lc.withOpacity(0.3)..style = PaintingStyle.fill..isAntiAlias = true);
      }

      // Endpoints
      if (cfg.showEndpoints) {
        for (final (pt, name) in [(src, conn.from.name), (tgt, conn.to.name)]) {
          canvas.drawCircle(pt, 4,
              Paint()..color = lc..style = PaintingStyle.fill..isAntiAlias = true);
          canvas.drawCircle(pt, 4,
              Paint()..color = Colors.white.withOpacity(0.6)..style = PaintingStyle.stroke
                ..strokeWidth = 1..isAntiAlias = true);
          if (cfg.showLabels && name != null) {
            final tp = textPainterCache.get(name,
                theme.typography.axisLabelStyle.copyWith(
                    color: Colors.white.withOpacity(0.7), fontSize: 8.5));
            tp.paint(canvas, Offset(pt.dx + 6, pt.dy - tp.height / 2));
          }
        }
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 6. GEO MORPH — animated transition between map and bar chart
// ═══════════════════════════════════════════════════════════════════════════
/// Regions are shown as a map at t=0 and morph into a horizontal bar chart
/// at t=1. Tap the play button to animate between views.
///
/// JSON:
/// ```json
/// { "type": "geoMorph",
///   "regions": [
///     { "id":"US","name":"United States","value":331,"polygon":[[...]] },
///     { "id":"CN","name":"China","value":1440,"polygon":[[...]]}
///   ]}
/// ```
class GeoMorphConfig extends BaseChartConfig {
  final List<GeoRegion> regions;
  final String colorScale;
  final Duration animDuration;
  final ChartTheme theme;

  GeoMorphConfig({
    required this.regions,
    this.colorScale = 'blues',
    this.animDuration = const Duration(milliseconds: 1200),
    this.theme = ChartTheme.light,
    super.title, super.tooltip, super.legend,
  }) : super(type: ChartType.geoMorph, series: const []);

  @override Widget buildChart() => GeoMorphWidget(config: this);

  factory GeoMorphConfig.fromJson(Map<String, dynamic> j) => GeoMorphConfig(
    regions: (j['regions'] as List? ?? []).whereType<Map<String, dynamic>>()
        .map(GeoRegion.fromJson).toList(),
    colorScale: j['colorScale']?.toString() ?? 'blues',
    title:   j['title'] != null ? TitlesData.fromJson(j['title']) : null,
    tooltip: j['tooltip'] != null ? ChartTooltip.fromJson(j['tooltip']) : null,
  );
  @override Map<String, dynamic> toJson() => {'type': 'geoMorph'};
}

class GeoMorphWidget extends StatefulWidget {
  final GeoMorphConfig config;
  const GeoMorphWidget({super.key, required this.config});
  @override State<GeoMorphWidget> createState() => _GeoMorphState();
}

class _GeoMorphState extends State<GeoMorphWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _showingMap = true;

  GeoMorphConfig get cfg => widget.config;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: cfg.animDuration);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.addListener(() => setState(() {}));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _toggle() {
    if (_showingMap) { _ctrl.forward(); _showingMap = false; }
    else { _ctrl.reverse(); _showingMap = true; }
  }

  @override
  Widget build(BuildContext context) {
    final morphT = _anim.value; // 0 = map, 1 = bar

    return Column(children: [
      if (cfg.title?.text != null)
        Padding(padding: const EdgeInsets.fromLTRB(12,10,12,0),
          child: Text(cfg.title!.text!, style: cfg.theme.typography.titleStyle
              .copyWith(color: cfg.theme.titleColor))),
      Expanded(child: RepaintBoundary(child: CustomPaint(
        size: Size.infinite,
        painter: _GeoMorphPainter(cfg: cfg, morphT: morphT),
      ))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                  color: cfg.theme.seriesColor(0),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_showingMap ? Icons.bar_chart : Icons.map,
                    color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(_showingMap ? 'Switch to Bar' : 'Switch to Map',
                    style: cfg.theme.typography.axisLabelStyle.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _GeoMorphPainter extends ChartPainterBase {
  final GeoMorphConfig cfg;
  final double morphT; // 0=map, 1=bar

  _GeoMorphPainter({required this.cfg, required this.morphT})
      : super(theme: cfg.theme);
  @override bool shouldRepaintChart(covariant _GeoMorphPainter o) =>
      o.morphT != morphT;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);

    final sorted = [...cfg.regions]
      ..sort((a, b) => (b.value ?? 0).compareTo(a.value ?? 0));
    final maxVal = sorted.isEmpty ? 1.0
        : (sorted.first.value ?? 1).clamp(1.0, 1e18);
    final cs = _ColorScale.fromName(cfg.colorScale);
    final proj = _Mercator();
    final n = sorted.length;

    // Bar chart target geometry
    const padL = 90.0, padR = 16.0, padT = 16.0, padB = 16.0;
    final plotW = size.width - padL - padR;
    final plotH = size.height - padT - padB;
    final rowH = n > 0 ? plotH / n : 1.0;
    final barH = rowH * 0.55;

    for (int i = 0; i < sorted.length; i++) {
      final region = sorted[i];
      final t = (region.value ?? 0) / maxVal;
      Color fill;
      try { fill = region.color != null ? colorCache.resolve(region.color!) : cs.lerp(t); }
      catch (_) { fill = cs.lerp(t); }

      // === MAP geometry: centroid of polygon ===
      Offset mapCenter = Offset(size.width / 2, size.height / 2);
      double mapW = 0, mapH = 0;
      if (region.polygon.isNotEmpty) {
        final canvasPts = region.polygon.map((ll) => proj.project(ll[0], ll[1], size)).toList();
        mapCenter = Offset(
          canvasPts.map((p) => p.dx).reduce((a, b) => a + b) / canvasPts.length,
          canvasPts.map((p) => p.dy).reduce((a, b) => a + b) / canvasPts.length,
        );
        mapW = (canvasPts.map((p) => p.dx).reduce(math.max) -
                canvasPts.map((p) => p.dx).reduce(math.min)).clamp(4, size.width);
        mapH = (canvasPts.map((p) => p.dy).reduce(math.max) -
                canvasPts.map((p) => p.dy).reduce(math.min)).clamp(4, size.height);
      }

      // === BAR geometry ===
      final barY = padT + i * rowH + (rowH - barH) / 2;
      final barLen = t * plotW;
      final barCenter = Offset(padL + barLen / 2, barY + barH / 2);

      // Interpolate center and size
      final cx = ui.lerpDouble(mapCenter.dx, barCenter.dx, morphT)!;
      final cy = ui.lerpDouble(mapCenter.dy, barCenter.dy, morphT)!;
      final rw = ui.lerpDouble(math.max(mapW, 6), barLen, morphT)!;
      final rh = ui.lerpDouble(math.max(mapH, 6), barH, morphT)!;

      final rect = Rect.fromCenter(center: Offset(cx, cy), width: rw, height: rh);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(morphT * 4)),
          Paint()..color = fill.withOpacity(0.85)..style = PaintingStyle.fill..isAntiAlias = true);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(morphT * 4)),
          paintCache.stroke(theme.gridColor, 0.6)..isAntiAlias = true);

      // Labels fade in as bar
      if (morphT > 0.3) {
        final opacity = ((morphT - 0.3) / 0.7).clamp(0.0, 1.0);
        final tp = textPainterCache.get(region.name,
            theme.typography.axisLabelStyle.copyWith(
                color: theme.axisLabelColor.withOpacity(opacity), fontSize: 9.5),
            maxWidth: padL - 8, align: TextAlign.right);
        tp.paint(canvas, Offset(padL - tp.width - 6, barY + (barH - tp.height) / 2));

        final vtp = textPainterCache.get(region.value?.toStringAsFixed(0) ?? '',
            theme.typography.axisLabelStyle.copyWith(
                color: fill.withOpacity(opacity), fontSize: 9, fontWeight: FontWeight.w600));
        vtp.paint(canvas, Offset(padL + barLen + 4, barY + (barH - vtp.height) / 2));
      }
    }

    // Graticule fades out
    if (morphT < 0.5) {
      canvas.saveLayer(Offset.zero & size,
          Paint()..color = Color.fromRGBO(255, 255, 255, (1 - morphT * 2).clamp(0, 1)));
      _drawGraticule(canvas, size, proj,
          paintCache.stroke(theme.gridColor.withOpacity(0.2), 0.4));
      canvas.restore();
    }
  }
}

/// indonesia_heatmap_chart.dart
///
/// Self-contained, config/JSON-driven geographic heatmap for Indonesia.
///
/// FEATURES
///   ┌─────────────────────────────────────────────────────────────────────┐
///   │  • All 38 provinces – filled polygons, value-mapped colour          │
///   │  • 117 cities / kabupaten capitals – sized circles                  │
///   │  • Render modes: 'province' | 'city' | 'combined'                   │
///   │  • Colour scales: 'blues' | 'reds' | 'greens' | 'heat' | 'national'│
///   │  • Optional Gaussian heat-blob density layer (city mode)            │
///   │  • Island-group filter tabs (All / Sumatra / Jawa / …)              │
///   │  • Pinch-to-zoom + drag-to-pan + one-tap reset                      │
///   │  • Hover/tap tooltip with name, type, value                         │
///   │  • Animated gradient legend bar                                     │
///   │  • Live search → highlight matching provinces or cities             │
///   │  • Smooth entry animation (1.1 s, easeOutCubic)                     │
///   └─────────────────────────────────────────────────────────────────────┘
///
/// JSON schema:
/// ```json
/// {
///   "type"       : "indonesiaHeatmap",
///   "mode"       : "combined",
///   "colorScale" : "heat",
///   "showCities" : true,
///   "showLabels" : true,
///   "showHeatBlobs": false,
///   "provinceData": [{ "id": "JK", "value": 10560 }, ...],
///   "cityData"    : [{ "id": "jakarta", "value": 10560000 }, ...]
/// }
/// ```
library indonesia_heatmap_chart;

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/config/base_config.dart';
import '../core/config/chart_type.dart';
import '../core/config/chart_theme.dart';
import '../core/config/title.dart';
import '../core/config/tooltip.dart' as ct;
import '../core/config/legend.dart';
import '../core/config/chart_model.dart';
import '../core/painters/chart_painter_base.dart';
import '../core/utils/chart_cache.dart';
import 'indonesia_geo_data.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MERCATOR PROJECTION — clamped to Indonesia's bounding box
// ═══════════════════════════════════════════════════════════════════════════

class _Proj {
  static const double _lonMin = 94.5, _lonMax = 141.5;
  static const double _latMin = -11.2, _latMax = 6.2;
  static const double _pad = 0.025; // 2.5% edge padding

  static Offset toCanvas(double lon, double lat, Size sz) {
    final padW = sz.width * _pad, padH = sz.height * _pad;
    final w = sz.width - padW * 2, h = sz.height - padH * 2;

    final x = padW + (lon - _lonMin) / (_lonMax - _lonMin) * w;

    final latR   = lat * math.pi / 180;
    final merc   = math.log(math.tan(math.pi / 4 + latR / 2));
    final minR   = _latMin * math.pi / 180;
    final mercMn = math.log(math.tan(math.pi / 4 + minR / 2));
    final maxR   = _latMax * math.pi / 180;
    final mercMx = math.log(math.tan(math.pi / 4 + maxR / 2));

    final y = padH + h * (1 - (merc - mercMn) / (mercMx - mercMn));
    return Offset(x, y);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COLOUR SCALE
// ═══════════════════════════════════════════════════════════════════════════

class _CS {
  final List<Color> stops;
  const _CS(this.stops);

  Color at(double t) {
    t = t.clamp(0.0, 1.0);
    if (stops.length == 1) return stops.first;
    final s = t * (stops.length - 1);
    final lo = s.floor().clamp(0, stops.length - 2);
    return Color.lerp(stops[lo], stops[lo + 1], s - lo)!;
  }

  static const _CS blues = _CS([
    Color(0xFFE3F2FD), Color(0xFF64B5F6), Color(0xFF1E88E5), Color(0xFF0D47A1),
  ]);
  static const _CS reds = _CS([
    Color(0xFFFFF8E1), Color(0xFFFFCC02), Color(0xFFFF6D00), Color(0xFFB71C1C),
  ]);
  static const _CS greens = _CS([
    Color(0xFFE8F5E9), Color(0xFF81C784), Color(0xFF388E3C), Color(0xFF1B5E20),
  ]);
  static const _CS heat = _CS([
    Color(0xFF1A237E), Color(0xFF1565C0), Color(0xFF00ACC1),
    Color(0xFF43A047), Color(0xFFFFD600), Color(0xFFEF5350),
  ]);
  // Merah-putih (red-white national palette)
  static const _CS national = _CS([
    Color(0xFFFFEBEE), Color(0xFFEF9A9A),
    Color(0xFFE53935), Color(0xFFB71C1C),
  ]);

  static _CS fromName(String? n) {
    switch (n?.toLowerCase()) {
      case 'reds':     return reds;
      case 'greens':   return greens;
      case 'heat':     return heat;
      case 'national': return national;
      default:         return blues;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VALUE MODELS
// ═══════════════════════════════════════════════════════════════════════════

class ProvinceValue {
  final String id;
  final double value;
  final String? label;
  const ProvinceValue({required this.id, required this.value, this.label});
  factory ProvinceValue.fromJson(Map<String, dynamic> j) => ProvinceValue(
    id: j['id']?.toString() ?? '',
    value: (j['value'] as num?)?.toDouble() ?? 0,
    label: j['label']?.toString(),
  );
}

class CityValue {
  final String id;
  final double value;
  const CityValue({required this.id, required this.value});
  factory CityValue.fromJson(Map<String, dynamic> j) => CityValue(
    id: j['id']?.toString() ?? '',
    value: (j['value'] as num?)?.toDouble() ?? 0,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// CONFIG
// ═══════════════════════════════════════════════════════════════════════════

/// Config for the Indonesia provincial + city heatmap chart.
class IndonesiaHeatmapConfig extends BaseChartConfig {
  /// Render mode: `'province'` | `'city'` | `'combined'`
  final String mode;

  /// Colour scale: `'blues'` | `'reds'` | `'greens'` | `'heat'` | `'national'`
  final String colorScale;

  /// Per-province override values. Falls back to uniform fill when empty.
  final List<ProvinceValue> provinceData;

  /// Per-city override values. Falls back to embedded population.
  final List<CityValue> cityData;

  final bool showCities;
  final bool showLabels;

  /// Render Gaussian density blobs behind city dots.
  final bool showHeatBlobs;

  final double cityMinSize;   // min dot radius px
  final double cityMaxSize;   // max dot radius px
  final double heatRadius;    // blob radius px

  final ChartTheme theme;

  IndonesiaHeatmapConfig({
    this.mode = 'combined',
    this.colorScale = 'heat',
    this.provinceData = const [],
    this.cityData = const [],
    this.showCities = true,
    this.showLabels = true,
    this.showHeatBlobs = false,
    this.cityMinSize = 3,
    this.cityMaxSize = 18,
    this.heatRadius = 38,
    this.theme = ChartTheme.light,
    super.title,
    super.tooltip,
    super.legend,
  }) : super(type: ChartType.indonesiaHeatmap, series: const []);

  @override
  Widget buildChart() => _IndonesiaHeatmapWidget(config: this);

  factory IndonesiaHeatmapConfig.fromJson(Map<String, dynamic> j) =>
      IndonesiaHeatmapConfig(
        mode:       j['mode']?.toString()       ?? 'combined',
        colorScale: j['colorScale']?.toString() ?? 'heat',
        provinceData: (j['provinceData'] as List? ?? [])
            .whereType<Map<String, dynamic>>().map(ProvinceValue.fromJson).toList(),
        cityData: (j['cityData'] as List? ?? [])
            .whereType<Map<String, dynamic>>().map(CityValue.fromJson).toList(),
        showCities:    j['showCities']    as bool? ?? true,
        showLabels:    j['showLabels']    as bool? ?? true,
        showHeatBlobs: j['showHeatBlobs'] as bool? ?? false,
        cityMinSize:   (j['cityMinSize']  as num?)?.toDouble() ?? 3,
        cityMaxSize:   (j['cityMaxSize']  as num?)?.toDouble() ?? 18,
        heatRadius:    (j['heatRadius']   as num?)?.toDouble() ?? 38,
        title:   j['title']   != null ? TitlesData.fromJson(j['title'])       : null,
        tooltip: j['tooltip'] != null ? ct.ChartTooltip.fromJson(j['tooltip']): null,
        legend:  j['legend']  != null ? ChartLegend.fromJson(j['legend'])     : null,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'indonesiaHeatmap', 'mode': mode, 'colorScale': colorScale,
  };
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class _IndonesiaHeatmapWidget extends StatefulWidget {
  final IndonesiaHeatmapConfig config;
  const _IndonesiaHeatmapWidget({required this.config});

  @override
  State<_IndonesiaHeatmapWidget> createState() => _IDHMState();
}

class _IDHMState extends State<_IndonesiaHeatmapWidget>
    with SingleTickerProviderStateMixin {

  // ── Animation ───────────────────────────────────────────────────────────────
  late AnimationController _ctrl;
  late Animation<double> _anim;

  // ── Pan / zoom state ────────────────────────────────────────────────────────
  Offset _pan   = Offset.zero;
  double _scale = 1.0;
  Offset _panStart  = Offset.zero;
  Offset _focalStart= Offset.zero;
  double _scaleStart= 1.0;

  // ── Interaction ─────────────────────────────────────────────────────────────
  String? _hovProvId;
  String? _hovCityId;
  Offset  _hovPos = Offset.zero;

  // ── Island filter ───────────────────────────────────────────────────────────
  String _island = 'All';
  static const _tabs = [
    'All','Sumatra','Jawa','Kalimantan','Sulawesi','Maluku','Papua','Bali & NT'
  ];

  // ── Search ──────────────────────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  String _query = '';

  // ── Pre-computed value maps ─────────────────────────────────────────────────
  late final Map<String, double> _pv;   // province id → value
  late final Map<String, double> _cv;   // city     id → value
  late final double _pvMax, _cvMax;

  IndonesiaHeatmapConfig get cfg => widget.config;

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Province values
    if (cfg.provinceData.isNotEmpty) {
      _pv = {for (final p in cfg.provinceData) p.id: p.value};
    } else {
      _pv = {for (final p in kIDProvinces) p.id: 1.0};
    }
    _pvMax = _pv.values.fold(0.0, math.max).clamp(1.0, 1e18);

    // City values
    if (cfg.cityData.isNotEmpty) {
      _cv = {for (final c in cfg.cityData) c.id: c.value};
    } else {
      _cv = {for (final c in kIDCities) c.id: c.pop.toDouble()};
    }
    _cvMax = _cv.values.fold(0.0, math.max).clamp(1.0, 1e18);

    // Animation
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() => setState(() {}));
    _ctrl.forward();

    // Search
    _searchCtrl.addListener(
        () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filtered lists ──────────────────────────────────────────────────────────
  List<IDProvince> get _provs => _island == 'All'
      ? kIDProvinces
      : kIDProvinces.where((p) => p.island == _island).toList();

  List<IDCity> get _cities {
    if (_island == 'All') return kIDCities;
    final ids = _provs.map((p) => p.id).toSet();
    return kIDCities.where((c) => ids.contains(c.provId)).toList();
  }

  // ── Gesture handlers ────────────────────────────────────────────────────────
  void _onScaleStart(ScaleStartDetails d) {
    _focalStart = d.focalPoint;
    _panStart   = _pan;
    _scaleStart = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) => setState(() {
    _scale = (_scaleStart * d.scale).clamp(0.5, 14.0);
    _pan   = _panStart + (d.focalPoint - _focalStart);
  });

  void _resetView() => setState(() { _pan = Offset.zero; _scale = 1.0; });

  // ── Hit test ────────────────────────────────────────────────────────────────
  void _onHover(Offset local, Size sz) {
    final inverted = (local - _pan) / _scale;

    // Cities first (higher z-order)
    if (cfg.showCities && cfg.mode != 'province') {
      for (final city in _cities.reversed) {
        final cp = _Proj.toCanvas(city.lon, city.lat, sz);
        final cv = _cv[city.id] ?? 0;
        final r  = cfg.cityMinSize +
            (cfg.cityMaxSize - cfg.cityMinSize) * (cv / _cvMax) + 5;
        if ((cp - inverted).distance <= r) {
          if (_hovCityId != city.id) {
            setState(() { _hovCityId = city.id; _hovProvId = null; _hovPos = local; });
          }
          return;
        }
      }
    }

    // Province polygons
    if (cfg.mode != 'city') {
      for (final prov in _provs) {
        final pts = prov.poly.map((ll) => _Proj.toCanvas(ll[0], ll[1], sz)).toList();
        if (pts.length < 3) continue;
        final path = Path()..moveTo(pts.first.dx, pts.first.dy);
        for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
        path.close();
        if (path.contains(inverted)) {
          if (_hovProvId != prov.id) {
            setState(() { _hovProvId = prov.id; _hovCityId = null; _hovPos = local; });
          }
          return;
        }
      }
    }

    if (_hovProvId != null || _hovCityId != null) {
      setState(() { _hovProvId = null; _hovCityId = null; });
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final t = cfg.theme;

    return Column(children: [
      // Title
      if (cfg.title?.text != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Text(cfg.title!.text!,
            style: t.typography.titleStyle.copyWith(
                color: t.titleColor, fontWeight: FontWeight.w700)),
        ),

      // Subtitle / description row
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 2, 14, 0),
        child: Row(children: [
          Icon(Icons.location_on, size: 11, color: t.seriesColor(0)),
          const SizedBox(width: 3),
          Text('${kIDProvinces.length} Provinsi  ·  ${kIDCities.length} Kota/Kabupaten',
            style: t.typography.axisLabelStyle.copyWith(
                color: t.axisLabelColor, fontSize: 9.5)),
        ]),
      ),

      // Search + reset row
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Row(children: [
          Expanded(child: _searchField(t)),
          const SizedBox(width: 8),
          _iconBtn(Icons.my_location, 'Reset view', _resetView, t),
          const SizedBox(width: 4),
          _modeToggle(t),
        ]),
      ),

      // Island tabs
      SizedBox(height: 30,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 4),
          itemBuilder: (ctx, i) => _islandTab(_tabs[i], t),
        ),
      ),
      const SizedBox(height: 4),

      // Map canvas
      Expanded(child: LayoutBuilder(builder: (ctx, con) {
        final sz = Size(con.maxWidth, con.maxHeight);
        return GestureDetector(
          onScaleStart:  _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onHover:  (e) => _onHover(e.localPosition, sz),
            onExit:   (_) => setState(() { _hovProvId = null; _hovCityId = null; }),
            child: Stack(children: [
              RepaintBoundary(child: CustomPaint(
                size: Size.infinite,
                painter: _IDPainter(
                  provs:   _provs,
                  cities:  _cities,
                  pv: _pv, cv: _cv,
                  pvMax: _pvMax, cvMax: _cvMax,
                  mode:         cfg.mode,
                  colorScale:   cfg.colorScale,
                  showCities:   cfg.showCities,
                  showLabels:   cfg.showLabels,
                  showBlobs:    cfg.showHeatBlobs,
                  cityMinSize:  cfg.cityMinSize,
                  cityMaxSize:  cfg.cityMaxSize,
                  blobR:        cfg.heatRadius,
                  hovProvId:    _hovProvId,
                  hovCityId:    _hovCityId,
                  query:        _query,
                  progress:     _anim.value,
                  pan:          _pan,
                  scale:        _scale,
                  theme:        t,
                ),
              )),
              if (_hovProvId != null || _hovCityId != null)
                _tooltip(sz, t),
            ]),
          ),
        );
      })),

      // Legend
      _legend(t),

      // Footer
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          'Cubit/scroll → zoom  ·  Seret → geser  ·  Ketuk ikon → atur ulang tampilan',
          style: t.typography.axisLabelStyle.copyWith(
              color: t.axisLabelColor.withOpacity(0.4), fontSize: 8)),
      ),
    ]);
  }

  // ── Sub-widgets ──────────────────────────────────────────────────────────────

  Widget _searchField(ChartTheme t) => SizedBox(height: 34,
    child: TextField(
      controller: _searchCtrl,
      style: t.typography.axisLabelStyle.copyWith(color: t.titleColor, fontSize: 11),
      decoration: InputDecoration(
        hintText: 'Cari provinsi atau kota…',
        hintStyle: t.typography.axisLabelStyle.copyWith(
            color: t.axisLabelColor.withOpacity(0.45), fontSize: 11),
        prefixIcon: Icon(Icons.search, size: 16, color: t.axisLabelColor),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close, size: 14, color: t.axisLabelColor),
                onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); })
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: t.gridColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: t.gridColor.withOpacity(0.6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: t.seriesColor(0), width: 1.5)),
        filled: true, fillColor: t.backgroundColor,
      ),
    ),
  );

  Widget _modeToggle(ChartTheme t) {
    final modes = [('province', Icons.map), ('city', Icons.circle), ('combined', Icons.layers)];
    return Container(
      height: 34,
      decoration: BoxDecoration(
          border: Border.all(color: t.gridColor.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(8),
          color: t.backgroundColor),
      child: Row(mainAxisSize: MainAxisSize.min, children: modes.map((m) {
        final active = cfg.mode == m.$1;
        return GestureDetector(
          onTap: () {},   // mode switching could emit callback; left as-is for static config
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
                color: active ? t.seriesColor(0).withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(7)),
            child: Icon(m.$2, size: 16,
                color: active ? t.seriesColor(0) : t.axisLabelColor.withOpacity(0.5)),
          ),
        );
      }).toList()),
    );
  }

  Widget _islandTab(String label, ChartTheme t) {
    final active = label == _island;
    return GestureDetector(
      onTap: () => setState(() { _island = label; _resetView(); }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: active ? t.seriesColor(0) : t.gridColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: active ? t.seriesColor(0) : t.gridColor.withOpacity(0.3),
              width: 0.8),
        ),
        child: Text(label,
          style: t.typography.axisLabelStyle.copyWith(
            color: active ? Colors.white : t.axisLabelColor,
            fontSize: 9.5,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          )),
      ),
    );
  }

  Widget _iconBtn(IconData icon, String tip, VoidCallback fn, ChartTheme t) =>
      Tooltip(message: tip,
        child: InkWell(onTap: fn, borderRadius: BorderRadius.circular(8),
          child: Container(width: 34, height: 34,
            decoration: BoxDecoration(
                border: Border.all(color: t.gridColor.withOpacity(0.6)),
                borderRadius: BorderRadius.circular(8),
                color: t.backgroundColor),
            child: Icon(icon, size: 18, color: t.axisLabelColor))));

  // ── Tooltip overlay ──────────────────────────────────────────────────────────
  Widget _tooltip(Size sz, ChartTheme t) {
    String name = '', sub = '', valStr = '';

    if (_hovCityId != null) {
      try {
        final c = kIDCities.firstWhere((x) => x.id == _hovCityId);
        name = c.name;
        sub  = '${c.type[0].toUpperCase()}${c.type.substring(1)} · ${c.provId}';
        final v = _cv[c.id] ?? c.pop.toDouble();
        valStr = _fmtVal(v);
      } catch (_) {}
    } else if (_hovProvId != null) {
      try {
        final p = kIDProvinces.firstWhere((x) => x.id == _hovProvId);
        name = p.name;
        sub  = p.island;
        final v = _pv[p.id] ?? 0;
        valStr = _fmtVal(v);
      } catch (_) {}
    }

    final dx = (_hovPos.dx + 14).clamp(0.0, sz.width - 190.0);
    final dy = (_hovPos.dy - 72).clamp(0.0, sz.height - 90.0);

    return Positioned(left: dx, top: dy,
      child: IgnorePointer(child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(minWidth: 140, maxWidth: 195),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: t.tooltipBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 3)),
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, children: [
            Text(name, style: t.typography.tooltipStyle.copyWith(
                color: t.tooltipTextColor, fontWeight: FontWeight.w700, fontSize: 12.5)),
            const SizedBox(height: 2),
            Text(sub, style: t.typography.tooltipStyle.copyWith(
                color: t.tooltipTextColor.withOpacity(0.6), fontSize: 9.5)),
            const SizedBox(height: 6),
            Row(children: [
              Container(width: 8, height: 8,
                  decoration: BoxDecoration(color: t.seriesColor(0), shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(valStr, style: t.typography.tooltipStyle.copyWith(
                  color: t.tooltipTextColor, fontWeight: FontWeight.w600, fontSize: 11.5)),
            ]),
          ]),
        ),
      )));
  }

  // ── Legend bar ────────────────────────────────────────────────────────────────
  Widget _legend(ChartTheme t) {
    final cs = _CS.fromName(cfg.colorScale);
    final labels = ['Rendah', 'Sedang', 'Tinggi'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(height: 12,
            child: Row(children: List.generate(40, (i) => Expanded(
              child: Container(color: cs.at(i / 39))))),
          ),
        ),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels.asMap().entries.map((e) => Text(e.value,
              style: t.typography.axisLabelStyle.copyWith(
                  color: t.axisLabelColor, fontSize: 8.5))).toList()),
      ]),
    );
  }

  static String _fmtVal(double v) {
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(2)} M';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(2)} Jt';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(0)} Rb';
    return v.toStringAsFixed(v == v.truncate() ? 0 : 1);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _IDPainter extends ChartPainterBase {
  final List<IDProvince> provs;
  final List<IDCity>     cities;
  final Map<String, double> pv, cv;
  final double pvMax, cvMax;

  final String mode, colorScale;
  final bool showCities, showLabels, showBlobs;
  final double cityMinSize, cityMaxSize, blobR;

  final String? hovProvId, hovCityId, query;
  final double progress;
  final Offset pan;
  final double scale;

  const _IDPainter({
    required this.provs, required this.cities,
    required this.pv, required this.cv,
    required this.pvMax, required this.cvMax,
    required this.mode, required this.colorScale,
    required this.showCities, required this.showLabels, required this.showBlobs,
    required this.cityMinSize, required this.cityMaxSize, required this.blobR,
    required this.hovProvId, required this.hovCityId, required this.query,
    required this.progress, required this.pan, required this.scale,
    required ChartTheme theme,
  }) : super(theme: theme);

  @override
  bool shouldRepaintChart(covariant _IDPainter old) =>
      old.progress != progress || old.pan != pan || old.scale != scale ||
      old.hovProvId != hovProvId || old.hovCityId != hovCityId ||
      old.query != query;

  @override
  void paint(Canvas canvas, Size sz) {
    // ── Ocean background ──────────────────────────────────────────────────────
    canvas.drawRect(Offset.zero & sz,
        Paint()..color = const Color(0xFFD6EAF8));

    // ── Indonesia land shadow beneath provinces ───────────────────────────────
    _paintLandShadow(canvas, sz);

    canvas.save();
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(scale);

    final cs = _CS.fromName(colorScale);

    // ── Pass 1: province fills ────────────────────────────────────────────────
    if (mode != 'city') _paintProvFills(canvas, sz, cs);

    // ── Pass 2: heat blobs ────────────────────────────────────────────────────
    if (showBlobs && mode != 'province') _paintBlobs(canvas, sz, cs);

    // ── Pass 3: province borders ──────────────────────────────────────────────
    _paintProvBorders(canvas, sz);

    // ── Pass 4: province labels ───────────────────────────────────────────────
    if (showLabels && progress > 0.65) _paintProvLabels(canvas, sz);

    // ── Pass 5: city dots ─────────────────────────────────────────────────────
    if (showCities && mode != 'province') _paintCities(canvas, sz, cs);

    canvas.restore();

    // ── Compass rose ──────────────────────────────────────────────────────────
    _paintCompass(canvas, sz);
  }

  // ── Province fills ───────────────────────────────────────────────────────────
  void _paintProvFills(Canvas canvas, Size sz, _CS cs) {
    for (final p in provs) {
      if (p.poly.isEmpty) continue;
      final pts = p.poly.map((ll) => _Proj.toCanvas(ll[0], ll[1], sz)).toList();
      if (pts.length < 3) continue;

      final v     = pv[p.id] ?? 0;
      final t     = (v / pvMax * progress).clamp(0.0, 1.0);
      final isHov = p.id == hovProvId;
      final hit   = _matches(p.name, p.id);
      final dim   = (query?.isNotEmpty ?? false) && !hit && !isHov;

      Color fill = cs.at(t);
      if (isHov) fill = Color.lerp(fill, Colors.white, 0.28)!;
      if (hit)   fill = Color.lerp(fill, const Color(0xFFFFD600), 0.55)!;
      if (dim)   fill = fill.withOpacity(0.22);

      final path = _buildPath(pts);
      canvas.drawPath(path,
          Paint()..color = fill..style = PaintingStyle.fill..isAntiAlias = true);
    }
  }

  // ── Province borders ─────────────────────────────────────────────────────────
  void _paintProvBorders(Canvas canvas, Size sz) {
    for (final p in provs) {
      if (p.poly.isEmpty) continue;
      final pts = p.poly.map((ll) => _Proj.toCanvas(ll[0], ll[1], sz)).toList();
      if (pts.length < 3) continue;
      final isHov = p.id == hovProvId;
      final path  = _buildPath(pts);
      canvas.drawPath(path, Paint()
        ..color = isHov
            ? Colors.white
            : Colors.white.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHov ? 2.0 : 0.7
        ..isAntiAlias = true);
    }
  }

  // ── Province centroid labels ─────────────────────────────────────────────────
  void _paintProvLabels(Canvas canvas, Size sz) {
    for (final p in provs) {
      if (p.poly.isEmpty) continue;
      final pts = p.poly.map((ll) => _Proj.toCanvas(ll[0], ll[1], sz)).toList();

      // rough area estimate – skip tiny polygons at low zoom
      double area = 0;
      for (int i = 0; i < pts.length - 1; i++) {
        area += (pts[i].dx * pts[i + 1].dy - pts[i + 1].dx * pts[i].dy).abs();
      }
      if (area < 800 && scale < 1.8) continue;

      final center  = _Proj.toCanvas(p.cLon, p.cLat, sz);
      final isHov   = p.id == hovProvId;
      final matched = _matches(p.name, p.id);

      // Abbreviate long names at small scale
      String label = p.name;
      if (!isHov && label.length > 14 && scale < 2.0) {
        final words = label.split(' ');
        label = words.length > 2
            ? words.map((w) => w[0]).join('.')
            : words.last;
      }

      final tp = textPainterCache.get(label,
        theme.typography.dataLabelStyle.copyWith(
          color: isHov || matched ? Colors.white : Colors.white.withOpacity(0.92),
          fontSize: isHov ? 9.5 : 8.0,
          fontWeight: isHov ? FontWeight.w700 : FontWeight.w500,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 4),
            Shadow(color: Colors.black38, blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        align: TextAlign.center, maxWidth: 80,
      );

      tp.paint(canvas,
          Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
    }
  }

  // ── Gaussian blobs ───────────────────────────────────────────────────────────
  void _paintBlobs(Canvas canvas, Size sz, _CS cs) {
    canvas.saveLayer(Offset.zero & sz,
        Paint()..blendMode = BlendMode.screen);
    for (final city in cities) {
      final cp  = _Proj.toCanvas(city.lon, city.lat, sz);
      final v   = cv[city.id] ?? 0;
      final t   = (v / cvMax * progress).clamp(0.0, 1.0);
      final r   = blobR * (0.35 + 0.65 * t);
      final hot = cs.at(t);
      canvas.drawCircle(cp, r, Paint()
        ..shader = RadialGradient(colors: [
          hot.withOpacity(0.55 * t + 0.05),
          hot.withOpacity(0.22 * t),
          Colors.transparent,
        ], stops: const [0, 0.5, 1])
            .createShader(Rect.fromCircle(center: cp, radius: r))
        ..isAntiAlias = true);
    }
    canvas.restore();
  }

  // ── City dots ─────────────────────────────────────────────────────────────────
  void _paintCities(Canvas canvas, Size sz, _CS cs) {
    // ascending value → big cities on top
    final sorted = [...cities]..sort((a, b) =>
        (cv[a.id] ?? 0).compareTo(cv[b.id] ?? 0));

    for (final city in sorted) {
      final cp   = _Proj.toCanvas(city.lon, city.lat, sz);
      final v    = cv[city.id] ?? city.pop.toDouble();
      final t    = (v / cvMax).clamp(0.0, 1.0);
      final r    = (cityMinSize + (cityMaxSize - cityMinSize) * t) * progress;

      final isHov  = city.id == hovCityId;
      final isCap  = city.type == 'capital';
      final matched= _matches(city.name, city.id);
      final dim    = (query?.isNotEmpty ?? false) && !matched && !isHov;

      Color dc = mode == 'province' ? theme.seriesColor(0) : cs.at(t);
      if (isHov)   dc = Color.lerp(dc, Colors.white, 0.38)!;
      if (matched) dc = const Color(0xFFFFD600);
      if (dim)     dc = dc.withOpacity(0.18);

      // Glow
      if ((isHov || matched) && !dim) {
        canvas.drawCircle(cp, r + 6, Paint()
          ..color = dc.withOpacity(0.28)..style = PaintingStyle.fill..isAntiAlias = true);
      }

      // Fill
      canvas.drawCircle(cp, r, Paint()
        ..color = dc.withOpacity(dim ? 0.18 : 0.90)
        ..style = PaintingStyle.fill..isAntiAlias = true);

      // Border
      canvas.drawCircle(cp, r, Paint()
        ..color = (isCap ? Colors.white : Colors.white.withOpacity(0.4))
        ..style = PaintingStyle.stroke
        ..strokeWidth = isCap ? 1.6 : 0.7
        ..isAntiAlias = true);

      // Capital centre dot
      if (isCap && r > 4 && !dim) {
        canvas.drawCircle(cp, 1.8,
            Paint()..color = Colors.white..style = PaintingStyle.fill..isAntiAlias = true);
      }

      // Label: always for hover/match; at high zoom for large cities
      if (showLabels && (isHov || matched || (scale > 2.4 && r > 7))) {
        final tp = textPainterCache.get(city.name,
          theme.typography.dataLabelStyle.copyWith(
            color: Colors.black87,
            fontSize: isHov ? 9.5 : 8.5,
            fontWeight: isHov ? FontWeight.w700 : FontWeight.w500,
            shadows: const [
              Shadow(color: Colors.white, blurRadius: 5),
              Shadow(color: Colors.white, blurRadius: 3),
            ],
          ),
        );
        tp.paint(canvas, Offset(cp.dx + r + 2.5, cp.dy - tp.height / 2));
      }
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  bool _matches(String name, String id) {
    if (query == null || query!.isEmpty) return false;
    return name.toLowerCase().contains(query!) || id.toLowerCase().contains(query!);
  }

  Path _buildPath(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
    return path..close();
  }

  void _paintLandShadow(Canvas canvas, Size sz) {
    // Draw all province polygons as one big shadow layer beneath
    for (final p in kIDProvinces) {
      if (p.poly.isEmpty) continue;
      final pts = p.poly.map((ll) => _Proj.toCanvas(ll[0], ll[1], sz)).toList();
      if (pts.length < 3) continue;
      final path = _buildPath(pts);
      canvas.drawPath(path, Paint()
        ..color = const Color(0xFFB8CCE4).withOpacity(0.35)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..isAntiAlias = true);
    }
  }

  void _paintCompass(Canvas canvas, Size sz) {
    // Simple N arrow in bottom-right corner
    const r = 14.0;
    final cx = sz.width - 28.0, cy = sz.height - 28.0;
    final bg = Paint()..color = Colors.white.withOpacity(0.7)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r, bg);
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = Colors.grey.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 0.8);

    // North arrow
    final arrowN = Path()
      ..moveTo(cx, cy - r * 0.72)
      ..lineTo(cx - 4, cy + r * 0.1)
      ..lineTo(cx + 4, cy + r * 0.1)
      ..close();
    canvas.drawPath(arrowN, Paint()..color = const Color(0xFFE53935)..style = PaintingStyle.fill);

    // South arrow
    final arrowS = Path()
      ..moveTo(cx, cy + r * 0.72)
      ..lineTo(cx - 4, cy - r * 0.1)
      ..lineTo(cx + 4, cy - r * 0.1)
      ..close();
    canvas.drawPath(arrowS, Paint()..color = Colors.grey..style = PaintingStyle.fill);

    // "N" label
    final tp = textPainterCache.get('N',
      theme.typography.dataLabelStyle.copyWith(
          color: const Color(0xFFE53935), fontSize: 7.5, fontWeight: FontWeight.w900));
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - r - tp.height + 1));
  }
}

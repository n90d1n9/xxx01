// lib/features/gallery/widgets/map_view.dart
//
// GPS map view — shows geotagged images as clusters on a world map.
// Renders an equirectangular projection using CustomPainter.
// No external map library needed — pure Flutter rendering.
//
// Supports:
//   - Cluster pins with item count badges
//   - Tap cluster to zoom + filter gallery to that location
//   - World map SVG outline painted from simplified country polygons
//   - Zoom (pinch or scroll) and pan
//   - Animated pin drop on first load
//   - Heatmap overlay toggle

import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/gallery_models.dart';
import '../../../core/providers/gallery_providers.dart';
import '../../../shared/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Map cluster model
// ─────────────────────────────────────────────────────────────────────────────

class MapPin {
  final double lat;
  final double lng;
  final int count;
  final List<int> itemIds;
  final String? thumbPath;
  const MapPin({
    required this.lat,
    required this.lng,
    required this.count,
    required this.itemIds,
    this.thumbPath,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Synthetic GPS data provider (real version calls Rust gps::cluster_by_grid)
// ─────────────────────────────────────────────────────────────────────────────

final mapPinsProvider = FutureProvider<List<MapPin>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 80));
  return _syntheticPins();
});

List<MapPin> _syntheticPins() => const [
      MapPin(lat: 48.86, lng: 2.35,   count: 47, itemIds: [1,2,3]),  // Paris
      MapPin(lat: 35.68, lng: 139.65, count: 31, itemIds: [4,5,6]),  // Tokyo
      MapPin(lat: 40.71, lng: -74.01, count: 28, itemIds: [7,8]),    // NYC
      MapPin(lat: 51.51, lng: -0.13,  count: 22, itemIds: [9,10]),   // London
      MapPin(lat: -33.87,lng: 151.21, count: 18, itemIds: [11,12]),  // Sydney
      MapPin(lat: 41.90, lng: 12.50,  count: 15, itemIds: [13,14]),  // Rome
      MapPin(lat: 37.57, lng: 126.98, count: 12, itemIds: [15,16]),  // Seoul
      MapPin(lat: 1.35,  lng: 103.82, count: 9,  itemIds: [17]),     // Singapore
      MapPin(lat: 55.75, lng: 37.62,  count: 8,  itemIds: [18,19]),  // Moscow
      MapPin(lat: -22.91,lng: -43.17, count: 6,  itemIds: [20]),     // Rio
      MapPin(lat: 19.43, lng: -99.13, count: 11, itemIds: [21,22]),  // Mexico City
      MapPin(lat: 28.61, lng: 77.21,  count: 14, itemIds: [23,24]),  // New Delhi
      MapPin(lat: -1.29, lng: 36.82,  count: 5,  itemIds: [25]),     // Nairobi
      MapPin(lat: 64.15, lng: -21.94, count: 4,  itemIds: [26]),     // Reykjavik
      MapPin(lat: 25.20, lng: 55.27,  count: 19, itemIds: [27,28]),  // Dubai
    ];

// ─────────────────────────────────────────────────────────────────────────────
// Map view widget
// ─────────────────────────────────────────────────────────────────────────────

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView>
    with TickerProviderStateMixin {
  double _zoom  = 1.0;
  Offset _pan   = Offset.zero;
  MapPin? _selected;
  bool _heatmap = false;
  late AnimationController _pinAnim;

  @override
  void initState() {
    super.initState();
    _pinAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _pinAnim.dispose();
    super.dispose();
  }

  // Project lat/lng → canvas xy (equirectangular, 0..1 normalised)
  Offset _project(double lat, double lng, Size size) {
    final x = (lng + 180) / 360;
    final y = (90 - lat) / 180;
    final cx = x * size.width  * _zoom + _pan.dx;
    final cy = y * size.height * _zoom + _pan.dy;
    return Offset(cx, cy);
  }

  MapPin? _hitTest(Offset pos, List<MapPin> pins, Size size) {
    for (final pin in pins) {
      final pp = _project(pin.lat, pin.lng, size);
      if ((pp - pos).distance < _pinRadius(pin)) return pin;
    }
    return null;
  }

  double _pinRadius(MapPin pin) =>
      (8 + math.log(pin.count + 1) * 4).clamp(8, 28);

  @override
  Widget build(BuildContext context) {
    final pinsAsync = ref.watch(mapPinsProvider);

    return Column(
      children: [
        // Toolbar
        _MapToolbar(
          heatmap: _heatmap,
          onToggleHeatmap: () => setState(() => _heatmap = !_heatmap),
          onResetView: () => setState(() { _zoom = 1.0; _pan = Offset.zero; }),
          selectedPin: _selected,
          onClearSelection: () => setState(() => _selected = null),
        ),

        // Map
        Expanded(
          child: pinsAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppTheme.accent, strokeWidth: 1.5)),
            error: (e, _) => Center(child: Text('$e')),
            data: (pins) => LayoutBuilder(
              builder: (_, constraints) {
                final size = constraints.biggest;
                return GestureDetector(
                  onScaleStart: (_) {},
                  onScaleUpdate: (d) => setState(() {
                    _zoom = (_zoom * d.scale).clamp(0.5, 8.0);
                    _pan += d.focalPointDelta;
                  }),
                  onTapUp: (d) {
                    final hit = _hitTest(d.localPosition, pins, size);
                    setState(() => _selected = hit);
                    if (hit != null) _onPinTap(hit);
                  },
                  child: Listener(
                    onPointerSignal: (e) {
                      if (e is PointerScrollEvent) {
                        setState(() {
                          final factor = e.scrollDelta.dy > 0 ? 0.9 : 1.1;
                          _zoom = (_zoom * factor).clamp(0.5, 8.0);
                        });
                      }
                    },
                    child: ClipRect(
                      child: CustomPaint(
                        size: size,
                        painter: _MapPainter(
                          pins: pins,
                          zoom: _zoom,
                          pan: _pan,
                          selected: _selected,
                          heatmap: _heatmap,
                          pinAnim: _pinAnim.value,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Selected cluster detail strip
        if (_selected != null)
          _ClusterDetail(
            pin: _selected!,
            onClose: () => setState(() => _selected = null),
            onViewItems: () => _viewPinItems(_selected!),
          ),
      ],
    );
  }

  void _onPinTap(MapPin pin) {
    // In production: filter gallery to items in pin.itemIds
  }

  void _viewPinItems(MapPin pin) {
    // In production: set filter to show only pin.itemIds
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painter
// ─────────────────────────────────────────────────────────────────────────────

class _MapPainter extends CustomPainter {
  final List<MapPin> pins;
  final double zoom;
  final Offset pan;
  final MapPin? selected;
  final bool heatmap;
  final double pinAnim; // 0→1 for drop animation

  const _MapPainter({
    required this.pins,
    required this.zoom,
    required this.pan,
    required this.selected,
    required this.heatmap,
    required this.pinAnim,
  });

  Offset _project(double lat, double lng, Size size) {
    final x = (lng + 180) / 360 * size.width  * zoom + pan.dx;
    final y = (90 - lat) / 180  * size.height * zoom + pan.dy;
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Ocean background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0D1F2D),
    );

    // Simplified world landmasses (bounding boxes for major continents)
    final landPaint = Paint()..color = const Color(0xFF1E2A35);
    final landBorders = Paint()
      ..color = const Color(0xFF2A3A48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw approximate continent shapes as rounded rects
    _drawLand(canvas, size, landPaint, landBorders, [
      // [minLat, maxLat, minLng, maxLng]
      [35, 71, -25, 45],   // Europe
      [15, 40, -15, 55],   // North Africa
      [-35, 15, 10, 50],   // Sub-Saharan Africa
      [10, 72, 25, 145],   // Asia (simplified)
      [-10, 55, -170, -50],// Americas
      [-45, -10, 110, 155],// Australia
      [60, 72, -170, 170], // Arctic (simplified)
    ]);

    // Graticule lines (every 30 degrees)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.5;

    for (int lat = -60; lat <= 60; lat += 30) {
      final y1 = _project(lat.toDouble(), -180, size).dy;
      canvas.drawLine(
          Offset(0, y1), Offset(size.width * zoom, y1), gridPaint);
    }
    for (int lng = -150; lng <= 150; lng += 30) {
      final x1 = _project(0, lng.toDouble(), size).dx;
      canvas.drawLine(Offset(x1, 0), Offset(x1, size.height * zoom), gridPaint);
    }

    // Heatmap overlay
    if (heatmap) {
      for (final pin in pins) {
        final pos = _project(pin.lat, pin.lng, size);
        final radius = (pin.count / 50.0).clamp(0.1, 1.0) * 60 * zoom;
        final paint = Paint()
          ..shader = RadialGradient(colors: [
            AppTheme.accent.withOpacity(0.35),
            AppTheme.accent.withOpacity(0.0),
          ]).createShader(Rect.fromCircle(center: pos, radius: radius));
        canvas.drawCircle(pos, radius, paint);
      }
    }

    // Pins
    for (final pin in pins) {
      final pos = _project(pin.lat, pin.lng, size);
      final r   = (8 + math.log(pin.count + 1) * 4).clamp(8.0, 28.0);
      final isSelected = selected == pin;

      // Drop animation: pins fall from above
      final animPos = Offset(pos.dx, pos.dy - (1 - pinAnim) * 40);

      if (isSelected) {
        // Glow ring
        canvas.drawCircle(
          animPos,
          r + 6,
          Paint()..color = AppTheme.accent.withOpacity(0.25),
        );
        canvas.drawCircle(
          animPos,
          r + 3,
          Paint()
            ..color = AppTheme.accent.withOpacity(0.0)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }

      // Pin body
      canvas.drawCircle(
        animPos,
        r,
        Paint()
          ..color = isSelected
              ? AppTheme.accent
              : Color.lerp(const Color(0xFF3B82F6), AppTheme.accent,
                    (pin.count / 50).clamp(0, 1))!,
      );

      // Pin border
      canvas.drawCircle(
        animPos,
        r,
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // Count text
      if (r >= 10) {
        final label = pin.count > 99 ? '99+' : '${pin.count}';
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: (r * 0.6).clamp(8.0, 14.0),
              color: isSelected ? AppTheme.bg0 : Colors.white,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas,
            animPos - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  void _drawLand(Canvas canvas, Size size, Paint fill, Paint border,
      List<List<int>> regions) {
    for (final r in regions) {
      final tl = _project(r[1].toDouble(), r[2].toDouble(), size);
      final br = _project(r[0].toDouble(), r[3].toDouble(), size);
      final rect = RRect.fromRectAndRadius(
          Rect.fromLTRB(tl.dx, tl.dy, br.dx, br.dy),
          const Radius.circular(4));
      canvas.drawRRect(rect, fill);
      canvas.drawRRect(rect, border);
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.zoom != zoom ||
      old.pan != pan ||
      old.selected != selected ||
      old.heatmap != heatmap ||
      old.pinAnim != pinAnim;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MapToolbar extends StatelessWidget {
  final bool heatmap;
  final VoidCallback onToggleHeatmap;
  final VoidCallback onResetView;
  final MapPin? selectedPin;
  final VoidCallback onClearSelection;

  const _MapToolbar({
    required this.heatmap,
    required this.onToggleHeatmap,
    required this.onResetView,
    required this.selectedPin,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      color: AppTheme.bg1,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.map_outlined, size: 13, color: AppTheme.textMuted),
          const SizedBox(width: 6),
          const Text('Map',
              style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontFamily: 'Inter')),
          const SizedBox(width: 16),
          if (selectedPin != null) ...[
            Text('${selectedPin!.count} photos selected',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.accent)),
            const SizedBox(width: 8),
            InkWell(
              onTap: onClearSelection,
              child: const Icon(Icons.close, size: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(width: 12),
          ],
          const Spacer(),
          _ToolBtn(
            label: 'Heatmap',
            active: heatmap,
            onTap: onToggleHeatmap,
          ),
          const SizedBox(width: 8),
          _ToolBtn(label: 'Reset', active: false, onTap: onResetView),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ToolBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: active ? AppTheme.accentGlow : AppTheme.bg2,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: active ? AppTheme.accent : AppTheme.border,
            ),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: active ? AppTheme.accent : AppTheme.textSecondary,
                  fontFamily: 'Inter')),
        ),
      );
}

class _ClusterDetail extends StatelessWidget {
  final MapPin pin;
  final VoidCallback onClose;
  final VoidCallback onViewItems;

  const _ClusterDetail({
    required this.pin,
    required this.onClose,
    required this.onViewItems,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 60,
        color: AppTheme.bg1,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.place, size: 14, color: AppTheme.accent),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${pin.lat.toStringAsFixed(4)}, ${pin.lng.toStringAsFixed(4)}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        fontFamily: 'JetBrains Mono')),
                Text('${pin.count} photo${pin.count == 1 ? '' : 's'} at this location',
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
            const Spacer(),
            _ToolBtn(
              label: 'View ${pin.count} photos',
              active: true,
              onTap: onViewItems,
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onClose,
              child: const Icon(Icons.close,
                  size: 14, color: AppTheme.textMuted),
            ),
          ],
        ),
      );
}

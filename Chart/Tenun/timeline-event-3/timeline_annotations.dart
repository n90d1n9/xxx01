// TimelineAnnotations — user-created annotation layer.
//
// Supports three annotation types:
//   [YearPin]        : sticky-note pin at a specific year (icon + label).
//   [YearRangeHighlight] : coloured band over a year range with a label.
//   [EventConnection]   : arrow line connecting two event IDs.
//
// Architecture:
//   - [TimelineAnnotationStore] : in-memory collection; serialises to/from JSON.
//   - [TimelineAnnotationPainter] : draws all annotations under the event nodes.
//   - [TimelineAnnotationLayer]  : StatefulWidget compositing store + painter.
//   - [TimelineAnnotationToolbar]: compact toolbar for add/edit/delete actions.
//
// Persistence:
//   Call [TimelineAnnotationStore.toJson()] and save the string.
//   Restore with [TimelineAnnotationStore.fromJson(jsonString)].

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../chart_painter_base.dart';
import '../chart_theme.dart';
import 'timeline_coordinate_system.dart';
import 'timeline_event.dart';

// ---------------------------------------------------------------------------
// Annotation models
// ---------------------------------------------------------------------------

enum AnnotationType { pin, range, connection }

/// A sticky-note pin at a specific year.
class YearPin {
  final String id;
  final double year;
  final String label;
  final Color color;
  final IconData icon;

  const YearPin({
    required this.id,
    required this.year,
    required this.label,
    this.color = const Color(0xFFFFB300),
    this.icon = Icons.push_pin,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'year': year,
    'label': label,
    'color': color.value,
    'icon': icon.codePoint,
  };

  factory YearPin.fromJson(Map<String, dynamic> j) => YearPin(
    id: j['id'],
    year: (j['year'] as num).toDouble(),
    label: j['label'],
    color: Color(j['color'] as int),
    icon: IconData(j['icon'] as int, fontFamily: 'MaterialIcons'),
  );
}

/// A coloured background band over a year range.
class YearRangeHighlight {
  final String id;
  final double startYear;
  final double endYear;
  final String label;
  final Color color;

  const YearRangeHighlight({
    required this.id,
    required this.startYear,
    required this.endYear,
    required this.label,
    this.color = const Color(0x22FF9800),
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'startYear': startYear,
    'endYear': endYear,
    'label': label,
    'color': color.value,
  };

  factory YearRangeHighlight.fromJson(Map<String, dynamic> j) => YearRangeHighlight(
    id: j['id'],
    startYear: (j['startYear'] as num).toDouble(),
    endYear: (j['endYear'] as num).toDouble(),
    label: j['label'],
    color: Color(j['color'] as int),
  );
}

/// A drawn arrow connecting two year positions.
class EventConnection {
  final String id;
  final double fromYear;
  final double toYear;
  final String label;
  final Color color;

  const EventConnection({
    required this.id,
    required this.fromYear,
    required this.toYear,
    required this.label,
    this.color = const Color(0xFF9C27B0),
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromYear': fromYear,
    'toYear': toYear,
    'label': label,
    'color': color.value,
  };

  factory EventConnection.fromJson(Map<String, dynamic> j) => EventConnection(
    id: j['id'],
    fromYear: (j['fromYear'] as num).toDouble(),
    toYear: (j['toYear'] as num).toDouble(),
    label: j['label'],
    color: Color(j['color'] as int),
  );
}

// ---------------------------------------------------------------------------
// TimelineAnnotationStore
// ---------------------------------------------------------------------------

class TimelineAnnotationStore extends ChangeNotifier {
  final List<YearPin> _pins = [];
  final List<YearRangeHighlight> _ranges = [];
  final List<EventConnection> _connections = [];

  List<YearPin> get pins => List.unmodifiable(_pins);
  List<YearRangeHighlight> get ranges => List.unmodifiable(_ranges);
  List<EventConnection> get connections => List.unmodifiable(_connections);

  bool get isEmpty => _pins.isEmpty && _ranges.isEmpty && _connections.isEmpty;

  // ── Add ─────────────────────────────────────────────────────────────────

  void addPin(YearPin pin) {
    _pins.add(pin);
    notifyListeners();
  }

  void addRange(YearRangeHighlight range) {
    _ranges.add(range);
    notifyListeners();
  }

  void addConnection(EventConnection conn) {
    _connections.add(conn);
    notifyListeners();
  }

  // ── Remove ──────────────────────────────────────────────────────────────

  void removePin(String id) {
    _pins.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void removeRange(String id) {
    _ranges.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void removeConnection(String id) {
    _connections.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void clearAll() {
    _pins.clear();
    _ranges.clear();
    _connections.clear();
    notifyListeners();
  }

  // ── Persistence ─────────────────────────────────────────────────────────

  String toJson() => jsonEncode({
    'pins': _pins.map((p) => p.toJson()).toList(),
    'ranges': _ranges.map((r) => r.toJson()).toList(),
    'connections': _connections.map((c) => c.toJson()).toList(),
  });

  factory TimelineAnnotationStore.fromJson(String json) {
    final store = TimelineAnnotationStore();
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      for (final j in (data['pins'] as List? ?? [])) {
        store._pins.add(YearPin.fromJson(j));
      }
      for (final j in (data['ranges'] as List? ?? [])) {
        store._ranges.add(YearRangeHighlight.fromJson(j));
      }
      for (final j in (data['connections'] as List? ?? [])) {
        store._connections.add(EventConnection.fromJson(j));
      }
    } catch (_) {}
    return store;
  }

  // ── Quick factory helpers ────────────────────────────────────────────────

  static String _uid() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  YearPin createPin({
    required double year,
    required String label,
    Color color = const Color(0xFFFFB300),
  }) {
    return YearPin(id: _uid(), year: year, label: label, color: color);
  }

  YearRangeHighlight createRange({
    required double startYear,
    required double endYear,
    required String label,
    Color color = const Color(0x22FF9800),
  }) {
    return YearRangeHighlight(
        id: _uid(), startYear: startYear, endYear: endYear, label: label, color: color);
  }

  EventConnection createConnection({
    required double fromYear,
    required double toYear,
    required String label,
    Color color = const Color(0xFF9C27B0),
  }) {
    return EventConnection(
        id: _uid(), fromYear: fromYear, toYear: toYear, label: label, color: color);
  }
}

// ---------------------------------------------------------------------------
// TimelineAnnotationPainter
// ---------------------------------------------------------------------------

class TimelineAnnotationPainter extends ChartPainterBase {
  final TimelineAnnotationStore store;
  final double axisY;
  final TimelineCoordinateSystem cs;
  final String? hoveredId;

  const TimelineAnnotationPainter({
    required this.store,
    required this.axisY,
    required this.cs,
    this.hoveredId,
    super.theme,
    super.repaint,
  });

  @override
  bool shouldRepaintChart(covariant TimelineAnnotationPainter old) =>
      !identical(old.store, store) ||
      old.cs.viewStartYear != cs.viewStartYear ||
      old.hoveredId != hoveredId;

  @override
  void paint(Canvas canvas, Size size) {
    _drawRanges(canvas, size);
    _drawConnections(canvas, size);
    _drawPins(canvas, size);
  }

  // ── Range highlights ────────────────────────────────────────────────────

  void _drawRanges(Canvas canvas, Size size) {
    for (final r in store.ranges) {
      final x1 = cs.yearToX(r.startYear).clamp(cs.left, cs.right);
      final x2 = cs.yearToX(r.endYear).clamp(cs.left, cs.right);
      if (x2 <= x1) continue;

      // Fill band
      canvas.drawRect(
        Rect.fromLTRB(x1, 0, x2, size.height),
        fillPaint(r.color),
      );

      // Border lines
      final border = strokePaint(r.color.withValues(alpha: 0.6), 1.0);
      canvas.drawLine(Offset(x1, 0), Offset(x1, size.height), border);
      canvas.drawLine(Offset(x2, 0), Offset(x2, size.height), border);

      // Label
      final labelStyle = theme.typography.axisLabelStyle.copyWith(
        color: r.color.withValues(alpha: 0.85),
        fontSize: 10,
        fontWeight: FontWeight.bold,
      );
      final tp = textPainterCache.get(r.label, labelStyle, maxWidth: x2 - x1 - 8);
      if (tp.width < x2 - x1 - 8) {
        tp.paint(canvas, Offset((x1 + x2) / 2 - tp.width / 2, 6));
      }
    }
  }

  // ── Connections ─────────────────────────────────────────────────────────

  void _drawConnections(Canvas canvas, Size size) {
    for (final conn in store.connections) {
      final x1 = cs.yearToX(conn.fromYear);
      final x2 = cs.yearToX(conn.toYear);
      if (x1 < cs.left - 20 && x2 < cs.left - 20) continue;
      if (x1 > cs.right + 20 && x2 > cs.right + 20) continue;

      final color = conn.color;
      final arcY = axisY - 40 - (x2 - x1).abs() * 0.08;

      final path = Path()
        ..moveTo(x1, axisY)
        ..quadraticBezierTo((x1 + x2) / 2, arcY.clamp(20, axisY - 20), x2, axisY);

      canvas.drawPath(path, strokePaint(color.withValues(alpha: 0.7), 2.0));

      // Arrow head at x2
      final arrowDir = x2 > x1 ? 1.0 : -1.0;
      _drawArrowHead(canvas, Offset(x2, axisY), arrowDir, color);

      // Label at arc midpoint
      final midX = (x1 + x2) / 2;
      final midY = (axisY + arcY) / 2;
      if (cs.isXVisible(midX)) {
        final labelStyle = theme.typography.axisLabelStyle.copyWith(
          color: color,
          fontSize: 9,
        );
        final tp = textPainterCache.get(conn.label, labelStyle, maxWidth: 120);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(midX - tp.width / 2 - 4, midY - tp.height / 2 - 3, tp.width + 8, tp.height + 6),
            const Radius.circular(4),
          ),
          fillPaint(theme.isDark ? const Color(0xFF1E1E2E) : Colors.white),
        );
        tp.paint(canvas, Offset(midX - tp.width / 2, midY - tp.height / 2));
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double dir, Color color) {
    const size = 8.0;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - dir * size, tip.dy - size / 2)
      ..lineTo(tip.dx - dir * size, tip.dy + size / 2)
      ..close();
    canvas.drawPath(path, fillPaint(color.withValues(alpha: 0.8)));
  }

  // ── Pins ────────────────────────────────────────────────────────────────

  void _drawPins(Canvas canvas, Size size) {
    for (final pin in store.pins) {
      final x = cs.yearToX(pin.year);
      if (x < cs.left - 20 || x > cs.right + 20) continue;

      final isHovered = pin.id == hoveredId;
      final color = pin.color;
      final pinY = axisY - (isHovered ? 56 : 48);

      // Stem
      canvas.drawLine(
        Offset(x, axisY),
        Offset(x, pinY + 18),
        strokePaint(color.withValues(alpha: 0.6), 1.5),
      );

      // Pin head (circle with icon)
      final r = isHovered ? 14.0 : 12.0;
      if (isHovered) {
        // Glow
        canvas.drawCircle(Offset(x, pinY), r + 4,
            fillPaint(color.withValues(alpha: 0.2)));
      }
      canvas.drawCircle(Offset(x, pinY), r, fillPaint(color));
      canvas.drawCircle(Offset(x, pinY), r, strokePaint(Colors.white.withValues(alpha: 0.6), 1.5));

      // Label box
      final labelStyle = theme.typography.axisLabelStyle.copyWith(
        color: theme.isDark ? Colors.white : Colors.black87,
        fontSize: 10,
      );
      final tp = textPainterCache.get(pin.label, labelStyle, maxWidth: 120);
      final boxW = tp.width + 10;
      final boxH = tp.height + 8;
      final boxX = (x - boxW / 2).clamp(cs.left, cs.right - boxW);
      final boxY = pinY - r - boxH - 4;

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(boxX, boxY, boxW, boxH), const Radius.circular(4)),
        fillPaint(theme.isDark ? const Color(0xFF252540) : Colors.white),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(boxX, boxY, boxW, boxH), const Radius.circular(4)),
        strokePaint(color, 1.0),
      );
      tp.paint(canvas, Offset(boxX + 5, boxY + 4));
    }
  }
}

// ---------------------------------------------------------------------------
// TimelineAnnotationLayer — compositing widget
// ---------------------------------------------------------------------------

/// Transparent overlay that draws annotations over the chart canvas.
///
/// ```dart
/// Stack(
///   children: [
///     TimelineChartV2(config: config),
///     Positioned.fill(
///       child: TimelineAnnotationLayer(
///         store: annotationStore,
///         axisYFraction: 0.5,
///         viewState: scrollCtrl.value,
///       ),
///     ),
///   ],
/// )
/// ```
class TimelineAnnotationLayer extends StatefulWidget {
  final TimelineAnnotationStore store;
  final double axisYFraction;
  final TimelineViewState viewState;
  final ChartTheme theme;

  const TimelineAnnotationLayer({
    super.key,
    required this.store,
    required this.axisYFraction,
    required this.viewState,
    this.theme = ChartTheme.light,
  });

  @override
  State<TimelineAnnotationLayer> createState() => _TimelineAnnotationLayerState();
}

class _TimelineAnnotationLayerState extends State<TimelineAnnotationLayer> {
  String? _hoveredPinId;
  late final _repaint = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreChange);
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreChange);
    _repaint.dispose();
    super.dispose();
  }

  void _onStoreChange() {
    _repaint.value++;
  }

  String? _hitTestPin(Offset local, double width, double height) {
    const hitRadius = 18.0;
    final cs = TimelineCoordinateSystem.fromState(
      canvasWidth: width,
      state: TimelineState(
        scale: widget.viewState.scale,
        offsetYears: widget.viewState.offsetYears,
        zoom: widget.viewState.zoom,
      ),
    );
    final axisY = height * widget.axisYFraction;
    for (final pin in widget.store.pins) {
      final x = cs.yearToX(pin.year);
      final y = axisY - 48;
      if ((local - Offset(x, y)).distance < hitRadius) return pin.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        final cs = TimelineCoordinateSystem.fromState(
          canvasWidth: w,
          state: TimelineState(
            scale: widget.viewState.scale,
            offsetYears: widget.viewState.offsetYears,
            zoom: widget.viewState.zoom,
          ),
        );

        return MouseRegion(
          onHover: (e) {
            final hit = _hitTestPin(e.localPosition, w, h);
            if (hit != _hoveredPinId) setState(() => _hoveredPinId = hit);
          },
          onExit: (_) {
            if (_hoveredPinId != null) setState(() => _hoveredPinId = null);
          },
          child: RepaintBoundary(
            child: CustomPaint(
              painter: TimelineAnnotationPainter(
                store: widget.store,
                axisY: h * widget.axisYFraction,
                cs: cs,
                hoveredId: _hoveredPinId,
                theme: widget.theme,
                repaint: _repaint,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// TimelineAnnotationToolbar
// ---------------------------------------------------------------------------

/// Compact toolbar for adding annotations.
///
/// Floats over the chart — typically placed in a [Stack] overlay.
class TimelineAnnotationToolbar extends StatelessWidget {
  final TimelineAnnotationStore store;
  final double Function() getCurrentYear;
  final bool isDark;
  final VoidCallback? onChanged;

  const TimelineAnnotationToolbar({
    super.key,
    required this.store,
    required this.getCurrentYear,
    this.isDark = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF252540) : Colors.white;
    final iconColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToolBtn(
            icon: Icons.push_pin_outlined,
            tooltip: 'Add pin at current year',
            color: const Color(0xFFFFB300),
            onTap: () => _addPinDialog(context),
          ),
          _ToolBtn(
            icon: Icons.horizontal_rule_outlined,
            tooltip: 'Add range highlight',
            color: const Color(0xFFFF9800),
            onTap: () => _addRangeDialog(context),
          ),
          _ToolBtn(
            icon: Icons.arrow_forward_outlined,
            tooltip: 'Add connection',
            color: const Color(0xFF9C27B0),
            onTap: () => _addConnectionDialog(context),
          ),
          if (!store.isEmpty)
            _ToolBtn(
              icon: Icons.delete_outline,
              tooltip: 'Clear all annotations',
              color: Colors.redAccent,
              onTap: () {
                store.clearAll();
                onChanged?.call();
              },
            ),
        ],
      ),
    );
  }

  void _addPinDialog(BuildContext context) {
    final labelCtrl = TextEditingController();
    final year = getCurrentYear();
    showDialog(
      context: context,
      builder: (_) => _LabelDialog(
        title: 'Add Pin',
        hint: 'Pin label',
        subtitle: 'at year ${year.round()}',
        controller: labelCtrl,
        onConfirm: () {
          if (labelCtrl.text.trim().isEmpty) return;
          store.addPin(store.createPin(year: year, label: labelCtrl.text.trim()));
          onChanged?.call();
        },
      ),
    );
  }

  void _addRangeDialog(BuildContext context) {
    final labelCtrl = TextEditingController();
    final startCtrl = TextEditingController(text: (getCurrentYear() - 50).round().toString());
    final endCtrl = TextEditingController(text: (getCurrentYear() + 50).round().toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Range Highlight'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Label')),
            Row(
              children: [
                Expanded(child: TextField(controller: startCtrl,
                    decoration: const InputDecoration(labelText: 'Start year'),
                    keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: endCtrl,
                    decoration: const InputDecoration(labelText: 'End year'),
                    keyboardType: TextInputType.number)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final s = double.tryParse(startCtrl.text) ?? 0;
              final e = double.tryParse(endCtrl.text) ?? 0;
              if (s >= e || labelCtrl.text.trim().isEmpty) return;
              store.addRange(store.createRange(startYear: s, endYear: e, label: labelCtrl.text.trim()));
              onChanged?.call();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addConnectionDialog(BuildContext context) {
    final labelCtrl = TextEditingController();
    final fromCtrl = TextEditingController(text: (getCurrentYear() - 100).round().toString());
    final toCtrl = TextEditingController(text: getCurrentYear().round().toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Connection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Label')),
            Row(
              children: [
                Expanded(child: TextField(controller: fromCtrl,
                    decoration: const InputDecoration(labelText: 'From year'),
                    keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: toCtrl,
                    decoration: const InputDecoration(labelText: 'To year'),
                    keyboardType: TextInputType.number)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final f = double.tryParse(fromCtrl.text) ?? 0;
              final t = double.tryParse(toCtrl.text) ?? 0;
              if (labelCtrl.text.trim().isEmpty) return;
              store.addConnection(store.createConnection(fromYear: f, toYear: t, label: labelCtrl.text.trim()));
              onChanged?.call();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _ToolBtn({required this.icon, required this.tooltip, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _LabelDialog extends StatelessWidget {
  final String title;
  final String hint;
  final String subtitle;
  final TextEditingController controller;
  final VoidCallback onConfirm;

  const _LabelDialog({
    required this.title,
    required this.hint,
    required this.subtitle,
    required this.controller,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: hint),
            onSubmitted: (_) { onConfirm(); Navigator.pop(context); },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () { onConfirm(); Navigator.pop(context); },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Extension: add isXVisible to TimelineCoordinateSystem
// ---------------------------------------------------------------------------

extension _CSExt on TimelineCoordinateSystem {
  bool isXVisible(double x) => x >= left && x <= right;
}

// ---------------------------------------------------------------------------
// TimelineViewState shim (re-export from physics)
// ---------------------------------------------------------------------------

// TimelineViewState is defined in timeline_physics.dart.
// This file imports it transitively via timeline_coordinate_system.dart.
// If needed, add: import 'timeline_physics.dart';

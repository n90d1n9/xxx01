// TimelineGestureLayer — platform-adaptive input handling.
//
// Replaces the basic GestureDetector in TimelineChartV2 with a full
// platform-aware input stack:
//
//  Desktop / Web
//   • Mouse scroll wheel  → zoom in/out at pointer position
//   • Trackpad two-finger → smooth pan (PointerScrollEvent with small delta)
//   • Right-click         → context menu (jump to, bookmark, copy year)
//   • Hover               → crosshair + tooltip after 600ms dwell
//   • Middle-click drag   → pan (alternative to left-drag)
//
//  Mobile / Touch
//   • Single-finger pan   → scroll timeline
//   • Pinch               → zoom
//   • Double-tap          → zoom in 2×
//   • Long-press          → tooltip / context popup
//
// All input is normalised into the same [TimelineGestureCallbacks] interface
// so the chart widget never branches on platform.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'timeline_event.dart';
import 'timeline_physics.dart';

// ---------------------------------------------------------------------------
// TimelineGestureCallbacks
// ---------------------------------------------------------------------------

class TimelineGestureCallbacks {
  final void Function(double screenX) onPanStart;
  final void Function(double screenX, double dtSec) onPanUpdate;
  final void Function() onPanEnd;

  final void Function(double focalYear) onPinchStart;
  final void Function(double scaleFactor) onPinchUpdate;
  final void Function() onPinchEnd;

  final void Function(double focalYear, double targetZoom) onZoomTo;
  final void Function(double screenX)? onCrosshairMove;
  final void Function()? onCrosshairEnd;

  final void Function(Offset localPos)? onTap;
  final void Function(Offset localPos)? onLongPress;
  final void Function(Offset localPos)? onRightClick;

  const TimelineGestureCallbacks({
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onPinchStart,
    required this.onPinchUpdate,
    required this.onPinchEnd,
    required this.onZoomTo,
    this.onCrosshairMove,
    this.onCrosshairEnd,
    this.onTap,
    this.onLongPress,
    this.onRightClick,
  });
}

// ---------------------------------------------------------------------------
// TimelineGestureLayer
// ---------------------------------------------------------------------------

class TimelineGestureLayer extends StatefulWidget {
  final Widget child;
  final TimelineGestureCallbacks callbacks;

  /// Converts a canvas X position to a year (used to compute focal year).
  final double Function(double screenX) screenXToYear;

  /// Current zoom level (used for scroll wheel sensitivity).
  final double currentZoom;

  const TimelineGestureLayer({
    super.key,
    required this.child,
    required this.callbacks,
    required this.screenXToYear,
    required this.currentZoom,
  });

  @override
  State<TimelineGestureLayer> createState() => _TimelineGestureLayerState();
}

class _TimelineGestureLayerState extends State<TimelineGestureLayer> {
  // ── Gesture state ──────────────────────────────────────────────────────
  bool _isPanning = false;
  bool _isPinching = false;
  double _lastPanX = 0;
  DateTime _lastPanTime = DateTime.now();

  // Scroll wheel accumulator — smooths trackpad momentum
  double _wheelAccum = 0;
  DateTime _lastWheelTime = DateTime.now();

  // Hover tooltip
  OverlayEntry? _tooltipEntry;
  Offset? _hoverPos;

  static bool get _isDesktop {
    if (kIsWeb) return true;
    try {
      return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    } catch (_) {
      return false;
    }
  }

  // ── Wheel / trackpad ───────────────────────────────────────────────────

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;

    final dx = event.scrollDelta.dx;
    final dy = event.scrollDelta.dy;

    // Trackpad two-finger scroll: small delta, pan
    // Mouse wheel: large discrete delta, zoom
    final isMagnify = event is PointerScaleEvent;
    final isTrackpad = dx.abs() > 0 || dy.abs() < 50;

    if (isTrackpad && dx.abs() > dy.abs()) {
      // Horizontal trackpad swipe → pan
      final dt = DateTime.now().difference(_lastWheelTime).inMicroseconds / 1e6;
      _lastWheelTime = DateTime.now();
      widget.callbacks.onPanStart(event.localPosition.dx);
      widget.callbacks.onPanUpdate(event.localPosition.dx - dx, dt.clamp(0.001, 0.1));
      widget.callbacks.onPanEnd();
    } else {
      // Vertical scroll → zoom
      final sensitivity = _isDesktop ? 0.0012 : 0.002;
      final scaleDelta = -dy * sensitivity * widget.currentZoom;
      final focalYear = widget.screenXToYear(event.localPosition.dx);
      final newZoom = (widget.currentZoom + scaleDelta).clamp(0.05, 500.0);
      widget.callbacks.onZoomTo(focalYear, newZoom);
    }
  }

  // ── Scale / pinch (touch) ──────────────────────────────────────────────

  void _onScaleStart(ScaleStartDetails d) {
    if (d.pointerCount == 1) {
      _isPanning = true;
      _isPinching = false;
      _lastPanX = d.focalPoint.dx;
      _lastPanTime = DateTime.now();
      widget.callbacks.onPanStart(d.focalPoint.dx);
    } else {
      _isPinching = true;
      _isPanning = false;
      final focalYear = widget.screenXToYear(d.focalPoint.dx);
      widget.callbacks.onPinchStart(focalYear);
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (_isPinching) {
      widget.callbacks.onPinchUpdate(d.scale);
      return;
    }
    if (_isPanning) {
      final now = DateTime.now();
      final dt = now.difference(_lastPanTime).inMicroseconds / 1e6;
      _lastPanTime = now;
      widget.callbacks.onPanUpdate(d.focalPoint.dx, dt.clamp(0.001, 0.1));
      _lastPanX = d.focalPoint.dx;
    }
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (_isPanning) widget.callbacks.onPanEnd();
    if (_isPinching) widget.callbacks.onPinchEnd();
    _isPanning = false;
    _isPinching = false;
  }

  // ── Double tap ────────────────────────────────────────────────────────

  void _onDoubleTap() {
    // Resolved via onDoubleTapDown
  }

  void _onDoubleTapDown(TapDownDetails d) {
    final focalYear = widget.screenXToYear(d.localPosition.dx);
    widget.callbacks.onZoomTo(focalYear, widget.currentZoom * 2.5);
  }

  // ── Tap ───────────────────────────────────────────────────────────────

  void _onTapUp(TapUpDetails d) {
    widget.callbacks.onTap?.call(d.localPosition);
  }

  // ── Long press ────────────────────────────────────────────────────────

  void _onLongPressStart(LongPressStartDetails d) {
    widget.callbacks.onLongPress?.call(d.localPosition);
  }

  // ── Hover (desktop) ───────────────────────────────────────────────────

  void _onHover(PointerHoverEvent event) {
    widget.callbacks.onCrosshairMove?.call(event.localPosition.dx);
    _hoverPos = event.localPosition;
  }

  void _onExit(PointerExitEvent event) {
    widget.callbacks.onCrosshairEnd?.call();
    _hoverPos = null;
  }

  // ── Right-click (desktop) ─────────────────────────────────────────────

  void _onPointerDown(PointerDownEvent event) {
    if (event.buttons == kSecondaryMouseButton) {
      widget.callbacks.onRightClick?.call(event.localPosition);
      _showContextMenu(event.localPosition, event.position);
    }
  }

  void _showContextMenu(Offset local, Offset global) {
    final year = widget.screenXToYear(local.dx).round();
    final yearLabel = year < 0 ? '${-year} BC' : '$year AD';

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        global.dx, global.dy, global.dx + 1, global.dy + 1,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          height: 32,
          child: Text(
            yearLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'copy_year',
          height: 36,
          child: _ContextItem(icon: Icons.copy, label: 'Copy year ($yearLabel)'),
        ),
        PopupMenuItem(
          value: 'zoom_in',
          height: 36,
          child: const _ContextItem(icon: Icons.zoom_in, label: 'Zoom in here'),
        ),
        PopupMenuItem(
          value: 'zoom_out',
          height: 36,
          child: const _ContextItem(icon: Icons.zoom_out, label: 'Zoom out'),
        ),
        PopupMenuItem(
          value: 'fit',
          height: 36,
          child: const _ContextItem(icon: Icons.fit_screen_outlined, label: 'Fit all events'),
        ),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'copy_year':
          Clipboard.setData(ClipboardData(text: yearLabel));
        case 'zoom_in':
          widget.callbacks.onZoomTo(year.toDouble(), widget.currentZoom * 3);
        case 'zoom_out':
          widget.callbacks.onZoomTo(year.toDouble(), widget.currentZoom / 3);
        case 'fit':
          widget.callbacks.onZoomTo(year.toDouble(), 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      onDoubleTap: _onDoubleTap,
      onDoubleTapDown: _onDoubleTapDown,
      onTapUp: _onTapUp,
      onLongPressStart: _onLongPressStart,
      child: widget.child,
    );

    // Desktop extras
    if (_isDesktop) {
      child = Listener(
        onPointerSignal: _onPointerSignal,
        onPointerDown: _onPointerDown,
        child: MouseRegion(
          onHover: _onHover,
          onExit: _onExit,
          cursor: SystemMouseCursors.precise,
          child: child,
        ),
      );
    }

    return child;
  }
}

// ---------------------------------------------------------------------------
// _ContextItem
// ---------------------------------------------------------------------------

class _ContextItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ContextItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TimelineHoverTooltip — dwell tooltip (300ms delay)
// ---------------------------------------------------------------------------

/// Shows a small floating tooltip at [position] after [delay].
/// Intended for use on desktop to preview event info before clicking.
class TimelineHoverTooltip extends StatefulWidget {
  final Offset? position;
  final String? title;
  final String? subtitle;
  final Color accentColor;
  final Duration delay;

  const TimelineHoverTooltip({
    super.key,
    required this.position,
    this.title,
    this.subtitle,
    this.accentColor = const Color(0xFF2196F3),
    this.delay = const Duration(milliseconds: 500),
  });

  @override
  State<TimelineHoverTooltip> createState() => _TimelineHoverTooltipState();
}

class _TimelineHoverTooltipState extends State<TimelineHoverTooltip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scheduleShow();
  }

  @override
  void didUpdateWidget(TimelineHoverTooltip old) {
    super.didUpdateWidget(old);
    if (widget.position != old.position || widget.title != old.title) {
      _ctrl.reverse();
      _scheduleShow();
    }
  }

  void _scheduleShow() {
    Future.delayed(widget.delay, () {
      if (mounted && widget.position != null && widget.title != null) {
        _ctrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.position == null || widget.title == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: widget.position!.dx + 12,
      top: widget.position!.dy - 36,
      child: FadeTransition(
        opacity: _opacity,
        child: IgnorePointer(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 7),
            constraints: const BoxConstraints(maxWidth: 220),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: widget.accentColor, width: 3),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

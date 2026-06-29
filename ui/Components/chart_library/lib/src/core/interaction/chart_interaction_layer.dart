/// Gesture interaction layer for charts.
///
/// [ChartInteractionLayer] is a transparent overlay widget that captures:
///   - Pinch-to-zoom  (scale gesture)
///   - Pan / drag     (move the viewport left/right)
///   - Fling          (momentum pan after a fast swipe)
///   - Double-tap     (zoom-in at tap point)
///   - Single tap     (data point selection)
///   - Long-press     (show crosshair / tooltip)
///   - Scroll wheel   (zoom on web/desktop via Listener)
///
/// It drives a [ChartZoomController] and notifies callers via callbacks for
/// tap-selection and crosshair events.
///
/// Usage:
/// ```dart
/// ChartInteractionLayer(
///   zoomController: _zoomCtrl,
///   onTap: (frac) => _selectDataPoint(frac),
///   onCrosshairMove: (frac) => _showCrosshair(frac),
///   child: ChartPainterWidget(painter: _painter),
/// )
/// ```
library chart_interaction_layer;

import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'chart_zoom_state.dart';

// ---------------------------------------------------------------------------
// ChartInteractionLayer
// ---------------------------------------------------------------------------

class ChartInteractionLayer extends StatefulWidget {
  final ChartZoomController zoomController;

  /// Called when the user taps a data point.
  /// [fraction] is the x-position in [0..1] of the full data range.
  final void Function(double fraction)? onTap;

  /// Called during a long-press drag (crosshair tracking).
  final void Function(double fraction)? onCrosshairMove;

  /// Called when the crosshair is dismissed (finger lifted).
  final void Function()? onCrosshairEnd;

  /// Called when the user double-taps — useful to trigger drill-down.
  final void Function(double fraction)? onDoubleTap;

  /// The chart widget rendered underneath this interaction layer.
  final Widget child;

  const ChartInteractionLayer({
    super.key,
    required this.zoomController,
    required this.child,
    this.onTap,
    this.onCrosshairMove,
    this.onCrosshairEnd,
    this.onDoubleTap,
  });

  @override
  State<ChartInteractionLayer> createState() =>
      _ChartInteractionLayerState();
}

class _ChartInteractionLayerState extends State<ChartInteractionLayer>
    with SingleTickerProviderStateMixin {
  // ---- Fling ticker ----
  late final Ticker _flingTicker;
  bool _flingActive = false;

  // ---- Scale gesture tracking ----
  double _lastScale = 1.0;
  Offset? _lastFocalPoint;
  bool _isScaling = false; // true = pinch in progress

  // ---- Crosshair ----
  bool _crosshairActive = false;
  Offset? _crosshairPosition;

  // ---- Canvas width (resolved via LayoutBuilder) ----
  double _canvasWidth = 0;
  double _canvasHeight = 0;

  @override
  void initState() {
    super.initState();
    _flingTicker = createTicker(_onFlingTick);
  }

  @override
  void dispose() {
    _flingTicker.dispose();
    super.dispose();
  }

  void _onFlingTick(Duration _) {
    widget.zoomController.advanceFling();
    if (!widget.zoomController.hasMomentum) {
      _flingTicker.stop();
      _flingActive = false;
    }
  }

  // ---- Scale gesture (pinch + single-finger pan) ----

  void _onScaleStart(ScaleStartDetails d) {
    _lastScale = 1.0;
    _lastFocalPoint = d.localFocalPoint;
    _isScaling = d.pointerCount > 1;
    // Stop any ongoing fling.
    if (_flingActive) {
      _flingTicker.stop();
      _flingActive = false;
      widget.zoomController.value =
          widget.zoomController.value.withVelocity(0);
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (_canvasWidth <= 0) return;

    if (_isScaling && d.pointerCount > 1) {
      // Pinch-to-zoom: apply scale delta.
      final scaleDelta = d.scale / _lastScale;
      _lastScale = d.scale;
      if ((scaleDelta - 1.0).abs() > 0.001) {
        widget.zoomController.onScaleUpdate(
          d.localFocalPoint.dx,
          _canvasWidth,
          scaleDelta,
        );
      }
    } else if (_lastFocalPoint != null) {
      // Single-finger pan.
      final deltaX = d.localFocalPoint.dx - _lastFocalPoint!.dx;
      widget.zoomController.onPanDelta(deltaX, _canvasWidth);
    }

    _lastFocalPoint = d.localFocalPoint;
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (!_isScaling && widget.zoomController.constraints.enableFling) {
      // Start fling from horizontal velocity.
      final vx = d.velocity.pixelsPerSecond.dx;
      if (vx.abs() > 50) {
        widget.zoomController.onFlingStart(vx, _canvasWidth);
        _flingActive = true;
        _flingTicker.start();
      }
    }
    _isScaling = false;
    _lastFocalPoint = null;
    _lastScale = 1.0;
  }

  // ---- Tap / double-tap ----

  void _onTapUp(TapUpDetails d) {
    if (_crosshairActive) return;
    final frac = widget.zoomController.value
        .canvasToFraction(d.localPosition.dx, _canvasWidth);
    widget.onTap?.call(frac);
  }

  void _onDoubleTap() {
    // Position tracked via onDoubleTapDown.
  }

  Offset? _doubleTapPosition;

  void _onDoubleTapDown(TapDownDetails d) {
    _doubleTapPosition = d.localPosition;
  }

  void _handleDoubleTap() {
    final pos = _doubleTapPosition;
    if (pos == null || _canvasWidth <= 0) return;

    widget.zoomController.onDoubleTap(pos.dx, _canvasWidth);

    final frac = widget.zoomController.value
        .canvasToFraction(pos.dx, _canvasWidth);
    widget.onDoubleTap?.call(frac);
  }

  // ---- Long-press (crosshair) ----

  void _onLongPressStart(LongPressStartDetails d) {
    _crosshairActive = true;
    _crosshairPosition = d.localPosition;
    HapticFeedback.selectionClick();
    final frac = widget.zoomController.value
        .canvasToFraction(d.localPosition.dx, _canvasWidth);
    widget.onCrosshairMove?.call(frac);
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails d) {
    _crosshairPosition = d.localPosition;
    final frac = widget.zoomController.value
        .canvasToFraction(d.localPosition.dx, _canvasWidth);
    widget.onCrosshairMove?.call(frac);
  }

  void _onLongPressEnd(LongPressEndDetails d) {
    _crosshairActive = false;
    _crosshairPosition = null;
    widget.onCrosshairEnd?.call();
  }

  // ---- Scroll wheel (desktop / web) ----

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      widget.zoomController.onScrollWheel(
        event.scrollDelta.dy,
        event.localPosition.dx,
        _canvasWidth,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasWidth = constraints.maxWidth;
        _canvasHeight = constraints.maxHeight;

        return Listener(
          onPointerSignal: _onPointerSignal,
          child: GestureDetector(
            onTapUp: _onTapUp,
            onDoubleTapDown: _onDoubleTapDown,
            onDoubleTap: () {
              _handleDoubleTap();
            },
            onLongPressStart: _onLongPressStart,
            onLongPressMoveUpdate: _onLongPressMoveUpdate,
            onLongPressEnd: _onLongPressEnd,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            behavior: HitTestBehavior.opaque,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// ZoomResetButton — floating back/reset control
// ---------------------------------------------------------------------------

/// A small overlay button shown when the chart is zoomed in.
///
/// Displays a breadcrumb trail and a "reset" (×) button.
///
/// ```dart
/// Stack(
///   children: [
///     myChart,
///     ZoomResetButton(
///       controller: _zoomCtrl,
///       alignment: Alignment.topRight,
///     ),
///   ],
/// )
/// ```
class ZoomResetButton extends StatelessWidget {
  final ChartZoomController controller;
  final Alignment alignment;

  const ZoomResetButton({
    super.key,
    required this.controller,
    this.alignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ChartZoomState>(
      valueListenable: controller,
      builder: (context, state, _) {
        if (state.isIdentity) return const SizedBox.shrink();

        final breadcrumbs = state.breadcrumbs;
        final canPop = state.canPop;

        return Align(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Material(
              color: Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Breadcrumb trail
                  if (breadcrumbs.isNotEmpty)
                    ...breadcrumbs.asMap().entries.map((e) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (e.key > 0)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.chevron_right,
                                    size: 14, color: Colors.white70),
                              ),
                            _crumb(e.value, () {
                              // Pop back to this level
                              int pops =
                                  breadcrumbs.length - e.key - 1;
                              for (int i = 0; i < pops; i++) {
                                controller.pop();
                              }
                            }),
                          ],
                        )),
                  const SizedBox(width: 8),
                  // Back button
                  if (canPop)
                    _iconButton(
                      Icons.arrow_back_ios_new_rounded,
                      'Back',
                      controller.pop,
                    ),
                  // Reset button
                  _iconButton(Icons.zoom_out_map_rounded, 'Reset zoom',
                      controller.reset),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _crumb(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ZoomMinimap — shows position of current viewport in the full dataset
// ---------------------------------------------------------------------------

/// A thin horizontal strip that shows the current zoom window.
///
/// Works as a scrubber / overview + detail pattern.
///
/// ```dart
/// Column(children: [
///   myChart,
///   ZoomMinimap(controller: _zoomCtrl, height: 32),
/// ])
/// ```
class ZoomMinimap extends StatefulWidget {
  final ChartZoomController controller;
  final double height;
  final Color windowColor;
  final Color trackColor;

  const ZoomMinimap({
    super.key,
    required this.controller,
    this.height = 28,
    this.windowColor = const Color(0x662196F3),
    this.trackColor = const Color(0x22000000),
  });

  @override
  State<ZoomMinimap> createState() => _ZoomMinimapState();
}

class _ZoomMinimapState extends State<ZoomMinimap> {
  double _dragStartFrac = 0;
  double _windowAtDragStart = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ChartZoomState>(
      valueListenable: widget.controller,
      builder: (context, state, _) {
        return GestureDetector(
          onHorizontalDragStart: (d) {
            _dragStartFrac =
                d.localPosition.dx / context.size!.width;
            _windowAtDragStart = state.xStart;
          },
          onHorizontalDragUpdate: (d) {
            final frac =
                d.localPosition.dx / context.size!.width;
            final delta = frac - _dragStartFrac;
            widget.controller.value = ChartZoomState(
              xStart: (_windowAtDragStart + delta)
                  .clamp(0, 1 - state.windowSize),
              xEnd: (_windowAtDragStart + delta + state.windowSize)
                  .clamp(state.windowSize, 1.0),
              minWindowFraction: state.minWindowFraction,
            );
          },
          onTapUp: (d) {
            // Centre viewport on tap.
            final frac = d.localPosition.dx / context.size!.width;
            widget.controller.value =
                state.centreOn(frac);
          },
          child: LayoutBuilder(
            builder: (ctx, box) {
              final w = box.maxWidth;
              return Container(
                height: widget.height,
                color: widget.trackColor,
                child: Stack(
                  children: [
                    // Viewport window indicator.
                    Positioned(
                      left: state.xStart * w,
                      width: state.windowSize * w,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.windowColor,
                          border: Border.all(
                            color: const Color(0xFF2196F3),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

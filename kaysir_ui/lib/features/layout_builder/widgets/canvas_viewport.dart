import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/component.dart';
import '../provider/canvas_viewport_provider.dart';
import '../provider/layout_state_provider.dart';

class LayoutCanvasViewport extends ConsumerStatefulWidget {
  final Widget child;
  final Size canvasSize;

  const LayoutCanvasViewport({
    super.key,
    required this.child,
    this.canvasSize = layoutCanvasSize,
  });

  @override
  ConsumerState<LayoutCanvasViewport> createState() =>
      _LayoutCanvasViewportState();
}

class _LayoutCanvasViewportState extends ConsumerState<LayoutCanvasViewport> {
  late final TransformationController _controller;
  var _handledFitRequestId = 0;
  var _handledFitSelectionRequestId = 0;
  var _handledResetRequestId = 0;
  var _isApplyingTransform = false;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
    _controller.addListener(_syncTransformFromController);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncTransformFromController);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CanvasViewportState>(canvasViewportProvider, (previous, next) {
      if (previous?.resetRequestId != next.resetRequestId &&
          _handledResetRequestId != next.resetRequestId) {
        _handledResetRequestId = next.resetRequestId;
        _applyReset();
        return;
      }

      if ((currentZoom - next.zoom).abs() > 0.005) {
        _applyZoom(next.zoom);
      }
    });

    final viewportState = ref.watch(canvasViewportProvider);
    final selectedComponents = ref.watch(
      layoutStateProvider.select((state) => state.selectedComponents),
    );
    final visibleSelectedComponents =
        selectedComponents.where((component) => component.isVisible).toList();
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = constraints.biggest;
        if (_handledFitRequestId != viewportState.fitRequestId) {
          _handledFitRequestId = viewportState.fitRequestId;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _fitToViewport(viewportSize);
          });
        }
        if (_handledFitSelectionRequestId !=
            viewportState.fitSelectionRequestId) {
          _handledFitSelectionRequestId = viewportState.fitSelectionRequestId;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || visibleSelectedComponents.isEmpty) return;
            _fitRectToViewport(
              _componentsBounds(visibleSelectedComponents),
              viewportSize,
            );
          });
        }

        return MouseRegion(
          onHover: (event) {
            ref
                .read(canvasViewportProvider.notifier)
                .setPointerCanvasPosition(_screenToCanvas(event.localPosition));
          },
          onExit:
              (_) => ref
                  .read(canvasViewportProvider.notifier)
                  .setPointerCanvasPosition(null),
          child: Stack(
            children: [
              InteractiveViewer(
                transformationController: _controller,
                constrained: false,
                clipBehavior: Clip.none,
                boundaryMargin: const EdgeInsets.all(700),
                minScale: CanvasViewportNotifier.minZoom,
                maxScale: CanvasViewportNotifier.maxZoom,
                panEnabled: !viewportState.isMarqueeSelecting,
                child: SizedBox.fromSize(
                  size: widget.canvasSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(color: colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: widget.child,
                  ),
                ),
              ),
              _CanvasRulers(
                canvasSize: widget.canvasSize,
                viewportState: viewportState,
              ),
              Positioned(
                right: 12,
                top: 36,
                child: _CanvasMinimap(
                  canvasSize: widget.canvasSize,
                  viewportSize: viewportSize,
                  viewportState: viewportState,
                  onNavigate:
                      (position) => _centerViewportOn(
                        canvasPosition: position,
                        viewportSize: viewportSize,
                      ),
                ),
              ),
              const Positioned(
                left: 12,
                bottom: 12,
                child: _CanvasZoomControls(),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: _CanvasCoordinateReadout(
                  position: viewportState.pointerCanvasPosition,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double get currentZoom => _controller.value.getMaxScaleOnAxis();

  Offset get currentPan {
    final storage = _controller.value.storage;
    return Offset(storage[12], storage[13]);
  }

  Offset? _screenToCanvas(Offset position) {
    final zoom = currentZoom;
    if (zoom <= 0) return null;

    final canvasPosition = (position - currentPan) / zoom;
    if (canvasPosition.dx < 0 ||
        canvasPosition.dy < 0 ||
        canvasPosition.dx > widget.canvasSize.width ||
        canvasPosition.dy > widget.canvasSize.height) {
      return null;
    }

    return canvasPosition;
  }

  void _syncTransformFromController() {
    if (_isApplyingTransform) return;
    ref
        .read(canvasViewportProvider.notifier)
        .syncTransform(zoom: currentZoom, pan: currentPan);
  }

  void _applyZoom(double zoom) {
    _setTransform((matrix) {
      matrix.setEntry(0, 0, zoom);
      matrix.setEntry(1, 1, zoom);
      matrix.setEntry(2, 2, 1);
      return matrix;
    });
  }

  void _applyReset() {
    _setTransform((_) => Matrix4.identity());
  }

  void _fitToViewport(Size viewportSize) {
    if (viewportSize.width <= 0 || viewportSize.height <= 0) return;

    final paddedViewport = Size(
      math.max(1, viewportSize.width - 56),
      math.max(1, viewportSize.height - 56),
    );
    final zoom =
        math
            .min(
              paddedViewport.width / widget.canvasSize.width,
              paddedViewport.height / widget.canvasSize.height,
            )
            .clamp(
              CanvasViewportNotifier.minZoom,
              CanvasViewportNotifier.maxZoom,
            )
            .toDouble();
    final dx = (viewportSize.width - widget.canvasSize.width * zoom) / 2;
    final dy = (viewportSize.height - widget.canvasSize.height * zoom) / 2;

    _setTransform((_) {
      return Matrix4.identity()
        ..translateByDouble(dx, dy, 0, 1)
        ..scaleByDouble(zoom, zoom, zoom, 1);
    });
    ref.read(canvasViewportProvider.notifier).setZoom(zoom);
  }

  void _fitRectToViewport(Rect targetBounds, Size viewportSize) {
    if (targetBounds.isEmpty ||
        viewportSize.width <= 0 ||
        viewportSize.height <= 0) {
      return;
    }

    final paddedViewport = Size(
      math.max(1, viewportSize.width - 96),
      math.max(1, viewportSize.height - 96),
    );
    final paddedTarget = targetBounds.inflate(80);
    final targetWidth = math.max(160, paddedTarget.width);
    final targetHeight = math.max(120, paddedTarget.height);
    final zoom =
        math
            .min(
              paddedViewport.width / targetWidth,
              paddedViewport.height / targetHeight,
            )
            .clamp(
              CanvasViewportNotifier.minZoom,
              CanvasViewportNotifier.maxZoom,
            )
            .toDouble();
    final center = targetBounds.center;
    final dx = viewportSize.width / 2 - center.dx * zoom;
    final dy = viewportSize.height / 2 - center.dy * zoom;

    _setTransform((_) {
      return Matrix4.identity()
        ..translateByDouble(dx, dy, 0, 1)
        ..scaleByDouble(zoom, zoom, zoom, 1);
    });
    ref.read(canvasViewportProvider.notifier).setZoom(zoom);
  }

  void _centerViewportOn({
    required Offset canvasPosition,
    required Size viewportSize,
  }) {
    final zoom = currentZoom;
    final dx = viewportSize.width / 2 - canvasPosition.dx * zoom;
    final dy = viewportSize.height / 2 - canvasPosition.dy * zoom;

    _setTransform((_) {
      return Matrix4.identity()
        ..translateByDouble(dx, dy, 0, 1)
        ..scaleByDouble(zoom, zoom, zoom, 1);
    });
  }

  void _setTransform(Matrix4 Function(Matrix4 matrix) update) {
    _isApplyingTransform = true;
    _controller.value = update(_controller.value.clone());
    _isApplyingTransform = false;
    ref
        .read(canvasViewportProvider.notifier)
        .syncTransform(zoom: currentZoom, pan: currentPan);
  }
}

class _CanvasMinimap extends ConsumerWidget {
  final Size canvasSize;
  final Size viewportSize;
  final CanvasViewportState viewportState;
  final ValueChanged<Offset> onNavigate;

  const _CanvasMinimap({
    required this.canvasSize,
    required this.viewportSize,
    required this.viewportState,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final components = ref.watch(
      layoutStateProvider.select((state) => state.components),
    );
    final selectedIds = ref.watch(
      layoutStateProvider.select((state) => state.selectedComponentIds),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 3,
      color: colorScheme.surface.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const width = 176.0;
          final height = width * canvasSize.height / canvasSize.width;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown:
                  (details) => _navigateFromLocal(
                    details.localPosition,
                    Size(width, height),
                  ),
              onPanUpdate:
                  (details) => _navigateFromLocal(
                    details.localPosition,
                    Size(width, height),
                  ),
              child: SizedBox(
                width: width,
                height: height,
                child: CustomPaint(
                  painter: _CanvasMinimapPainter(
                    canvasSize: canvasSize,
                    viewportSize: viewportSize,
                    viewportState: viewportState,
                    components: components,
                    selectedIds: selectedIds,
                    colorScheme: colorScheme,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateFromLocal(Offset localPosition, Size minimapSize) {
    final canvasPosition = _localToCanvasPosition(localPosition, minimapSize);
    onNavigate(canvasPosition);
  }

  Offset _localToCanvasPosition(Offset localPosition, Size minimapSize) {
    final scale = _minimapScale(minimapSize);
    final origin = _minimapOrigin(minimapSize, scale);
    final position = (localPosition - origin) / scale;

    return Offset(
      position.dx.clamp(0, canvasSize.width).toDouble(),
      position.dy.clamp(0, canvasSize.height).toDouble(),
    );
  }

  double _minimapScale(Size minimapSize) {
    return math.min(
      minimapSize.width / canvasSize.width,
      minimapSize.height / canvasSize.height,
    );
  }

  Offset _minimapOrigin(Size minimapSize, double scale) {
    final paintedSize = Size(
      canvasSize.width * scale,
      canvasSize.height * scale,
    );
    return Offset(
      (minimapSize.width - paintedSize.width) / 2,
      (minimapSize.height - paintedSize.height) / 2,
    );
  }
}

class _CanvasMinimapPainter extends CustomPainter {
  final Size canvasSize;
  final Size viewportSize;
  final CanvasViewportState viewportState;
  final List<ComponentData> components;
  final Set<String> selectedIds;
  final ColorScheme colorScheme;

  _CanvasMinimapPainter({
    required this.canvasSize,
    required this.viewportSize,
    required this.viewportState,
    required this.components,
    required this.selectedIds,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / canvasSize.width,
      size.height / canvasSize.height,
    );
    final paintedSize = Size(
      canvasSize.width * scale,
      canvasSize.height * scale,
    );
    final origin = Offset(
      (size.width - paintedSize.width) / 2,
      (size.height - paintedSize.height) / 2,
    );
    final canvasRect = origin & paintedSize;

    final backgroundPaint = Paint()..color = colorScheme.surface;
    final borderPaint =
        Paint()
          ..color = colorScheme.outlineVariant
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    final componentPaint =
        Paint()
          ..color = colorScheme.primary.withValues(alpha: 0.42)
          ..style = PaintingStyle.fill;
    final selectedPaint =
        Paint()
          ..color = colorScheme.primary
          ..style = PaintingStyle.fill;
    final hiddenPaint =
        Paint()
          ..color = colorScheme.outline.withValues(alpha: 0.28)
          ..style = PaintingStyle.fill;
    final viewportFill =
        Paint()
          ..color = colorScheme.tertiary.withValues(alpha: 0.14)
          ..style = PaintingStyle.fill;
    final viewportStroke =
        Paint()
          ..color = colorScheme.tertiary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6;

    canvas.drawRRect(
      RRect.fromRectAndRadius(canvasRect, const Radius.circular(7)),
      backgroundPaint,
    );

    for (final component in components) {
      final rect = _componentRect(component, origin, scale);
      final paint =
          !component.isVisible
              ? hiddenPaint
              : selectedIds.contains(component.id)
              ? selectedPaint
              : componentPaint;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
    }

    final visibleRect = _visibleCanvasRect();
    if (!visibleRect.isEmpty) {
      final minimapVisibleRect = Rect.fromLTWH(
        origin.dx + visibleRect.left * scale,
        origin.dy + visibleRect.top * scale,
        visibleRect.width * scale,
        visibleRect.height * scale,
      );
      canvas.drawRect(minimapVisibleRect, viewportFill);
      canvas.drawRect(minimapVisibleRect, viewportStroke);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(canvasRect, const Radius.circular(7)),
      borderPaint,
    );
  }

  Rect _componentRect(ComponentData component, Offset origin, double scale) {
    return Rect.fromLTWH(
      origin.dx + component.position.dx * scale,
      origin.dy + component.position.dy * scale,
      math.max(2, component.size.width * scale),
      math.max(2, component.size.height * scale),
    );
  }

  Rect _visibleCanvasRect() {
    final zoom = viewportState.zoom;
    if (zoom <= 0) return Rect.zero;

    final left = (-viewportState.pan.dx / zoom).clamp(0, canvasSize.width);
    final top = (-viewportState.pan.dy / zoom).clamp(0, canvasSize.height);
    final right = ((viewportSize.width - viewportState.pan.dx) / zoom).clamp(
      0,
      canvasSize.width,
    );
    final bottom = ((viewportSize.height - viewportState.pan.dy) / zoom).clamp(
      0,
      canvasSize.height,
    );

    if (right <= left || bottom <= top) return Rect.zero;
    return Rect.fromLTRB(
      left.toDouble(),
      top.toDouble(),
      right.toDouble(),
      bottom.toDouble(),
    );
  }

  @override
  bool shouldRepaint(covariant _CanvasMinimapPainter oldDelegate) {
    return oldDelegate.canvasSize != canvasSize ||
        oldDelegate.viewportSize != viewportSize ||
        oldDelegate.viewportState.zoom != viewportState.zoom ||
        oldDelegate.viewportState.pan != viewportState.pan ||
        oldDelegate.components != components ||
        oldDelegate.selectedIds != selectedIds ||
        oldDelegate.colorScheme != colorScheme;
  }
}

class _CanvasRulers extends ConsumerWidget {
  final Size canvasSize;
  final CanvasViewportState viewportState;

  const _CanvasRulers({required this.canvasSize, required this.viewportState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedComponents = ref.watch(
      layoutStateProvider.select((state) => state.selectedComponents),
    );
    final visibleSelectedComponents =
        selectedComponents.where((component) => component.isVisible).toList();
    final showPrecisionGuides = viewportState.showPrecisionGuides;
    final selectionBounds =
        showPrecisionGuides && visibleSelectedComponents.isNotEmpty
            ? _componentsBounds(visibleSelectedComponents)
            : null;
    final pointerPosition =
        showPrecisionGuides ? viewportState.pointerCanvasPosition : null;
    final colorScheme = Theme.of(context).colorScheme;
    final background = colorScheme.surface.withValues(alpha: 0.92);
    final lineColor = colorScheme.outlineVariant;
    final textColor = colorScheme.onSurfaceVariant;
    final selectionColor = colorScheme.primary;
    final pointerColor = colorScheme.secondary;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: _RulerPainter.thickness,
            right: 0,
            top: 0,
            height: _RulerPainter.thickness,
            child: CustomPaint(
              painter: _RulerPainter(
                axis: Axis.horizontal,
                canvasSize: canvasSize,
                zoom: viewportState.zoom,
                pan: viewportState.pan,
                selectionBounds: selectionBounds,
                pointerPosition: pointerPosition,
                background: background,
                lineColor: lineColor,
                textColor: textColor,
                selectionColor: selectionColor,
                pointerColor: pointerColor,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: _RulerPainter.thickness,
            bottom: 0,
            width: _RulerPainter.thickness,
            child: CustomPaint(
              painter: _RulerPainter(
                axis: Axis.vertical,
                canvasSize: canvasSize,
                zoom: viewportState.zoom,
                pan: viewportState.pan,
                selectionBounds: selectionBounds,
                pointerPosition: pointerPosition,
                background: background,
                lineColor: lineColor,
                textColor: textColor,
                selectionColor: selectionColor,
                pointerColor: pointerColor,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: _RulerPainter.thickness,
            height: _RulerPainter.thickness,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: background,
                border: Border(
                  right: BorderSide(color: lineColor),
                  bottom: BorderSide(color: lineColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  static const thickness = 24.0;

  final Axis axis;
  final Size canvasSize;
  final double zoom;
  final Offset pan;
  final Rect? selectionBounds;
  final Offset? pointerPosition;
  final Color background;
  final Color lineColor;
  final Color textColor;
  final Color selectionColor;
  final Color pointerColor;

  _RulerPainter({
    required this.axis,
    required this.canvasSize,
    required this.zoom,
    required this.pan,
    required this.selectionBounds,
    required this.pointerPosition,
    required this.background,
    required this.lineColor,
    required this.textColor,
    required this.selectionColor,
    required this.pointerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = background;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final borderPaint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 1;
    if (axis == Axis.horizontal) {
      canvas.drawLine(
        Offset(0, size.height - 0.5),
        Offset(size.width, size.height - 0.5),
        borderPaint,
      );
    } else {
      canvas.drawLine(
        Offset(size.width - 0.5, 0),
        Offset(size.width - 0.5, size.height),
        borderPaint,
      );
    }

    _paintSelectionRange(canvas, size);

    final majorStep = _majorStepForZoom();
    final minorStep = majorStep / 2;
    final tickPaint =
        Paint()
          ..color = textColor.withValues(alpha: 0.8)
          ..strokeWidth = 1;
    final canvasExtent =
        axis == Axis.horizontal ? canvasSize.width : canvasSize.height;
    final panOffset = axis == Axis.horizontal ? pan.dx : pan.dy;
    final viewOffset = axis == Axis.horizontal ? thickness : thickness;
    final maxScreenExtent = axis == Axis.horizontal ? size.width : size.height;

    for (var world = 0.0; world <= canvasExtent; world += minorStep) {
      final isMajor = world % majorStep == 0;
      final screen = panOffset + world * zoom - viewOffset;
      if (screen < -1 || screen > maxScreenExtent + 1) continue;

      final tickLength = isMajor ? 12.0 : 7.0;
      if (axis == Axis.horizontal) {
        canvas.drawLine(
          Offset(screen, size.height),
          Offset(screen, size.height - tickLength),
          tickPaint,
        );
      } else {
        canvas.drawLine(
          Offset(size.width, screen),
          Offset(size.width - tickLength, screen),
          tickPaint,
        );
      }

      if (isMajor) {
        _paintLabel(canvas, size, screen, world.round().toString());
      }
    }

    _paintPointerMarker(canvas, size);
  }

  double _majorStepForZoom() {
    if (zoom >= 1.5) return 50;
    if (zoom >= 0.85) return 100;
    if (zoom >= 0.5) return 200;
    return 400;
  }

  void _paintSelectionRange(Canvas canvas, Size size) {
    final bounds = selectionBounds;
    if (bounds == null || bounds.isEmpty) return;

    final rangeStart = axis == Axis.horizontal ? bounds.left : bounds.top;
    final rangeEnd = axis == Axis.horizontal ? bounds.right : bounds.bottom;
    final panOffset = axis == Axis.horizontal ? pan.dx : pan.dy;
    final startScreen = panOffset + rangeStart * zoom - thickness;
    final endScreen = panOffset + rangeEnd * zoom - thickness;
    if (endScreen < 0 ||
        startScreen > (axis == Axis.horizontal ? size.width : size.height)) {
      return;
    }

    final start = startScreen.clamp(
      0.0,
      axis == Axis.horizontal ? size.width : size.height,
    );
    final end = endScreen.clamp(
      0.0,
      axis == Axis.horizontal ? size.width : size.height,
    );
    if (end <= start) return;

    final fillPaint =
        Paint()
          ..color = selectionColor.withValues(alpha: 0.13)
          ..style = PaintingStyle.fill;
    final edgePaint =
        Paint()
          ..color = selectionColor.withValues(alpha: 0.75)
          ..strokeWidth = 1.2;

    if (axis == Axis.horizontal) {
      canvas.drawRect(Rect.fromLTRB(start, 0, end, size.height), fillPaint);
      canvas.drawLine(Offset(start, 0), Offset(start, size.height), edgePaint);
      canvas.drawLine(Offset(end, 0), Offset(end, size.height), edgePaint);
      _paintRangeLabel(
        canvas,
        size,
        start,
        end,
        '${(rangeEnd - rangeStart).round()}px',
      );
      return;
    }

    canvas.drawRect(Rect.fromLTRB(0, start, size.width, end), fillPaint);
    canvas.drawLine(Offset(0, start), Offset(size.width, start), edgePaint);
    canvas.drawLine(Offset(0, end), Offset(size.width, end), edgePaint);
    _paintRangeLabel(
      canvas,
      size,
      start,
      end,
      '${(rangeEnd - rangeStart).round()}px',
    );
  }

  void _paintRangeLabel(
    Canvas canvas,
    Size size,
    double start,
    double end,
    String label,
  ) {
    if (end - start < 36) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: selectionColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: math.max(0, end - start - 6));

    if (axis == Axis.horizontal) {
      final x = ((start + end - textPainter.width) / 2).clamp(
        2.0,
        math.max(2.0, size.width - textPainter.width - 2),
      );
      textPainter.paint(canvas, Offset(x.toDouble(), size.height - 14));
      return;
    }

    canvas.save();
    final y = ((start + end + textPainter.width) / 2).clamp(
      textPainter.width + 2,
      math.max(textPainter.width + 2, size.height - 2),
    );
    canvas.translate(5, y.toDouble());
    canvas.rotate(-math.pi / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _paintPointerMarker(Canvas canvas, Size size) {
    final pointer = pointerPosition;
    if (pointer == null) return;

    final value = axis == Axis.horizontal ? pointer.dx : pointer.dy;
    final canvasExtent =
        axis == Axis.horizontal ? canvasSize.width : canvasSize.height;
    if (value < 0 || value > canvasExtent) return;

    final panOffset = axis == Axis.horizontal ? pan.dx : pan.dy;
    final screen = panOffset + value * zoom - thickness;
    final maxScreenExtent = axis == Axis.horizontal ? size.width : size.height;
    if (screen < 0 || screen > maxScreenExtent) return;

    final markerPaint =
        Paint()
          ..color = pointerColor.withValues(alpha: 0.9)
          ..strokeWidth = 1.5;
    final trianglePaint =
        Paint()
          ..color = pointerColor
          ..style = PaintingStyle.fill;

    if (axis == Axis.horizontal) {
      canvas.drawLine(
        Offset(screen, 0),
        Offset(screen, size.height),
        markerPaint,
      );
      _drawHorizontalPointerTriangle(canvas, size, screen, trianglePaint);
      _paintPointerLabel(canvas, size, screen, 'X ${value.round()}');
      return;
    }

    canvas.drawLine(Offset(0, screen), Offset(size.width, screen), markerPaint);
    _drawVerticalPointerTriangle(canvas, size, screen, trianglePaint);
    _paintPointerLabel(canvas, size, screen, 'Y ${value.round()}');
  }

  void _drawHorizontalPointerTriangle(
    Canvas canvas,
    Size size,
    double screen,
    Paint paint,
  ) {
    final path =
        Path()
          ..moveTo(screen, size.height)
          ..lineTo(screen - 4, size.height - 6)
          ..lineTo(screen + 4, size.height - 6)
          ..close();
    canvas.drawPath(path, paint);
  }

  void _drawVerticalPointerTriangle(
    Canvas canvas,
    Size size,
    double screen,
    Paint paint,
  ) {
    final path =
        Path()
          ..moveTo(size.width, screen)
          ..lineTo(size.width - 6, screen - 4)
          ..lineTo(size.width - 6, screen + 4)
          ..close();
    canvas.drawPath(path, paint);
  }

  void _paintPointerLabel(
    Canvas canvas,
    Size size,
    double screen,
    String label,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    if (axis == Axis.horizontal) {
      final width = textPainter.width + 8;
      final left = (screen - width / 2).clamp(
        2.0,
        math.max(2.0, size.width - width - 2),
      );
      final rect = Rect.fromLTWH(left.toDouble(), 3, width, 16);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        Paint()..color = pointerColor,
      );
      textPainter.paint(canvas, rect.topLeft + const Offset(4, 2));
      return;
    }

    final width = textPainter.width + 8;
    final top = (screen - width / 2).clamp(
      2.0,
      math.max(2.0, size.height - width - 2),
    );
    final rect = Rect.fromLTWH(3, top.toDouble(), 16, width);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      Paint()..color = pointerColor,
    );
    canvas.save();
    canvas.translate(rect.left + 3, rect.bottom - 4);
    canvas.rotate(-math.pi / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _paintLabel(Canvas canvas, Size size, double screen, String label) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    if (axis == Axis.horizontal) {
      textPainter.paint(canvas, Offset(screen + 3, 3));
      return;
    }

    canvas.save();
    canvas.translate(4, screen + textPainter.width + 3);
    canvas.rotate(-math.pi / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) {
    return oldDelegate.axis != axis ||
        oldDelegate.canvasSize != canvasSize ||
        oldDelegate.zoom != zoom ||
        oldDelegate.pan != pan ||
        oldDelegate.selectionBounds != selectionBounds ||
        oldDelegate.pointerPosition != pointerPosition ||
        oldDelegate.background != background ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.selectionColor != selectionColor ||
        oldDelegate.pointerColor != pointerColor;
  }
}

Rect _componentsBounds(List<ComponentData> components) {
  final first = components.first;
  var left = first.position.dx;
  var top = first.position.dy;
  var right = first.position.dx + first.size.width;
  var bottom = first.position.dy + first.size.height;

  for (final component in components.skip(1)) {
    left = math.min(left, component.position.dx);
    top = math.min(top, component.position.dy);
    right = math.max(right, component.position.dx + component.size.width);
    bottom = math.max(bottom, component.position.dy + component.size.height);
  }

  return Rect.fromLTRB(left, top, right, bottom);
}

class _CanvasCoordinateReadout extends StatelessWidget {
  final Offset? position;

  const _CanvasCoordinateReadout({required this.position});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label =
        position == null
            ? 'Outside canvas'
            : 'X ${position!.dx.round()}  Y ${position!.dy.round()}';

    return Material(
      elevation: 3,
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

class _CanvasZoomControls extends ConsumerWidget {
  const _CanvasZoomControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewportState = ref.watch(canvasViewportProvider);
    final notifier = ref.read(canvasViewportProvider.notifier);
    final hasVisibleSelection = ref.watch(
      layoutStateProvider.select(
        (state) =>
            state.selectedComponents.any((component) => component.isVisible),
      ),
    );
    final colorScheme = Theme.of(context).colorScheme;
    final zoomLabel = '${(viewportState.zoom * 100).round()}%';

    return Material(
      elevation: 3,
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ZoomButton(
              icon: Icons.remove,
              tooltip: 'Zoom out',
              onPressed:
                  viewportState.zoom <= CanvasViewportNotifier.minZoom
                      ? null
                      : notifier.zoomOut,
            ),
            SizedBox(
              width: 50,
              child: Text(
                zoomLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            _ZoomButton(
              icon: Icons.add,
              tooltip: 'Zoom in',
              onPressed:
                  viewportState.zoom >= CanvasViewportNotifier.maxZoom
                      ? null
                      : notifier.zoomIn,
            ),
            const SizedBox(width: 4),
            _ZoomButton(
              icon: Icons.fit_screen,
              tooltip: 'Fit canvas',
              onPressed: notifier.fitToScreen,
            ),
            _ZoomButton(
              icon: Icons.center_focus_weak,
              tooltip: 'Fit selection',
              onPressed: hasVisibleSelection ? notifier.fitSelection : null,
            ),
            _ZoomButton(
              icon: Icons.center_focus_strong,
              tooltip: 'Reset canvas',
              onPressed: notifier.resetZoom,
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ZoomButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      iconSize: 18,
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}

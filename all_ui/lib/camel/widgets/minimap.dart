import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/node.dart';
import '../models/canvas_transform.dart';

import '../states/canvas_transform_provider.dart';
import '../states/provider.dart';
import '../states/select_route_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MiniMap extends ConsumerStatefulWidget {
  final WNode route;
  final CanvasTransform transform;

  const MiniMap({Key? key, required this.route, required this.transform})
    : super(key: key);

  @override
  ConsumerState<MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends ConsumerState<MiniMap> {
  final double _miniMapSize = 180.0;
  final double _miniMapPadding = 8.0;
  bool _isDragging = false;
  Offset? _dragStartOffset;

  @override
  Widget build(BuildContext context) {
    final selectedNodeIds = ref.watch(selectedNodesProvider);
    final selectedNodeId = ref.watch(selectedNodeIdProvider);

    // Calculate bounds of all nodes
    final bounds = _calculateBounds();
    if (bounds == null) {
      return const SizedBox(); // No nodes to display
    }

    final viewportRect = _calculateViewportRect(bounds);

    return Container(
      width: _miniMapSize,
      height: _miniMapSize,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // MiniMap background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _MiniMapPainter(
                  route: widget.route,
                  bounds: bounds,
                  selectedNodeIds: selectedNodeIds,
                  selectedNodeId: selectedNodeId,
                  viewportRect: viewportRect,
                  isDark: Theme.of(context).brightness == Brightness.dark,
                ),
              ),
            ),
          ),

          // Interactive overlay for panning - FIXED VERSION
          Positioned.fill(
            child: GestureDetector(
              onPanStart: (details) {
                final localPosition = details.localPosition;
                final viewportRect = _calculateViewportRect(bounds);

                // Check if click is inside viewport for dragging
                if (viewportRect.contains(localPosition)) {
                  setState(() {
                    _isDragging = true;
                    _dragStartOffset = localPosition;
                  });
                } else {
                  // Click outside viewport - jump to position
                  _handleMiniMapClick(localPosition, bounds);
                }
              },
              onPanUpdate: (details) {
                if (_isDragging && _dragStartOffset != null) {
                  final delta = details.localPosition - _dragStartOffset!;
                  _handleMiniMapViewportDrag(delta, bounds);
                  _dragStartOffset = details.localPosition;
                }
              },
              onPanEnd: (details) {
                setState(() {
                  _isDragging = false;
                  _dragStartOffset = null;
                });
              },
              onPanCancel: () {
                setState(() {
                  _isDragging = false;
                  _dragStartOffset = null;
                });
              },
              onTapDown: (details) {
                final localPosition = details.localPosition;
                final viewportRect = _calculateViewportRect(bounds);

                // Only handle tap if not on viewport (viewport handles drag)
                if (!viewportRect.contains(localPosition)) {
                  _handleMiniMapClick(localPosition, bounds);
                }
              },
              behavior: HitTestBehavior.opaque,
            ),
          ),

          // Close button
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(
                Icons.close,
                size: 16,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                ref.read(showMiniMapProvider.notifier).state = false;
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ),

          // Title
          Positioned(
            top: 8,
            left: 8,
            child: Text(
              'Mini Map',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),

          // Drag indicator
          if (_isDragging)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Dragging viewport',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Rect? _calculateBounds() {
    if (widget.route.nodes.isEmpty) return null;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final node in widget.route.nodes) {
      minX = minX < node.position.dx ? minX : node.position.dx;
      minY = minY < node.position.dy ? minY : node.position.dy;
      maxX = maxX > node.position.dx ? maxX : node.position.dx;
      maxY = maxY > node.position.dy ? maxY : node.position.dy;
    }

    // Add some padding around the bounds
    const padding = 100.0;
    return Rect.fromLTRB(
      minX - padding,
      minY - padding,
      maxX + padding,
      maxY + padding,
    );
  }

  Rect _calculateViewportRect(Rect bounds) {
    final contentSize = _miniMapSize - (_miniMapPadding * 2);

    // Calculate the scale to fit bounds in minimap
    final scaleX = contentSize / bounds.width;
    final scaleY = contentSize / bounds.height;
    final scale = math.min(scaleX, scaleY);

    // Calculate the actual content area after scaling
    final scaledContentWidth = bounds.width * scale;
    final scaledContentHeight = bounds.height * scale;

    // Calculate content offset to center the content
    final contentOffsetX = (_miniMapSize - scaledContentWidth) / 2;
    final contentOffsetY = (_miniMapSize - scaledContentHeight) / 2;

    // Calculate current visible area in canvas coordinates
    final visibleCanvasLeft =
        -widget.transform.offset.dx / widget.transform.scale;
    final visibleCanvasTop =
        -widget.transform.offset.dy / widget.transform.scale;
    final visibleCanvasRight =
        visibleCanvasLeft +
        MediaQuery.of(context).size.width / widget.transform.scale;
    final visibleCanvasBottom =
        visibleCanvasTop +
        MediaQuery.of(context).size.height / widget.transform.scale;

    // Convert visible area to minimap coordinates
    final viewportLeft =
        contentOffsetX + (visibleCanvasLeft - bounds.left) * scale;
    final viewportTop =
        contentOffsetY + (visibleCanvasTop - bounds.top) * scale;
    final viewportRight =
        contentOffsetX + (visibleCanvasRight - bounds.left) * scale;
    final viewportBottom =
        contentOffsetY + (visibleCanvasBottom - bounds.top) * scale;

    return Rect.fromLTRB(
      viewportLeft.clamp(contentOffsetX, contentOffsetX + scaledContentWidth),
      viewportTop.clamp(contentOffsetY, contentOffsetY + scaledContentHeight),
      viewportRight.clamp(contentOffsetX, contentOffsetX + scaledContentWidth),
      viewportBottom.clamp(
        contentOffsetY,
        contentOffsetY + scaledContentHeight,
      ),
    );
  }

  void _handleMiniMapClick(Offset localPosition, Rect bounds) {
    final contentSize = _miniMapSize - (_miniMapPadding * 2);

    // Calculate the scale to fit bounds in minimap
    final scaleX = contentSize / bounds.width;
    final scaleY = contentSize / bounds.height;
    final scale = math.min(scaleX, scaleY);

    // Calculate the actual content area after scaling
    final scaledContentWidth = bounds.width * scale;
    final scaledContentHeight = bounds.height * scale;

    // Calculate content offset to center the content
    final contentOffsetX = (_miniMapSize - scaledContentWidth) / 2;
    final contentOffsetY = (_miniMapSize - scaledContentHeight) / 2;

    // Convert mini-map coordinates to canvas coordinates
    final canvasX = bounds.left + (localPosition.dx - contentOffsetX) / scale;
    final canvasY = bounds.top + (localPosition.dy - contentOffsetY) / scale;

    // Center the view on the clicked position
    final viewportWidth = MediaQuery.of(context).size.width;
    final viewportHeight = MediaQuery.of(context).size.height;

    final targetOffset = Offset(
      -canvasX * widget.transform.scale + viewportWidth / 2,
      -canvasY * widget.transform.scale + viewportHeight / 2,
    );

    ref.read(canvasTransformProvider.notifier).setOffset(targetOffset);
  }

  void _handleMiniMapViewportDrag(Offset delta, Rect bounds) {
    final contentSize = _miniMapSize - (_miniMapPadding * 2);

    // Calculate the scale to fit bounds in minimap
    final scaleX = contentSize / bounds.width;
    final scaleY = contentSize / bounds.height;
    final scale = math.min(scaleX, scaleY);

    // Convert drag delta from minimap to canvas coordinates
    final canvasDeltaX = delta.dx / scale;
    final canvasDeltaY = delta.dy / scale;

    // Convert to screen offset delta (inverse because we're moving the viewport)
    final screenDelta = Offset(
      -canvasDeltaX * widget.transform.scale,
      -canvasDeltaY * widget.transform.scale,
    );

    // Update canvas transform by panning
    ref.read(canvasTransformProvider.notifier).pan(screenDelta);
  }
}

class _MiniMapPainter extends CustomPainter {
  final WNode route;
  final Rect bounds;
  final Set<String> selectedNodeIds;
  final String? selectedNodeId;
  final Rect viewportRect;
  final bool isDark;

  _MiniMapPainter({
    required this.route,
    required this.bounds,
    required this.selectedNodeIds,
    required this.selectedNodeId,
    required this.viewportRect,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final contentSize = size.width - 16; // Account for padding
    final scaleX = contentSize / bounds.width;
    final scaleY = contentSize / bounds.height;
    final scale = math.min(scaleX, scaleY);

    final scaledContentWidth = bounds.width * scale;
    final scaledContentHeight = bounds.height * scale;

    // Calculate content offset to center the content
    final offsetX = (size.width - scaledContentWidth) / 2;
    final offsetY = (size.height - scaledContentHeight) / 2;

    // Draw background
    final backgroundPaint =
        Paint()..color = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    // Draw content background
    final contentBackgroundPaint =
        Paint()..color = isDark ? Colors.grey[800]! : Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(offsetX, offsetY, scaledContentWidth, scaledContentHeight),
      contentBackgroundPaint,
    );

    // Draw connections
    for (final node in route.nodes) {
      for (final connection in node.connections) {
        final targetNode = route.nodes.firstWhere(
          (n) => n.id == connection.targetNodeId,
          orElse: () => node,
        );

        final startPos = _toMiniMapPos(
          node.position,
          bounds,
          scale,
          offsetX,
          offsetY,
        );
        final endPos = _toMiniMapPos(
          targetNode.position,
          bounds,
          scale,
          offsetX,
          offsetY,
        );

        final connectionPaint =
            Paint()
              ..color = Colors.grey.withOpacity(0.5)
              ..strokeWidth = 1.0
              ..style = PaintingStyle.stroke;

        canvas.drawLine(startPos, endPos, connectionPaint);
      }
    }

    // Draw nodes
    for (final node in route.nodes) {
      final pos = _toMiniMapPos(node.position, bounds, scale, offsetX, offsetY);

      Paint nodePaint;
      if (selectedNodeId == node.id) {
        nodePaint =
            Paint()
              ..color = Colors.orange
              ..style = PaintingStyle.fill;
      } else if (selectedNodeIds.contains(node.id)) {
        nodePaint =
            Paint()
              ..color = Colors.amber
              ..style = PaintingStyle.fill;
      } else {
        nodePaint =
            Paint()
              ..color =
                  node
                      .color //_getNodeColor(node.color)
              ..style = PaintingStyle.fill;
      }

      // Draw node as a small rectangle
      const nodeSize = 4.0;
      canvas.drawRect(
        Rect.fromCenter(center: pos, width: nodeSize, height: nodeSize),
        nodePaint,
      );

      // Draw node border
      final borderPaint =
          Paint()
            ..color = isDark ? Colors.white : Colors.black
            ..strokeWidth = 0.5
            ..style = PaintingStyle.stroke;

      canvas.drawRect(
        Rect.fromCenter(center: pos, width: nodeSize, height: nodeSize),
        borderPaint,
      );
    }

    // Draw viewport rectangle - FIXED POSITION
    final viewportPaint =
        Paint()
          ..color = Colors.blue.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final viewportBorderPaint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    canvas.drawRect(viewportRect, viewportPaint);
    canvas.drawRect(viewportRect, viewportBorderPaint);
  }

  Offset _toMiniMapPos(
    Offset canvasPos,
    Rect bounds,
    double scale,
    double offsetX,
    double offsetY,
  ) {
    return Offset(
      offsetX + (canvasPos.dx - bounds.left) * scale,
      offsetY + (canvasPos.dy - bounds.top) * scale,
    );
  }

  Color _getNodeColor(String colorString) {
    try {
      // Convert color string to Color object
      final colorValue = int.parse(colorString.replaceAll('#', ''), radix: 16);
      return Color(colorValue | 0xFF000000);
    } catch (e) {
      return Colors.blue; // Default color
    }
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter oldDelegate) {
    return route != oldDelegate.route ||
        bounds != oldDelegate.bounds ||
        selectedNodeIds != oldDelegate.selectedNodeIds ||
        selectedNodeId != oldDelegate.selectedNodeId ||
        viewportRect != oldDelegate.viewportRect ||
        isDark != oldDelegate.isDark;
  }
}

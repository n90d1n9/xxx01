import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../schema/workflow/workflow_edge.dart';
import '../../schema/workflow/workflow_node.dart';
import '../../state/canvas_provider.dart';

class CanvasPainter extends CustomPainter {
  final List<WorkflowNode> nodes;
  final List<WorkflowEdge> edges;
  final List<WorkflowNode> selectedNodes;
  final CanvasState canvasState;
  final Rect? selectionRect;
  final String? connectingFromNode;
  final String? hoveredNodeId;
  final String? hoveredEdgeId;

  CanvasPainter({
    required this.nodes,
    required this.edges,
    required this.selectedNodes,
    required this.canvasState,
    this.selectionRect,
    this.connectingFromNode,
    this.hoveredNodeId,
    this.hoveredEdgeId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stopwatch = Stopwatch()..start();

    // Draw grid
    if (canvasState.showGrid) {
      _drawGrid(canvas, size);
    }

    // Transform canvas for nodes and edges
    canvas.save();
    canvas.translate(canvasState.panOffset.dx, canvasState.panOffset.dy);
    canvas.scale(canvasState.zoom);

    // Draw edges behind nodes
    for (final edge in edges) {
      _drawEdge(canvas, edge);
    }

    // Draw node selection highlights
    for (final node in selectedNodes) {
      _drawNodeSelection(canvas, node);
    }

    canvas.restore();

    // Draw selection rectangle (in screen coordinates)
    if (selectionRect != null) {
      _drawSelectionRect(canvas, selectionRect!);
    }

    debugPrint('CanvasPainter painted in ${stopwatch.elapsedMicroseconds}μs');
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 0.5;

    final gridSize = canvasState.gridSize * canvasState.zoom;
    final offsetX = canvasState.panOffset.dx % gridSize;
    final offsetY = canvasState.panOffset.dy % gridSize;

    // Draw major grid lines every 5 lines
    final majorPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1;

    // Vertical lines
    for (double x = offsetX; x < size.width; x += gridSize) {
      final isMajor = ((x - offsetX) / gridSize) % 5 == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        isMajor ? majorPaint : paint,
      );
    }

    // Horizontal lines
    for (double y = offsetY; y < size.height; y += gridSize) {
      final isMajor = ((y - offsetY) / gridSize) % 5 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isMajor ? majorPaint : paint,
      );
    }
  }

  void _drawEdge(Canvas canvas, WorkflowEdge edge) {
    final sourceNode = nodes.firstWhereOrNull((n) => n.id == edge.source);
    final targetNode = nodes.firstWhereOrNull((n) => n.id == edge.target);

    if (sourceNode == null || targetNode == null) return;

    final isHovered = edge.id == hoveredEdgeId;
    final isHighlighted = canvasState.highlightedEdges.contains(edge.id);

    // Calculate connection points from node centers
    final start = _getNodeConnectionPoint(sourceNode, edge.sourceHandle);
    final end = _getNodeConnectionPoint(targetNode, edge.targetHandle);

    // Special handling for multicast edges
    if (edge.type == EdgeType.multicast) {
      _drawMulticastEdge(canvas, start, end, edge, isHovered, isHighlighted);
      return;
    }

    // Determine edge color and style based on type and channel
    final paint = Paint()
      ..color = _getEdgeColor(edge, isHovered, isHighlighted)
      ..strokeWidth = isHovered ? 3.0 : (isHighlighted ? 2.5 : 2.0)
      ..style = PaintingStyle.stroke;

    if (edge.animated == true) {
      paint.shader = _createAnimatedShader(start, end);
    }

    // Draw edge based on type and channel
    final path = _createEdgePath(start, end, edge);
    canvas.drawPath(path, paint);

    // Draw arrow head
    _drawArrowHead(canvas, path, paint);

    // Draw edge label
    if (edge.label != null && edge.label!.isNotEmpty) {
      _drawEdgeLabel(canvas, edge.label!, path);
    }

    // Draw channel type indicator
    if (edge.channelType != null) {
      _drawChannelIndicator(canvas, path, edge.channelType!);
    }
  }

  void _drawMulticastEdge(
    Canvas canvas,
    Offset start,
    Offset end,
    WorkflowEdge edge,
    bool isHovered,
    bool isHighlighted,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;

    // Calculate normal vector for parallel lines
    final normal = _calculateNormal(Offset(dx, dy)) * 3;

    final mainPaint = Paint()
      ..color = _getEdgeColor(edge, isHovered, isHighlighted)
      ..strokeWidth = isHovered ? 3.0 : (isHighlighted ? 2.5 : 2.0)
      ..style = PaintingStyle.stroke;

    // Draw main curved path
    final mainPath = _createEdgePath(start, end, edge);
    canvas.drawPath(mainPath, mainPaint);

    // Draw parallel lines for multicast effect
    final parallelPaint = Paint()
      ..color = _getEdgeColor(edge, isHovered, isHighlighted)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final parallelPath1 = Path();
    parallelPath1.moveTo(start.dx + normal.dx, start.dy + normal.dy);
    final control1 = Offset(
      start.dx + dx * 0.5 + normal.dx,
      start.dy + normal.dy,
    );
    final control2 = Offset(
      start.dx + dx * 0.5 + normal.dx,
      end.dy + normal.dy,
    );
    parallelPath1.cubicTo(
      control1.dx,
      control1.dy,
      control2.dx,
      control2.dy,
      end.dx + normal.dx,
      end.dy + normal.dy,
    );
    canvas.drawPath(parallelPath1, parallelPaint);

    final parallelPath2 = Path();
    parallelPath2.moveTo(start.dx - normal.dx, start.dy - normal.dy);
    final control3 = Offset(
      start.dx + dx * 0.5 - normal.dx,
      start.dy - normal.dy,
    );
    final control4 = Offset(
      start.dx + dx * 0.5 - normal.dx,
      end.dy - normal.dy,
    );
    parallelPath2.cubicTo(
      control3.dx,
      control3.dy,
      control4.dx,
      control4.dy,
      end.dx - normal.dx,
      end.dy - normal.dy,
    );
    canvas.drawPath(parallelPath2, parallelPaint);

    // Draw arrow head on main path
    _drawArrowHead(canvas, mainPath, mainPaint);

    // Draw edge label
    if (edge.label != null && edge.label!.isNotEmpty) {
      _drawEdgeLabel(canvas, edge.label!, mainPath);
    }
  }

  Offset _calculateNormal(Offset vector) {
    final length = math.sqrt(vector.dx * vector.dx + vector.dy * vector.dy);
    if (length > 0) {
      return Offset(-vector.dy / length, vector.dx / length);
    }
    return Offset.zero;
  }

  Offset _getNodeConnectionPoint(WorkflowNode node, String? handleId) {
    const nodeWidth = 200.0;
    const nodeHeight = 100.0;

    // If no specific handle, use node center
    if (handleId == null) {
      return Offset(
        node.position.x + nodeWidth / 2,
        node.position.y + nodeHeight / 2,
      );
    }

    // TODO: Implement handle-based connection points
    // For now, use node center
    return Offset(
      node.position.x + nodeWidth / 2,
      node.position.y + nodeHeight / 2,
    );
  }

  Color _getEdgeColor(WorkflowEdge edge, bool isHovered, bool isHighlighted) {
    if (isHovered) return Colors.purple;
    if (isHighlighted) return Colors.blue.shade600;

    // Color based on edge type
    switch (edge.type ?? EdgeType.defaultType) {
      case EdgeType.error:
        return Colors.red.shade600;
      case EdgeType.conditional:
        return Colors.orange.shade600;
      case EdgeType.fallback:
        return Colors.yellow.shade700;
      case EdgeType.loop:
        return Colors.green.shade600;
      case EdgeType.wireTap:
        return Colors.purple.shade400;
      case EdgeType.multicast:
        return Colors.cyan.shade600;
      case EdgeType.dataFlow:
        return Colors.blue.shade700;
      case EdgeType.straight:
        return Colors.grey.shade600;
      case EdgeType.defaultType:
      default:
        // Color based on channel type if no specific edge type
        return _getChannelColor(edge.channelType);
    }
  }

  Color _getChannelColor(ChannelType? channelType) {
    switch (channelType) {
      case ChannelType.queue:
        return Colors.orange.shade500;
      case ChannelType.topic:
        return Colors.purple.shade500;
      case ChannelType.pubsub:
        return Colors.green.shade500;
      case ChannelType.requestReply:
        return Colors.blue.shade500;
      case ChannelType.direct:
      default:
        return Colors.blue.shade400;
    }
  }

  Shader? _createAnimatedShader(Offset start, Offset end) {
    // Create a simple gradient for animated edges
    return LinearGradient(
      colors: [
        Colors.blue.shade400,
        Colors.blue.shade200,
        Colors.blue.shade400,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromPoints(start, end));
  }

  Path _createEdgePath(Offset start, Offset end, WorkflowEdge edge) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;

    // Create path based on edge type
    switch (edge.type ?? EdgeType.defaultType) {
      case EdgeType.straight:
        path.lineTo(end.dx, end.dy);
        break;

      case EdgeType.loop:
        // Create a loopback path for cycles
        final control1 = Offset(start.dx + dx * 0.5, start.dy - 80);
        final control2 = Offset(start.dx + dx * 0.5, end.dy - 80);
        path.cubicTo(
          control1.dx,
          control1.dy,
          control2.dx,
          control2.dy,
          end.dx,
          end.dy,
        );
        break;

      case EdgeType.conditional:
        // Zig-zag path for conditional edges
        final midX = start.dx + dx * 0.5;
        final midY = start.dy + dy * 0.5;
        path.lineTo(midX - 20, midY - 20);
        path.lineTo(midX + 20, midY + 20);
        path.lineTo(end.dx, end.dy);
        break;

      case EdgeType.wireTap:
        // Dashed line for wire tap pattern
        final distance = math.sqrt(dx * dx + dy * dy);
        final dashLength = 8.0;
        final dashGap = 4.0;
        final totalLength = dashLength + dashGap;

        for (double i = 0; i < distance; i += totalLength) {
          final ratio = i / distance;
          final x = start.dx + dx * ratio;
          final y = start.dy + dy * ratio;

          if (i + dashLength <= distance) {
            final endRatio = (i + dashLength) / distance;
            final endX = start.dx + dx * endRatio;
            final endY = start.dy + dy * endRatio;
            path.lineTo(endX, endY);
          } else {
            path.lineTo(end.dx, end.dy);
          }

          if (i + totalLength < distance) {
            final gapRatio = (i + totalLength) / distance;
            final gapX = start.dx + dx * gapRatio;
            final gapY = start.dy + dy * gapRatio;
            path.moveTo(gapX, gapY);
          }
        }
        break;

      case EdgeType.multicast:
        // For multicast, we'll create a simple bold line
        // The parallel lines will be drawn separately in the main paint method
        final control1 = Offset(start.dx + dx * 0.5, start.dy);
        final control2 = Offset(start.dx + dx * 0.5, end.dy);
        path.cubicTo(
          control1.dx,
          control1.dy,
          control2.dx,
          control2.dy,
          end.dx,
          end.dy,
        );
        break;

      default:
        // Default curved path for most edges
        final control1 = Offset(start.dx + dx * 0.5, start.dy);
        final control2 = Offset(start.dx + dx * 0.5, end.dy);
        path.cubicTo(
          control1.dx,
          control1.dy,
          control2.dx,
          control2.dy,
          end.dx,
          end.dy,
        );
    }

    return path;
  }

  void _drawArrowHead(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics().first;
    final length = metrics.length;

    // Don't draw arrow if the path is too short
    if (length < 20) return;

    final tangent = metrics.getTangentForOffset(length - 15);

    if (tangent != null) {
      final arrowSize = 8.0;
      final angle = math.atan2(tangent.vector.dy, tangent.vector.dx);

      final arrowPath = Path();
      arrowPath.moveTo(tangent.position.dx, tangent.position.dy);
      arrowPath.lineTo(
        tangent.position.dx - arrowSize * math.cos(angle - math.pi / 6),
        tangent.position.dy - arrowSize * math.sin(angle - math.pi / 6),
      );
      arrowPath.moveTo(tangent.position.dx, tangent.position.dy);
      arrowPath.lineTo(
        tangent.position.dx - arrowSize * math.cos(angle + math.pi / 6),
        tangent.position.dy - arrowSize * math.sin(angle + math.pi / 6),
      );

      canvas.drawPath(arrowPath, paint);
    }
  }

  void _drawEdgeLabel(Canvas canvas, String label, Path path) {
    final metrics = path.computeMetrics().first;
    final tangent = metrics.getTangentForOffset(metrics.length * 0.5);

    if (tangent != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            backgroundColor: Colors.white.withOpacity(0.9),
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      final textOffset =
          tangent.position -
          Offset(textPainter.width / 2, textPainter.height / 2);

      // Draw background
      final backgroundRect = Rect.fromLTWH(
        textOffset.dx - 2,
        textOffset.dy - 1,
        textPainter.width + 4,
        textPainter.height + 2,
      );
      final backgroundPaint = Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.fill;
      canvas.drawRect(backgroundRect, backgroundPaint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.grey.withOpacity(0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawRect(backgroundRect, borderPaint);

      textPainter.paint(canvas, textOffset);
    }
  }

  void _drawChannelIndicator(
    Canvas canvas,
    Path path,
    ChannelType channelType,
  ) {
    final metrics = path.computeMetrics().first;
    final tangent = metrics.getTangentForOffset(metrics.length * 0.7);

    if (tangent != null) {
      final indicatorColor = _getChannelColor(channelType);
      final paint = Paint()
        ..color = indicatorColor
        ..style = PaintingStyle.fill;

      // Different shapes for different channel types
      switch (channelType) {
        case ChannelType.queue:
          canvas.drawRect(
            Rect.fromCircle(center: tangent.position, radius: 3),
            paint,
          );
          break;
        case ChannelType.topic:
          canvas.drawCircle(tangent.position, 4, paint);
          break;
        case ChannelType.pubsub:
          final starPath = _createStarPath(tangent.position, 4);
          canvas.drawPath(starPath, paint);
          break;
        case ChannelType.requestReply:
          canvas.drawCircle(tangent.position, 3, paint);
          final borderPaint = Paint()
            ..color = Colors.white
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;
          canvas.drawCircle(tangent.position, 3, borderPaint);
          break;
        default:
          canvas.drawCircle(tangent.position, 3, paint);
      }
    }
  }

  Path _createStarPath(Offset center, double size) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = i * 4 * math.pi / 5;
      final x = center.dx + size * math.sin(angle);
      final y = center.dy + size * math.cos(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _drawNodeSelection(Canvas canvas, WorkflowNode node) {
    const nodeWidth = 200.0;
    const nodeHeight = 100.0;

    final selectionRect = Rect.fromCenter(
      center: Offset(
        node.position.x + nodeWidth / 2,
        node.position.y + nodeHeight / 2,
      ),
      width: nodeWidth + 8,
      height: nodeHeight + 8,
    );

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRect(selectionRect, paint);
    canvas.drawRect(selectionRect, borderPaint);
  }

  void _drawSelectionRect(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    // Draw selection corners
    final cornerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    const cornerSize = 6.0;
    canvas.drawCircle(rect.topLeft, cornerSize, cornerPaint);
    canvas.drawCircle(rect.topRight, cornerSize, cornerPaint);
    canvas.drawCircle(rect.bottomLeft, cornerSize, cornerPaint);
    canvas.drawCircle(rect.bottomRight, cornerSize, cornerPaint);
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return oldDelegate.nodes.length != nodes.length ||
        oldDelegate.edges.length != edges.length ||
        oldDelegate.selectedNodes.length != selectedNodes.length ||
        oldDelegate.canvasState != canvasState ||
        oldDelegate.selectionRect != selectionRect ||
        oldDelegate.connectingFromNode != connectingFromNode ||
        oldDelegate.hoveredNodeId != hoveredNodeId ||
        oldDelegate.hoveredEdgeId != hoveredEdgeId;
  }
}

extension OffsetExtension on Offset {
  Offset get normalized {
    final length = distance;
    return length > 0 ? this / length : this;
  }
}

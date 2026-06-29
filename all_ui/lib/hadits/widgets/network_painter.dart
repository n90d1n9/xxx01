import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/line.dart';
import '../models/network_mode.dart';

class EnhancedNetworkPainter extends CustomPainter {
  final List<NetworkNode> nodes;
  final double zoom;
  final Offset offset;
  final Set<String> collapsedNodes;
  final String? selectedNode;
  final String? hoveredNode;
  final double animation;
  final double pulseAnimation;
  final bool is3D;
  final double rotationX;
  final double rotationY;

  EnhancedNetworkPainter({
    required this.nodes,
    required this.zoom,
    required this.offset,
    required this.collapsedNodes,
    required this.selectedNode,
    required this.hoveredNode,
    required this.animation,
    required this.pulseAnimation,
    required this.is3D,
    required this.rotationX,
    required this.rotationY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final transform =
        Matrix4.identity()
          ..translate(size.width / 2 + offset.dx, size.height / 2 + offset.dy)
          ..scale(zoom);

    if (is3D) {
      transform
        ..rotateX(rotationX)
        ..rotateY(rotationY);
    }

    canvas.save();
    canvas.transform(transform.storage);

    // Draw connections
    for (final node in nodes) {
      if (collapsedNodes.contains(node.id)) continue;

      for (final targetId in node.connectedTo) {
        final target = nodes.firstWhereOrNull((n) => n.id == targetId);
        if (target != null && !collapsedNodes.contains(targetId)) {
          _drawConnection(canvas, node, target);
        }
      }
    }

    // Draw nodes
    for (final node in nodes) {
      if (collapsedNodes.contains(node.id)) continue;
      _drawNode(canvas, node);
    }

    canvas.restore();
  }

  void _drawConnection(Canvas canvas, NetworkNode from, NetworkNode to) {
    final isConnected =
        from.id == selectedNode ||
        to.id == selectedNode ||
        from.id == hoveredNode ||
        to.id == hoveredNode;

    final paint =
        Paint()
          ..strokeWidth = isConnected ? 3.0 : 2.0
          ..style = PaintingStyle.stroke;

    final grade = from.grade?.toLowerCase() ?? '';
    final color = _getGradeColor(grade);
    final style = _getLineStyle(grade);

    paint.color = color.withOpacity(isConnected ? 0.9 : 0.5 * animation);

    final path =
        Path()
          ..moveTo(from.position.dx, from.position.dy)
          ..lineTo(to.position.dx, to.position.dy);

    if (style == LineStyle.dashed) {
      _drawDashedPath(canvas, path, paint, dashLength: 10, gapLength: 5);
    } else if (style == LineStyle.dotted) {
      _drawDashedPath(canvas, path, paint, dashLength: 3, gapLength: 3);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawNode(Canvas canvas, NetworkNode node) {
    final isSelected = selectedNode == node.id;
    final isHovered = hoveredNode == node.id;
    final scale = isSelected || isHovered ? pulseAnimation : 1.0;

    final size = _getNodeSize(node.type);
    final width = size.width * scale * animation;
    final height = size.height * scale * animation;

    // Shadow for depth
    if (isHovered || isSelected) {
      final shadowPaint =
          Paint()
            ..color = Colors.black.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final shadowRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: node.position + const Offset(4, 4),
          width: width,
          height: height,
        ),
        Radius.circular(node.type == 'prophet' ? 30 : 12),
      );
      canvas.drawRRect(shadowRect, shadowPaint);
    }

    // Node background
    final bgPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = _getNodeColor(node);

    final rect = Rect.fromCenter(
      center: node.position,
      width: width,
      height: height,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(node.type == 'prophet' ? 30 : 12),
    );

    // Gradient for depth
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_getNodeColor(node), _getNodeColor(node).withOpacity(0.7)],
    );

    bgPaint.shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, bgPaint);

    // Border
    final borderPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth =
              isSelected
                  ? 4.0
                  : isHovered
                  ? 3.0
                  : 2.0
          ..color =
              isSelected
                  ? Colors.amber
                  : isHovered
                  ? Colors.white
                  : Colors.white.withOpacity(0.5);

    canvas.drawRRect(rrect, borderPaint);

    // Icon for node type
    if (node.type == 'prophet') {
      _drawIcon(canvas, node.position, Icons.star, Colors.white, 24);
    } else if (node.type == 'companion') {
      _drawIcon(canvas, node.position, Icons.person, Colors.white, 20);
    } else {
      _drawIcon(canvas, node.position, Icons.description, Colors.white, 18);
    }

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: node.type == 'prophet' ? 12 : 10,
          fontWeight:
              node.type == 'prophet' ? FontWeight.bold : FontWeight.w600,
          shadows: [
            const Shadow(
              color: Colors.black54,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: width - 8);
    textPainter.paint(
      canvas,
      node.position - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Pulse ring for selected node
    if (isSelected) {
      final pulsePaint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.amber.withOpacity(0.5 * pulseAnimation);

      final pulseRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: node.position,
          width: width * (1 + pulseAnimation * 0.3),
          height: height * (1 + pulseAnimation * 0.3),
        ),
        Radius.circular(node.type == 'prophet' ? 35 : 15),
      );

      canvas.drawRRect(pulseRect, pulsePaint);
    }
  }

  void _drawIcon(
    Canvas canvas,
    Offset center,
    IconData icon,
    Color color,
    double size,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final metrics = path.computeMetrics().first;
    var distance = 0.0;

    while (distance < metrics.length) {
      final start = metrics.getTangentForOffset(distance);
      final end = metrics.getTangentForOffset(distance + dashLength);

      if (start != null && end != null) {
        canvas.drawLine(start.position, end.position, paint);
      }

      distance += dashLength + gapLength;
    }
  }

  Size _getNodeSize(String type) {
    switch (type) {
      case 'prophet':
        return const Size(120, 60);
      case 'companion':
        return const Size(100, 50);
      case 'hadith':
        return const Size(90, 45);
      default:
        return const Size(80, 40);
    }
  }

  Color _getNodeColor(NetworkNode node) {
    if (node.type == 'prophet') return Colors.purple.shade700;
    if (node.type == 'companion') return Colors.teal.shade600;
    return _getGradeColor(node.grade?.toLowerCase() ?? '');
  }

  Color _getGradeColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'mutawatir':
        return Colors.green.shade700;
      case 'sahih':
        return Colors.blue.shade700;
      case 'hasan':
        return Colors.orange.shade700;
      case 'daif':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  LineStyle _getLineStyle(String grade) {
    switch (grade.toLowerCase()) {
      case 'mutawatir':
      case 'sahih':
        return LineStyle.solid;
      case 'hasan':
        return LineStyle.dashed;
      case 'daif':
        return LineStyle.dotted;
      default:
        return LineStyle.solid;
    }
  }

  @override
  bool shouldRepaint(EnhancedNetworkPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
        oldDelegate.offset != offset ||
        oldDelegate.selectedNode != selectedNode ||
        oldDelegate.hoveredNode != hoveredNode ||
        oldDelegate.animation != animation ||
        oldDelegate.pulseAnimation != pulseAnimation ||
        oldDelegate.is3D != is3D ||
        oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY ||
        !setEquals(oldDelegate.collapsedNodes, collapsedNodes);
  }
}

// Add this helper extension at the end
extension on Set<String> {
  bool setEquals(Set<String> other) {
    if (length != other.length) return false;
    return every(other.contains);
  }
}

// Helper function for min
int min(int a, int b) => a < b ? a : b;

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../models/line.dart';
import '../models/network_mode.dart';

class NetworkGraphPainter extends CustomPainter {
  final List<NetworkNode> nodes;
  final double zoom;
  final Offset offset;
  final Set<String> collapsedNodes;
  final String? selectedNode;
  final double animation;
  final Function(String) onNodeTap;

  NetworkGraphPainter({
    required this.nodes,
    required this.zoom,
    required this.offset,
    required this.collapsedNodes,
    required this.selectedNode,
    required this.animation,
    required this.onNodeTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final transform =
        Matrix4.identity()
          ..translate(size.width / 2 + offset.dx, size.height / 2 + offset.dy)
          ..scale(zoom);

    canvas.save();
    canvas.transform(transform.storage);

    // Draw connections first (so they appear behind nodes)
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
    final paint =
        Paint()
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    // Determine color and style based on hadith grade
    final grade = from.grade?.toLowerCase() ?? '';
    final color = _getGradeColor(grade);
    final style = _getLineStyle(grade);

    paint.color = color.withOpacity(0.6 * animation);

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

  void _drawNode(Canvas canvas, NetworkNode node) {
    final isSelected = selectedNode == node.id;
    final scale = isSelected ? 1.2 : 1.0;
    final radius =
        (node.type == 'prophet'
            ? 40.0
            : node.type == 'companion'
            ? 30.0
            : 25.0) *
        scale *
        animation;

    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = _getNodeColor(node);

    final borderPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 3.0 : 2.0
          ..color = isSelected ? Colors.amber : Colors.white;

    // Draw node shape
    if (node.type == 'prophet') {
      _drawStar(canvas, node.position, radius, paint);
      _drawStar(canvas, node.position, radius, borderPaint);
    } else if (node.type == 'hadith') {
      canvas.drawCircle(node.position, radius, paint);
      canvas.drawCircle(node.position, radius, borderPaint);
    } else {
      canvas.drawCircle(node.position, radius, paint);
      canvas.drawCircle(node.position, radius, borderPaint);
    }

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: node.type == 'prophet' ? 14 : 11,
          fontWeight:
              node.type == 'prophet' ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      node.position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const points = 5;
    const angle = 3.14159 * 2 / points;
    final path = Path();

    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius / 2;
      final x = center.dx + r * cos(i * angle - 3.14159 / 2);
      final y = center.dy + r * sin(i * angle - 3.14159 / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  Color _getNodeColor(NetworkNode node) {
    if (node.type == 'prophet') return Colors.purple;
    if (node.type == 'companion') return Colors.teal;
    return _getGradeColor(node.grade?.toLowerCase() ?? '');
  }

  Color _getGradeColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'mutawatir':
        return Colors.green;
      case 'sahih':
        return Colors.blue;
      case 'hasan':
        return Colors.orange;
      case 'daif':
        return Colors.red;
      default:
        return Colors.grey;
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
  bool shouldRepaint(NetworkGraphPainter oldDelegate) => true;
}

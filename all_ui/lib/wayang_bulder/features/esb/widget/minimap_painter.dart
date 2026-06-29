import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/connection.dart';
import '../model/integration_component.dart';

class MinimapPainter extends CustomPainter {
  final List<IntegrationComponent> components;
  final List<Connection> connections;

  MinimapPainter(this.components, this.connections);

  @override
  void paint(Canvas canvas, Size size) {
    if (components.isEmpty) return;

    // Calculate bounds
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;

    for (final comp in components) {
      minX = math.min(minX, comp.position.dx);
      minY = math.min(minY, comp.position.dy);
      maxX = math.max(maxX, comp.position.dx + 180);
      maxY = math.max(maxY, comp.position.dy + 80);
    }

    final width = maxX - minX;
    final height = maxY - minY;
    final scale = math.min(size.width / width, size.height / height) * 0.9;

    // Draw connections
    final connPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;

    for (final conn in connections) {
      try {
        final from = components.firstWhere((c) => c.id == conn.fromId);
        final to = components.firstWhere((c) => c.id == conn.toId);

        final start = Offset(
          (from.position.dx - minX) * scale + 10,
          (from.position.dy - minY) * scale + 10,
        );
        final end = Offset(
          (to.position.dx - minX) * scale + 10,
          (to.position.dy - minY) * scale + 10,
        );

        canvas.drawLine(start, end, connPaint);
      } catch (e) {
        // Skip if component not found
      }
    }

    // Draw components
    for (final comp in components) {
      final rect = Rect.fromLTWH(
        (comp.position.dx - minX) * scale + 10,
        (comp.position.dy - minY) * scale + 10,
        180 * scale,
        80 * scale,
      );

      final paint = Paint()..color = Colors.blue[300]!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

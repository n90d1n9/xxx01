import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/models/task_model.dart';

class DependencyArrow {
  final Offset from;
  final Offset to;
  final bool isCritical;
  final DependencyType type;
  const DependencyArrow({
    required this.from,
    required this.to,
    this.isCritical = false,
    this.type = DependencyType.fs,
  });
}

class DependencyArrowPainter extends CustomPainter {
  final List<DependencyArrow> arrows;
  const DependencyArrowPainter({required this.arrows});

  @override
  void paint(Canvas canvas, Size size) {
    for (final arrow in arrows) {
      final color = arrow.isCritical
          ? const Color(0xFFEF4444)
          : const Color(0xFF6366F1);

      final strokePaint = Paint()
        ..color = color.withOpacity(0.65)
        ..strokeWidth = arrow.isCritical ? 1.5 : 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final arrowPaint = Paint()
        ..color = color.withOpacity(0.9)
        ..style = PaintingStyle.fill;

      final path = _buildPath(arrow.from, arrow.to);
      canvas.drawPath(path, strokePaint);
      _drawArrowhead(canvas, path, arrowPaint);
    }
  }

  Path _buildPath(Offset from, Offset to) {
    final path = Path();
    final deltaX = to.dx - from.dx;

    path.moveTo(from.dx, from.dy);

    if (deltaX < 20) {
      // Tight space — route around with an S-curve
      final stepOut = 14.0;
      final midY = (from.dy + to.dy) / 2;
      path.lineTo(from.dx + stepOut, from.dy);
      path.quadraticBezierTo(from.dx + stepOut + 10, from.dy, from.dx + stepOut + 10, midY);
      path.quadraticBezierTo(to.dx - stepOut - 10, to.dy, to.dx - stepOut, to.dy);
      path.lineTo(to.dx, to.dy);
    } else {
      // Standard S-curve connecting the two rows
      final midX = from.dx + deltaX * 0.5;
      path.cubicTo(midX, from.dy, midX, to.dy, to.dx, to.dy);
    }

    return path;
  }

  void _drawArrowhead(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics().last;
    if (metrics.length < 1) return;

    final tangent = metrics.getTangentForOffset(metrics.length);
    if (tangent == null) return;

    final tip = tangent.position;
    final angle = tangent.angle; // angle in radians of the path at this point
    const arrowSize = 6.0;

    // Build a small triangle pointing in the direction of travel
    final arrowPath = Path();
    arrowPath.moveTo(tip.dx, tip.dy);
    arrowPath.lineTo(
      tip.dx - arrowSize * math.cos(angle - 0.4),
      tip.dy - arrowSize * math.sin(angle - 0.4),
    );
    arrowPath.lineTo(
      tip.dx - arrowSize * math.cos(angle + 0.4),
      tip.dy - arrowSize * math.sin(angle + 0.4),
    );
    arrowPath.close();
    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(DependencyArrowPainter old) => old.arrows != arrows;
}

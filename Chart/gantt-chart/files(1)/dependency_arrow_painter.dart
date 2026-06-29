import 'package:flutter/material.dart';
import '../../shared/theme/gantt_theme.dart';

class DependencyArrow {
  final Offset from; // right edge of predecessor bar
  final Offset to;   // left edge of successor bar
  final bool isCritical;

  const DependencyArrow({
    required this.from,
    required this.to,
    this.isCritical = false,
  });
}

/// Paints dependency arrows between tasks as orthogonal lines with arrowheads.
class DependencyArrowPainter extends CustomPainter {
  final List<DependencyArrow> arrows;

  DependencyArrowPainter({required this.arrows});

  @override
  void paint(Canvas canvas, Size size) {
    for (final arrow in arrows) {
      _drawArrow(canvas, arrow);
    }
  }

  void _drawArrow(Canvas canvas, DependencyArrow arrow) {
    final color = arrow.isCritical
        ? GanttTheme.danger.withOpacity(0.8)
        : GanttTheme.textMuted.withOpacity(0.6);

    final paint = Paint()
      ..color = color
      ..strokeWidth = arrow.isCritical ? 1.5 : 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final from = arrow.from;
    final to = arrow.to;

    // Build orthogonal path:
    // from → right bend → down/up → left bend → to
    final path = Path();
    path.moveTo(from.dx, from.dy);

    const cornerRadius = 4.0;
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final goRight = dx > 0;

    if (goRight) {
      // Simple L-shape (normal case)
      final midX = from.dx + dx / 2;
      path.lineTo(midX - cornerRadius, from.dy);
      path.quadraticBezierTo(midX, from.dy, midX, from.dy + (dy > 0 ? cornerRadius : -cornerRadius));
      path.lineTo(midX, to.dy + (dy > 0 ? -cornerRadius : cornerRadius));
      path.quadraticBezierTo(midX, to.dy, midX + cornerRadius, to.dy);
      path.lineTo(to.dx - 6, to.dy);
    } else {
      // Backward arrow (loop around)
      const offset = 16.0;
      final rightX = from.dx + offset;
      path.lineTo(rightX - cornerRadius, from.dy);
      path.quadraticBezierTo(rightX, from.dy, rightX, from.dy + (dy > 0 ? cornerRadius : -cornerRadius));
      path.lineTo(rightX, to.dy + (dy > 0 ? -cornerRadius : cornerRadius));
      path.quadraticBezierTo(rightX, to.dy, rightX - cornerRadius, to.dy);
      path.lineTo(to.dx - 6, to.dy);
    }

    canvas.drawPath(path, paint);
    _drawArrowHead(canvas, to, paint);
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Paint paint) {
    final headPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    const size = 5.0;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - size, tip.dy - size / 2)
      ..lineTo(tip.dx - size, tip.dy + size / 2)
      ..close();
    canvas.drawPath(path, headPaint);
  }

  @override
  bool shouldRepaint(DependencyArrowPainter old) => old.arrows != arrows;
}

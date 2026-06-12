
// Custom painter for dependency lines
import 'package:flutter/material.dart';

class DependencyLinePainter extends CustomPainter {
  final Offset startPoint;
  final List<Offset> endPoints;
  final Color color;

  DependencyLinePainter({
    required this.startPoint,
    required this.endPoints,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var endPoint in endPoints) {
      final path = Path();
      path.moveTo(startPoint.dx, startPoint.dy);
      
      // Create a curved path between start and end points
      path.cubicTo(
        startPoint.dx + 50, startPoint.dy,
        endPoint.dx - 50, endPoint.dy,
        endPoint.dx, endPoint.dy
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
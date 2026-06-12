
// Custom Painters and Widgets
import 'package:flutter/material.dart';

class MilestonePainter extends CustomPainter {
  final Color color;
  final double position;

  MilestonePainter({super.repaint, required this.color, required this.position});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(position, 0)
      ..lineTo(position + 10, 10)
      ..lineTo(position, 20)
      ..lineTo(position - 10, 10)
      ..close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(MilestonePainter oldDelegate) =>
      color != oldDelegate.color || position != oldDelegate.position;
}

class DependencyLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  DependencyLinePainter({super.repaint, required this.start, required this.end, required Offset startPoint, required List endPoints, required Color color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + 50, start.dy,
        end.dx - 50, end.dy,
        end.dx, end.dy,
      );
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(DependencyLinePainter oldDelegate) =>
      start != oldDelegate.start || end != oldDelegate.end;
}

import 'package:flutter/material.dart';

class LoadBalancerConnectionPainter extends CustomPainter {
  final String algorithm;

  LoadBalancerConnectionPainter({required this.algorithm});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw lines from client to load balancer
    final Paint clientPaint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(64, size.height / 2),
      Offset(size.width / 2 - 40, size.height / 2),
      clientPaint,
    );

    // Draw connection lines based on algorithm
    final count = 4;
    final spacing = size.height / (count + 1);

    for (int i = 0; i < count; i++) {
      final isActive = i != 3; // Last server is inactive

      if (!isActive) continue;

      final color = _getConnectionColor(i);
      double lineWeight = 2.0;

      // Change line weight for weighted algorithms
      if (algorithm.contains('Weighted') && i == 1) {
        lineWeight = 3.5;
      }

      // Change line weight for least connections
      if (algorithm.contains('Least')) {
        lineWeight = 2.0 + (3 - i) * 0.5;
      }

      final Paint serverPaint =
          Paint()
            ..color = color
            ..strokeWidth = lineWeight
            ..style = PaintingStyle.stroke;

      if (algorithm.contains('Hashing')) {
        // For consistent hashing, draw curved lines
        final path = Path();
        final controlPoint1 = Offset(
          size.width / 2 + 40,
          size.height / 2 - 20 + i * 20,
        );
        final controlPoint2 = Offset(size.width - 100, spacing * (i + 1));

        path.moveTo(size.width / 2 + 40, size.height / 2);
        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          size.width - 74,
          spacing * (i + 1),
        );

        canvas.drawPath(path, serverPaint);
      } else {
        // For other algorithms, draw straight lines
        canvas.drawLine(
          Offset(size.width / 2 + 40, size.height / 2),
          Offset(size.width - 74, spacing * (i + 1)),
          serverPaint,
        );
      }
    }
  }

  Color _getConnectionColor(int index) {
    switch (index) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

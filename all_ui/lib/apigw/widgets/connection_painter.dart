import 'package:flutter/material.dart';

class ConnectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.5)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    final dashPaint =
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.5)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    // Client to Gateway lines
    final clientX = 64;
    final gatewayX = size.width / 2;
    final clientY1 = size.height / 2 - 60;
    final clientY2 = size.height / 2;
    final clientY3 = size.height / 2 + 60;

    // Draw dashed lines from clients to gateway
    _drawDashedLine(
      canvas,
      Offset(clientX + 40, clientY1),
      Offset(gatewayX - 80, size.height / 2 - 50),
      dashPaint,
    );

    _drawDashedLine(
      canvas,
      Offset(clientX + 40, clientY2),
      Offset(gatewayX - 80, size.height / 2),
      dashPaint,
    );

    _drawDashedLine(
      canvas,
      Offset(clientX + 40, clientY3),
      Offset(gatewayX - 80, size.height / 2 + 50),
      dashPaint,
    );

    // Gateway to Services lines
    final serviceX = size.width - 145;
    final serviceY1 = size.height / 2 - 100;
    final serviceY2 = size.height / 2;
    final serviceY3 = size.height / 2 + 100;

    // Draw dashed lines from gateway to services
    _drawDashedLine(
      canvas,
      Offset(gatewayX + 80, size.height / 2 - 50),
      Offset(serviceX, serviceY1),
      dashPaint,
    );

    _drawDashedLine(
      canvas,
      Offset(gatewayX + 80, size.height / 2),
      Offset(serviceX, serviceY2),
      dashPaint,
    );

    _drawDashedLine(
      canvas,
      Offset(gatewayX + 80, size.height / 2 + 50),
      Offset(serviceX, serviceY3),
      dashPaint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path =
        Path()
          ..moveTo(start.dx, start.dy)
          ..lineTo(end.dx, end.dy);

    const dashWidth = 4.0;
    const dashSpace = 4.0;

    final distances = <double>[dashWidth, dashSpace];
    canvas.drawPath(dashPath(path, distances), paint);
  }

  Path dashPath(Path path, List<double> dashArray) {
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      var distance = 0.0;
      var draw = true;
      var index = 0;

      while (distance < pathMetric.length) {
        final dash = dashArray[index % dashArray.length];
        final next = distance + dash;

        if (draw) {
          dashPath.addPath(pathMetric.extractPath(distance, next), Offset.zero);
        }

        distance = next;
        draw = !draw;
        index++;
      }
    }

    return dashPath;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

class FaceOverlayPainter extends CustomPainter {
  final Rect faceRect;

  FaceOverlayPainter(this.faceRect);

  @override
  void paint(Canvas canvas, Size size) {
    // Scale face rect to canvas size
    final scaledRect = Rect.fromLTRB(
      faceRect.left * size.width,
      faceRect.top * size.height,
      faceRect.right * size.width,
      faceRect.bottom * size.height,
    );

    // Draw face rectangle
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(scaledRect, paint);

    // Draw landmarks (simplified)
    final landmarkPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    // Eye positions (estimated)
    final leftEye = Offset(
      scaledRect.left + scaledRect.width * 0.3,
      scaledRect.top + scaledRect.height * 0.4,
    );
    final rightEye = Offset(
      scaledRect.left + scaledRect.width * 0.7,
      scaledRect.top + scaledRect.height * 0.4,
    );

    canvas.drawCircle(leftEye, 3, landmarkPaint);
    canvas.drawCircle(rightEye, 3, landmarkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';

import '../schema/layer/designer_layer.dart';

class TimelineTrackPainter extends CustomPainter {
  final DesignerLayer layer;
  final double duration;
  final double currentTime;

  TimelineTrackPainter(this.layer, this.duration, this.currentTime);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw keyframes
    for (var keyframe in layer.keyframes) {
      final x = (keyframe.time / duration) * size.width;

      final paint =
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, size.height / 2), 4, paint);
    }

    // Draw current time indicator
    final currentX = (currentTime / duration) * size.width;
    final indicatorPaint =
        Paint()
          ..color = Colors.red.withOpacity(0.3)
          ..strokeWidth = 2;

    canvas.drawLine(
      Offset(currentX, 0),
      Offset(currentX, size.height),
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(TimelineTrackPainter oldDelegate) {
    return oldDelegate.currentTime != currentTime ||
        oldDelegate.duration != duration ||
        oldDelegate.layer != layer;
  }
}

import 'package:flutter/material.dart';

import '../models/auth_status.dart';

class EnhancedFaceOverlayPainter extends CustomPainter {
  final double pulseScale;
  final AuthStatus status;
  final double? confidence;

  EnhancedFaceOverlayPainter({
    required this.pulseScale,
    required this.status,
    this.confidence,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.25;
    final radius = baseRadius * pulseScale;

    // Main circle
    final mainPaint = Paint()
      ..color = _getStatusColor().withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, mainPaint);

    // Pulse effect
    final pulsePaint = Paint()
      ..color = _getStatusColor().withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius * 1.2, pulsePaint);

    // Corner brackets
    _drawCornerBrackets(canvas, center, radius);

    // Status indicator
    _drawStatusIndicator(canvas, center, radius);

    // Confidence meter
    if (confidence != null) {
      _drawConfidenceMeter(canvas, center, radius, confidence!);
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case AuthStatus.authenticated:
        return Colors.green;
      case AuthStatus.authenticating:
        return Colors.orange;
      case AuthStatus.failed:
      case AuthStatus.locked:
        return Colors.red;
      case AuthStatus.ready:
        return Colors.blue;
      default:
        return Colors.white;
    }
  }

  void _drawCornerBrackets(Canvas canvas, Offset center, double radius) {
    final bracketSize = radius * 0.3;
    final bracketPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
      Offset(center.dx - radius, center.dy - radius + bracketSize),
      Offset(center.dx - radius, center.dy - radius),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy - radius),
      Offset(center.dx - radius + bracketSize, center.dy - radius),
      bracketPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(center.dx + radius - bracketSize, center.dy - radius),
      Offset(center.dx + radius, center.dy - radius),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius, center.dy - radius),
      Offset(center.dx + radius, center.dy - radius + bracketSize),
      bracketPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(center.dx - radius, center.dy + radius - bracketSize),
      Offset(center.dx - radius, center.dy + radius),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy + radius),
      Offset(center.dx - radius + bracketSize, center.dy + radius),
      bracketPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(center.dx + radius - bracketSize, center.dy + radius),
      Offset(center.dx + radius, center.dy + radius),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius, center.dy + radius),
      Offset(center.dx + radius, center.dy + radius - bracketSize),
      bracketPaint,
    );
  }

  void _drawStatusIndicator(Canvas canvas, Offset center, double radius) {
    final indicatorPaint = Paint()
      ..color = _getStatusColor()
      ..style = PaintingStyle.fill;

    switch (status) {
      case AuthStatus.authenticated:
        // Checkmark
        final path = Path()
          ..moveTo(center.dx - radius * 0.2, center.dy)
          ..lineTo(center.dx - radius * 0.05, center.dy + radius * 0.15)
          ..lineTo(center.dx + radius * 0.25, center.dy - radius * 0.15);
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round,
        );
        break;
      case AuthStatus.authenticating:
        // Scanning animation
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.3),
          -0.5,
          2.0,
          false,
          indicatorPaint,
        );
        break;
      case AuthStatus.failed:
      case AuthStatus.locked:
        // X mark
        canvas.drawLine(
          Offset(center.dx - radius * 0.2, center.dy - radius * 0.2),
          Offset(center.dx + radius * 0.2, center.dy + radius * 0.2),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          Offset(center.dx + radius * 0.2, center.dy - radius * 0.2),
          Offset(center.dx - radius * 0.2, center.dy + radius * 0.2),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round,
        );
        break;
      default:
        // Face icon
        canvas.drawCircle(center, radius * 0.15, indicatorPaint);
        canvas.drawCircle(
          Offset(center.dx - radius * 0.1, center.dy - radius * 0.05),
          radius * 0.03,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          Offset(center.dx + radius * 0.1, center.dy - radius * 0.05),
          radius * 0.03,
          Paint()..color = Colors.white,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + radius * 0.05),
            width: radius * 0.3,
            height: radius * 0.2,
          ),
          0.2,
          2.8,
          false,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
    }
  }

  void _drawConfidenceMeter(
    Canvas canvas,
    Offset center,
    double radius,
    double confidence,
  ) {
    final meterWidth = radius * 0.8;
    final meterHeight = 8.0;
    final meterY = center.dy + radius * 0.6;

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, meterY),
          width: meterWidth,
          height: meterHeight,
        ),
        Radius.circular(meterHeight / 2),
      ),
      Paint()..color = Colors.white.withOpacity(0.3),
    );

    // Progress
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            center.dx - meterWidth / 2 + (meterWidth * confidence) / 2,
            meterY,
          ),
          width: meterWidth * confidence,
          height: meterHeight,
        ),
        Radius.circular(meterHeight / 2),
      ),
      Paint()..color = _getConfidenceColor(confidence),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.green;
    if (confidence > 0.6) return Colors.lightGreen;
    if (confidence > 0.4) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(covariant EnhancedFaceOverlayPainter oldDelegate) {
    return oldDelegate.pulseScale != pulseScale ||
        oldDelegate.status != status ||
        oldDelegate.confidence != confidence;
  }
}

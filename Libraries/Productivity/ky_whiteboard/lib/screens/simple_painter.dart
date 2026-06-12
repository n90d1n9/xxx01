import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/drawing_path.dart';
import '../models/laser_point.dart';
import '../models/user.dart';
import '../models/whiteboard_image.dart';

class SimpleWhiteboardPainter extends CustomPainter {
  final List<DrawingPath> paths;
  final Map<String, User> activeUsers;
  final Set<String> selectedPathIds;
  final bool isGridVisible;
  final Map<String, WhiteboardImage> images;
  final String? selectedImageId;
  final Uint8List? backgroundImage;
  final List<LaserPoint> laserPoints;
  final bool showTouchIndicators;

  SimpleWhiteboardPainter({
    required this.paths,
    required this.activeUsers,
    required this.selectedPathIds,
    required this.isGridVisible,
    this.images = const {},
    this.selectedImageId,
    this.backgroundImage,
    this.laserPoints = const [],
    this.showTouchIndicators = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    _drawBackground(canvas, size);

    // Draw grid
    if (isGridVisible) {
      _drawGrid(canvas, size);
    }

    // Draw all paths
    for (final path in paths) {
      _drawPath(canvas, path);
    }

    // Draw selection highlights
    for (final path in paths) {
      if (selectedPathIds.contains(path.id)) {
        _drawSelection(canvas, path);
      }
    }

    // Draw images
    for (var image in images.values) {
      _drawImage(canvas, image);
      if (image.id == selectedImageId) {
        _drawImageSelection(canvas, image);
      }
    }

    // Draw laser points
    if (laserPoints.isNotEmpty) {
      _drawLaserPoints(canvas);
    }

    // Draw user cursors
    _drawUserCursors(canvas);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFFF8F9FA);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..strokeWidth = 1;

    const gridSize = 50.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawPath(Canvas canvas, DrawingPath path) {
    if (path.points.isEmpty) return;

    if (path.points.length == 1) {
      // Draw single point
      canvas.drawCircle(
        path.points.first.point,
        path.points.first.paint.strokeWidth / 2,
        path.points.first.paint,
      );
      return;
    }

    // Draw connected path
    final drawPath = Path();
    drawPath.moveTo(path.points.first.point.dx, path.points.first.point.dy);

    for (int i = 1; i < path.points.length; i++) {
      drawPath.lineTo(path.points[i].point.dx, path.points[i].point.dy);
    }

    canvas.drawPath(drawPath, path.points.first.paint);
  }

  void _drawSelection(Canvas canvas, DrawingPath path) {
    if (path.points.isEmpty) return;

    // Calculate bounds
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final point in path.points) {
      minX = math.min(minX, point.point.dx);
      maxX = math.max(maxX, point.point.dx);
      minY = math.min(minY, point.point.dy);
      maxY = math.max(maxY, point.point.dy);
    }

    const padding = 8.0;
    final rect = Rect.fromLTRB(
      minX - padding,
      minY - padding,
      maxX + padding,
      maxY + padding,
    );

    final selectionPaint =
        Paint()
          ..color = const Color(0xFF3B82F6).withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawRect(rect, selectionPaint);
  }

  void _drawImage(Canvas canvas, WhiteboardImage image) {
    // Implement image drawing
  }

  void _drawImageSelection(Canvas canvas, WhiteboardImage image) {
    // Implement image selection drawing
  }

  void _drawLaserPoints(Canvas canvas) {
    if (laserPoints.isEmpty) return;

    final paint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(laserPoints.first.point.dx, laserPoints.first.point.dy);

    for (int i = 1; i < laserPoints.length; i++) {
      path.lineTo(laserPoints[i].point.dx, laserPoints[i].point.dy);
    }

    canvas.drawPath(path, paint);

    // Draw laser dot
    final dotPaint =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill;

    canvas.drawCircle(laserPoints.last.point, 5, dotPaint);
  }

  void _drawUserCursors(Canvas canvas) {
    for (var user in activeUsers.values) {
      if (user.cursorPosition != null && user.isActive) {
        final cursorPaint =
            Paint()
              ..color = user.cursorColor
              ..style = PaintingStyle.fill;

        final cursorPath =
            Path()
              ..moveTo(user.cursorPosition!.dx, user.cursorPosition!.dy)
              ..lineTo(user.cursorPosition!.dx, user.cursorPosition!.dy + 20)
              ..lineTo(
                user.cursorPosition!.dx + 5,
                user.cursorPosition!.dy + 15,
              )
              ..lineTo(
                user.cursorPosition!.dx + 10,
                user.cursorPosition!.dy + 18,
              )
              ..lineTo(
                user.cursorPosition!.dx + 12,
                user.cursorPosition!.dy + 13,
              )
              ..lineTo(
                user.cursorPosition!.dx + 15,
                user.cursorPosition!.dy + 15,
              )
              ..lineTo(user.cursorPosition!.dx + 8, user.cursorPosition!.dy + 8)
              ..close();

        canvas.drawPath(cursorPath, cursorPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SimpleWhiteboardPainter oldDelegate) {
    return paths != oldDelegate.paths ||
        selectedPathIds != oldDelegate.selectedPathIds ||
        isGridVisible != oldDelegate.isGridVisible ||
        images != oldDelegate.images ||
        laserPoints != oldDelegate.laserPoints ||
        activeUsers != oldDelegate.activeUsers ||
        showTouchIndicators != oldDelegate.showTouchIndicators;
  }
}

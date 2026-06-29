import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'drawing_tool.dart';
import 'shape_fill_style.dart';
import 'line_style.dart';
import 'laser_point.dart';
import 'whiteboard_image.dart';
import 'drawing_path.dart';
import 'user.dart';

class WhiteboardPainter extends CustomPainter {
  final List<DrawingPath> paths;
  final Map<String, User> activeUsers;
  final double zoom;
  final Offset panOffset;
  final Set<String> selectedPathIds;
  final bool isGridVisible;
  final Map<String, WhiteboardImage> images;
  final String? selectedImageId;
  final Uint8List? backgroundImage;
  final List<LaserPoint> laserPoints;
  final bool showTouchIndicators;

  WhiteboardPainter({
    required this.paths,
    required this.activeUsers,
    required this.zoom,
    required this.panOffset,
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
    // Apply zoom and pan transformations
    canvas.save();
    canvas.translate(panOffset.dx, panOffset.dy);
    canvas.scale(zoom);

    // Draw background (in world coordinates)
    _drawBackground(canvas, size);

    // Draw grid (in world coordinates)
    if (isGridVisible) {
      _drawGrid(canvas, size);
    }

    // Draw all paths (they are stored in world coordinates)
    for (final path in paths) {
      _drawPath(canvas, path);
    }

    // Draw selection highlights
    for (final path in paths) {
      if (selectedPathIds.contains(path.id)) {
        _drawSelection(canvas, path);
      }
    }

    // Draw images (in world coordinates)
    for (var image in images.values) {
      _drawImage(canvas, image);
      if (image.id == selectedImageId) {
        _drawImageSelection(canvas, image);
      }
    }

    // Draw laser points (in world coordinates)
    if (laserPoints.isNotEmpty) {
      _drawLaserPoints(canvas);
    }

    canvas.restore();

    // Draw user cursors (in screen coordinates - after restore)
    _drawUserCursors(canvas);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFFF8F9FA);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width / zoom, size.height / zoom),
      backgroundPaint,
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..strokeWidth = 1;

    const gridSize = 50.0;
    final worldWidth = size.width / zoom;
    final worldHeight = size.height / zoom;

    for (double x = 0; x < worldWidth; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, worldHeight), paint);
    }
    for (double y = 0; y < worldHeight; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(worldWidth, y), paint);
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

    // Calculate bounds in world coordinates
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
    // Implement image drawing in world coordinates
  }

  void _drawImageSelection(Canvas canvas, WhiteboardImage image) {
    // Implement image selection drawing in world coordinates
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
    // User cursors are drawn in screen coordinates (after canvas.restore())
    for (var user in activeUsers.values) {
      if (user.cursorPosition != null && user.isActive) {
        // cursorPosition is already in screen coordinates
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
  bool shouldRepaint(covariant WhiteboardPainter oldDelegate) {
    return paths != oldDelegate.paths ||
        zoom != oldDelegate.zoom ||
        panOffset != oldDelegate.panOffset ||
        selectedPathIds != oldDelegate.selectedPathIds ||
        isGridVisible != oldDelegate.isGridVisible ||
        images != oldDelegate.images ||
        laserPoints != oldDelegate.laserPoints ||
        activeUsers != oldDelegate.activeUsers ||
        showTouchIndicators != oldDelegate.showTouchIndicators;
  }
}

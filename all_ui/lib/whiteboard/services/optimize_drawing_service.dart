// Create an optimized Drawing Service
import 'package:flutter/material.dart';

import '../models/drawing_path.dart';
import '../models/drawing_point.dart';
import '../models/drawing_tool.dart';
import '../models/line_style.dart';
import '../models/shape_fill_style.dart';

class OptimizedDrawingService {
  DrawingPath? _currentPath;
  Offset? _lastPoint;
  static const double _minDistance = 2.0; // Minimum distance between points

  DrawingPath? get currentPath => _currentPath;

  DrawingPath createNewPath({
    required Offset point,
    required String userId,
    required DrawingTool tool,
    required Color color,
    required double strokeWidth,
    required double opacity,
    required ShapeFillStyle fillStyle,
    required Color? fillColor,
    required LineStyle lineStyle,
    double pressure = 1.0,
  }) {
    _lastPoint = point;

    final adjustedStrokeWidth = strokeWidth * pressure;
    final paint =
        Paint()
          ..color =
              tool == DrawingTool.eraser
                  ? Colors.white
                  : _getColorForTool(color, opacity, tool)
          ..strokeWidth =
              tool == DrawingTool.highlighter
                  ? adjustedStrokeWidth * 3
                  : adjustedStrokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true;

    return DrawingPath(
      points: [
        DrawingPoint(
          point: point,
          paint: paint,
          userId: userId,
          timestamp: DateTime.now(),
          pressure: pressure,
        ),
      ],
      id: '${userId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      tool: tool,
      fillStyle: fillStyle,
      fillColor: fillColor,
      lineStyle: lineStyle,
      opacity: opacity,
    );
  }

  Color _getColorForTool(Color color, double opacity, DrawingTool tool) {
    switch (tool) {
      case DrawingTool.highlighter:
        return color.withOpacity(0.3 * opacity);
      case DrawingTool.eraser:
        return Colors.white;
      default:
        return color.withOpacity(opacity);
    }
  }

  bool shouldAddPoint(Offset newPoint) {
    if (_lastPoint == null) return true;

    final distance = (_lastPoint! - newPoint).distance;
    return distance >= _minDistance;
  }

  DrawingPath updatePathWithNewPoint(
    DrawingPath path,
    Offset point,
    String userId, {
    double pressure = 1.0,
  }) {
    if (!shouldAddPoint(point)) {
      return path;
    }

    _lastPoint = point;

    final newPoint = DrawingPoint(
      point: point,
      paint: path.points.first.paint, // Reuse the same paint object
      userId: userId,
      timestamp: DateTime.now(),
      pressure: pressure,
    );

    return path.copyWith(points: [...path.points, newPoint]);
  }

  DrawingPath updateShapePath(
    DrawingPath path,
    Offset point,
    String userId, {
    double pressure = 1.0,
  }) {
    final newPoint = DrawingPoint(
      point: point,
      paint: path.points.first.paint,
      userId: userId,
      timestamp: DateTime.now(),
      pressure: pressure,
    );

    return path.copyWith(points: [path.points.first, newPoint]);
  }

  void setCurrentPath(DrawingPath? path) {
    _currentPath = path;
    _lastPoint = path?.points.lastOrNull?.point;
  }

  void reset() {
    _currentPath = null;
    _lastPoint = null;
  }
}

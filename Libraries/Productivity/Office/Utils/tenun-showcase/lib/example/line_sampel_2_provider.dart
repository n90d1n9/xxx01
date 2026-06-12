import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'line_sampel_2_models.dart';

// Chart state provider
class LineChartProvider extends ChangeNotifier {
  TooltipData? _tooltipData;
  bool _isLoading = false;
  String? _error;
  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;

  // Data optimization
  List<ChartSeries> _originalSeries = [];
  List<ChartSeries> _optimizedSeries = [];
  ChartBounds? _dataBounds;

  // Getters
  TooltipData? get tooltipData => _tooltipData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get zoomLevel => _zoomLevel;
  Offset get panOffset => _panOffset;
  List<ChartSeries> get optimizedSeries => _optimizedSeries;
  ChartBounds? get dataBounds => _dataBounds;

  void setData(List<ChartSeries> series) {
    _isLoading = true;
    notifyListeners();

    try {
      _originalSeries = series;
      _calculateBounds();
      _optimizeData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void showTooltip(TooltipData tooltipData) {
    _tooltipData = tooltipData;
    notifyListeners();
  }

  void hideTooltip() {
    if (_tooltipData != null) {
      _tooltipData = null;
      notifyListeners();
    }
  }

  void updateZoom(double zoom, Offset focalPoint) {
    _zoomLevel = math.max(0.5, math.min(5.0, zoom));
    _optimizeData();
    notifyListeners();
  }

  void updatePan(Offset delta) {
    _panOffset += delta;
    _optimizeData();
    notifyListeners();
  }

  void resetZoomAndPan() {
    _zoomLevel = 1.0;
    _panOffset = Offset.zero;
    _optimizeData();
    notifyListeners();
  }

  void _calculateBounds() {
    if (_originalSeries.isEmpty) return;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final series in _originalSeries) {
      for (final point in series.points) {
        minX = math.min(minX, point.x);
        maxX = math.max(maxX, point.x);
        minY = math.min(minY, point.y);
        maxY = math.max(maxY, point.y);
      }
    }

    final xPadding = (maxX - minX) * 0.05;
    final yPadding = (maxY - minY) * 0.1;

    _dataBounds = ChartBounds(
      minX: minX - xPadding,
      maxX: maxX + xPadding,
      minY: minY - yPadding,
      maxY: maxY + yPadding,
    );
  }

  void _optimizeData() {
    if (_originalSeries.isEmpty || _dataBounds == null) return;

    _optimizedSeries = _originalSeries.map((series) {
      List<ChartPoint> optimizedPoints = _optimizeSeriesPoints(series.points);
      return ChartSeries(
        name: series.name,
        points: optimizedPoints,
        color: series.color,
        strokeWidth: series.strokeWidth,
        showPoints: series.showPoints,
        fill: series.fill,
      );
    }).toList();
  }

  List<ChartPoint> _optimizeSeriesPoints(List<ChartPoint> points) {
    if (points.length <= 100) return points;

    // Calculate visible range based on zoom and pan
    final bounds = _dataBounds!;
    final visibleWidth = (bounds.maxX - bounds.minX) / _zoomLevel;
    final visibleHeight = (bounds.maxY - bounds.minY) / _zoomLevel;

    final centerX =
        bounds.minX + (bounds.maxX - bounds.minX) / 2 + _panOffset.dx;
    final centerY =
        bounds.minY + (bounds.maxY - bounds.minY) / 2 + _panOffset.dy;

    final visibleMinX = centerX - visibleWidth / 2;
    final visibleMaxX = centerX + visibleWidth / 2;
    final visibleMinY = centerY - visibleHeight / 2;
    final visibleMaxY = centerY + visibleHeight / 2;

    // Filter points within visible area with some buffer
    final buffer = visibleWidth * 0.1;
    final visiblePoints = points
        .where(
          (point) =>
              point.x >= visibleMinX - buffer &&
              point.x <= visibleMaxX + buffer &&
              point.y >= visibleMinY - buffer &&
              point.y <= visibleMaxY + buffer,
        )
        .toList();

    // Apply Douglas-Peucker algorithm for line simplification
    if (visiblePoints.length > 500) {
      return _douglasPeucker(visiblePoints, _calculateTolerance(visiblePoints));
    }

    return visiblePoints;
  }

  double _calculateTolerance(List<ChartPoint> points) {
    if (points.isEmpty) return 0.0;

    double maxDistance = 0;
    for (int i = 1; i < points.length; i++) {
      final distance = math.sqrt(
        math.pow(points[i].x - points[i - 1].x, 2) +
            math.pow(points[i].y - points[i - 1].y, 2),
      );
      maxDistance = math.max(maxDistance, distance);
    }
    return maxDistance * 0.01; // 1% tolerance
  }

  List<ChartPoint> _douglasPeucker(List<ChartPoint> points, double tolerance) {
    if (points.length <= 2) return points;

    double maxDistance = 0;
    int maxIndex = 0;

    final start = points.first;
    final end = points.last;

    for (int i = 1; i < points.length - 1; i++) {
      final distance = _perpendicularDistance(points[i], start, end);
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }

    if (maxDistance > tolerance) {
      final leftPoints = _douglasPeucker(
        points.sublist(0, maxIndex + 1),
        tolerance,
      );
      final rightPoints = _douglasPeucker(points.sublist(maxIndex), tolerance);

      return [...leftPoints.sublist(0, leftPoints.length - 1), ...rightPoints];
    } else {
      return [start, end];
    }
  }

  double _perpendicularDistance(
    ChartPoint point,
    ChartPoint lineStart,
    ChartPoint lineEnd,
  ) {
    final A = lineEnd.y - lineStart.y;
    final B = lineStart.x - lineEnd.x;
    final C = lineEnd.x * lineStart.y - lineStart.x * lineEnd.y;

    return (A * point.x + B * point.y + C).abs() / math.sqrt(A * A + B * B);
  }
}

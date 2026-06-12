import 'package:flutter/material.dart';

import 'line_sampel_2_models.dart';

// Enhanced tooltip handling with gesture detection
class TooltipDetector {
  static TooltipData? detectNearestPoint({
    required Offset tapPosition,
    required List<ChartSeries> series,
    required Rect chartArea,
    required ChartBounds bounds,
    required double tolerance,
  }) {
    if ((bounds.maxX - bounds.minX).abs() < 1e-6 ||
        (bounds.maxY - bounds.minY).abs() < 1e-6) {
      return null;
    }

    double minDistance = double.infinity;
    TooltipData? bestTooltip;

    for (final s in series) {
      for (final p in s.points) {
        final screenX =
            chartArea.left +
            ((p.x - bounds.minX) / (bounds.maxX - bounds.minX)) *
                chartArea.width;
        final screenY =
            chartArea.bottom -
            ((p.y - bounds.minY) / (bounds.maxY - bounds.minY)) *
                chartArea.height;
        final distance = (tapPosition - Offset(screenX, screenY)).distance;
        if (distance < minDistance) {
          minDistance = distance;
          bestTooltip = TooltipData(
            point: p,
            seriesName: s.name,
            seriesColor: s.color,
            position: Offset(screenX, screenY),
            distance: distance,
          );
        }
      }
    }

    if (minDistance <= tolerance) {
      return bestTooltip;
    }
    return null;
  }

  static List<TooltipData>? detectNearestXGroup({
    required Offset tapPosition,
    required List<ChartSeries> series,
    required Rect chartArea,
    required ChartBounds bounds,
    required double tolerance,
  }) {
    double minDistance = double.infinity;
    double? bestX;
    for (final s in series) {
      for (final p in s.points) {
        final screenX =
            chartArea.left +
            ((p.x - bounds.minX) / (bounds.maxX - bounds.minX)) *
                chartArea.width;
        final d = (tapPosition.dx - screenX).abs();
        if (d < minDistance) {
          minDistance = d;
          bestX = p.x;
        }
      }
    }

    if (minDistance > tolerance || bestX == null) return null;

    final tooltips = <TooltipData>[];
    for (final s in series) {
      final match = s.points.where((p) => p.x == bestX).toList();
      if (match.isNotEmpty) {
        final p = match.first;
        final screenX =
            chartArea.left +
            ((p.x - bounds.minX) / (bounds.maxX - bounds.minX)) *
                chartArea.width;
        final screenY =
            chartArea.bottom -
            ((p.y - bounds.minY) / (bounds.maxY - bounds.minY)) *
                chartArea.height;
        tooltips.add(
          TooltipData(
            point: p,
            seriesName: s.name,
            seriesColor: s.color,
            position: Offset(screenX, screenY),
          ),
        );
      }
    }

    return tooltips;
  }
}

import 'package:flutter/material.dart';

import 'line_sampel_2_models.dart';

// Memory-efficient data structure for large datasets
class DataWindow {
  final int maxSize;
  final List<ChartPoint> _points = [];

  DataWindow(this.maxSize);

  void addPoint(ChartPoint point) {
    _points.add(point);
    if (_points.length > maxSize) {
      _points.removeAt(0); // Remove oldest point
    }
  }

  List<ChartPoint> get points => List.unmodifiable(_points);

  void clear() {
    _points.clear();
  }
}

// Utility class for performance monitoring
class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};

  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  static void stopTimer(String name) {
    final timer = _timers[name];
    if (timer != null) {
      timer.stop();
      debugPrint('$name: ${timer.elapsedMilliseconds}ms');
      _timers.remove(name);
    }
  }
}

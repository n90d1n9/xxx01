import 'package:flutter/material.dart';

class MotionPathData {
  Path path;
  double duration;
  bool autoRotate;

  MotionPathData({
    required this.path,
    required this.duration,
    this.autoRotate = false,
  });

  Offset getPositionAt(double t) {
    final metrics = path.computeMetrics().first;
    final distance = metrics.length * t;
    final tangent = metrics.getTangentForOffset(distance);
    return tangent?.position ?? Offset.zero;
  }

  double getRotationAt(double t) {
    final metrics = path.computeMetrics().first;
    final distance = metrics.length * t;
    final tangent = metrics.getTangentForOffset(distance);
    return tangent?.angle ?? 0;
  }
}

import 'package:flutter/widgets.dart';

class MotionPathAnimator {
  final Path path;
  final Duration duration;

  MotionPathAnimator({required this.path, required this.duration});

  Offset getPositionAtTime(double t) {
    final metrics = path.computeMetrics().first;
    final length = metrics.length;
    final distance = length * t;
    final tangent = metrics.getTangentForOffset(distance);
    return tangent?.position ?? Offset.zero;
  }

  double getRotationAtTime(double t) {
    final metrics = path.computeMetrics().first;
    final length = metrics.length;
    final distance = length * t;
    final tangent = metrics.getTangentForOffset(distance);
    return tangent?.angle ?? 0;
  }
}

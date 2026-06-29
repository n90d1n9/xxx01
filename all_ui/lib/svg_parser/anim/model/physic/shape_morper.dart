import 'package:flutter/material.dart';

class ShapeMorpher {
  static Path morph(Path from, Path to, double t) {
    final fromMetrics = from.computeMetrics().first;
    final toMetrics = to.computeMetrics().first;

    final result = Path();
    final numSamples = 100;

    for (var i = 0; i <= numSamples; i++) {
      final progress = i / numSamples;

      final fromPos =
          fromMetrics
              .getTangentForOffset(fromMetrics.length * progress)
              ?.position;
      final toPos =
          toMetrics.getTangentForOffset(toMetrics.length * progress)?.position;

      if (fromPos != null && toPos != null) {
        final interpolated = Offset.lerp(fromPos, toPos, t)!;

        if (i == 0) {
          result.moveTo(interpolated.dx, interpolated.dy);
        } else {
          result.lineTo(interpolated.dx, interpolated.dy);
        }
      }
    }

    return result;
  }
}

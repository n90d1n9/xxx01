import 'package:flutter/material.dart';

import 'color_stop.dart';

enum GradientType { linear, radial, sweep }

class GradientData {
  GradientType type;
  List<ColorStop> stops;

  GradientData({required this.type, required this.stops});

  Gradient toGradient() {
    final colors = stops.map((s) => s.color).toList();
    final offsets = stops.map((s) => s.offset).toList();

    switch (type) {
      case GradientType.linear:
        return LinearGradient(colors: colors, stops: offsets);
      case GradientType.radial:
        return RadialGradient(colors: colors, stops: offsets);
      case GradientType.sweep:
        return SweepGradient(colors: colors, stops: offsets);
    }
  }
}

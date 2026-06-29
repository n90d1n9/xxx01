import 'package:flutter/material.dart';

import '../models/filter.dart';
import '../models/gradient_stop.dart';
import '../models/svg_definition.dart';
import '../models/svg_linear_gradient.dart';
import '../models/svg_radial_gradient.dart';

extension SvgDefinitionFactory on SvgDefinition {
  /// Create a linear gradient from simple parameters
  static SvgLinearGradient linearGradient({
    required String id,
    required List<Color> colors,
    List<double>? stops,
    Alignment begin = Alignment.centerLeft,
    Alignment end = Alignment.centerRight,
  }) {
    final gradientStops = <GradientStop>[];

    for (var i = 0; i < colors.length; i++) {
      final offset = stops != null ? stops[i] : i / (colors.length - 1);
      gradientStops.add(GradientStop(offset: offset, color: colors[i]));
    }

    return SvgLinearGradient(
      id: id,
      x1: (begin.x + 1) / 2,
      y1: (begin.y + 1) / 2,
      x2: (end.x + 1) / 2,
      y2: (end.y + 1) / 2,
      stops: gradientStops,
    );
  }

  /// Create a radial gradient from simple parameters
  static SvgRadialGradient radialGradient({
    required String id,
    required List<Color> colors,
    List<double>? stops,
    Alignment center = Alignment.center,
    double radius = 0.5,
  }) {
    final gradientStops = <GradientStop>[];

    for (var i = 0; i < colors.length; i++) {
      final offset = stops != null ? stops[i] : i / (colors.length - 1);
      gradientStops.add(GradientStop(offset: offset, color: colors[i]));
    }

    return SvgRadialGradient(
      id: id,
      cx: (center.x + 1) / 2,
      cy: (center.y + 1) / 2,
      r: radius,
      stops: gradientStops,
    );
  }

  /// Create a blur filter
  static SvgFilter blurFilter({required String id, required double amount}) {
    return SvgFilter(
      id: id,
      primitives: [FeGaussianBlur(stdDeviation: amount)],
    );
  }

  /// Create a drop shadow filter
  static SvgFilter dropShadowFilter({
    required String id,
    double dx = 2,
    double dy = 2,
    double blur = 3,
    Color color = Colors.black,
    double opacity = 0.5,
  }) {
    return SvgFilter(
      id: id,
      primitives: [
        FeDropShadow(
          dx: dx,
          dy: dy,
          stdDeviation: blur,
          floodColor: color,
          floodOpacity: opacity,
        ),
      ],
    );
  }

  /// Create a glow filter
  static SvgFilter glowFilter({
    required String id,
    double blur = 5,
    Color color = Colors.white,
  }) {
    return SvgFilter(
      id: id,
      primitives: [
        FeGaussianBlur(stdDeviation: blur),
        FeColorMatrix(
          type: 'matrix',
          values:
              '0 0 0 0 ${color.red / 255} '
              '0 0 0 0 ${color.green / 255} '
              '0 0 0 0 ${color.blue / 255} '
              '0 0 0 1 0',
        ),
        FeBlend(mode: 'screen', in1: 'SourceGraphic'),
      ],
    );
  }
}

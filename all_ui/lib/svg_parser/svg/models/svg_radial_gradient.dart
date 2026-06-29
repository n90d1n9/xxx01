import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'gradient_stop.dart';
import 'svg_definition.dart';

/// Radial gradient definition
class SvgRadialGradient extends SvgDefinition {
  final double cx, cy, r;
  final double? fx, fy;
  final List<GradientStop> stops;
  final String gradientUnits;
  final Matrix4? gradientTransform;

  SvgRadialGradient({
    required String id,
    required this.cx,
    required this.cy,
    required this.r,
    this.fx,
    this.fy,
    required this.stops,
    this.gradientUnits = 'objectBoundingBox',
    this.gradientTransform,
  }) : super(id);

  /// Creates a Flutter Gradient from this radial gradient
  ui.Gradient createGradient(Rect bounds) {
    Offset center;
    double radius;

    if (gradientUnits == 'objectBoundingBox') {
      center = Offset(
        bounds.left + bounds.width * cx,
        bounds.top + bounds.height * cy,
      );
      radius = math.max(bounds.width, bounds.height) * r;
    } else {
      center = Offset(cx, cy);
      radius = r;
    }

    final focal =
        fx != null && fy != null
            ? Offset(
              bounds.left + bounds.width * fx!,
              bounds.top + bounds.height * fy!,
            )
            : center;

    return ui.Gradient.radial(
      center,
      radius,
      stops.map((s) => s.color).toList(),
      stops.map((s) => s.offset).toList(),
    );
  }

  @override
  String toString() => 'SvgRadialGradient(id: $id, stops: ${stops.length})';
}

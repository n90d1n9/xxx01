import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

import 'gradient_stop.dart';
import 'svg_definition.dart';

/// Linear gradient definition
class SvgLinearGradient extends SvgDefinition {
  final double x1, y1, x2, y2;
  final List<GradientStop> stops;
  final String gradientUnits;
  final Matrix4? gradientTransform;

  SvgLinearGradient({
    required String id,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.stops,
    this.gradientUnits = 'objectBoundingBox',
    this.gradientTransform,
  }) : super(id);

  /// Creates a Flutter Gradient from this linear gradient
  ui.Gradient createGradient(Rect bounds) {
    Offset begin, end;

    if (gradientUnits == 'objectBoundingBox') {
      begin = Offset(
        bounds.left + bounds.width * x1,
        bounds.top + bounds.height * y1,
      );
      end = Offset(
        bounds.left + bounds.width * x2,
        bounds.top + bounds.height * y2,
      );
    } else {
      begin = Offset(x1, y1);
      end = Offset(x2, y2);
    }

    return ui.Gradient.linear(
      begin,
      end,
      stops.map((s) => s.color).toList(),
      stops.map((s) => s.offset).toList(),
    );
  }

  @override
  String toString() => 'SvgLinearGradient(id: $id, stops: ${stops.length})';
}

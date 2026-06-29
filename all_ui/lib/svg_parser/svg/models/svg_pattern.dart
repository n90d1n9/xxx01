import 'package:flutter/widgets.dart';

import 'svg_definition.dart';

/// Pattern definition for tiled backgrounds
class SvgPattern extends SvgDefinition {
  final double x, y, width, height;
  final String patternUnits;
  final Matrix4? patternTransform;
  final List<dynamic> elements; // List of SvgElement

  SvgPattern({
    required String id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.patternUnits = 'objectBoundingBox',
    this.patternTransform,
    required this.elements,
  }) : super(id);

  @override
  String toString() => 'SvgPattern(id: $id, ${width}x$height)';
}

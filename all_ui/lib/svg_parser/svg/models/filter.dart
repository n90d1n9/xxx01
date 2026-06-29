import 'package:flutter/material.dart';

import 'filter_primitive.dart';
import 'svg_definition.dart';

/// Gaussian blur filter primitive
class FeGaussianBlur extends FilterPrimitive {
  final double stdDeviation;

  FeGaussianBlur({required this.stdDeviation, super.input, super.result});

  @override
  String toString() => 'FeGaussianBlur(stdDev: $stdDeviation)';
}

/// Drop shadow filter primitive
class FeDropShadow extends FilterPrimitive {
  final double dx, dy, stdDeviation;
  final Color? floodColor;
  final double floodOpacity;

  FeDropShadow({
    required this.dx,
    required this.dy,
    required this.stdDeviation,
    this.floodColor,
    this.floodOpacity = 1.0,
  }) : super();

  @override
  String toString() => 'FeDropShadow(dx: $dx, dy: $dy, blur: $stdDeviation)';
}

/// Offset filter primitive
class FeOffset extends FilterPrimitive {
  final double dx, dy;

  FeOffset({required this.dx, required this.dy, String? input, String? result})
    : super(input: input, result: result);

  @override
  String toString() => 'FeOffset(dx: $dx, dy: $dy)';
}

/// Color matrix filter primitive
class FeColorMatrix extends FilterPrimitive {
  final String type;
  final String? values;

  FeColorMatrix({
    required this.type,
    this.values,
    String? input,
    String? result,
  }) : super(input: input, result: result);

  @override
  String toString() => 'FeColorMatrix(type: $type)';
}

/// Blend filter primitive
class FeBlend extends FilterPrimitive {
  final String mode;
  final String? in1, in2;

  FeBlend({required this.mode, this.in1, this.in2, String? result})
    : super(result: result);

  @override
  String toString() => 'FeBlend(mode: $mode)';
}

/// Composite filter primitive (Porter-Duff operations)
class FeComposite extends FilterPrimitive {
  final String operator;
  final String? in1, in2;
  final double? k1, k2, k3, k4;

  FeComposite({
    required this.operator,
    this.in1,
    this.in2,
    this.k1,
    this.k2,
    this.k3,
    this.k4,
    String? result,
  }) : super(result: result);

  @override
  String toString() => 'FeComposite(operator: $operator)';
}

/// Morphology filter primitive (erode/dilate)
class FeMorphology extends FilterPrimitive {
  final String operator;
  final double radius;

  FeMorphology({
    required this.operator,
    required this.radius,
    String? input,
    String? result,
  }) : super(input: input, result: result);

  @override
  String toString() => 'FeMorphology(operator: $operator, radius: $radius)';
}

/// Turbulence filter primitive (noise generation)
class FeTurbulence extends FilterPrimitive {
  final String type;
  final double baseFrequency;
  final int numOctaves;
  final double seed;
  final bool stitchTiles;

  FeTurbulence({
    required this.type,
    required this.baseFrequency,
    this.numOctaves = 1,
    this.seed = 0,
    this.stitchTiles = false,
    String? result,
  }) : super(result: result);

  @override
  String toString() => 'FeTurbulence(type: $type, freq: $baseFrequency)';
}

/// Displacement map filter primitive
class FeDisplacementMap extends FilterPrimitive {
  final String? in2;
  final double scale;
  final String xChannelSelector;
  final String yChannelSelector;

  FeDisplacementMap({
    String? input,
    this.in2,
    required this.scale,
    this.xChannelSelector = 'A',
    this.yChannelSelector = 'A',
    String? result,
  }) : super(input: input, result: result);

  @override
  String toString() => 'FeDisplacementMap(scale: $scale)';
}

/// Filter definition containing multiple primitives
class SvgFilter extends SvgDefinition {
  final List<FilterPrimitive> primitives;

  SvgFilter({required String id, required this.primitives}) : super(id);

  @override
  String toString() => 'SvgFilter(id: $id, primitives: ${primitives.length})';
}

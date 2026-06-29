import 'package:flutter/material.dart';

/// Represents a gradient stop with color and offset
class GradientStop {
  final double offset;
  final Color color;

  GradientStop({required this.offset, required this.color});

  @override
  String toString() => 'GradientStop(offset: $offset, color: $color)';
}

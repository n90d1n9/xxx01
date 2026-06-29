import 'package:flutter/material.dart';

class GradientAnimation {
  final List<Color> colors;
  final double duration;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  GradientAnimation({
    required this.colors,
    this.duration = 3.0,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });
}

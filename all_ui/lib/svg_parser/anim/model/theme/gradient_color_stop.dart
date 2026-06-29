import 'package:flutter/material.dart';

enum GradientType { linear, radial, sweep }

class GradientColorStop {
  double offset;
  Color color;

  GradientColorStop({required this.offset, required this.color});
}

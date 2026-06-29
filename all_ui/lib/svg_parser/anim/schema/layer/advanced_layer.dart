import 'package:flutter/material.dart';

import '../path/bezier_path_data.dart';
import '../theme/gradient_data.dart';
import 'layer.dart';

class AdvancedLayer {
  String id;
  String name;
  LayerType type;
  Offset position;
  Size size;
  Color color;
  double rotation;
  double scale;
  double opacity;
  BezierPathData? bezierPath;
  GradientData? gradient;

  AdvancedLayer({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    required this.size,
    required this.color,
    this.rotation = 0,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.bezierPath,
    this.gradient,
  });
}

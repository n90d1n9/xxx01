import 'package:flutter/material.dart';

class NeumorphismStyle {
  final Color baseColor;
  final double depth;
  final bool isPressed;
  final double borderRadius;

  NeumorphismStyle({
    required this.baseColor,
    this.depth = 10,
    this.isPressed = false,
    this.borderRadius = 16,
  });
}

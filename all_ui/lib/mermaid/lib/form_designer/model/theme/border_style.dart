import 'package:flutter/material.dart';

class BorderStyles {
  final double radius;
  final double width;
  final BorderStyle style;

  const BorderStyles({
    required this.radius,
    required this.width,
    required this.style,
  });

  Map<String, dynamic> toJson() {
    return {'radius': radius, 'width': width, 'style': style.toString()};
  }
}

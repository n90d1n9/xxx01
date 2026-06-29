import 'package:flutter/material.dart';

class NodeStyle {
  final Color color;
  final Color borderColor;
  final double width;
  final double height;
  final FontStyle? fontStyle;
  final PortStyle? portStyle;

  const NodeStyle({
    this.color = Colors.white,
    this.borderColor = const Color(0xFF35A5F4),
    this.width = 10,
    this.height = 10,
    this.fontStyle,
    this.portStyle,
  });
}

class PortStyle {
  final double width;
  final double height;
  final Color borderColor;
  final Color color;
  final Color strokeColor;
  final Color labelColor;
  final Color iconColor;

  const PortStyle({
    this.borderColor = const Color(0xFF35A5F4),
    this.color = const Color(0xFFD8D8D8),
    this.iconColor = Colors.grey,
    this.width = 10,
    this.height = 10,
    this.strokeColor = const Color(0xFF35A5F4),
    this.labelColor = const Color(0xFF35A5F4),
  });
}

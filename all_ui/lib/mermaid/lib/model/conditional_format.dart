import 'package:flutter/material.dart';

/// Conditional formatting rules
class ConditionalFormat {
  final String id;
  final String columnId;
  final String condition; // Expression: "value > 100"
  final Color backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final IconData? icon;
  final bool enabled;

  ConditionalFormat({
    required this.id,
    required this.columnId,
    required this.condition,
    required this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.icon,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'columnId': columnId,
    'condition': condition,
    'backgroundColor': backgroundColor.value,
    'textColor': textColor?.value,
    'icon': icon?.codePoint,
    'enabled': enabled,
  };
}

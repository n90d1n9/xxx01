import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class PieSlice {
  final String label;
  final double value;
  final Color color;
  final int percentage;

  PieSlice({
    required this.label,
    required this.value,
    required this.color,
    required this.percentage,
  });

  PieSlice copyWith({
    String? label,
    double? value,
    Color? color,
    int? percentage,
  }) {
    return PieSlice(
      label: label ?? this.label,
      value: value ?? this.value,
      color: color ?? this.color,
      percentage: percentage ?? this.percentage,
    );
  }

  @override
  String toString() {
    return 'PieSlice(label: $label, value: $value, percentage: $percentage%)';
  }
}

import 'package:flutter/material.dart';

class HRMetric {
  final String title;
  final double value;
  final double previousValue;
  final String unit;
  final Color color;
  final bool lowerIsBetter;

  const HRMetric({
    required this.title,
    required this.value,
    required this.previousValue,
    required this.unit,
    required this.color,
    this.lowerIsBetter = false,
  });
  double get percentChange =>
      previousValue > 0 ? ((value - previousValue) / previousValue) * 100 : 0;

  bool get isPositive =>
      lowerIsBetter ? value < previousValue : value > previousValue;
}

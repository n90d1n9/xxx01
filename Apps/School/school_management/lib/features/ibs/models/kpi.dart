// Models
import 'package:flutter/material.dart';

class KpiData {
  final String title;
  final int value;
  final int target;
  final double progress;
  final IconData icon;
  final Color color;

  KpiData({
    required this.title,
    required this.value,
    required this.target,
    required this.progress,
    required this.icon,
    required this.color,
  });
}

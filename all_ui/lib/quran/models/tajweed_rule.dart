import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tajweed_category.dart';

class TajweedRule {
  final String id;
  final String name;
  final String arabicName;
  final String description;
  final String detailedExplanation;
  final Color color;
  final TajweedCategory category;
  final List<String> patterns;
  final List<String> examples;
  final int priority;
  TajweedRule({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.detailedExplanation,
    required this.color,
    required this.category,
    required this.patterns,
    required this.examples,
    this.priority = 0,
  });
}

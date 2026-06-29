// Templates Library (Enhanced)
import 'package:flutter/material.dart';

import 'node.dart';

class RouteTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final WNode route;
  final IconData icon;
  final List<String> tags;
  final int usageCount;
  final double rating;
  final String author;

  RouteTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.route,
    required this.icon,
    this.tags = const [],
    this.usageCount = 0,
    this.rating = 0.0,
    this.author = 'System',
  });
}

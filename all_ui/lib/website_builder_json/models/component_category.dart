import 'package:flutter/material.dart';

import 'schema/layout/section.dart';

class ComponentCategory {
  final String name;
  final IconData icon;
  final List<Section> components;

  ComponentCategory({
    required this.name,
    required this.icon,
    required this.components,
  });
}

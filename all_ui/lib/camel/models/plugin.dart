// Plugin System
import 'package:flutter/material.dart';

import 'component_template.dart';

class Plugin {
  final String id;
  final String name;
  final String version;
  final String description;
  final IconData icon;
  final List<ComponentTemplate> components;
  final Map<String, dynamic> settings;
  final bool enabled;

  Plugin({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.icon,
    this.components = const [],
    this.settings = const {},
    this.enabled = true,
  });
}

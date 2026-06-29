// Component Template
import 'package:flutter/material.dart';

import '../schema/config_property.dart';

class ComponentTemplate {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String category;
  final IconData icon;
  final Color color;
  final String? eipPattern;
  final Map<String, dynamic> defaultConfig;
  final List<ConfigProperty> properties;
  final List<String> tags;
  final ComponentType type;

  final String? version;
  final Map<String, dynamic>? configuration;
  final List<String>? examples;

  final String? documentationUrl;

  const ComponentTemplate({
    required this.id,
    required this.name,
    required this.description,
    this.categoryId = '',
    required this.icon,
    required this.color,
    this.category = '',
    this.eipPattern,
    required this.defaultConfig,
    required this.properties,
    this.tags = const [],
    this.type = ComponentType.router,
    this.documentationUrl = '',
    this.configuration,
    this.version,
    this.examples,
  });
}

class ComponentProperty {
  final String name;
  final String description;
  final String type;
  final bool required;
  final dynamic defaultValue;

  const ComponentProperty({
    required this.name,
    required this.description,
    required this.type,
    this.required = false,
    this.defaultValue,
  });
}

enum ComponentType {
  source,
  processor,
  sink,
  router,
  transformer,
  aggregator,
  filter,
  other,
}

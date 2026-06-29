import 'package:flutter/material.dart';

import 'field_config.dart';

class TabConfig {
  final String id;
  final String label;
  final IconData? icon;
  final List<FieldConfig> fields;
  final bool enabled;

  TabConfig({
    required this.id,
    required this.label,
    this.icon,
    required this.fields,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'icon': icon?.codePoint,
      'fields': fields.map((f) => f.toJson()).toList(),
      'enabled': enabled,
    };
  }
}

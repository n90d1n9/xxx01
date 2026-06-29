import 'package:flutter/material.dart';

import 'config_field_schema.dart';
import 'port_schema.dart';

class NodeSchema {
  final String name;
  final String description;
  final String category;
  final IconData icon;
  final Color color;
  final List<PortSchema> inputs;
  final List<PortSchema> outputs;
  final List<ConfigFieldSchema> configFields;
  final List<String> requiredSecrets;

  NodeSchema({
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.inputs,
    required this.outputs,
    this.configFields = const [],
    this.requiredSecrets = const [],
  });
}

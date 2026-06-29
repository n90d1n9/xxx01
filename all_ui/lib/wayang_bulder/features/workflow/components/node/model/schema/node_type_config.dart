import 'package:flutter/material.dart';

import '../../../../../plugin/model/config_field.dart';
import '../../../../../plugin/model/port_config.dart';
import 'node_style.dart';

class NodeConfig {
  //final NodeType type;
  final String type;
  final String label;
  final String description;
  final IconData icon;
  final NodeStyle? style;
  final List<PortConfig> inputs;
  final List<PortConfig> outputs;
  final Map<String, ConfigField> configFields;
  final String category;

  NodeConfig({
    required this.type,
    required this.label,
    required this.description,
    required this.icon,
    this.style,
    required this.inputs,
    required this.outputs,
    this.configFields = const {},
    required this.category,
  });
}

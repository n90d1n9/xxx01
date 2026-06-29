import 'package:flutter/material.dart';

import 'action/action_definition.dart';
import 'config_field_definition.dart';
import 'port_definition.dart';

class NodeDefinition {
  final String id;
  final String name;
  final String type;
  final String description;
  final IconData icon;
  final Color color;
  final List<PortDefinition> inputs;
  final List<PortDefinition> outputs;
  final List<ConfigFieldDefinition> configFields;
  final List<String> requiredSecrets;
  final ActionDefinition action;
  final Map<String, dynamic> metadata;

  NodeDefinition({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.icon,
    required this.color,
    this.inputs = const [],
    this.outputs = const [],
    this.configFields = const [],
    this.requiredSecrets = const [],
    required this.action,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'description': description,
    'icon': icon.codePoint,
    'color': color.value,
    'inputs': inputs.map((i) => i.toJson()).toList(),
    'outputs': outputs.map((o) => o.toJson()).toList(),
    'configFields': configFields.map((c) => c.toJson()).toList(),
    'requiredSecrets': requiredSecrets,
    'action': action.toJson(),
    'metadata': metadata,
  };

  factory NodeDefinition.fromJson(Map<String, dynamic> json) => NodeDefinition(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    description: json['description'],
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    color: Color(json['color']),
    inputs: (json['inputs'] as List)
        .map((i) => PortDefinition.fromJson(i))
        .toList(),
    outputs: (json['outputs'] as List)
        .map((o) => PortDefinition.fromJson(o))
        .toList(),
    configFields: (json['configFields'] as List)
        .map((c) => ConfigFieldDefinition.fromJson(c))
        .toList(),
    requiredSecrets: List<String>.from(json['requiredSecrets'] ?? []),
    action: ActionDefinition.fromJson(json['action']),
    metadata: json['metadata'] ?? {},
  );
}

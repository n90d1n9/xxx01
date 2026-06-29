import 'ifelse_condition.dart';

class IfElseNodeDefinition {
  final String id;
  final String name;
  final String description;
  final List<IfElseCondition> conditions;
  final bool hasElse;
  final Map<String, dynamic> metadata;

  IfElseNodeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.conditions,
    this.hasElse = true,
    this.metadata = const {},
  });

  List<String> getOutputPorts() {
    final ports = conditions.map((c) => c.id).toList();
    if (hasElse) ports.add('else');
    return ports;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'conditions': conditions.map((c) => c.toJson()).toList(),
    'hasElse': hasElse,
    'metadata': metadata,
  };

  factory IfElseNodeDefinition.fromJson(Map<String, dynamic> json) =>
      IfElseNodeDefinition(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        conditions: (json['conditions'] as List)
            .map((c) => IfElseCondition.fromJson(c))
            .toList(),
        hasElse: json['hasElse'] ?? true,
        metadata: json['metadata'] ?? {},
      );
}

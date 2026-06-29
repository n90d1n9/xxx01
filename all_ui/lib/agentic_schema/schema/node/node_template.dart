import 'node_type.dart';

class NodeTemplate {
  final String id;
  final String name;
  final NodeType type;
  final Map<String, dynamic> config;
  final String? description;

  NodeTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.config,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'config': config,
    'description': description,
  };

  factory NodeTemplate.fromJson(Map<String, dynamic> json) {
    return NodeTemplate(
      id: json['id'],
      name: json['name'],
      type: NodeType.values.firstWhere((t) => t.name == json['type']),
      config: json['config'],
      description: json['description'],
    );
  }
}

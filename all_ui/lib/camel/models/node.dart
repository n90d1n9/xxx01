// Route Model
import 'node_card.dart';

class WNode {
  final String id;
  final String name;
  final String description;
  final List<NodeCard> nodes;
  final DateTime createdAt;
  final DateTime? modifiedAt;

  WNode({
    required this.id,
    required this.name,
    this.description = '',
    this.nodes = const [],
    DateTime? createdAt,
    this.modifiedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  WNode copyWith({
    String? id,
    String? name,
    String? description,
    List<NodeCard>? nodes,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return WNode(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      nodes: nodes ?? this.nodes,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'nodes': nodes.map((n) => n.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
    };
  }

  factory WNode.fromJson(Map<String, dynamic> json) {
    return WNode(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      nodes: (json['nodes'] as List).map((n) => NodeCard.fromJson(n)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt:
          json['modifiedAt'] != null
              ? DateTime.parse(json['modifiedAt'])
              : null,
    );
  }
}

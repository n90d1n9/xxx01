import 'connection.dart';
import 'integration_component.dart';

class IntegrationRoute {
  final String id;
  final String name;
  final String description;
  final List<IntegrationComponent> components;
  final List<Connection> connections;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  IntegrationRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.components,
    required this.connections,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  IntegrationRoute copyWith({
    String? id,
    String? name,
    String? description,
    List<IntegrationComponent>? components,
    List<Connection>? connections,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return IntegrationRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      components: components ?? this.components,
      connections: connections ?? this.connections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'components': components.map((c) => c.toJson()).toList(),
      'connections': connections.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory IntegrationRoute.fromJson(Map<String, dynamic> json) {
    return IntegrationRoute(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      components: (json['components'] as List)
          .map((c) => IntegrationComponent.fromJson(c))
          .toList(),
      connections: (json['connections'] as List)
          .map((c) => Connection.fromJson(c))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      metadata: json['metadata'],
    );
  }
}

import 'node_definition.dart';

class PluginDefinition {
  final String id;
  final String name;
  final String version;
  final String description;
  final String author;
  final String category;
  final List<String> tags;
  final List<NodeDefinition> nodes;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PluginDefinition({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.category,
    this.tags = const [],
    this.nodes = const [],
    this.settings = const {},
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'version': version,
    'description': description,
    'author': author,
    'category': category,
    'tags': tags,
    'nodes': nodes.map((n) => n.toJson()).toList(),
    'settings': settings,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory PluginDefinition.fromJson(Map<String, dynamic> json) =>
      PluginDefinition(
        id: json['id'],
        name: json['name'],
        version: json['version'],
        description: json['description'],
        author: json['author'],
        category: json['category'],
        tags: List<String>.from(json['tags'] ?? []),
        nodes: (json['nodes'] as List)
            .map((n) => NodeDefinition.fromJson(n))
            .toList(),
        settings: json['settings'] ?? {},
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );

  PluginDefinition copyWith({
    String? name,
    String? version,
    String? description,
    String? author,
    String? category,
    List<String>? tags,
    List<NodeDefinition>? nodes,
    Map<String, dynamic>? settings,
    DateTime? updatedAt,
  }) {
    return PluginDefinition(
      id: id,
      name: name ?? this.name,
      version: version ?? this.version,
      description: description ?? this.description,
      author: author ?? this.author,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      nodes: nodes ?? this.nodes,
      settings: settings ?? this.settings,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

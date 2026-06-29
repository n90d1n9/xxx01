import 'plugin_capabilities.dart';
import 'plugin_dependancy.dart';

class PluginMetadata {
  final String id;
  final String name;
  final String version;
  final String description;
  final String author;
  final String? homepage;
  final String? repository;
  final List<String> tags;
  final List<PluginDependency> dependencies;
  final PluginCapabilities capabilities;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PluginMetadata({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    this.homepage,
    this.repository,
    this.tags = const [],
    this.dependencies = const [],
    required this.capabilities,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'version': version,
    'description': description,
    'author': author,
    'homepage': homepage,
    'repository': repository,
    'tags': tags,
    'dependencies': dependencies.map((d) => d.toJson()).toList(),
    'capabilities': capabilities.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory PluginMetadata.fromJson(Map<String, dynamic> json) => PluginMetadata(
    id: json['id'],
    name: json['name'],
    version: json['version'],
    description: json['description'],
    author: json['author'],
    homepage: json['homepage'],
    repository: json['repository'],
    tags: List<String>.from(json['tags'] ?? []),
    dependencies:
        (json['dependencies'] as List?)
            ?.map((d) => PluginDependency.fromJson(d))
            .toList() ??
        [],
    capabilities: PluginCapabilities.fromJson(json['capabilities']),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
  );
}

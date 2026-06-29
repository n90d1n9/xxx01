import 'design_component.dart';

class Project {
  final String id;
  final String name;
  final List<DesignComponent> components;
  final Map<String, List<String>> groups;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String version;

  const Project({
    required this.id,
    required this.name,
    required this.components,
    required this.groups,
    required this.createdAt,
    required this.updatedAt,
    this.version = '2.0',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'components': components.map((c) => c.toJson()).toList(),
    'groups': groups,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'version': version,
  };

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      components:
          (json['components'] as List)
              .map((c) => DesignComponent.fromJson(c))
              .toList(),
      groups: Map<String, List<String>>.from(
        (json['groups'] as Map).map(
          (k, v) => MapEntry(k, List<String>.from(v)),
        ),
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['version'] ?? '2.0',
    );
  }
}

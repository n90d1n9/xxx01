import 'component.dart';

class ComponentPreset {
  final String id;
  final String name;
  final String? description;
  final List<ComponentData> components;
  final DateTime createdAt;
  final DateTime updatedAt;

  ComponentPreset({
    required this.id,
    required this.name,
    this.description,
    ComponentData? component,
    List<ComponentData>? components,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : assert(
         component != null || (components != null && components.isNotEmpty),
       ),
       components = List.unmodifiable(components ?? [component!]),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  ComponentData get component => components.first;

  bool get isBlock => components.length > 1;

  ComponentPreset copyWith({
    String? id,
    String? name,
    String? description,
    ComponentData? component,
    List<ComponentData>? components,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ComponentPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      components: components ?? (component == null ? this.components : null),
      component: component,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'component': component.toJson(),
      'components': components.map((component) => component.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ComponentPreset.fromJson(Map<String, dynamic> json) {
    final rawComponents = json['components'] as List?;
    final components =
        rawComponents
            ?.whereType<Map>()
            .map(
              (item) => ComponentData.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList() ??
        const <ComponentData>[];
    final legacyComponent = ComponentData.fromJson(
      Map<String, dynamic>.from(json['component'] as Map? ?? const {}),
    );

    return ComponentPreset(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Untitled preset',
      description: json['description'] as String?,
      components: components.isEmpty ? [legacyComponent] : components,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}

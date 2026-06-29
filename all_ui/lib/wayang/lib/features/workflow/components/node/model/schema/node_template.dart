import 'package:flutter/material.dart';

class NodeTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final IconData icon;
  final Color color;
  final String nodeType;
  final Map<String, dynamic> defaultConfig;
  final List<String> tags;

  NodeTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.nodeType,
    this.defaultConfig = const {},
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'icon': _iconDataToMap(icon),
      'color': color.value,
      'nodeType': nodeType,
      'defaultConfig': Map<String, dynamic>.from(defaultConfig),
      'tags': List<String>.from(tags),
    };
  }

  factory NodeTemplate.fromMap(Map<String, dynamic> map) {
    return NodeTemplate(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      icon: _iconDataFromMap(Map<String, dynamic>.from(map['icon'] as Map)),
      color: Color(map['color'] as int),
      nodeType: map['nodeType'] as String,
      defaultConfig: Map<String, dynamic>.from(
        map['defaultConfig'] as Map? ?? {},
      ),
      tags: List<String>.from(map['tags'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory NodeTemplate.fromJson(Map<String, dynamic> json) =>
      NodeTemplate.fromMap(json);

  NodeTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    IconData? icon,
    Color? color,
    String? nodeType,
    Map<String, dynamic>? defaultConfig,
    List<String>? tags,
  }) {
    return NodeTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      nodeType: nodeType ?? this.nodeType,
      defaultConfig: defaultConfig ?? this.defaultConfig,
      tags: tags ?? this.tags,
    );
  }

  // Helper methods for IconData serialization (same as in WorkflowNode)
  static Map<String, dynamic> _iconDataToMap(IconData icon) {
    return {
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
    };
  }

  static IconData _iconDataFromMap(Map<String, dynamic> map) {
    return IconData(
      map['codePoint'] as int,
      fontFamily: map['fontFamily'] as String?,
      fontPackage: map['fontPackage'] as String?,
    );
  }

  @override
  String toString() {
    return 'NodeTemplate(id: $id, name: $name, category: $category, nodeType: $nodeType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NodeTemplate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

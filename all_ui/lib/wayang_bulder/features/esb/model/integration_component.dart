import 'package:flutter/widgets.dart';

import 'component_type.dart';

class IntegrationComponent {
  final String id;
  final ComponentType type;
  final String label;
  final Map<String, dynamic> properties;
  final Offset position;
  final String? description;
  final bool enabled;

  IntegrationComponent({
    required this.id,
    required this.type,
    required this.label,
    required this.properties,
    required this.position,
    this.description,
    this.enabled = true,
  });

  IntegrationComponent copyWith({
    String? id,
    ComponentType? type,
    String? label,
    Map<String, dynamic>? properties,
    Offset? position,
    String? description,
    bool? enabled,
  }) {
    return IntegrationComponent(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      properties: properties ?? this.properties,
      position: position ?? this.position,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'label': label,
      'properties': properties,
      'position': {'dx': position.dx, 'dy': position.dy},
      'description': description,
      'enabled': enabled,
    };
  }

  factory IntegrationComponent.fromJson(Map<String, dynamic> json) {
    return IntegrationComponent(
      id: json['id'],
      type: ComponentType.values.firstWhere((e) => e.name == json['type']),
      label: json['label'],
      properties: Map<String, dynamic>.from(json['properties']),
      position: Offset(json['position']['dx'], json['position']['dy']),
      description: json['description'],
      enabled: json['enabled'] ?? true,
    );
  }
}

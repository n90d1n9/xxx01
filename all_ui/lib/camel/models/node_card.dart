// Node Model
import 'package:flutter/material.dart';

import '../data/component_library.dart';
import 'node_connection.dart';

class NodeCard {
  final String id;
  final String type;
  final String name;
  final IconData icon;
  final Color color;
  final Offset position;
  final Map<String, dynamic> config;
  final List<NodeConnection> connections;
  final String? groupId;

  NodeCard({
    required this.id,
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
    required this.position,
    required this.config,
    this.connections = const [],
    this.groupId,
  });

  NodeCard copyWith({
    String? id,
    String? type,
    String? name,
    IconData? icon,
    Color? color,
    Offset? position,
    Map<String, dynamic>? config,
    List<NodeConnection>? connections,
    String? groupId,
  }) {
    return NodeCard(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      position: position ?? this.position,
      config: config ?? this.config,
      connections: connections ?? this.connections,
      groupId: groupId ?? this.groupId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'position': {'x': position.dx, 'y': position.dy},
      'config': config,
      'connections': connections,
      if (groupId != null) 'groupId': groupId,
    };
  }

  factory NodeCard.fromJson(Map<String, dynamic> json) {
    final components = ComponentLibrary.allComponents;
    final template = components.firstWhere(
      (c) => c.id == json['type'],
      orElse: () => components.first,
    );

    return NodeCard(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      icon: template.icon,
      color: template.color,
      position: Offset(json['position']['x'], json['position']['y']),
      config: Map<String, dynamic>.from(json['config']),
      connections: List<NodeConnection>.from(json['connections'] ?? []),
      groupId: json['groupId'],
    );
  }
}

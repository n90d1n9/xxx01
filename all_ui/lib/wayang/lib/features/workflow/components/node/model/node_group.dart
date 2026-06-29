import 'package:flutter/material.dart';

class NodeGroup {
  final String id;
  final String name;
  final List<String> nodeIds;
  final Color color;
  final bool collapsed;

  NodeGroup({
    required this.id,
    required this.name,
    required this.nodeIds,
    required this.color,
    this.collapsed = false,
  });

  NodeGroup copyWith({
    String? name,
    List<String>? nodeIds,
    Color? color,
    bool? collapsed,
  }) {
    return NodeGroup(
      id: id,
      name: name ?? this.name,
      nodeIds: nodeIds ?? this.nodeIds,
      color: color ?? this.color,
      collapsed: collapsed ?? this.collapsed,
    );
  }
}

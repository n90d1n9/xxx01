// Node Grouping
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'node_card.dart';

class NodeGroup {
  final String id;
  final String name;
  final Color color;
  final List<String> nodeIds;
  final Rect? bounds; // Calculated bounds of all nodes in the group
  final Offset position; // Manual position if user moves the group

  NodeGroup({
    required this.id,
    required this.name,
    required this.color,
    required this.nodeIds,
    this.bounds,
    this.position = Offset.zero,
  });

  NodeGroup copyWith({
    String? id,
    String? name,
    Color? color,
    List<String>? nodeIds,
    Rect? bounds,
    Offset? position,
  }) {
    return NodeGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      nodeIds: nodeIds ?? this.nodeIds,
      bounds: bounds ?? this.bounds,
      position: position ?? this.position,
    );
  }

  // Calculate bounds from nodes
  Rect calculateBounds(List<NodeCard> nodes) {
    if (nodes.isEmpty) return Rect.zero;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final node in nodes) {
      minX = math.min(minX, node.position.dx);
      minY = math.min(minY, node.position.dy);
      maxX = math.max(maxX, node.position.dx);
      maxY = math.max(maxY, node.position.dy);
    }

    // Add padding for group visual
    const padding = 20.0;
    return Rect.fromLTRB(
      minX - padding,
      minY - padding,
      maxX + padding,
      maxY + padding,
    );
  }
}

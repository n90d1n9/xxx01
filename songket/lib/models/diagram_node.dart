import 'package:flutter/material.dart';

import 'node_shape.dart';

class DiagramNode {
  final String id;
  final String label;
  final Offset position;
  final NodeShape shape;
  final Color? fillColor;
  final Color? strokeColor;

  DiagramNode({
    required this.id,
    required this.label,
    this.position = Offset.zero,
    this.shape = NodeShape.rectangle,
    this.fillColor,
    this.strokeColor,
  });

  DiagramNode copyWith({
    String? id,
    String? label,
    Offset? position,
    NodeShape? shape,
    Color? fillColor,
    Color? strokeColor,
  }) {
    return DiagramNode(
      id: id ?? this.id,
      label: label ?? this.label,
      position: position ?? this.position,
      shape: shape ?? this.shape,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
    );
  }

  @override
  String toString() {
    return 'DiagramNode(id: $id, label: $label, position: $position, shape: $shape)';
  }
}

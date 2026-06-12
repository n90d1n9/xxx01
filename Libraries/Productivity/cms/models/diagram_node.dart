import 'package:flutter/material.dart';

class DiagramNode {
  final String schemaId;
  Offset position;
  Size size;
  bool isSelected;
  bool isDragging;
  DiagramNode({
    required this.schemaId,
    required this.position,
    this.size = const Size(200, 150),
    this.isSelected = false,
    this.isDragging = false,
  });
  DiagramNode copyWith({
    Offset? position,
    Size? size,
    bool? isSelected,
    bool? isDragging,
  }) {
    return DiagramNode(
      schemaId: schemaId,
      position: position ?? this.position,
      size: size ?? this.size,
      isSelected: isSelected ?? this.isSelected,
      isDragging: isDragging ?? this.isDragging,
    );
  }
}

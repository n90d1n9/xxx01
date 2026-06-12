import 'package:flutter/material.dart';

class StateNode {
  final String id;
  final String label;
  final Offset position;
  final bool isInitial;
  final bool isFinal;
  final String? description;

  StateNode({
    required this.id,
    required this.label,
    this.position = Offset.zero,
    this.isInitial = false,
    this.isFinal = false,
    this.description,
  });

  StateNode copyWith({
    String? id,
    String? label,
    Offset? position,
    bool? isInitial,
    bool? isFinal,
    String? description,
  }) {
    return StateNode(
      id: id ?? this.id,
      label: label ?? this.label,
      position: position ?? this.position,
      isInitial: isInitial ?? this.isInitial,
      isFinal: isFinal ?? this.isFinal,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'StateNode(id: $id, label: $label, isInitial: $isInitial, isFinal: $isFinal, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StateNode && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

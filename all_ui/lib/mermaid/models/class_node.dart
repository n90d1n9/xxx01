import 'class_member.dart';

import 'package:flutter/material.dart';

class ClassNode {
  final String id;
  final String label;
  final Offset position;
  final List<ClassMember> attributes;
  final List<ClassMember> methods;
  final String? annotation;

  ClassNode({
    required this.id,
    required this.label,
    this.position = Offset.zero,
    this.attributes = const [],
    this.methods = const [],
    this.annotation,
  });

  ClassNode copyWith({
    String? id,
    String? label,
    Offset? position,
    List<ClassMember>? attributes,
    List<ClassMember>? methods,
    String? annotation,
  }) {
    return ClassNode(
      id: id ?? this.id,
      label: label ?? this.label,
      position: position ?? this.position,
      attributes: attributes ?? this.attributes,
      methods: methods ?? this.methods,
      annotation: annotation ?? this.annotation,
    );
  }

  @override
  String toString() {
    return 'ClassNode(id: $id, label: $label, position: $position, attributes: $attributes, methods: $methods)';
  }
}

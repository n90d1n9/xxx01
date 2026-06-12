import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';

class EREntity {
  final String name;
  final List<String> attributes;
  final Offset position;

  EREntity({
    required this.name,
    this.attributes = const [],
    this.position = Offset.zero,
  });

  EREntity copyWith({
    String? name,
    List<String>? attributes,
    Offset? position,
  }) {
    return EREntity(
      name: name ?? this.name,
      attributes: attributes ?? this.attributes,
      position: position ?? this.position,
    );
  }

  @override
  String toString() {
    return 'EREntity(name: $name, attributes: $attributes, position: $position)';
  }
}

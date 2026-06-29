import 'package:flutter/material.dart';

import 'field_style.dart';

class StylePresets {
  static FieldStyle get minimal => const FieldStyle(
    borderRadius: 4,
    borderWidth: 1,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );

  static FieldStyle get rounded => const FieldStyle(
    borderRadius: 24,
    borderWidth: 1,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  static FieldStyle get elevated => FieldStyle(
    borderRadius: 8,
    borderWidth: 0,
    elevation: 2,
    shadow: BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  static FieldStyle get outlined => const FieldStyle(
    borderRadius: 8,
    borderWidth: 2,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  static List<MapEntry<String, FieldStyle>> get all => [
    MapEntry('Minimal', minimal),
    MapEntry('Rounded', rounded),
    MapEntry('Elevated', elevated),
    MapEntry('Outlined', outlined),
  ];
}

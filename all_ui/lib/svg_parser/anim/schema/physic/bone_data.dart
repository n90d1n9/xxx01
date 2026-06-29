import 'dart:math' as math;

import 'package:flutter/material.dart';

class BoneData {
  String id;
  String name;
  Offset position;
  double length;
  double rotation;
  BoneData? parent;

  BoneData({
    required this.id,
    required this.name,
    required this.position,
    required this.length,
    required this.rotation,
    this.parent,
  });

  Offset get endPosition {
    return position +
        Offset(math.cos(rotation) * length, math.sin(rotation) * length);
  }
}

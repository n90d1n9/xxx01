import 'dart:math' as math;

import 'package:flutter/material.dart';

class Bone {
  final String id;
  final String name;
  Offset position;
  double rotation;
  double length;
  Bone? parent;
  final List<Bone> children = [];

  Bone({
    required this.id,
    required this.name,
    required this.position,
    this.rotation = 0,
    this.length = 100,
    this.parent,
  });

  Offset get worldPosition {
    if (parent == null) return position;

    final parentWorld = parent!.worldPosition;
    final rotated = _rotatePoint(position, parent!.rotation);
    return parentWorld + rotated;
  }

  Offset _rotatePoint(Offset point, double angle) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    return Offset(
      point.dx * cos - point.dy * sin,
      point.dx * sin + point.dy * cos,
    );
  }
}

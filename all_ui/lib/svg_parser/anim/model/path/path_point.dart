import 'package:flutter/material.dart';

class PathPoint {
  Offset position;
  Offset? handleIn;
  Offset? handleOut;
  PathPointType type;

  PathPoint({
    required this.position,
    this.handleIn,
    this.handleOut,
    this.type = PathPointType.smooth,
  });
}

enum PathPointType { corner, smooth, symmetric, disconnected }

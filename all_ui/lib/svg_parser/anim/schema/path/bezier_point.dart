import 'package:flutter/material.dart';

import 'point.dart';

class BezierPoint {
  Offset position;
  Offset handleIn;
  Offset handleOut;
  PointType type;

  BezierPoint({
    required this.position,
    required this.handleIn,
    required this.handleOut,
    required this.type,
  });
}

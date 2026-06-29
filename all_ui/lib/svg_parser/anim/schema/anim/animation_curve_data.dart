import 'package:flutter/material.dart';

class AnimationCurveData {
  Offset p1;
  Offset p2;

  AnimationCurveData({required this.p1, required this.p2});

  double evaluate(double t) {
    final u = 1 - t;
    return 3 * u * u * t * p1.dy + 3 * u * t * t * p2.dy + t * t * t;
  }
}

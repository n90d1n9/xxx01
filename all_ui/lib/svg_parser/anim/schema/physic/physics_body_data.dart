import 'package:flutter/material.dart';

class PhysicsBodyData {
  Offset position;
  Offset velocity;
  double mass;
  double restitution;
  double radius;

  PhysicsBodyData({
    required this.position,
    required this.velocity,
    required this.mass,
    required this.restitution,
    required this.radius,
  });
}

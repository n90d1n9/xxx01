import 'package:flutter/material.dart';

class ParticleData {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double life;
  double maxLife;

  ParticleData({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.life,
    required this.maxLife,
  });

  bool get isDead => life <= 0;

  void update(double dt) {
    position += velocity * dt;
    velocity += const Offset(0, 200) * dt; // Gravity
    life -= dt;
  }
}

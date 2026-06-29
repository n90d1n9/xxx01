import 'package:flutter/material.dart';

class ParticleEffect {
  final int particleCount;
  final Color color;
  final double speed;
  final double size;

  ParticleEffect({
    this.particleCount = 50,
    this.color = Colors.white,
    this.speed = 1.0,
    this.size = 3.0,
  });
}

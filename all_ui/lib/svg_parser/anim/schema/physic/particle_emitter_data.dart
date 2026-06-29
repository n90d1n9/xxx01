import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'particle_data.dart';

class ParticleEmitterData {
  Offset position;
  double rate;
  double particleLifeSpan;
  double particleSize;
  Color particleColor;
  double spread;
  double speed;
  double _accumulator = 0;

  ParticleEmitterData({
    required this.position,
    required this.rate,
    required this.particleLifeSpan,
    required this.particleSize,
    required this.particleColor,
    required this.spread,
    required this.speed,
  });

  bool shouldEmit(double dt) {
    _accumulator += dt;
    if (_accumulator >= 1.0 / rate) {
      _accumulator = 0;
      return true;
    }
    return false;
  }

  ParticleData createParticle() {
    final random = math.Random();
    final angle = random.nextDouble() * spread - spread / 2;
    final velocity = Offset(math.cos(angle) * speed, math.sin(angle) * speed);

    return ParticleData(
      position: position,
      velocity: velocity,
      color: particleColor,
      size: particleSize,
      life: particleLifeSpan,
      maxLife: particleLifeSpan,
    );
  }
}

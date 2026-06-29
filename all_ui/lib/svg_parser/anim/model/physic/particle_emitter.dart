import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'particle.dart';

class ParticleEmitter {
  final Offset position;
  final double emissionRate;
  double _timeSinceLastEmit = 0;

  ParticleEmitter({required this.position, this.emissionRate = 10});

  bool shouldEmit() {
    _timeSinceLastEmit += 0.016; // Assume 60fps
    if (_timeSinceLastEmit >= 1 / emissionRate) {
      _timeSinceLastEmit = 0;
      return true;
    }
    return false;
  }

  Particle createParticle() {
    final random = math.Random();
    return Particle(
      position: position,
      velocity: Offset(
        random.nextDouble() * 200 - 100,
        random.nextDouble() * 200 - 100,
      ),
      color: Colors.primaries[random.nextInt(Colors.primaries.length)],
      size: random.nextDouble() * 10 + 5,
      maxLife: random.nextDouble() * 2 + 1,
    );
  }
}

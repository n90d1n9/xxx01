import 'package:flutter/widgets.dart';

import 'particle.dart';
import 'particle_emitter.dart';

class ParticleSystem {
  final List<Particle> particles = [];
  final ParticleEmitter emitter;

  ParticleSystem({required this.emitter});

  void update(double dt) {
    // Emit new particles
    if (emitter.shouldEmit()) {
      particles.add(emitter.createParticle());
    }

    // Update existing particles
    particles.removeWhere((p) => p.isDead);
    for (var particle in particles) {
      particle.update(dt);
    }
  }

  void render(Canvas canvas) {
    for (var particle in particles) {
      particle.render(canvas);
    }
  }
}

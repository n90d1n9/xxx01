import 'particle_data.dart';
import 'particle_emitter_data.dart';

class ParticleSystemData {
  ParticleEmitterData emitter;
  List<ParticleData> particles = [];
  bool active = true;

  ParticleSystemData({required this.emitter});

  void update(double dt) {
    if (active && emitter.shouldEmit(dt)) {
      particles.add(emitter.createParticle());
    }

    particles.removeWhere((p) => p.isDead);
    for (var particle in particles) {
      particle.update(dt);
    }
  }
}

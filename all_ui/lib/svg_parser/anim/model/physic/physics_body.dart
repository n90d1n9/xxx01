import 'package:flutter/material.dart';

class PhysicsBody {
  Offset position;
  Offset velocity;
  Offset acceleration;
  double mass;
  double friction;
  double restitution; // Bounciness

  PhysicsBody({
    required this.position,
    this.velocity = Offset.zero,
    this.acceleration = Offset.zero,
    this.mass = 1.0,
    this.friction = 0.1,
    this.restitution = 0.8,
  });

  void update(double dt) {
    velocity += acceleration * dt;
    velocity *= (1 - friction);
    position += velocity * dt;
    acceleration = Offset.zero;
  }

  void applyForce(Offset force) {
    acceleration += force / mass;
  }

  void applyGravity(double gravity) {
    applyForce(Offset(0, gravity * mass));
  }
}

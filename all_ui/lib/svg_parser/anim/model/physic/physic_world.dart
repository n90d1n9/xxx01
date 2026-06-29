import 'package:flutter/material.dart';

import 'physics_body.dart';

class PhysicsWorld {
  final List<PhysicsBody> bodies = [];
  final double gravity = 980; // pixels/s²
  final Rect bounds;

  PhysicsWorld({required this.bounds});

  void update(double dt) {
    for (var body in bodies) {
      body.applyGravity(gravity);
      body.update(dt);
      _handleBoundaryCollisions(body);
    }

    _handleBodyCollisions();
  }

  void _handleBoundaryCollisions(PhysicsBody body) {
    if (body.position.dy > bounds.bottom) {
      body.position = Offset(body.position.dx, bounds.bottom);
      body.velocity = Offset(
        body.velocity.dx,
        -body.velocity.dy * body.restitution,
      );
    }

    if (body.position.dx < bounds.left || body.position.dx > bounds.right) {
      body.velocity = Offset(
        -body.velocity.dx * body.restitution,
        body.velocity.dy,
      );
    }
  }

  void _handleBodyCollisions() {
    // Simple collision detection between bodies
    for (var i = 0; i < bodies.length; i++) {
      for (var j = i + 1; j < bodies.length; j++) {
        // Implement collision response
      }
    }
  }
}

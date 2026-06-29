import 'package:flutter/material.dart';

import 'physics_body_data.dart';

class PhysicsWorldData {
  Offset gravity;
  Rect bounds;
  List<PhysicsBodyData> bodies = [];
  bool active = false;

  PhysicsWorldData({required this.gravity, required this.bounds});

  void update(double dt) {
    if (!active) return;

    for (var body in bodies) {
      body.velocity += gravity * dt;
      body.position += body.velocity * dt;

      // Boundary collision
      if (body.position.dy + body.radius > bounds.bottom) {
        body.position = Offset(body.position.dx, bounds.bottom - body.radius);
        body.velocity = Offset(
          body.velocity.dx,
          -body.velocity.dy * body.restitution,
        );
      }

      if (body.position.dx - body.radius < bounds.left ||
          body.position.dx + body.radius > bounds.right) {
        body.velocity = Offset(
          -body.velocity.dx * body.restitution,
          body.velocity.dy,
        );
      }
    }
  }
}

import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double life;
  double maxLife;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.maxLife,
  }) : life = maxLife;

  bool get isDead => life <= 0;

  void update(double dt) {
    position += velocity * dt;
    life -= dt;
  }

  void render(Canvas canvas) {
    final opacity = (life / maxLife).clamp(0.0, 1.0);
    final paint =
        Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(position, size, paint);
  }
}

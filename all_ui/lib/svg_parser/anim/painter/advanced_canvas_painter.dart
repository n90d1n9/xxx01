import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../schema/layer/advanced_layer.dart';
import '../schema/layer/layer.dart';
import '../schema/path/bezier_path_data.dart';
import '../schema/path/motion_path_data.dart';
import '../schema/physic/bone_data.dart';
import '../schema/physic/particle_system_data.dart';
import '../schema/physic/physic_word_data.dart';

class AdvancedCanvasPainter extends CustomPainter {
  final List<AdvancedLayer> layers;
  final AdvancedLayer? selectedLayer;
  final double progress;
  final ParticleSystemData? particleSystem;
  final PhysicsWorldData? physicsWorld;
  final List<BoneData> skeleton;
  final BezierPathData? currentPath;
  final MotionPathData? currentMotionPath;

  AdvancedCanvasPainter({
    required this.layers,
    this.selectedLayer,
    required this.progress,
    this.particleSystem,
    this.physicsWorld,
    required this.skeleton,
    this.currentPath,
    this.currentMotionPath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Update systems
    final dt = 1 / 60;
    particleSystem?.update(dt);
    physicsWorld?.update(dt);

    // Draw layers
    for (var layer in layers) {
      _drawLayer(canvas, layer);
    }

    // Draw particles
    if (particleSystem != null) {
      _drawParticles(canvas, particleSystem!);
    }

    // Draw physics bodies
    if (physicsWorld != null) {
      _drawPhysicsBodies(canvas, physicsWorld!);
    }

    // Draw skeleton
    _drawSkeleton(canvas, skeleton);

    // Draw current path
    if (currentPath != null) {
      _drawBezierPath(canvas, currentPath!);
    }

    // Draw motion path
    if (currentMotionPath != null && selectedLayer != null) {
      _drawMotionPath(canvas, currentMotionPath!, selectedLayer!);
    }
  }

  void _drawLayer(Canvas canvas, AdvancedLayer layer) {
    canvas.save();

    canvas.translate(layer.position.dx, layer.position.dy);
    canvas.rotate(layer.rotation * math.pi / 180);
    canvas.scale(layer.scale);

    final paint = Paint()..color = layer.color.withOpacity(layer.opacity);

    if (layer.gradient != null) {
      paint.shader = layer.gradient!.toGradient().createShader(
        Rect.fromCenter(
          center: Offset.zero,
          width: layer.size.width,
          height: layer.size.height,
        ),
      );
    }

    switch (layer.type) {
      case LayerType.rectangle:
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: layer.size.width,
            height: layer.size.height,
          ),
          paint,
        );
        break;

      case LayerType.circle:
        canvas.drawCircle(Offset.zero, layer.size.width / 2, paint);
        break;

      case LayerType.path:
        if (layer.bezierPath != null) {
          canvas.drawPath(layer.bezierPath!.toPath(), paint);
        }
        break;

      default:
        break;
    }

    // Draw selection indicator
    if (layer == selectedLayer) {
      final selectionPaint =
          Paint()
            ..color = Colors.blue
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: layer.size.width + 10,
          height: layer.size.height + 10,
        ),
        selectionPaint,
      );
    }

    canvas.restore();
  }

  void _drawParticles(Canvas canvas, ParticleSystemData system) {
    for (var particle in system.particles) {
      final opacity = (particle.life / particle.maxLife).clamp(0.0, 1.0);
      final paint =
          Paint()
            ..color = particle.color.withOpacity(opacity)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  void _drawPhysicsBodies(Canvas canvas, PhysicsWorldData world) {
    for (var body in world.bodies) {
      final paint =
          Paint()
            ..color = Colors.orange
            ..style = PaintingStyle.fill;

      canvas.drawCircle(body.position, body.radius, paint);

      // Draw velocity vector
      final velocityPaint =
          Paint()
            ..color = Colors.red
            ..strokeWidth = 2;

      canvas.drawLine(
        body.position,
        body.position + body.velocity * 0.1,
        velocityPaint,
      );
    }
  }

  void _drawSkeleton(Canvas canvas, List<BoneData> bones) {
    for (var bone in bones) {
      final paint =
          Paint()
            ..color = Colors.green
            ..strokeWidth = 3;

      canvas.drawLine(bone.position, bone.endPosition, paint);

      // Draw joints
      final jointPaint =
          Paint()
            ..color = Colors.yellow
            ..style = PaintingStyle.fill;

      canvas.drawCircle(bone.position, 5, jointPaint);
      canvas.drawCircle(bone.endPosition, 5, jointPaint);
    }
  }

  void _drawBezierPath(Canvas canvas, BezierPathData pathData) {
    final path = pathData.toPath();

    // Draw path
    final pathPaint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawPath(path, pathPaint);

    // Draw points and handles
    for (var point in pathData.points) {
      // Draw handles
      final handlePaint =
          Paint()
            ..color = Colors.grey
            ..strokeWidth = 1;

      canvas.drawLine(
        point.position,
        point.position + point.handleIn,
        handlePaint,
      );
      canvas.drawLine(
        point.position,
        point.position + point.handleOut,
        handlePaint,
      );

      // Draw handle points
      canvas.drawCircle(
        point.position + point.handleIn,
        4,
        Paint()..color = Colors.red,
      );
      canvas.drawCircle(
        point.position + point.handleOut,
        4,
        Paint()..color = Colors.green,
      );

      // Draw anchor point
      final pointPaint =
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill;

      canvas.drawCircle(point.position, 6, pointPaint);
    }
  }

  void _drawMotionPath(
    Canvas canvas,
    MotionPathData motionPath,
    AdvancedLayer layer,
  ) {
    // Draw the path
    final pathPaint =
        Paint()
          ..color = Colors.purple
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawPath(motionPath.path, pathPaint);

    // Draw layer at current position
    final position = motionPath.getPositionAt(progress);
    final rotation =
        motionPath.autoRotate ? motionPath.getRotationAt(progress) : 0;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation.toDouble());

    final paint =
        Paint()
          ..color = layer.color.withOpacity(0.5)
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: layer.size.width,
        height: layer.size.height,
      ),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(AdvancedCanvasPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:math';
import 'package:flutter/material.dart';

import 'dart:math';
import 'package:flutter/material.dart';

class MagicalSparkleReveal extends StatefulWidget {
  final Widget? child;

  final bool autoStart;
  final Duration duration;

  final int sparkleCount;
  final double spreadRadius;
  final double minSize;
  final double maxSize;

  const MagicalSparkleReveal({
    super.key,
    this.child,
    this.autoStart = true,
    this.duration = const Duration(seconds: 2),
    this.sparkleCount = 80,
    this.spreadRadius = 200,
    this.minSize = 6,
    this.maxSize = 18,
  });

  @override
  State<MagicalSparkleReveal> createState() => _MagicalSparkleRevealState();
}

class _MagicalSparkleRevealState extends State<MagicalSparkleReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  final Random random = Random();
  final List<_Sparkle> sparkles = [];

  bool generated = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: widget.duration);

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        start();
      });
    }
  }

  void start() {
    if (!generated) {
      _generateSparkles();
      generated = true;
    }

    controller.forward(from: 0);
  }

  void _generateSparkles() {
    final size = context.size ?? MediaQuery.of(context).size;

    sparkles.clear();

    for (int i = 0; i < widget.sparkleCount; i++) {
      final start = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );

      final angle = random.nextDouble() * pi * 2;
      final distance = random.nextDouble() * widget.spreadRadius;

      sparkles.add(
        _Sparkle(
          start: start,
          velocity: Offset(cos(angle) * distance, sin(angle) * distance),
          size:
              widget.minSize +
              random.nextDouble() * (widget.maxSize - widget.minSize),
          rotationSpeed: random.nextDouble() * 4 - 2,
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _SparklePainter(
                    progress: controller.value,
                    sparkles: sparkles,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Sparkle {
  final Offset start;
  final Offset velocity;
  final double size;
  final double rotationSpeed;

  _Sparkle({
    required this.start,
    required this.velocity,
    required this.size,
    required this.rotationSpeed,
  });
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final List<_Sparkle> sparkles;

  _SparklePainter({required this.progress, required this.sparkles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in sparkles) {
      final pos = s.start + s.velocity * progress;

      final scale = sin(progress * pi);
      final opacity = scale;

      canvas.save();

      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(progress * s.rotationSpeed);

      _drawSparkle(canvas, s.size * scale, opacity);

      canvas.restore();
    }
  }

  void _drawSparkle(Canvas canvas, double size, double opacity) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(opacity)
          ..strokeWidth = size * 0.15
          ..strokeCap = StrokeCap.round;

    final long = size * 0.5;
    final short = size * 0.25;

    canvas.drawLine(Offset(-long, 0), Offset(long, 0), paint);
    canvas.drawLine(Offset(0, -long), Offset(0, long), paint);

    canvas.drawLine(Offset(-short, -short), Offset(short, short), paint);
    canvas.drawLine(Offset(short, -short), Offset(-short, short), paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Example
class SparkleDemo extends StatefulWidget {
  @override
  State<SparkleDemo> createState() => _SparkleDemoState();
}

class _SparkleDemoState extends State<SparkleDemo> {
  final GlobalKey<_MagicalSparkleRevealState> _sparkleKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '✨',
              style: TextStyle(fontSize: 100, color: Colors.white),
            ),
            const SizedBox(height: 50),
            MagicalSparkleReveal(
              sparkleCount: 120,
              spreadRadius: 220,
              duration: Duration(seconds: 2),
            ),
            /*  MagicalSparkleReveal(
              key: _sparkleKey,
              autoStart: false,
              child: Container(),
            ), */
            /* ElevatedButton(
              onPressed: () => _sparkleKey.currentState?.startReveal(),
              child: const Text('Show Sparkles'),
            ), */
          ],
        ),
      ),
    );
  }
}

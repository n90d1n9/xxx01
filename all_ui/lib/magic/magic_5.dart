import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class MagicalSparkleReveal extends StatefulWidget {
  final Widget? child;
  final bool autoStart;
  final Duration revealDuration;
  final VoidCallback? onComplete;

  const MagicalSparkleReveal({
    Key? key,
    this.child,
    this.autoStart = true,
    this.revealDuration = const Duration(seconds: 3),
    this.onComplete,
  }) : super(key: key);

  @override
  State<MagicalSparkleReveal> createState() => _MagicalSparkleRevealState();
}

class _MagicalSparkleRevealState extends State<MagicalSparkleReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ScatteringSparkle> _sparkles = [];
  final Random _random = Random();
  Timer? _sparkleTimer;
  bool _isRevealing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.revealDuration,
    );

    if (widget.autoStart) {
      startReveal();
    }
  }

  void startReveal() {
    if (_isRevealing) return;
    _isRevealing = true;
    _controller.forward().then((_) {
      _sparkleTimer?.cancel();
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
    _startSparkleTimer();
  }

  void _startSparkleTimer() {
    _sparkleTimer?.cancel();
    _sparkleTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!_isRevealing || _controller.isCompleted) {
        return;
      }

      setState(() {
        // Add a burst of sparkles at random positions
        int burstCount = _random.nextInt(5) + 3; // 3-7 sparkles per burst
        for (int i = 0; i < burstCount; i++) {
          _sparkles.add(
            ScatteringSparkle.random(_random, MediaQuery.of(context).size),
          );
        }

        // Remove sparkles that have completed their scattering
        _sparkles.removeWhere((sparkle) => sparkle.isComplete);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _sparkleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        // Sparkles overlay
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: SparklePainter(
                    sparkles: _sparkles,
                    progress: _controller.value,
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

class ScatteringSparkle {
  Offset startPosition;
  double startTime;
  double size;
  Color color;
  double rotation;
  double scatterAngle;
  double scatterDistance;
  double scatterSpeed;
  double currentProgress = 0.0;
  bool isComplete = false;

  ScatteringSparkle({
    required this.startPosition,
    required this.startTime,
    required this.size,
    required this.color,
    required this.rotation,
    required this.scatterAngle,
    required this.scatterDistance,
    required this.scatterSpeed,
  });

  factory ScatteringSparkle.random(Random random, Size screenSize) {
    // Random position anywhere on screen
    double x = random.nextDouble() * screenSize.width;
    double y = random.nextDouble() * screenSize.height;

    // Random size between 20 and 50
    double size = random.nextDouble() * 30 + 20;

    // Sparkle colors (gold, white, silver)
    Color color;
    int colorChoice = random.nextInt(4);
    switch (colorChoice) {
      case 0:
        color = const Color(0xFFFFD700); // Gold
        break;
      case 1:
        color = const Color(0xFFF0F0F0); // Silver white
        break;
      case 2:
        color = const Color(0xFFFFFACD); // Lemon chiffon
        break;
      default:
        color = Colors.white;
    }

    // Random scatter direction
    double scatterAngle = random.nextDouble() * 2 * pi;

    // Random distance to scatter
    double scatterDistance = random.nextDouble() * 100 + 50;

    // Random speed (0.5 to 1.5)
    double scatterSpeed = random.nextDouble() + 0.5;

    return ScatteringSparkle(
      startPosition: Offset(x, y),
      startTime: 0,
      size: size,
      color: color,
      rotation: random.nextDouble() * 2 * pi,
      scatterAngle: scatterAngle,
      scatterDistance: scatterDistance,
      scatterSpeed: scatterSpeed,
    );
  }

  void update(double progress) {
    currentProgress = progress * scatterSpeed;
    if (currentProgress >= 1.0) {
      isComplete = true;
    }
  }

  Offset getCurrentPosition() {
    if (currentProgress <= 0.3) {
      // Phase 1: Scale up from center (no movement)
      return startPosition;
    } else {
      // Phase 2: Scatter outward
      double scatterProgress = (currentProgress - 0.3) / 0.7;
      scatterProgress = min(scatterProgress, 1.0);

      // Ease out for scattering
      scatterProgress = 1 - pow(1 - scatterProgress, 3).toDouble();

      double distance = scatterDistance * scatterProgress;
      return Offset(
        startPosition.dx + cos(scatterAngle) * distance,
        startPosition.dy + sin(scatterAngle) * distance,
      );
    }
  }

  double getCurrentScale() {
    if (currentProgress <= 0.15) {
      // Phase 1: Scale up quickly
      return currentProgress / 0.15;
    } else if (currentProgress <= 0.3) {
      // Phase 1: Hold at full scale
      return 1.0;
    } else {
      // Phase 2: Scale down while scattering
      double scaleProgress = (currentProgress - 0.3) / 0.7;
      scaleProgress = min(scaleProgress, 1.0);
      // Ease in for scaling down
      scaleProgress = scaleProgress * scaleProgress;
      return 1.0 - scaleProgress * 0.7; // Scale down to 0.3
    }
  }

  double getCurrentOpacity() {
    if (currentProgress <= 0.1) {
      // Fade in quickly
      return currentProgress / 0.1;
    } else if (currentProgress <= 0.7) {
      // Full opacity
      return 1.0;
    } else {
      // Fade out
      double fadeProgress = (currentProgress - 0.7) / 0.3;
      return 1.0 - fadeProgress;
    }
  }
}

class SparklePainter extends CustomPainter {
  final List<ScatteringSparkle> sparkles;
  final double progress;

  SparklePainter({required this.sparkles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var sparkle in sparkles) {
      sparkle.update(progress);
      if (sparkle.isComplete) continue;

      final position = sparkle.getCurrentPosition();
      final scale = sparkle.getCurrentScale();
      final opacity = sparkle.getCurrentOpacity();
      final rotation = sparkle.rotation;

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(rotation);

      _drawPreciseSparkle(
        canvas,
        sparkle.size * scale,
        sparkle.color.withOpacity(opacity),
      );

      canvas.restore();
    }
  }

  void _drawPreciseSparkle(Canvas canvas, double size, Color color) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..strokeWidth = size / 15
          ..strokeCap = StrokeCap.round;

    final center = Offset.zero;
    final mainLength = size * 0.6;
    final subLength = size * 0.3;
    final thickness = size / 12;

    // Draw the main sparkle shape exactly like "✨"

    // Main vertical ray (long)
    paint.strokeWidth = thickness;
    canvas.drawLine(Offset(0, -mainLength), Offset(0, mainLength), paint);

    // Main horizontal ray (long)
    canvas.drawLine(Offset(-mainLength, 0), Offset(mainLength, 0), paint);

    // Diagonal rays (medium)
    paint.strokeWidth = thickness * 0.8;
    canvas.drawLine(
      Offset(-subLength * 0.7, -subLength * 0.7),
      Offset(subLength * 0.7, subLength * 0.7),
      paint,
    );

    canvas.drawLine(
      Offset(subLength * 0.7, -subLength * 0.7),
      Offset(-subLength * 0.7, subLength * 0.7),
      paint,
    );

    // Small dots at ends (like in the emoji)
    paint.strokeWidth = thickness * 1.5;
    paint.strokeCap = StrokeCap.round;

    // Draw dots at the ends of main rays
    paint.color = color.withOpacity(color.opacity * 1.2);

    // Top dot
    canvas.drawPoints(PointMode.points, [
      Offset(0, -mainLength - thickness / 2),
    ], paint);

    // Bottom dot
    canvas.drawPoints(PointMode.points, [
      Offset(0, mainLength + thickness / 2),
    ], paint);

    // Left dot
    canvas.drawPoints(PointMode.points, [
      Offset(-mainLength - thickness / 2, 0),
    ], paint);

    // Right dot
    canvas.drawPoints(PointMode.points, [
      Offset(mainLength + thickness / 2, 0),
    ], paint);

    // Add central glow
    paint
      ..color = Colors.white.withOpacity(color.opacity * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(center, size / 8, paint);
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) {
    return oldDelegate.sparkles != sparkles || oldDelegate.progress != progress;
  }
}

// Example usage
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
      body: Stack(
        children: [
          // Background with subtle gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.black,
                  Colors.purple.withOpacity(0.2),
                  Colors.blue.withOpacity(0.1),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // Sparkle effect
          MagicalSparkleReveal(
            key: _sparkleKey,
            autoStart: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Magical item to reveal
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFFFFD700),
                          Color(0xFFFF69B4),
                          Color(0xFF00FFFF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '✨',
                        style: TextStyle(
                          fontSize: 80,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.purple, blurRadius: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Trigger button
                  ElevatedButton(
                    onPressed: () {
                      _sparkleKey.currentState?.startReveal();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      '✨ REVEAL MAGIC ✨',
                      style: TextStyle(fontSize: 18, letterSpacing: 2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SparkleDemo()));
}

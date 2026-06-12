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
    _sparkleTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!_isRevealing || _controller.isCompleted) {
        return;
      }

      setState(() {
        // Add more sparkles per burst for dramatic effect
        int burstCount = _random.nextInt(8) + 5; // 5-13 sparkles per burst
        for (int i = 0; i < burstCount; i++) {
          _sparkles.add(
            ScatteringSparkle.random(_random, MediaQuery.of(context).size),
          );
        }

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
    required this.size,
    required this.color,
    required this.rotation,
    required this.scatterAngle,
    required this.scatterDistance,
    required this.scatterSpeed,
  });

  factory ScatteringSparkle.random(Random random, Size screenSize) {
    double x = random.nextDouble() * screenSize.width;
    double y = random.nextDouble() * screenSize.height;

    // More varied sizes for dramatic effect
    double size = random.nextDouble() * 50 + 30; // 30-80 pixels

    // Brilliant sparkle colors
    Color color;
    int colorChoice = random.nextInt(6);
    switch (colorChoice) {
      case 0:
        color = const Color(0xFFFFD700); // Bright Gold
        break;
      case 1:
        color = const Color(0xFFFFFACD); // Lemon Chiffon
        break;
      case 2:
        color = const Color(0xFFF0F8FF); // Alice Blue
        break;
      case 3:
        color = const Color(0xFFFAEBD7); // Antique White
        break;
      case 4:
        color = const Color(0xFFFFE4E1); // Misty Rose
        break;
      default:
        color = Colors.white;
    }

    double scatterAngle = random.nextDouble() * 2 * pi;
    double scatterDistance = random.nextDouble() * 200 + 100; // 100-300 pixels
    double scatterSpeed = random.nextDouble() * 1.5 + 0.8; // 0.8-2.3

    return ScatteringSparkle(
      startPosition: Offset(x, y),
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
    if (currentProgress <= 0.25) {
      return startPosition;
    } else {
      double scatterProgress = (currentProgress - 0.25) / 0.75;
      scatterProgress = min(scatterProgress, 1.0);
      scatterProgress =
          1 - pow(1 - scatterProgress, 2.5).toDouble(); // More dramatic easing

      double distance = scatterDistance * scatterProgress;
      return Offset(
        startPosition.dx + cos(scatterAngle) * distance,
        startPosition.dy + sin(scatterAngle) * distance,
      );
    }
  }

  double getCurrentScale() {
    if (currentProgress <= 0.1) {
      // Quick scale up
      return currentProgress / 0.1;
    } else if (currentProgress <= 0.25) {
      // Hold at full size
      return 1.0;
    } else {
      // Scale down while scattering
      double scaleProgress = (currentProgress - 0.25) / 0.75;
      scaleProgress = min(scaleProgress, 1.0);
      scaleProgress = pow(scaleProgress, 1.5).toDouble(); // Smooth scaling
      return 1.0 - scaleProgress * 0.8; // Scale down to 0.2
    }
  }

  double getCurrentOpacity() {
    if (currentProgress <= 0.05) {
      // Quick fade in
      return currentProgress / 0.05;
    } else if (currentProgress <= 0.6) {
      // Full brightness
      return 1.0;
    } else {
      // Fade out
      double fadeProgress = (currentProgress - 0.6) / 0.4;
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

      _drawExactSparkle(
        canvas,
        sparkle.size * scale,
        sparkle.color.withOpacity(opacity),
      );

      canvas.restore();
    }
  }

  void _drawExactSparkle(Canvas canvas, double size, Color color) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth =
              size *
              0.12 // Thicker strokes for drama
          ..strokeCap = StrokeCap.round;

    final mainLength = size * 0.6;
    final subLength = size * 0.35;

    // Draw main vertical line (longest)
    canvas.drawLine(Offset(0, -mainLength), Offset(0, mainLength), paint);

    // Draw main horizontal line (longest)
    canvas.drawLine(Offset(-mainLength, 0), Offset(mainLength, 0), paint);

    // Draw diagonal lines (medium)
    canvas.drawLine(
      Offset(-subLength, -subLength),
      Offset(subLength, subLength),
      paint,
    );

    canvas.drawLine(
      Offset(subLength, -subLength),
      Offset(-subLength, subLength),
      paint,
    );

    // Draw extra small rays for more sparkle
    paint.strokeWidth = size * 0.08;
    final extraLength = size * 0.2;

    canvas.drawLine(
      Offset(-extraLength, -mainLength * 0.3),
      Offset(extraLength, -mainLength * 0.7),
      paint,
    );

    canvas.drawLine(
      Offset(extraLength, -mainLength * 0.3),
      Offset(-extraLength, -mainLength * 0.7),
      paint,
    );

    canvas.drawLine(
      Offset(-extraLength, mainLength * 0.3),
      Offset(extraLength, mainLength * 0.7),
      paint,
    );

    canvas.drawLine(
      Offset(extraLength, mainLength * 0.3),
      Offset(-extraLength, mainLength * 0.7),
      paint,
    );

    // Draw the distinctive dots at ends (key feature of ✨)
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 1;

    final dotSize = size * 0.1;

    // Top dot
    paint.color = color.withOpacity(color.opacity * 1.2);
    canvas.drawCircle(Offset(0, -mainLength - dotSize * 0.5), dotSize, paint);

    // Bottom dot
    canvas.drawCircle(Offset(0, mainLength + dotSize * 0.5), dotSize, paint);

    // Left dot
    canvas.drawCircle(Offset(-mainLength - dotSize * 0.5, 0), dotSize, paint);

    // Right dot
    canvas.drawCircle(Offset(mainLength + dotSize * 0.5, 0), dotSize, paint);

    // Diagonal end dots
    canvas.drawCircle(
      Offset(-subLength - dotSize * 0.3, -subLength - dotSize * 0.3),
      dotSize * 0.8,
      paint,
    );
    canvas.drawCircle(
      Offset(subLength + dotSize * 0.3, subLength + dotSize * 0.3),
      dotSize * 0.8,
      paint,
    );
    canvas.drawCircle(
      Offset(subLength + dotSize * 0.3, -subLength - dotSize * 0.3),
      dotSize * 0.8,
      paint,
    );
    canvas.drawCircle(
      Offset(-subLength - dotSize * 0.3, subLength + dotSize * 0.3),
      dotSize * 0.8,
      paint,
    );

    // Add extra sparkle dots
    paint.color = Colors.white.withOpacity(color.opacity * 0.8);
    for (int i = 0; i < 4; i++) {
      double angle = i * pi / 2;
      double x = cos(angle) * mainLength * 0.4;
      double y = sin(angle) * mainLength * 0.4;
      canvas.drawCircle(Offset(x, y), dotSize * 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) {
    return oldDelegate.sparkles != sparkles || oldDelegate.progress != progress;
  }
}

// Example usage with dramatic entrance
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
          // Dramatic background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.black,
                  const Color(0xFF2D1B3A).withOpacity(0.5),
                  const Color(0xFF1A237E).withOpacity(0.3),
                ],
                stops: const [0.0, 0.5, 1.0],
                center: Alignment.center,
                radius: 1.2,
              ),
            ),
          ),

          // Sparkle effect
          MagicalSparkleReveal(
            key: _sparkleKey,
            autoStart: false,
            revealDuration: const Duration(seconds: 4),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Magical crystal to reveal
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(seconds: 2),
                    curve: Curves.elasticInOut,
                    builder: (context, double scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFF69B4),
                                Color(0xFF00FFFF),
                                Color(0xFFAA00FF),
                              ],
                              stops: [0.0, 0.3, 0.7, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.6),
                                blurRadius: 50,
                                spreadRadius: 20,
                              ),
                              BoxShadow(
                                color: const Color(0xFFFF69B4).withOpacity(0.4),
                                blurRadius: 80,
                                spreadRadius: 30,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '✨',
                              style: TextStyle(
                                fontSize: 120,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFFFFD700),
                                    blurRadius: 30,
                                  ),
                                  Shadow(
                                    color: Color(0xFFFF69B4),
                                    blurRadius: 50,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 60),

                  // Magical trigger button
                  ElevatedButton(
                    onPressed: () {
                      _sparkleKey.currentState?.startReveal();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 25,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                        side: const BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2,
                        ),
                      ),
                      elevation: 10,
                      shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('✨ ', style: TextStyle(fontSize: 24)),
                        Text(
                          'SUMMON MAGIC',
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(' ✨', style: TextStyle(fontSize: 24)),
                      ],
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

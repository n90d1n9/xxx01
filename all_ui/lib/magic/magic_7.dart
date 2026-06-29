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
    _sparkleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRevealing || _controller.isCompleted) {
        return;
      }

      setState(() {
        int burstCount = _random.nextInt(6) + 4; // 4-10 sparkles
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

    double size = random.nextDouble() * 40 + 25; // 25-65 pixels

    // Exact sparkle colors - bright and brilliant
    Color color;
    int colorChoice = random.nextInt(5);
    switch (colorChoice) {
      case 0:
        color = const Color(0xFFFFF68F); // Khaki
        break;
      case 1:
        color = const Color(0xFFFFFACD); // Lemon Chiffon
        break;
      case 2:
        color = const Color(0xFFFFE4B5); // Moccasin
        break;
      case 3:
        color = const Color(0xFFFFF0F5); // Lavender Blush
        break;
      default:
        color = Colors.white70;
    }

    double scatterAngle = random.nextDouble() * 2 * pi;
    double scatterDistance = random.nextDouble() * 150 + 80;
    double scatterSpeed = random.nextDouble() * 1.2 + 0.8;

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
    if (currentProgress <= 0.2) {
      return startPosition;
    } else {
      double scatterProgress = (currentProgress - 0.2) / 0.8;
      scatterProgress = min(scatterProgress, 1.0);
      scatterProgress = 1 - pow(1 - scatterProgress, 2).toDouble();

      double distance = scatterDistance * scatterProgress;
      return Offset(
        startPosition.dx + cos(scatterAngle) * distance,
        startPosition.dy + sin(scatterAngle) * distance,
      );
    }
  }

  double getCurrentScale() {
    if (currentProgress <= 0.1) {
      return currentProgress / 0.1;
    } else if (currentProgress <= 0.2) {
      return 1.0;
    } else {
      double scaleProgress = (currentProgress - 0.2) / 0.8;
      scaleProgress = min(scaleProgress, 1.0);
      return 1.0 - scaleProgress * 0.7;
    }
  }

  double getCurrentOpacity() {
    if (currentProgress <= 0.05) {
      return currentProgress / 0.05;
    } else if (currentProgress <= 0.7) {
      return 1.0;
    } else {
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

      _drawExactSparkleEmoji(
        canvas,
        sparkle.size * scale,
        sparkle.color.withOpacity(opacity),
      );

      canvas.restore();
    }
  }

  void _drawExactSparkleEmoji(Canvas canvas, double size, Color color) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = size * 0.12
          ..strokeCap = StrokeCap.round;

    final mainLength = size * 0.5;
    final mediumLength = size * 0.35;
    final smallLength = size * 0.2;

    // Draw the 8 rays of the sparkle (exactly like ✨)

    // Vertical line (top-bottom)
    canvas.drawLine(Offset(0, -mainLength), Offset(0, mainLength), paint);

    // Horizontal line (left-right)
    canvas.drawLine(Offset(-mainLength, 0), Offset(mainLength, 0), paint);

    // Diagonal lines (45 degrees)
    canvas.drawLine(
      Offset(-mediumLength, -mediumLength),
      Offset(mediumLength, mediumLength),
      paint,
    );

    canvas.drawLine(
      Offset(mediumLength, -mediumLength),
      Offset(-mediumLength, mediumLength),
      paint,
    );

    // Smaller diagonal rays (22.5 degrees)
    paint.strokeWidth = size * 0.08;

    // Top-right small ray
    canvas.drawLine(
      Offset(smallLength * 0.7, -smallLength * 1.2),
      Offset(smallLength * 1.2, -smallLength * 0.7),
      paint,
    );

    // Top-left small ray
    canvas.drawLine(
      Offset(-smallLength * 0.7, -smallLength * 1.2),
      Offset(-smallLength * 1.2, -smallLength * 0.7),
      paint,
    );

    // Bottom-right small ray
    canvas.drawLine(
      Offset(smallLength * 0.7, smallLength * 1.2),
      Offset(smallLength * 1.2, smallLength * 0.7),
      paint,
    );

    // Bottom-left small ray
    canvas.drawLine(
      Offset(-smallLength * 0.7, smallLength * 1.2),
      Offset(-smallLength * 1.2, smallLength * 0.7),
      paint,
    );

    // Add the distinctive dots at the ends (key feature of ✨)
    paint.style = PaintingStyle.fill;
    final dotSize = size * 0.08;

    // Main dots at ends of primary rays
    paint.color = color.withOpacity(color.opacity * 1.3);

    // Top dot
    canvas.drawCircle(Offset(0, -mainLength - dotSize * 0.3), dotSize, paint);

    // Bottom dot
    canvas.drawCircle(Offset(0, mainLength + dotSize * 0.3), dotSize, paint);

    // Left dot
    canvas.drawCircle(Offset(-mainLength - dotSize * 0.3, 0), dotSize, paint);

    // Right dot
    canvas.drawCircle(Offset(mainLength + dotSize * 0.3, 0), dotSize, paint);

    // Diagonal dots (slightly smaller)
    paint.color = color.withOpacity(color.opacity);

    // Top-left diagonal dot
    canvas.drawCircle(
      Offset(-mediumLength - dotSize * 0.2, -mediumLength - dotSize * 0.2),
      dotSize * 0.9,
      paint,
    );

    // Top-right diagonal dot
    canvas.drawCircle(
      Offset(mediumLength + dotSize * 0.2, -mediumLength - dotSize * 0.2),
      dotSize * 0.9,
      paint,
    );

    // Bottom-left diagonal dot
    canvas.drawCircle(
      Offset(-mediumLength - dotSize * 0.2, mediumLength + dotSize * 0.2),
      dotSize * 0.9,
      paint,
    );

    // Bottom-right diagonal dot
    canvas.drawCircle(
      Offset(mediumLength + dotSize * 0.2, mediumLength + dotSize * 0.2),
      dotSize * 0.9,
      paint,
    );

    // Small dots on the smaller rays
    paint.color = color.withOpacity(color.opacity * 0.8);
    final smallDotSize = dotSize * 0.7;

    // Positions for small ray dots
    canvas.drawCircle(
      Offset(smallLength * 1.4, -smallLength * 0.7),
      smallDotSize,
      paint,
    );
    canvas.drawCircle(
      Offset(-smallLength * 1.4, -smallLength * 0.7),
      smallDotSize,
      paint,
    );
    canvas.drawCircle(
      Offset(smallLength * 1.4, smallLength * 0.7),
      smallDotSize,
      paint,
    );
    canvas.drawCircle(
      Offset(-smallLength * 1.4, smallLength * 0.7),
      smallDotSize,
      paint,
    );
    canvas.drawCircle(
      Offset(smallLength * 0.7, -smallLength * 1.4),
      smallDotSize,
      paint,
    );
    canvas.drawCircle(
      Offset(-smallLength * 0.7, -smallLength * 1.4),
      smallDotSize,
      paint,
    );
    canvas.drawCircle(
      Offset(smallLength * 0.7, smallLength * 1.4),
      smallDotSize,
      paint,
    );
    canvas.drawCircle(
      Offset(-smallLength * 0.7, smallLength * 1.4),
      smallDotSize,
      paint,
    );
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
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.black,
                  Colors.deepPurple.withOpacity(0.3),
                  Colors.blue.withOpacity(0.2),
                ],
              ),
            ),
          ),

          MagicalSparkleReveal(
            key: _sparkleKey,
            autoStart: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    ),
                    child: const Center(
                      child: Text(
                        '✨',
                        style: TextStyle(fontSize: 100, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

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
                      '✨ REVEAL ✨',
                      style: TextStyle(fontSize: 20),
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

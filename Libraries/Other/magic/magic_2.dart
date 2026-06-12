import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';

class MagicalSparkleField extends StatefulWidget {
  final Widget? child;
  final bool autoStart;
  final Color primaryColor;
  final Color secondaryColor;

  const MagicalSparkleField({
    Key? key,
    this.child,
    this.autoStart = true,
    this.primaryColor = const Color(0xFFFFD700),
    this.secondaryColor = const Color(0xFFFF69B4),
  }) : super(key: key);

  @override
  State<MagicalSparkleField> createState() => _MagicalSparkleFieldState();
}

class _MagicalSparkleFieldState extends State<MagicalSparkleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<DramaticSparkle> _sparkles = [];
  final Random _random = Random();
  static const int MAX_SPARKLES = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    if (widget.autoStart) {
      _startSparking();
    }
  }

  void _startSparking() {
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted) {
        setState(() {
          // Add multiple sparkles at once for dramatic effect
          for (int i = 0; i < _random.nextInt(5) + 3; i++) {
            if (_sparkles.length < MAX_SPARKLES) {
              _sparkles.add(
                DramaticSparkle.random(
                  _random,
                  widget.primaryColor,
                  widget.secondaryColor,
                ),
              );
            }
          }

          // Remove dead sparkles
          _sparkles.removeWhere((sparkle) => !sparkle.isAlive);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            if (widget.child != null) widget.child!,
            ..._sparkles.map((sparkle) {
              return Positioned(
                left: sparkle.x * MediaQuery.of(context).size.width,
                top: sparkle.y * MediaQuery.of(context).size.height,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: sparkle.opacity,
                    duration: Duration.zero,
                    child: CustomPaint(
                      size: Size(sparkle.size, sparkle.size),
                      painter: DramaticSparklePainter(
                        sparkle: sparkle,
                        animation: _controller,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DramaticSparkle {
  double x, y;
  double size;
  double opacity;
  double life;
  double maxLife;
  Color color;
  SparkleType type;
  double rotation;
  double pulseSpeed;
  bool get isAlive => life > 0;

  DramaticSparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.life,
    required this.maxLife,
    required this.color,
    required this.type,
    required this.rotation,
    required this.pulseSpeed,
  });

  factory DramaticSparkle.random(
    Random random,
    Color primary,
    Color secondary,
  ) {
    final types = SparkleType.values;
    final type = types[random.nextInt(types.length)];

    // Random position anywhere on screen
    double x = random.nextDouble();
    double y = random.nextDouble();

    // Random size (can be quite large for dramatic effect)
    double size = random.nextDouble() * 60 + 20;

    // Start with full opacity but will fade
    double maxLife = random.nextDouble() * 1.5 + 0.8;
    double life = maxLife;

    // Random color from palette
    Color color;
    if (random.nextDouble() > 0.5) {
      color = primary.withOpacity(1.0);
    } else {
      color = secondary.withOpacity(1.0);
    }

    // Add some color variation
    if (random.nextDouble() > 0.7) {
      color = Colors.cyan.withOpacity(1.0);
    } else if (random.nextDouble() > 0.8) {
      color = Colors.white;
    }

    return DramaticSparkle(
      x: x,
      y: y,
      size: size,
      opacity: 1.0,
      life: life,
      maxLife: maxLife,
      color: color,
      type: type,
      rotation: random.nextDouble() * 2 * pi,
      pulseSpeed: random.nextDouble() * 2 + 1,
    );
  }
}

enum SparkleType { star, burst, flare, cross, diamond, circle }

class DramaticSparklePainter extends CustomPainter {
  final DramaticSparkle sparkle;
  final Animation<double> animation;

  DramaticSparklePainter({required this.sparkle, required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    sparkle.life -= 0.01;
    if (sparkle.life <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final now = DateTime.now().millisecondsSinceEpoch / 1000;

    // Pulse effect
    final pulse = sin(now * sparkle.pulseSpeed * 2) * 0.2 + 0.8;
    final currentSize = sparkle.size * pulse * sparkle.life;
    final currentOpacity = sparkle.life * pulse;

    // Rotation animation
    final rotationAngle = sparkle.rotation + animation.value * 2 * pi;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    switch (sparkle.type) {
      case SparkleType.star:
        _drawStar(
          canvas,
          currentSize,
          sparkle.color.withOpacity(currentOpacity),
        );
        break;
      case SparkleType.burst:
        _drawBurst(
          canvas,
          currentSize,
          sparkle.color.withOpacity(currentOpacity),
        );
        break;
      case SparkleType.flare:
        _drawFlare(
          canvas,
          currentSize,
          sparkle.color.withOpacity(currentOpacity),
        );
        break;
      case SparkleType.cross:
        _drawCross(
          canvas,
          currentSize,
          sparkle.color.withOpacity(currentOpacity),
        );
        break;
      case SparkleType.diamond:
        _drawDiamond(
          canvas,
          currentSize,
          sparkle.color.withOpacity(currentOpacity),
        );
        break;
      case SparkleType.circle:
        _drawCircle(
          canvas,
          currentSize,
          sparkle.color.withOpacity(currentOpacity),
        );
        break;
    }

    canvas.restore();
  }

  void _drawStar(Canvas canvas, double size, Color color) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();
    int points = 5;
    double outerRadius = size / 2;
    double innerRadius = size / 4;

    for (int i = 0; i < points * 2; i++) {
      double radius = i.isEven ? outerRadius : innerRadius;
      double angle = (i * pi / points) - pi / 2;
      double x = radius * cos(angle);
      double y = radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawBurst(Canvas canvas, double size, Color color) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int i = 0; i < 12; i++) {
      double angle = (i * 30 * pi / 180);
      double x1 = 0;
      double y1 = 0;
      double x2 = size * cos(angle);
      double y2 = size * sin(angle);

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        paint..strokeWidth = size / 8,
      );
    }

    // Center glow
    paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset.zero, size / 3, paint);
  }

  void _drawFlare(Canvas canvas, double size, Color color) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Main flare shape (elongated)
    final path = Path();
    path.moveTo(-size / 2, 0);
    path.lineTo(0, -size / 6);
    path.lineTo(size / 2, 0);
    path.lineTo(0, size / 3);
    path.close();

    canvas.drawPath(path, paint);

    // Additional rays
    for (int i = -1; i <= 1; i += 2) {
      canvas.drawLine(
        Offset.zero,
        Offset(size * 0.7 * i, -size * 0.3),
        paint..strokeWidth = size / 10,
      );
    }
  }

  void _drawCross(Canvas canvas, double size, Color color) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Horizontal bar
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: size, height: size / 4),
      paint,
    );

    // Vertical bar
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: size / 4, height: size),
      paint,
    );

    // Diagonal rays
    paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    for (int i = 0; i < 4; i++) {
      double angle = i * pi / 2 + pi / 4;
      double x = size * cos(angle) * 0.6;
      double y = size * sin(angle) * 0.6;
      canvas.drawLine(Offset.zero, Offset(x, y), paint..strokeWidth = size / 8);
    }
  }

  void _drawDiamond(Canvas canvas, double size, Color color) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();
    path.moveTo(0, -size / 2);
    path.lineTo(size / 2, 0);
    path.lineTo(0, size / 2);
    path.lineTo(-size / 2, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Inner glow
    paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset.zero, size / 4, paint);
  }

  void _drawCircle(Canvas canvas, double size, Color color) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawCircle(Offset.zero, size / 2, paint);

    // Inner highlight
    paint
      ..color = Colors.white.withOpacity(color.opacity * 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset.zero, size / 4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Progress bar with sparkles
class MagicalSparkleProgress extends StatelessWidget {
  final double progress;
  final VoidCallback? onComplete;

  const MagicalSparkleProgress({
    Key? key,
    required this.progress,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        // Progress with sparkles
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Progress bar
                Container(
                  height: 6,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFF69B4),
                        Color(0xFF00FFFF),
                        Color(0xFFFFA500),
                      ],
                      stops: [0.0, 0.3, 0.6, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // Sparkles on progress bar
                ...List.generate(10, (index) {
                  if (progress == 0) return const SizedBox.shrink();

                  final random = Random(index);
                  final sparkleX =
                      random.nextDouble() * constraints.maxWidth * progress;
                  final sparkleY = random.nextDouble() * 20 - 10;

                  return Positioned(
                    left: sparkleX,
                    top: sparkleY,
                    child: AnimatedSparkle(
                      size: random.nextDouble() * 20 + 10,
                      color: Color.fromRGBO(
                        255,
                        random.nextInt(100) + 155,
                        random.nextInt(100),
                        1,
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }
}

class AnimatedSparkle extends StatefulWidget {
  final double size;
  final Color color;

  const AnimatedSparkle({Key? key, required this.size, required this.color})
    : super(key: key);

  @override
  State<AnimatedSparkle> createState() => _AnimatedSparkleState();
}

class _AnimatedSparkleState extends State<AnimatedSparkle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 + Random().nextInt(500)),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.5 + _controller.value * 0.5,
          child: Opacity(
            opacity: 0.3 + _controller.value * 0.7,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: SimpleSparklePainter(color: widget.color),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SimpleSparklePainter extends CustomPainter {
  final Color color;

  SimpleSparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Draw a simple star
    final path = Path();
    for (int i = 0; i < 8; i++) {
      double angle = i * pi / 4;
      double radius = i.isEven ? size.width / 2 : size.width / 4;
      double x = center.dx + radius * cos(angle);
      double y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Example usage with dramatic entrance
class MagicalEntranceDemo extends StatefulWidget {
  @override
  State<MagicalEntranceDemo> createState() => _MagicalEntranceDemoState();
}

class _MagicalEntranceDemoState extends State<MagicalEntranceDemo>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
      setState(() {
        _progress = _progressController.value;
      });
    });
  }

  void _startMagic() {
    _progressController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background sparkle field
          MagicalSparkleField(
            primaryColor: const Color(0xFFFFD700),
            secondaryColor: const Color(0xFFFF69B4),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.black,
                    Colors.purple.withOpacity(0.3),
                    Colors.blue.withOpacity(0.2),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Magical item to reveal
                AnimatedOpacity(
                  opacity: _progress,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedScale(
                    scale: 0.5 + _progress * 0.5,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
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
                            blurRadius: 50,
                            spreadRadius: 20,
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
                  ),
                ),
                const SizedBox(height: 50),

                // Magical progress
                Container(
                  width: 300,
                  child: Column(
                    children: [
                      MagicalSparkleProgress(progress: _progress),
                      const SizedBox(height: 20),
                      const Text(
                        'Magic Manifesting...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(color: Colors.purple, blurRadius: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Cast button
                ElevatedButton(
                  onPressed: _startMagic,
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
                    '✨ CAST MAGIC SPELL ✨',
                    style: TextStyle(fontSize: 18, letterSpacing: 2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

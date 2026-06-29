import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class MagicalSparkleEffect extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final Duration duration;
  final Widget? child;
  final bool autoStart;
  final VoidCallback? onComplete;

  const MagicalSparkleEffect({
    Key? key,
    this.progress = 0.0,
    this.duration = const Duration(seconds: 3),
    this.child,
    this.autoStart = false,
    this.onComplete,
  }) : super(key: key);

  @override
  State<MagicalSparkleEffect> createState() => _MagicalSparkleEffectState();
}

class _MagicalSparkleEffectState extends State<MagicalSparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  List<Sparkle> _sparkles = [];
  final Random _random = Random();
  Timer? _sparkleTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.autoStart) {
      _startEffect();
    }

    _controller.addListener(_updateProgress);
  }

  void _updateProgress() {
    setState(() {});
  }

  void _startEffect() {
    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
    _startSparkleTimer();
  }

  void _startSparkleTimer() {
    _sparkleTimer?.cancel();
    _sparkleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_controller.isCompleted) {
        timer.cancel();
        return;
      }
      setState(() {
        // Add new sparkles
        for (int i = 0; i < 3; i++) {
          _sparkles.add(
            Sparkle(
              position: Offset(_random.nextDouble(), _random.nextDouble()),
              size: _random.nextDouble() * 30 + 10,
              color: _getRandomSparkleColor(),
              velocity: Offset(
                (_random.nextDouble() - 0.5) * 0.02,
                -_random.nextDouble() * 0.03 - 0.01,
              ),
              life: 1.0,
            ),
          );
        }

        // Update existing sparkles
        _sparkles.removeWhere((sparkle) {
          sparkle.position += sparkle.velocity;
          sparkle.life -= 0.02;
          return sparkle.life <= 0;
        });
      });
    });
  }

  Color _getRandomSparkleColor() {
    const colors = [
      Color(0xFFFFD700), // Gold
      Color(0xFFFF69B4), // Hot Pink
      Color(0xFF00FFFF), // Cyan
      Color(0xFFFFA500), // Orange
      Color(0xFFFFFFFF), // White
      Color(0xFFE6E6FA), // Lavender
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    _sparkleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            if (widget.child != null) Positioned.fill(child: widget.child!),
            // Progress indicator (magical bar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                child: Stack(
                  children: [
                    // Background
                    Container(color: Colors.grey.withOpacity(0.3)),
                    // Progress with magical gradient
                    FractionallySizedBox(
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple,
                              Colors.blue,
                              Colors.pink,
                              Colors.orange,
                            ],
                            stops: const [0.0, 0.3, 0.6, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sparkles
            ..._sparkles.map(
              (sparkle) => Positioned(
                left: sparkle.position.dx * MediaQuery.of(context).size.width,
                top: sparkle.position.dy * MediaQuery.of(context).size.height,
                child: Opacity(
                  opacity: sparkle.life,
                  child: TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween<double>(begin: 0.8, end: 1.2),
                    builder: (context, double scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: CustomPaint(
                      size: Size(sparkle.size, sparkle.size),
                      painter: SparklePainter(
                        color: sparkle.color.withOpacity(sparkle.life),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Magical glow overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.purple.withOpacity(
                          0.1 * sin(_controller.value * pi),
                        ),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class Sparkle {
  Offset position;
  double size;
  Color color;
  Offset velocity;
  double life;

  Sparkle({
    required this.position,
    required this.size,
    required this.color,
    required this.velocity,
    required this.life,
  });
}

class SimpleSparkle extends StatelessWidget {
  final double size;
  final Color color;

  const SimpleSparkle({Key? key, this.size = 50, this.color = Colors.white})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: SparklePainter(color: color),
    );
  }
}

class SparklePainter extends CustomPainter {
  final Color color;

  SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.12
          ..strokeCap = StrokeCap.round;

    double w = size.width / 2;
    double h = size.height / 2;

    // Four main lines
    canvas.drawLine(
      Offset(-w * 0.6, 0),
      Offset(w * 0.6, 0),
      paint,
    ); // horizontal
    canvas.drawLine(Offset(0, -h * 0.6), Offset(0, h * 0.6), paint); // vertical
    canvas.drawLine(
      Offset(-w * 0.4, -h * 0.4),
      Offset(w * 0.4, h * 0.4),
      paint,
    ); // diagonal
    canvas.drawLine(
      Offset(w * 0.4, -h * 0.4),
      Offset(-w * 0.4, h * 0.4),
      paint,
    ); // other diagonal

    // Dots at ends
    paint.style = PaintingStyle.fill;
    double dotSize = size.width * 0.08;

    canvas.drawCircle(Offset(w * 0.6, 0), dotSize, paint);
    canvas.drawCircle(Offset(-w * 0.6, 0), dotSize, paint);
    canvas.drawCircle(Offset(0, h * 0.6), dotSize, paint);
    canvas.drawCircle(Offset(0, -h * 0.6), dotSize, paint);
    canvas.drawCircle(Offset(w * 0.4, h * 0.4), dotSize * 0.8, paint);
    canvas.drawCircle(Offset(-w * 0.4, -h * 0.4), dotSize * 0.8, paint);
    canvas.drawCircle(Offset(w * 0.4, -h * 0.4), dotSize * 0.8, paint);
    canvas.drawCircle(Offset(-w * 0.4, h * 0.4), dotSize * 0.8, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Usage example
class MagicalSparkleDemo extends StatefulWidget {
  @override
  State<MagicalSparkleDemo> createState() => _MagicalSparkleDemoState();
}

class _MagicalSparkleDemoState extends State<MagicalSparkleDemo>
    with TickerProviderStateMixin {
  double _progress = 0.0;
  late AnimationController _demoController;

  @override
  void initState() {
    super.initState();
    _demoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
      setState(() {
        _progress = _demoController.value;
      });
    });
  }

  @override
  void dispose() {
    _demoController.dispose();
    super.dispose();
  }

  void _startMagic() {
    _demoController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Content to reveal
                  AnimatedOpacity(
                    opacity: _progress,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Colors.purple, Colors.blue, Colors.pink],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '✨ MAGIC! ✨',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.purple, blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Sparkle effect
                  MagicalSparkleEffect(
                    progress: _progress,
                    duration: const Duration(seconds: 3),
                    onComplete: () {
                      // Magic complete!
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: _startMagic,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '✨ Cast Magic Spell ✨',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

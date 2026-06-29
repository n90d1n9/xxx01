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
      if (!_isRevealing || _controller.isCompleted) return;

      setState(() {
        int burstCount = _random.nextInt(5) + 3;
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
    return ScatteringSparkle(
      startPosition: Offset(
        random.nextDouble() * screenSize.width,
        random.nextDouble() * screenSize.height,
      ),
      size: random.nextDouble() * 30 + 20,
      color: Colors.white.withOpacity(0.9),
      rotation: random.nextDouble() * 2 * pi,
      scatterAngle: random.nextDouble() * 2 * pi,
      scatterDistance: random.nextDouble() * 100 + 50,
      scatterSpeed: random.nextDouble() * 1.5 + 0.5,
    );
  }

  void update(double progress) {
    currentProgress = progress * scatterSpeed;
    if (currentProgress >= 1.0) isComplete = true;
  }

  Offset getCurrentPosition() {
    if (currentProgress <= 0.2) return startPosition;

    double scatterProgress = (currentProgress - 0.2) / 0.8;
    scatterProgress = min(scatterProgress, 1.0);
    double distance = scatterDistance * scatterProgress;

    return Offset(
      startPosition.dx + cos(scatterAngle) * distance,
      startPosition.dy + sin(scatterAngle) * distance,
    );
  }

  double getCurrentScale() {
    if (currentProgress <= 0.1) return currentProgress / 0.1;
    if (currentProgress <= 0.2) return 1.0;

    double scaleProgress = (currentProgress - 0.2) / 0.8;
    scaleProgress = min(scaleProgress, 1.0);
    return 1.0 - scaleProgress * 0.8;
  }

  double getCurrentOpacity() {
    if (currentProgress <= 0.05) return currentProgress / 0.05;
    if (currentProgress <= 0.7) return 1.0;

    double fadeProgress = (currentProgress - 0.7) / 0.3;
    return 1.0 - fadeProgress;
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

void main() => runApp(MaterialApp(home: SparkleDemo()));

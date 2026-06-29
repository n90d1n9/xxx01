// animated_rating.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedRating extends StatefulWidget {
  final double rating;
  final double size;
  final int maxRating;
  final Duration animationDuration;
  final Color activeColor;
  final Color inactiveColor;
  final bool enableGesture;
  final Function(double)? onRatingUpdate;

  const AnimatedRating({
    super.key,
    this.rating = 0.0,
    this.size = 40.0,
    this.maxRating = 5,
    this.animationDuration = const Duration(milliseconds: 400),
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.enableGesture = true,
    this.onRatingUpdate,
  });

  @override
  State<AnimatedRating> createState() => _AnimatedRatingState();
}

class _AnimatedRatingState extends State<AnimatedRating>
    with TickerProviderStateMixin {
  late double _rating;
  late List<AnimationController> _scaleControllers;
  late List<Animation<double>> _scaleAnimations;
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Initialize scale animations for each star
    _scaleControllers = List.generate(
      widget.maxRating,
      (index) => AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      ),
    );

    _scaleAnimations = _scaleControllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
      ]).animate(controller);
    }).toList();

    // Initialize color animation
    _colorController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));
  }

  void _handleRatingUpdate(double newRating) {
    if (newRating == _rating) return;

    setState(() {
      final oldRating = _rating;
      _rating = newRating;

      // Animate stars that changed state
      for (var i = 0; i < widget.maxRating; i++) {
        if ((i < newRating && i >= oldRating) ||
            (i < oldRating && i >= newRating)) {
          _scaleControllers[i].forward().then((_) {
            if (mounted) _scaleControllers[i].reset();
          });
        }
      }
    });

    widget.onRatingUpdate?.call(newRating);
  }

  @override
  void dispose() {
    for (var controller in _scaleControllers) {
      controller.dispose();
    }
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: widget.enableGesture
          ? (details) {
              setState(() => _isInteracting = true);
            }
          : null,
      onHorizontalDragUpdate: widget.enableGesture
          ? (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              final newRating = (localPosition.dx / widget.size)
                  .clamp(0.0, widget.maxRating.toDouble());
              _handleRatingUpdate(newRating);
            }
          : null,
      onHorizontalDragEnd: widget.enableGesture
          ? (details) {
              setState(() => _isInteracting = false);
              _handleRatingUpdate(_rating.roundToDouble());
            }
          : null,
      onTapDown: widget.enableGesture
          ? (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              final newRating =
                  ((localPosition.dx / widget.size).floor() + 1).toDouble();
              _handleRatingUpdate(newRating.clamp(0.0, widget.maxRating.toDouble()));
            }
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.maxRating, (index) {
          final filled = index < _rating;
          final partial = _rating - index;
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: ScaleTransition(
              scale: _scaleAnimations[index],
              child: CustomPaint(
                painter: _StarPainter(
                  fillPercentage: filled
                      ? 1.0
                      : (partial > 0 && partial < 1)
                          ? partial
                          : 0.0,
                  activeColor: widget.activeColor,
                  inactiveColor: widget.inactiveColor,
                  isInteracting: _isInteracting,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final double fillPercentage;
  final Color activeColor;
  final Color inactiveColor;
  final bool isInteracting;

  _StarPainter({
    required this.fillPercentage,
    required this.activeColor,
    required this.inactiveColor,
    required this.isInteracting,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / 5;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final innerAngle = angle + math.pi * 2 / 10;
      final innerPoint = Offset(
        center.dx + radius * 0.4 * math.cos(innerAngle),
        center.dy + radius * 0.4 * math.sin(innerAngle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();

    // Draw inactive star
    paint.color = inactiveColor;
    canvas.drawPath(path, paint);

    // Draw active part of star
    if (fillPercentage > 0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(0, 0, size.width * fillPercentage, size.height));
      paint.color = activeColor;
      canvas.drawPath(path, paint);
      canvas.restore();
    }

    // Add shine effect when interacting
    if (isInteracting && fillPercentage > 0) {
      final shinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 2.0;
      canvas.drawPath(path, shinePaint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.isInteracting != isInteracting;
  }
}

import 'package:flutter/widgets.dart';

import '../models/svg_element.dart';

/// Animated SVG element with animation support
class AnimatedSvgElement extends StatefulWidget {
  final SvgElement element;
  final Duration duration;
  final Curve curve;
  final Matrix4? targetTransform;
  final Color? targetColor;

  const AnimatedSvgElement({
    super.key,
    required this.element,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.targetTransform,
    this.targetColor,
  });

  @override
  State<AnimatedSvgElement> createState() => _AnimatedSvgElementState();
}

class _AnimatedSvgElementState extends State<AnimatedSvgElement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _AnimatedElementPainter(
            element: widget.element,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class _AnimatedElementPainter extends CustomPainter {
  final SvgElement element;
  final double progress;

  _AnimatedElementPainter({required this.element, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Apply animation progress to element
    element.paint(canvas, size, {});
  }

  @override
  bool shouldRepaint(_AnimatedElementPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

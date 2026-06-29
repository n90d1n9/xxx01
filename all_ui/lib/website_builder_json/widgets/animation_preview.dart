import 'package:flutter/material.dart';

import '../models/schema/animation/animation.dart' as a;

class AnimationPreview extends StatefulWidget {
  final a.Animation animationConfig;

  const AnimationPreview({super.key, required this.animationConfig});

  @override
  State<AnimationPreview> createState() => _AnimationPreviewState();
}

class _AnimationPreviewState extends State<AnimationPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(
        milliseconds:
            int.tryParse(
              widget.animationConfig.duration?.replaceAll('ms', '') ?? '1000',
            ) ??
            1000,
      ),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.5 + (_controller.value * 0.5),
              child: Opacity(
                opacity: 0.5 + (_controller.value * 0.5),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.animation, color: Colors.white, size: 40),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

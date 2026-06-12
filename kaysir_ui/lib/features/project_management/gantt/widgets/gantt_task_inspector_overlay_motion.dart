import 'package:flutter/material.dart';

class GanttTaskInspectorOverlayMotion extends StatelessWidget {
  const GanttTaskInspectorOverlayMotion({
    required this.isBottomSheet,
    required this.child,
    this.duration = const Duration(milliseconds: 180),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  static const motionKey = ValueKey('gantt-task-inspector-overlay-motion');

  final bool isBottomSheet;
  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: motionKey,
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        final offset =
            isBottomSheet
                ? Offset(0, 22 * (1 - value))
                : Offset(20 * (1 - value), 0);

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: offset,
            child: Transform.scale(
              scale: 0.98 + (0.02 * value),
              alignment:
                  isBottomSheet
                      ? Alignment.bottomCenter
                      : Alignment.centerRight,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

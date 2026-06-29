import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/arrow_provider.dart';
import 'connection_arrow_painter.dart';
import 'connection_painter.dart';

class ConnectionArrow extends ConsumerWidget {
  final Offset start;
  final Offset end;
  final double scale;
  final Color color;
  final Offset controlPoint1;
  final Offset controlPoint2;

  const ConnectionArrow({
    super.key,
    required this.start,
    required this.end,
    required this.scale,
    required this.controlPoint1,
    required this.controlPoint2,
    this.color = Colors.green,
    required ConnectionLineType lineType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arrowPosition = ref.watch(arrowPositionProvider);
    final isHovered = ref.watch(isHoveredProvider);

    return GestureDetector(
      onPanStart: (details) {
        final localPosition = details.localPosition;
        final painter = ConnectionArrowPainter(
          start: start + arrowPosition,
          end: end + arrowPosition,
          scale: scale,
          controlPoint1: controlPoint1 + arrowPosition,
          controlPoint2: controlPoint2 + arrowPosition,
          color: color,
        );

        // Check if the pointer is within the arrow's bounds
        if (painter.hitTest(localPosition)) {
          print('---onPanStart within arrow bounds');
          ref.read(isDraggingProvider.notifier).state = true;
        } else {
          print('---onPanStart outside arrow bounds');
        }
      },
      onPanUpdate: (details) {
        if (ref.read(isDraggingProvider)) {
          ref.read(arrowPositionProvider.notifier).state += details.delta;
        }
      },
      onPanEnd: (_) {
        print('---onPanEnd');
        ref.read(isDraggingProvider.notifier).state = false;
      },
      child: MouseRegion(
        cursor: isHovered ? SystemMouseCursors.grab : SystemMouseCursors.basic,
        onEnter: (_) {
          ref.read(isHoveredProvider.notifier).state = true;
        },
        onExit: (_) {
          ref.read(isHoveredProvider.notifier).state = false;
        },
        child: CustomPaint(
          size: Size.infinite, // Ensure the CustomPaint covers the entire area
          painter: ConnectionArrowPainter(
            start: start + arrowPosition,
            end: end + arrowPosition,
            scale: scale,
            controlPoint1: controlPoint1 + arrowPosition,
            controlPoint2: controlPoint2 + arrowPosition,
            color: color,
          ),
        ),
      ),
    );
  }
}

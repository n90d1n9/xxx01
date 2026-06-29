import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/canvas_transform.dart';
import '../../states/canvas_controller_provider.dart';
import '../../states/canvas_transform_provider.dart';
import '../selection_rectangle_painter.dart';

class CanvasSelectionOverlay extends ConsumerWidget {
  const CanvasSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transform = ref.watch(canvasTransformProvider);
    final controller = ref.read(canvasControllerProvider);

    if (controller.selectionStart == null || controller.selectionEnd == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: CustomPaint(
        painter: SelectionRectanglePainter(
          start: _canvasToScreen(controller.selectionStart!, transform),
          end: _canvasToScreen(controller.selectionEnd!, transform),
        ),
      ),
    );
  }

  Offset _canvasToScreen(Offset canvasPos, CanvasTransform transform) {
    return canvasPos * transform.scale + transform.offset;
  }
}

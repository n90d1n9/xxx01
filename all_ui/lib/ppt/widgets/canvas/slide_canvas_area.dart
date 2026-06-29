import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../docs/widgets/horizontal_ruler.dart';
import '../../states/component_provider.dart';
import '../../states/presentation_provider.dart';
import '../ruler/vertical_ruler.dart';
import 'slide_canvas.dart';

class SlideCanvasArea extends ConsumerStatefulWidget {
  const SlideCanvasArea({super.key});

  @override
  ConsumerState<SlideCanvasArea> createState() => _SlideCanvasAreaState();
}

class _SlideCanvasAreaState extends ConsumerState<SlideCanvasArea> {
  @override
  Widget build(BuildContext context) {
    final showRuler = ref.watch(rulerVisibilityProvider);
    final cursorPosition = ref.watch(cursorPositionProvider);
    final presentation = ref.watch(presentationProvider);

    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          if (showRuler)
            HorizontalRuler(
              width: presentation.slideSize.width,
              cursorX: cursorPosition.dx,
            ),
          Expanded(
            child: Row(
              children: [
                if (showRuler)
                  VerticalRuler(
                    height: presentation.slideSize.height,
                    cursorY: cursorPosition.dy,
                  ),
                Expanded(child: Center(child: SlideCanvas())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

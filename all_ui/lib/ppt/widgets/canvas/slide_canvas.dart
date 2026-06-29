import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/component.dart';
import '../../models/enums.dart';
import '../../models/presentation_component.dart';
import '../../models/rich_text_content.dart';
import '../../states/component_provider.dart';
import '../../states/history_provider.dart';
import '../../states/presentation_provider.dart';
import '../modern_resizable_component.dart';
import '../particle_background.dart';
import 'grid_painter.dart';

class SlideCanvas extends ConsumerStatefulWidget {
  const SlideCanvas({super.key});

  @override
  ConsumerState<SlideCanvas> createState() => _SlideCanvasState();
}

class _SlideCanvasState extends ConsumerState<SlideCanvas> {
  @override
  Widget build(BuildContext context) {
    final presentation = ref.watch(presentationProvider);
    final currentSlide = presentation.slides[presentation.currentSlideIndex];
    final sortedComponents = List<PresentationComponent>.from(
      currentSlide.components,
    )..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    final zoom = ref.watch(zoomLevelProvider);
    final showGrid = ref.watch(showGridProvider);
    final currentTool = ref.watch(currentToolProvider);

    return MouseRegion(
      onHover: (event) {
        ref.read(cursorPositionProvider.notifier).state =
            event.localPosition / zoom;
      },
      child: Transform.scale(
        scale: zoom,
        child: Container(
          width: presentation.slideSize.width,
          height: presentation.slideSize.height,
          decoration: BoxDecoration(
            color:
                currentSlide.backgroundColor ??
                presentation.theme.backgroundColor,
            image:
                currentSlide.backgroundImage != null
                    ? DecorationImage(
                      image: MemoryImage(currentSlide.backgroundImage!),
                      fit: BoxFit.cover,
                    )
                    : null,
            gradient:
                currentSlide.backgroundGradient != null
                    ? LinearGradient(
                      colors: currentSlide.backgroundGradient!.colors,
                      begin: currentSlide.backgroundGradient!.begin,
                      end: currentSlide.backgroundGradient!.end,
                    )
                    : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: GestureDetector(
            onTapDown: (details) {
              final localPos = details.localPosition;
              if (currentTool == ToolMode.text) {
                _addRichText(localPos);
              } else {
                ref.read(selectedComponentProvider.notifier).state = null;
              }
            },
            child: Stack(
              children: [
                if (currentSlide.backgroundParticles != null)
                  ParticleBackground(effect: currentSlide.backgroundParticles!),
                if (showGrid) const GridPainter(),
                ...sortedComponents
                    .map((c) => ModernResizableComponent(component: c))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addRichText(Offset position) {
    final presentation = ref.read(presentationProvider);
    final richText = RichTextContent(
      text: 'Double click to edit',
      style: presentation.theme.bodyStyle,
      alignment: TextAlign.left,
    );

    final component = PresentationComponent(
      id: const Uuid().v4(),
      type: ComponentType.richText,
      position: position,
      size: const Size(300, 100),
      richText: richText,
      backgroundColor: Colors.transparent,
    );

    ref.read(presentationProvider.notifier).addComponent(component);
    ref.read(selectedComponentProvider.notifier).state = component.id;
    ref.read(historyProvider.notifier).addState(ref.read(presentationProvider));
    ref.read(currentToolProvider.notifier).state = ToolMode.select;
  }
}

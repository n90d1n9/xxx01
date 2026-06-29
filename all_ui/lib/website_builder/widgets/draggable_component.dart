import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/family_provider.dart';
import '../states/provider.dart';
import 'component_widget.dart';

class DraggableComponent extends ConsumerWidget {
  final String componentId;

  const DraggableComponent({super.key, required this.componentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final component = ref.watch(componentByIdProvider(componentId));
    final isSelected = ref.watch(isComponentSelectedProvider(componentId));
    final state = ref.watch(designerProvider);
    final notifier = ref.read(designerProvider.notifier);

    if (component == null) return const SizedBox();

    return Positioned(
      left: component.position.dx * state.canvasZoom,
      top: component.position.dy * state.canvasZoom,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (!component.locked) {
            var newPosition = Offset(
              component.position.dx + details.delta.dx / state.canvasZoom,
              component.position.dy + details.delta.dy / state.canvasZoom,
            );

            if (state.snapToGrid) {
              const gridSize = 20.0;
              newPosition = Offset(
                (newPosition.dx / gridSize).round() * gridSize,
                (newPosition.dy / gridSize).round() * gridSize,
              );
            }

            notifier.updateComponent(
              componentId,
              component.copyWith(position: newPosition),
            );
          }
        },
        onTap: () {
          notifier.selectComponent(
            componentId,
            multiSelect: HardwareKeyboard.instance.isShiftPressed,
          );
        },
        child: Transform.scale(
          scale: state.canvasZoom,
          alignment: Alignment.topLeft,
          child: Container(
            width: component.size.width,
            height: component.size.height,
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    isSelected
                        ? Colors.blue
                        : (component.locked ? Colors.red : Colors.transparent),
                width: 2,
              ),
            ),
            child: ComponentWidget(component: component),
          ),
        ),
      ),
    );
  }
}

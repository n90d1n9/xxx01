import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/component_provider.dart';
import '../states/provider.dart';
import 'component_renderer.dart';

class DraggableComponentWidget extends ConsumerWidget {
  final String componentId;

  const DraggableComponentWidget({super.key, required this.componentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final component = ref.watch(componentByIdProvider(componentId));
    final state = ref.watch(designerProvider);
    final notifier = ref.read(designerProvider.notifier);

    if (component == null) return const SizedBox();

    final isSelected = state.selectedComponentIds.contains(componentId);

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
              newPosition = Offset(
                (newPosition.dx / state.gridSize).round() * state.gridSize,
                (newPosition.dy / state.gridSize).round() * state.gridSize,
              );
            }

            notifier.updateComponent(
              componentId,
              component.copyWith(position: newPosition),
            );
          }
        },
        onTap:
            () => notifier.selectComponent(
              componentId,
              multiSelect: HardwareKeyboard.instance.isShiftPressed,
            ),
        child: Transform.scale(
          scale: state.canvasZoom,
          alignment: Alignment.topLeft,
          child: Transform.rotate(
            angle: component.rotation * math.pi / 180,
            child: Container(
              width: component.size.width,
              height: component.size.height,
              decoration: BoxDecoration(
                border:
                    isSelected
                        ? Border.all(color: Colors.blue, width: 3)
                        : component.locked
                        ? Border.all(color: Colors.red, width: 2)
                        : null,
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ]
                        : null,
              ),
              child: ComponentRenderer(component: component),
            ),
          ),
        ),
      ),
    );
  }
}

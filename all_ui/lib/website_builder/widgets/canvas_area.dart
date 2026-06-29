import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/component_provider.dart';
import '../states/provider.dart';
import 'draggable_component_widget.dart';
import 'grind_painter.dart';

class CanvasArea extends ConsumerWidget {
  const CanvasArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designerProvider);
    final sortedComponents = ref.watch(sortedComponentsProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: state.isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (state.showGrid)
              CustomPaint(
                size: Size.infinite,
                painter: GridPainter(
                  isDark: state.isDarkMode,
                  gridSize: state.gridSize,
                ),
              ),
            ...sortedComponents
                .where((c) => c.visible)
                .map((c) => DraggableComponentWidget(componentId: c.id)),
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.straighten, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      '${state.currentBreakpoint.name.toUpperCase()} • ${state.currentBreakpoint.maxWidth.toInt()}px',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

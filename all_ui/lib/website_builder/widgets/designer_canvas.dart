import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/component_provider.dart';
import '../services/designer_service.dart';
import '../states/provider.dart';
import 'draggable_component.dart';
import 'grind_painter.dart';
import 'zoom_control.dart';

class DesignerCanvas extends ConsumerWidget {
  const DesignerCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designerProvider);
    final sortedComponents = ref.watch(sortedComponentsProvider);

    return Container(
      color: state.isDarkMode ? Colors.grey : Colors.white,
      margin: const EdgeInsets.all(16),
      child: Stack(
        children: [
          if (state.showGrid)
            CustomPaint(
              size: Size.infinite,
              painter: GridPainter(isDark: state.isDarkMode),
            ),
          ...sortedComponents.map((c) => DraggableComponent(componentId: c.id)),
          const Positioned(bottom: 16, right: 16, child: ZoomControls()),

          // Collaborator cursors
          ...state.collaborators.entries.map(
            (entry) => Positioned(
              left: entry.value['x'] ?? 0,
              top: entry.value['y'] ?? 0,
              child: Icon(Icons.touch_app, color: Colors.red, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

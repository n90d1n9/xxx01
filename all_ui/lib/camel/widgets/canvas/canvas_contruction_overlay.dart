import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/provider.dart';
import '../../states/select_route_provider.dart';

class CanvasInstructionsOverlay extends ConsumerWidget {
  const CanvasInstructionsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(selectedRouteProvider);
    final isDraggingComponent = ref.watch(isDraggingComponentProvider);

    if (route == null || route.nodes.isNotEmpty || isDraggingComponent) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Drag components here to start building',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildShortcutChip(
                  Icons.control_camera,
                  'Shift+Drag',
                  'Select',
                ),
                _buildShortcutChip(Icons.pan_tool, 'Drag', 'Pan'),
                _buildShortcutChip(Icons.zoom_in, 'Scroll/Pinch', 'Zoom'),
                _buildShortcutChip(Icons.touch_app, 'Two-finger', 'Pan'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutChip(IconData icon, String key, String action) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text('$key: $action', style: const TextStyle(fontSize: 11)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

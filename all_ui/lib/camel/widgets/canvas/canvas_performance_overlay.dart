import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/select_route_provider.dart';

class CanvasPerformanceOverlay extends ConsumerWidget {
  const CanvasPerformanceOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(selectedRouteProvider);

    if (route == null || route.nodes.length <= 50) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              'Large route (${route.nodes.length} nodes)',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'canvas_transform_provider.dart';

class CanvasZoomIndicator extends ConsumerWidget {
  const CanvasZoomIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transform = ref.watch(canvasTransformProvider);

    return Positioned(
      bottom: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.zoom_in, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              '${(transform.scale * 100).toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

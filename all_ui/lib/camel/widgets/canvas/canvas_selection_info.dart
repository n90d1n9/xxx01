import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/provider.dart';

class CanvasSelectionInfo extends ConsumerWidget {
  const CanvasSelectionInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedNodeIds = ref.watch(selectedNodesProvider);
    final showMiniMap = ref.watch(showMiniMapProvider);

    if (selectedNodeIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 16,
      right: showMiniMap ? 182 : 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_box, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              '${selectedNodeIds.length} selected',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

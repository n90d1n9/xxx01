import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/provider.dart';

class CanvasDropZoneIndicator extends ConsumerWidget {
  const CanvasDropZoneIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDraggingComponent = ref.watch(isDraggingComponentProvider);

    if (!isDraggingComponent) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            width: 4,
          ),
          color: Theme.of(context).primaryColor.withOpacity(0.05),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Drop here to add component',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

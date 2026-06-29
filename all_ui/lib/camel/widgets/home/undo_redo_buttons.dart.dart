import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/route_history_provider.dart';

class UndoRedoButtons extends ConsumerWidget {
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const UndoRedoButtons({
    super.key,
    required this.onUndo,
    required this.onRedo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(routeHistoryProvider.notifier);
    final canUndo = history.canUndo;
    final canRedo = history.canRedo;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: canUndo ? onUndo : null,
          tooltip: 'Undo (Ctrl+Z)',
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: canRedo ? onRedo : null,
          tooltip: 'Redo (Ctrl+Y)',
        ),
      ],
    );
  }
}

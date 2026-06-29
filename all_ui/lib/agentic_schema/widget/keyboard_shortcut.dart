import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/workflow/workflow_provider.dart';

class KeyboardShortcuts extends ConsumerWidget {
  final Widget child;

  const KeyboardShortcuts({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          final isControl = event.isControlPressed;
          final isShift = event.isShiftPressed;

          if (isControl && event.logicalKey == LogicalKeyboardKey.keyZ) {
            if (isShift) {
              ref.read(workflowProvider.notifier).redo();
            } else {
              ref.read(workflowProvider.notifier).undo();
            }
            return KeyEventResult.handled;
          }

          if (isControl && event.logicalKey == LogicalKeyboardKey.keyC) {
            ref.read(workflowProvider.notifier).copySelectedNodes();
            return KeyEventResult.handled;
          }

          if (isControl && event.logicalKey == LogicalKeyboardKey.keyV) {
            ref.read(workflowProvider.notifier).pasteNodes(Offset.zero);
            return KeyEventResult.handled;
          }

          if (event.logicalKey == LogicalKeyboardKey.delete ||
              event.logicalKey == LogicalKeyboardKey.backspace) {
            ref.read(workflowProvider.notifier).deleteSelectedNodes();
            return KeyEventResult.handled;
          }
        }

        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}

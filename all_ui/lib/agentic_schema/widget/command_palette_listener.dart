import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/command_palette_provider.dart';

class CommandPaletteListener extends ConsumerWidget {
  final Widget child;

  const CommandPaletteListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      onKey: (node, event) {
        if (event is KeyDownEvent) {
          // Cmd+K or Ctrl+K
          if ((HardwareKeyboard.instance.isMetaPressed ||
                  HardwareKeyboard.instance.isControlPressed) &&
              event.logicalKey == LogicalKeyboardKey.keyK) {
            ref.read(commandPaletteProvider.notifier).show();
            return KeyEventResult.handled;
          }

          // Handle navigation in command palette
          final state = ref.read(commandPaletteProvider);
          if (state.isVisible) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              ref.read(commandPaletteProvider.notifier).selectNext();
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              ref.read(commandPaletteProvider.notifier).selectPrevious();
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              ref.read(commandPaletteProvider.notifier).executeSelected();
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              ref.read(commandPaletteProvider.notifier).hide();
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}

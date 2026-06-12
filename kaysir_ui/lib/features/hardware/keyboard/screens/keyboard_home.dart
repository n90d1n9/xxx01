import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../states/shortcut.dart';

class KeyboardShortcutDemo extends ConsumerWidget {
  const KeyboardShortcutDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcutState = ref.watch(keyboardShortcutProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard Shortcuts Demo')),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            // Update modifier keys state
            ref
                .read(keyboardShortcutProvider.notifier)
                .updateModifierKeys(
                  isControlPressed: event.isControlPressed,
                  isShiftPressed: event.isShiftPressed,
                  isAltPressed: event.isAltPressed,
                );

            // Handle keyboard shortcuts
            if (event.isControlPressed) {
              switch (event.logicalKey) {
                case LogicalKeyboardKey.keyS:
                  ref
                      .read(keyboardShortcutProvider.notifier)
                      .updateShortcut('Save (Ctrl + S)');
                  _handleSave();
                  return KeyEventResult.handled;
                case LogicalKeyboardKey.keyC:
                  ref
                      .read(keyboardShortcutProvider.notifier)
                      .updateShortcut('Copy (Ctrl + C)');
                  _handleCopy();
                  return KeyEventResult.handled;
                case LogicalKeyboardKey.keyV:
                  ref
                      .read(keyboardShortcutProvider.notifier)
                      .updateShortcut('Paste (Ctrl + V)');
                  _handlePaste();
                  return KeyEventResult.handled;
              }
            }
          }
          return KeyEventResult.ignored;
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Press a keyboard shortcut',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                'Last pressed shortcut: ${shortcutState.lastPressedShortcut}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text('Modifier keys:', style: const TextStyle(fontSize: 16)),
              Text(
                'Control: ${shortcutState.isControlPressed}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Shift: ${shortcutState.isShiftPressed}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Alt: ${shortcutState.isAltPressed}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    debugPrint('Save action triggered');
  }

  void _handleCopy() {
    debugPrint('Copy action triggered');
  }

  void _handlePaste() {
    debugPrint('Paste action triggered');
  }
}

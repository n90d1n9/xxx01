import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardShortcuts extends StatelessWidget {
  final Widget child;

  const KeyboardShortcuts({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.delete): const DeleteIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
            const UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY):
            const RedoIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const PlayPauseIntent(),
      },
      actions: {
        DeleteIntent: CallbackAction<DeleteIntent>(
          onInvoke: (intent) => debugPrint('Delete'),
        ),
        UndoIntent: CallbackAction<UndoIntent>(
          onInvoke: (intent) => debugPrint('Undo'),
        ),
        RedoIntent: CallbackAction<RedoIntent>(
          onInvoke: (intent) => debugPrint('Redo'),
        ),
        PlayPauseIntent: CallbackAction<PlayPauseIntent>(
          onInvoke: (intent) => debugPrint('Play/Pause'),
        ),
      },
      child: child,
    );
  }
}

class DeleteIntent extends Intent {
  const DeleteIntent();
}

class UndoIntent extends Intent {
  const UndoIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}

class PlayPauseIntent extends Intent {
  const PlayPauseIntent();
}

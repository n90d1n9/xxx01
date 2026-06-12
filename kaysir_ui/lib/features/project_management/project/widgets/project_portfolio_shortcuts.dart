import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProjectPortfolioShortcuts extends StatelessWidget {
  const ProjectPortfolioShortcuts({
    required this.child,
    required this.onSearchPressed,
    required this.onClearViewPressed,
    super.key,
  });

  static const searchShortcutLabel = 'Ctrl/Cmd+F';
  static const clearViewShortcutLabel = 'Ctrl/Cmd+Shift+L';

  final Widget child;
  final VoidCallback onSearchPressed;
  final VoidCallback onClearViewPressed;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            onSearchPressed,
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
            onSearchPressed,
        const SingleActivator(
              LogicalKeyboardKey.keyL,
              control: true,
              shift: true,
            ):
            onClearViewPressed,
        const SingleActivator(LogicalKeyboardKey.keyL, meta: true, shift: true):
            onClearViewPressed,
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}

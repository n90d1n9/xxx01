import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminShellShortcuts extends StatelessWidget {
  const AdminShellShortcuts({
    super.key,
    required this.child,
    required this.onSearchPressed,
  });

  static const searchShortcutLabel = 'Ctrl/Cmd+K';

  final Widget child;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            onSearchPressed,
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            onSearchPressed,
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}

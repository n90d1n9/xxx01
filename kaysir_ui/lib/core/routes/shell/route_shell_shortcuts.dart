import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

/// Keyboard shortcuts for the workspace route shell.
class RouteShellShortcuts extends StatelessWidget {
  const RouteShellShortcuts({
    super.key,
    required this.child,
    required this.onSearchPressed,
  });

  /// Standard command palette shortcut label used by shell affordances.
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

@Preview(name: 'Route shell shortcuts')
Widget routeShellShortcutsPreview() {
  return const MaterialApp(
    home: RouteShellShortcuts(
      onSearchPressed: _previewSearchPressed,
      child: Scaffold(body: Center(child: Text('Route shell'))),
    ),
  );
}

void _previewSearchPressed() {}

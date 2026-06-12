import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GanttChartShortcuts extends StatelessWidget {
  const GanttChartShortcuts({
    required this.child,
    required this.onDismissPressed,
    required this.onSearchPressed,
    this.onToggleControlsPressed,
    this.onOpenSettingsPressed,
    this.onClearFiltersPressed,
    this.onUndoPressed,
    this.onPreviousTaskPressed,
    this.onNextTaskPressed,
    super.key,
  });

  static const dismissShortcutLabel = 'Esc';
  static const searchShortcutLabel = 'Ctrl/Cmd+F';
  static const toggleControlsShortcutLabel = r'Ctrl/Cmd+\';
  static const settingsShortcutLabel = 'Ctrl/Cmd+,';
  static const clearFiltersShortcutLabel = 'Ctrl/Cmd+Shift+L';
  static const undoShortcutLabel = 'Ctrl/Cmd+Z';
  static const previousTaskShortcutLabel = 'Ctrl/Cmd+Left';
  static const nextTaskShortcutLabel = 'Ctrl/Cmd+Right';

  final Widget child;
  final VoidCallback onDismissPressed;
  final VoidCallback onSearchPressed;
  final VoidCallback? onToggleControlsPressed;
  final VoidCallback? onOpenSettingsPressed;
  final VoidCallback? onClearFiltersPressed;
  final VoidCallback? onUndoPressed;
  final VoidCallback? onPreviousTaskPressed;
  final VoidCallback? onNextTaskPressed;

  @override
  Widget build(BuildContext context) {
    final bindings = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.escape): onDismissPressed,
      const SingleActivator(LogicalKeyboardKey.keyF, control: true):
          onSearchPressed,
      const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
          onSearchPressed,
    };

    void bindMacAndControl(
      LogicalKeyboardKey key,
      VoidCallback? callback, {
      bool shift = false,
    }) {
      if (callback == null) return;

      bindings[SingleActivator(key, control: true, shift: shift)] = callback;
      bindings[SingleActivator(key, meta: true, shift: shift)] = callback;
    }

    bindMacAndControl(LogicalKeyboardKey.backslash, onToggleControlsPressed);
    bindMacAndControl(LogicalKeyboardKey.comma, onOpenSettingsPressed);
    bindMacAndControl(LogicalKeyboardKey.keyZ, onUndoPressed);
    bindMacAndControl(LogicalKeyboardKey.arrowLeft, onPreviousTaskPressed);
    bindMacAndControl(LogicalKeyboardKey.arrowRight, onNextTaskPressed);
    bindMacAndControl(
      LogicalKeyboardKey.keyL,
      onClearFiltersPressed,
      shift: true,
    );

    return CallbackShortcuts(
      bindings: bindings,
      child: Focus(autofocus: true, child: child),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardShortcutHandler {
  final Map<LogicalKeySet, VoidCallback> shortcuts = {};

  KeyboardShortcutHandler({
    VoidCallback? onUndo,
    VoidCallback? onRedo,
    VoidCallback? onSave,
    VoidCallback? onDelete,
    VoidCallback? onSelectAll,
    VoidCallback? onCopy,
    VoidCallback? onPaste,
    VoidCallback? onDuplicate,
    VoidCallback? onSearch,
  }) {
    if (onUndo != null) {
      shortcuts[LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyZ,
          )] =
          onUndo;
    }
    if (onRedo != null) {
      shortcuts[LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyY,
          )] =
          onRedo;
    }
    if (onSave != null) {
      shortcuts[LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyS,
          )] =
          onSave;
    }
    if (onDelete != null) {
      shortcuts[LogicalKeySet(LogicalKeyboardKey.delete)] = onDelete;
    }
    if (onSelectAll != null) {
      shortcuts[LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyA,
          )] =
          onSelectAll;
    }
    if (onCopy != null) {
      shortcuts[LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyC,
          )] =
          onCopy;
    }
    if (onPaste != null) {
      shortcuts[LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyV,
          )] =
          onPaste;
    }
    if (onDuplicate != null) {
      shortcuts[LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyD,
          )] =
          onDuplicate;
    }
    if (onSearch != null) {
      shortcuts[LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyK,
          )] =
          onSearch;
    }
  }

  Widget wrap(Widget child) {
    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(autofocus: true, child: child),
    );
  }
}

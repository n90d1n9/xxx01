import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_controller.dart';

class WebsiteBuilderKeyboardShortcuts extends StatelessWidget {
  final WebsiteBuilderController controller;
  final Widget child;

  const WebsiteBuilderKeyboardShortcuts({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        if (_hasEditableTextFocus()) return KeyEventResult.ignored;

        final handled = _handleKeyEvent(event);
        return handled ? KeyEventResult.handled : KeyEventResult.ignored;
      },
      child: child,
    );
  }

  bool _handleKeyEvent(KeyEvent event) {
    final keyboard = HardwareKeyboard.instance;
    final key = event.logicalKey;
    final hasCommandModifier =
        keyboard.isMetaPressed || keyboard.isControlPressed;
    final hasShiftModifier = keyboard.isShiftPressed;

    if (hasCommandModifier && key == LogicalKeyboardKey.keyZ) {
      if (hasShiftModifier) {
        controller.redo();
      } else {
        controller.undo();
      }
      return true;
    }

    if (hasCommandModifier && key == LogicalKeyboardKey.keyY) {
      controller.redo();
      return true;
    }

    if (hasCommandModifier && key == LogicalKeyboardKey.keyD) {
      controller.duplicateSelected();
      return true;
    }

    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      controller.removeSelected();
      return true;
    }

    if (key == LogicalKeyboardKey.escape) {
      controller.selectComponent(null);
      return true;
    }

    final nudge = _nudgeForKey(
      key,
      controller.canvasConfig,
      isLargeStep: hasShiftModifier,
    );
    if (nudge != null) {
      controller.nudgeSelected(nudge);
      return true;
    }

    return false;
  }
}

bool _hasEditableTextFocus() {
  final focusedContext = FocusManager.instance.primaryFocus?.context;
  if (focusedContext == null) return false;
  if (focusedContext.widget is EditableText) return true;
  return focusedContext.findAncestorWidgetOfExactType<EditableText>() != null;
}

Offset? _nudgeForKey(
  LogicalKeyboardKey key,
  BuilderCanvasConfig config, {
  required bool isLargeStep,
}) {
  final step = _nudgeStep(config, isLargeStep: isLargeStep);
  if (key == LogicalKeyboardKey.arrowLeft) return Offset(-step, 0);
  if (key == LogicalKeyboardKey.arrowRight) return Offset(step, 0);
  if (key == LogicalKeyboardKey.arrowUp) return Offset(0, -step);
  if (key == LogicalKeyboardKey.arrowDown) return Offset(0, step);
  return null;
}

double _nudgeStep(BuilderCanvasConfig config, {required bool isLargeStep}) {
  if (!config.snapToGrid) return isLargeStep ? 32.0 : 8.0;

  return switch (config.layoutMechanism) {
    BuilderLayoutMechanism.tabularColumns =>
      (config.tabularColumnWidth + config.tabularColumnGap) *
          (isLargeStep ? 2 : 1),
    BuilderLayoutMechanism.autoGrid =>
      (config.autoGridColumnWidth + config.autoGridGap) * (isLargeStep ? 2 : 1),
    _ => config.gridSize * (isLargeStep ? 2 : 1),
  };
}

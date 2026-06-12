import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../provider/layout_state_provider.dart';

/// Runs canvas-placement actions and reports consistent selection feedback.
class LayoutCanvasPlacementActionService {
  const LayoutCanvasPlacementActionService();

  bool moveSelectionToOrigin(
    BuildContext context,
    WidgetRef ref, {
    double padding = 0,
    String subject = 'selection',
  }) {
    return _runPlacementAction(
      context,
      ref,
      action:
          (notifier) => notifier.moveSelectedToCanvasOrigin(padding: padding),
      successMessage: 'Moved $subject to canvas origin',
      noChangeMessage: '${_capitalize(subject)} is already at canvas origin',
    );
  }

  bool moveSelectionToCorner(
    BuildContext context,
    WidgetRef ref,
    CanvasCorner corner, {
    Size? canvasSize,
    double padding = 0,
    String subject = 'selection',
  }) {
    final cornerLabel = _cornerLabel(corner);

    return _runPlacementAction(
      context,
      ref,
      action:
          (notifier) => notifier.moveSelectedToCanvasCorner(
            corner,
            canvasSize: canvasSize,
            padding: padding,
          ),
      successMessage: 'Moved $subject to $cornerLabel corner',
      noChangeMessage:
          '${_capitalize(subject)} is already at $cornerLabel corner',
    );
  }

  bool moveSelectionToEdge(
    BuildContext context,
    WidgetRef ref,
    CanvasEdge edge, {
    Size? canvasSize,
    double padding = 0,
    String subject = 'selection',
  }) {
    final edgeLabel = _edgeLabel(edge);

    return _runPlacementAction(
      context,
      ref,
      action:
          (notifier) => notifier.moveSelectedToCanvasEdge(
            edge,
            canvasSize: canvasSize,
            padding: padding,
          ),
      successMessage: 'Moved $subject to $edgeLabel edge',
      noChangeMessage: '${_capitalize(subject)} is already on $edgeLabel edge',
    );
  }

  bool pinSelectionToEdge(
    BuildContext context,
    WidgetRef ref,
    CanvasEdge edge, {
    Size? canvasSize,
    double padding = 0,
    String subject = 'selection',
  }) {
    final edgeLabel = _edgeLabel(edge);

    return _runPlacementAction(
      context,
      ref,
      action:
          (notifier) => notifier.pinSelectedToCanvasEdge(
            edge,
            canvasSize: canvasSize,
            padding: padding,
          ),
      successMessage: 'Pinned $subject to $edgeLabel edge',
      noChangeMessage:
          '${_capitalize(subject)} is already pinned to $edgeLabel edge',
    );
  }

  bool centerSelectionOnCanvas(
    BuildContext context,
    WidgetRef ref, {
    bool horizontal = true,
    bool vertical = true,
    Size? canvasSize,
    String subject = 'selection',
  }) {
    return _runPlacementAction(
      context,
      ref,
      action:
          (notifier) => notifier.centerSelectedOnCanvas(
            horizontal: horizontal,
            vertical: vertical,
            canvasSize: canvasSize,
          ),
      successMessage:
          'Centered $subject ${_centerSuccessQualifier(horizontal: horizontal, vertical: vertical)}',
      noChangeMessage:
          '${_capitalize(subject)} is already ${_centeredQualifier(horizontal: horizontal, vertical: vertical)}',
    );
  }

  bool _runPlacementAction(
    BuildContext context,
    WidgetRef ref, {
    required void Function(LayoutStateNotifier notifier) action,
    required String successMessage,
    required String noChangeMessage,
  }) {
    final layoutState = ref.read(layoutStateProvider);
    final selectedComponents = layoutState.selectedComponents;
    final movableComponents =
        selectedComponents.where((component) => !component.isLocked).toList();

    if (selectedComponents.isEmpty) {
      _showStatus(context, 'Select a component first');
      return false;
    }

    if (movableComponents.isEmpty) {
      _showStatus(context, 'Selected components are locked');
      return false;
    }

    final beforePositions = _positionsById(movableComponents);
    action(ref.read(layoutStateProvider.notifier));

    final afterComponents = ref.read(layoutStateProvider).selectedComponents;
    final afterPositions = _positionsById(afterComponents);
    final moved = beforePositions.entries.any((entry) {
      final after = afterPositions[entry.key];
      return after != null && (after - entry.value).distance >= 0.01;
    });

    _showStatus(context, moved ? successMessage : noChangeMessage);
    return moved;
  }

  Map<String, Offset> _positionsById(Iterable<ComponentData> components) {
    return {
      for (final component in components) component.id: component.position,
    };
  }

  String _cornerLabel(CanvasCorner corner) {
    return switch (corner) {
      CanvasCorner.topLeft => 'top-left',
      CanvasCorner.topRight => 'top-right',
      CanvasCorner.bottomLeft => 'bottom-left',
      CanvasCorner.bottomRight => 'bottom-right',
    };
  }

  String _edgeLabel(CanvasEdge edge) {
    return switch (edge) {
      CanvasEdge.top => 'top',
      CanvasEdge.right => 'right',
      CanvasEdge.bottom => 'bottom',
      CanvasEdge.left => 'left',
    };
  }

  String _centerSuccessQualifier({
    required bool horizontal,
    required bool vertical,
  }) {
    if (horizontal && vertical) return 'on canvas';
    if (horizontal) return 'horizontally on canvas';
    if (vertical) return 'vertically on canvas';
    return 'on canvas';
  }

  String _centeredQualifier({
    required bool horizontal,
    required bool vertical,
  }) {
    if (horizontal && vertical) return 'centered on canvas';
    if (horizontal) return 'centered horizontally on canvas';
    if (vertical) return 'centered vertically on canvas';
    return 'centered on canvas';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  void _showStatus(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

const layoutCanvasPlacementActionService = LayoutCanvasPlacementActionService();

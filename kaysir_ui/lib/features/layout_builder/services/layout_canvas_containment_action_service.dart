import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../provider/layout_state_provider.dart';

/// Runs canvas-containment actions and reports consistent user-facing feedback.
class LayoutCanvasContainmentActionService {
  const LayoutCanvasContainmentActionService();

  bool moveSelectionInsideCanvas(
    BuildContext context,
    WidgetRef ref, {
    Size? canvasSize,
    String subject = 'selection',
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
    final notifier = ref.read(layoutStateProvider.notifier);
    notifier.moveSelectedInsideCanvas(canvasSize: canvasSize);

    final afterComponents = ref.read(layoutStateProvider).selectedComponents;
    final afterPositions = _positionsById(afterComponents);
    final moved = beforePositions.entries.any((entry) {
      final after = afterPositions[entry.key];
      return after != null && (after - entry.value).distance >= 0.01;
    });

    _showStatus(
      context,
      moved
          ? 'Moved $subject inside canvas'
          : '${_capitalize(subject)} is already inside canvas',
    );
    return moved;
  }

  bool fitSelectionInsideCanvas(
    BuildContext context,
    WidgetRef ref, {
    Size? canvasSize,
    double padding = 24,
    String subject = 'selection',
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

    final beforeGeometry = _geometryById(movableComponents);
    final notifier = ref.read(layoutStateProvider.notifier);
    notifier.fitSelectedInsideCanvas(canvasSize: canvasSize, padding: padding);

    final afterComponents = ref.read(layoutStateProvider).selectedComponents;
    final afterGeometry = _geometryById(afterComponents);
    final fitted = beforeGeometry.entries.any((entry) {
      final after = afterGeometry[entry.key];
      return after != null && !entry.value.isSameAs(after);
    });

    _showStatus(
      context,
      fitted
          ? 'Fit $subject into canvas'
          : '${_capitalize(subject)} already fits inside canvas',
    );
    return fitted;
  }

  Map<String, Offset> _positionsById(List<ComponentData> components) {
    return {
      for (final component in components) component.id: component.position,
    };
  }

  Map<String, _ComponentGeometrySnapshot> _geometryById(
    List<ComponentData> components,
  ) {
    return {
      for (final component in components)
        component.id: _ComponentGeometrySnapshot(
          position: component.position,
          size: component.size,
        ),
    };
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

const layoutCanvasContainmentActionService =
    LayoutCanvasContainmentActionService();

/// Captures component geometry for lightweight action result comparisons.
class _ComponentGeometrySnapshot {
  const _ComponentGeometrySnapshot({
    required this.position,
    required this.size,
  });

  final Offset position;
  final Size size;

  bool isSameAs(_ComponentGeometrySnapshot other) {
    return (position - other.position).distance < 0.01 &&
        (size.width - other.size.width).abs() < 0.01 &&
        (size.height - other.size.height).abs() < 0.01;
  }
}

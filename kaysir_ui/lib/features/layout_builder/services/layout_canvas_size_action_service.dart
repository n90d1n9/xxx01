import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/layout_state.dart';
import '../provider/layout_state_provider.dart';

/// Runs canvas-size actions and reports consistent editing feedback.
class LayoutCanvasSizeActionService {
  const LayoutCanvasSizeActionService();

  bool rotateCanvasSize(BuildContext context, WidgetRef ref) {
    final layoutState = ref.read(layoutStateProvider);
    final size = layoutState.config.canvasSize;
    if ((size.width - size.height).abs() < 0.01) {
      _showStatus(context, 'Canvas is already square');
      return false;
    }

    return _runCanvasAction(
      context,
      ref,
      action: (notifier) => notifier.rotateCanvasSize(),
      successMessage: 'Rotated canvas size',
      noChangeMessage: 'Canvas size did not change',
    );
  }

  bool fitCanvasToContent(
    BuildContext context,
    WidgetRef ref, {
    double padding = 24,
  }) {
    final layoutState = ref.read(layoutStateProvider);
    if (!_hasVisibleComponents(layoutState)) {
      _showStatus(context, 'No visible components');
      return false;
    }

    return _runCanvasAction(
      context,
      ref,
      action: (notifier) => notifier.fitCanvasToContent(padding: padding),
      successMessage: 'Fit canvas to content',
      noChangeMessage: 'Canvas already fits content',
    );
  }

  bool trimCanvasToContent(
    BuildContext context,
    WidgetRef ref, {
    double padding = 24,
  }) {
    final layoutState = ref.read(layoutStateProvider);
    if (!_hasVisibleComponents(layoutState)) {
      _showStatus(context, 'No visible components');
      return false;
    }

    return _runCanvasAction(
      context,
      ref,
      action: (notifier) => notifier.trimCanvasToContent(padding: padding),
      successMessage: 'Trimmed canvas to content',
      noChangeMessage: 'Canvas is already trimmed to content',
    );
  }

  bool fitCanvasToSelection(
    BuildContext context,
    WidgetRef ref, {
    double padding = 24,
  }) {
    final layoutState = ref.read(layoutStateProvider);
    final selectedComponents = layoutState.selectedComponents;
    if (selectedComponents.isEmpty) {
      _showStatus(context, 'Select a component first');
      return false;
    }

    if (!selectedComponents.any((component) => component.isVisible)) {
      _showStatus(context, 'Select a visible component first');
      return false;
    }

    return _runCanvasAction(
      context,
      ref,
      action: (notifier) => notifier.fitCanvasToSelection(padding: padding),
      successMessage: 'Fit canvas to selection',
      noChangeMessage: 'Canvas already fits selection',
    );
  }

  bool _runCanvasAction(
    BuildContext context,
    WidgetRef ref, {
    required void Function(LayoutStateNotifier notifier) action,
    required String successMessage,
    required String noChangeMessage,
  }) {
    final before = _CanvasLayoutSnapshot.fromState(
      ref.read(layoutStateProvider),
    );
    action(ref.read(layoutStateProvider.notifier));
    final after = _CanvasLayoutSnapshot.fromState(
      ref.read(layoutStateProvider),
    );
    final changed = !before.isSameAs(after);

    _showStatus(context, changed ? successMessage : noChangeMessage);
    return changed;
  }

  bool _hasVisibleComponents(LayoutState layoutState) {
    return layoutState.components.any((component) => component.isVisible);
  }

  void _showStatus(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

const layoutCanvasSizeActionService = LayoutCanvasSizeActionService();

/// Captures canvas size and component geometry for canvas action comparisons.
class _CanvasLayoutSnapshot {
  const _CanvasLayoutSnapshot({
    required this.canvasSize,
    required this.geometryById,
  });

  final Size canvasSize;
  final Map<String, _ComponentGeometrySnapshot> geometryById;

  factory _CanvasLayoutSnapshot.fromState(LayoutState layoutState) {
    return _CanvasLayoutSnapshot(
      canvasSize: layoutState.config.canvasSize,
      geometryById: {
        for (final component in layoutState.components)
          component.id: _ComponentGeometrySnapshot(
            position: component.position,
            size: component.size,
          ),
      },
    );
  }

  bool isSameAs(_CanvasLayoutSnapshot other) {
    if ((canvasSize.width - other.canvasSize.width).abs() >= 0.01 ||
        (canvasSize.height - other.canvasSize.height).abs() >= 0.01) {
      return false;
    }

    if (geometryById.length != other.geometryById.length) return false;

    return geometryById.entries.every((entry) {
      final otherGeometry = other.geometryById[entry.key];
      return otherGeometry != null && entry.value.isSameAs(otherGeometry);
    });
  }
}

/// Captures component geometry for lightweight canvas action comparisons.
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/canvas_viewport_provider.dart';
import '../provider/layout_state_provider.dart';

/// Runs canvas viewport actions and reports consistent editor feedback.
class LayoutCanvasViewActionService {
  const LayoutCanvasViewActionService();

  bool zoomIn(BuildContext context, WidgetRef ref) {
    return _runZoomAction(
      context,
      ref,
      action: (notifier) => notifier.zoomIn(),
      noChangeMessage: 'Already at maximum zoom',
    );
  }

  bool zoomOut(BuildContext context, WidgetRef ref) {
    return _runZoomAction(
      context,
      ref,
      action: (notifier) => notifier.zoomOut(),
      noChangeMessage: 'Already at minimum zoom',
    );
  }

  bool resetZoom(BuildContext context, WidgetRef ref) {
    return _runZoomAction(
      context,
      ref,
      action: (notifier) => notifier.resetZoom(),
      successMessage: 'Reset zoom to 100%',
      noChangeMessage: 'Zoom is already 100%',
    );
  }

  bool setZoom(
    BuildContext context,
    WidgetRef ref,
    double zoom, {
    bool rememberRecent = false,
  }) {
    if (rememberRecent) {
      rememberCanvasZoomPreset(zoom);
    }

    return _runZoomAction(
      context,
      ref,
      action: (notifier) => notifier.setZoom(zoom),
      successMessage: 'Zoom set to ${_zoomPercentLabel(zoom)}',
      noChangeMessage: 'Already at ${_zoomPercentLabel(zoom)}',
    );
  }

  bool fitCanvas(BuildContext context, WidgetRef ref) {
    ref.read(canvasViewportProvider.notifier).fitToScreen();
    _showStatus(context, 'Fit canvas to screen');
    return true;
  }

  bool fitSelection(BuildContext context, WidgetRef ref) {
    final selectedComponents = ref.read(layoutStateProvider).selectedComponents;
    if (selectedComponents.isEmpty) {
      _showStatus(context, 'Select a component first');
      return false;
    }

    if (!selectedComponents.any((component) => component.isVisible)) {
      _showStatus(context, 'Select a visible component first');
      return false;
    }

    ref.read(canvasViewportProvider.notifier).fitSelection();
    _showStatus(context, 'Fit selection to screen');
    return true;
  }

  bool togglePrecisionGuides(BuildContext context, WidgetRef ref) {
    final before = ref.read(canvasViewportProvider).showPrecisionGuides;
    ref.read(canvasViewportProvider.notifier).togglePrecisionGuides();
    final after = ref.read(canvasViewportProvider).showPrecisionGuides;
    _showStatus(
      context,
      after ? 'Precision guides shown' : 'Precision guides hidden',
    );
    return before != after;
  }

  bool toggleAutoGridOccupancy(BuildContext context, WidgetRef ref) {
    final before = ref.read(canvasViewportProvider).showAutoGridOccupancy;
    ref.read(canvasViewportProvider.notifier).toggleAutoGridOccupancy();
    final after = ref.read(canvasViewportProvider).showAutoGridOccupancy;
    _showStatus(
      context,
      after ? 'Auto Grid occupancy shown' : 'Auto Grid occupancy hidden',
    );
    return before != after;
  }

  bool clearRecentZooms(BuildContext context) {
    final hadRecent = recentCanvasZoomPresets.isNotEmpty;
    clearRecentCanvasZoomPresets();
    _showStatus(
      context,
      hadRecent ? 'Cleared recent custom zooms' : 'No recent custom zooms',
    );
    return hadRecent;
  }

  bool _runZoomAction(
    BuildContext context,
    WidgetRef ref, {
    required void Function(CanvasViewportNotifier notifier) action,
    String? successMessage,
    required String noChangeMessage,
  }) {
    final before = ref.read(canvasViewportProvider).zoom;
    action(ref.read(canvasViewportProvider.notifier));
    final after = ref.read(canvasViewportProvider).zoom;
    final changed = (after - before).abs() >= 0.001;
    _showStatus(
      context,
      changed
          ? successMessage ?? 'Zoom set to ${_zoomPercentLabel(after)}'
          : noChangeMessage,
    );
    return changed;
  }

  void _showStatus(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

const layoutCanvasViewActionService = LayoutCanvasViewActionService();

String _zoomPercentLabel(double zoom) {
  return '${(zoom * 100).round()}%';
}

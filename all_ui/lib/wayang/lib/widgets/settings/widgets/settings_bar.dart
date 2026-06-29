import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsBar extends ConsumerStatefulWidget {
  final TransformationController transformationController;
  final GlobalKey canvasKey;
  final (double, double) position;
  final Function() onShowSetting;
  const SettingsBar(
      {super.key,
      required this.transformationController,
      required this.canvasKey,
      required this.position,
      required this.onShowSetting});

  @override
  ConsumerState<SettingsBar> createState() => _SettingsBarState();
}

class _SettingsBarState extends ConsumerState<SettingsBar> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: widget.position.$1,
      bottom: widget.position.$2,
      child: Card(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.center_focus_strong),
              onPressed: _resetCanvasPosition,
              tooltip: 'Center Canvas',
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () => zoomIn(),
              tooltip: 'Zoom In',
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: () => zoomOut(),
              tooltip: 'Zoom Out',
            ),
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo',
              onPressed: () {}, // Implement undo logic
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              tooltip: 'Redo',
              onPressed: () {}, // Implement redo logic
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: widget.onShowSetting, //_toggleSettings,
              tooltip: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  void _resetCanvasPosition() {
    widget.transformationController.value = Matrix4.identity();
  }

  void zoomIn() {
    final currentScale =
        widget.transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * 1.2).clamp(0.5, 2.0);
    setCenterCanvas(newScale);
  }

  void zoomOut() {
    final currentScale =
        widget.transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale / 1.2).clamp(0.5, 2.0);
    setCenterCanvas(newScale);
  }

  void setCenterCanvas(normalizedFactor) {
    // Get the center of the canvas
    final renderBox =
        widget.canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final center = Offset(
      renderBox.size.width / 2,
      renderBox.size.height / 2,
    );

    // Apply scale transformation around the center
    final matrix = Matrix4.identity()
      ..translate(center.dx, center.dy)
      ..scale(normalizedFactor)
      ..translate(-center.dx, -center.dy);

    widget.transformationController.value = matrix;
  }
}

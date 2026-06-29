import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ZoomControls extends ConsumerWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitToScreen;
  final VoidCallback onResetView;

  const ZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitToScreen,
    required this.onResetView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.zoom_in),
          onPressed: onZoomIn,
          tooltip: 'Zoom In',
        ),
        IconButton(
          icon: const Icon(Icons.zoom_out),
          onPressed: onZoomOut,
          tooltip: 'Zoom Out',
        ),
        IconButton(
          icon: const Icon(Icons.fit_screen),
          onPressed: onFitToScreen,
          tooltip: 'Fit to Screen',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onResetView,
          tooltip: 'Reset View',
        ),
      ],
    );
  }
}

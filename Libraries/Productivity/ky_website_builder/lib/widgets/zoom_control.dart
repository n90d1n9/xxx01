import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../camel/states/canvas_transform_provider.dart';
import '../states/provider.dart';

class ZoomControls extends ConsumerStatefulWidget {
  const ZoomControls({super.key});

  @override
  ConsumerState<ZoomControls> createState() => _ZoomControlsState();
}

class _ZoomControlsState extends ConsumerState<ZoomControls> {
  bool _showSlider = false;

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasTransformProvider);
    final designerState = ref.watch(designerProvider);
    final canvasNotifier = ref.read(canvasTransformProvider.notifier);
    final designerNotifier = ref.read(designerProvider.notifier);

    final zoomLevel = designerState?.canvasZoom ?? canvasState.scale;
    final zoomPercentage = (zoomLevel * 100).toInt();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out, size: 18),
                  onPressed: () => _setZoom(zoomLevel - 0.1, ref),
                  tooltip: 'Zoom Out',
                ),

                // Zoom percentage with toggle for slider
                GestureDetector(
                  onTap: () => setState(() => _showSlider = !_showSlider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(
                      '$zoomPercentage%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.zoom_in, size: 18),
                  onPressed: () => _setZoom(zoomLevel + 0.1, ref),
                  tooltip: 'Zoom In',
                ),
              ],
            ),

            // Zoom slider
            if (_showSlider) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: 120,
                child: Slider(
                  value: zoomLevel.clamp(0.1, 3.0),
                  min: 0.1,
                  max: 3.0,
                  divisions: 29,
                  onChanged: (value) => _setZoom(value, ref),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _setZoom(double newZoom, WidgetRef ref) {
    final clampedZoom = newZoom.clamp(0.1, 3.0);
    final canvasNotifier = ref.read(canvasTransformProvider.notifier);
    final designerNotifier = ref.read(designerProvider.notifier);

    if (designerNotifier != null) {
      designerNotifier.setZoom(clampedZoom);
    } else {
      final currentZoom = ref.read(canvasTransformProvider).scale;
      final delta = clampedZoom - currentZoom;
      canvasNotifier.zoom(delta, const Offset(400, 300));
    }
  }
}

// lib/widgets/grid_size_slider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/file_provider.dart';

class GridSizeSlider extends ConsumerWidget {
  const GridSizeSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = ref.watch(gridColumnCountProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.grid_on_rounded, size: 16, color: colorScheme.onSurfaceVariant),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: columns.toDouble(),
                min: 2, max: 6,
                divisions: 4,
                onChanged: (v) {
                  ref.read(gridColumnCountProvider.notifier).state = v.round();
                  ref.read(appPreferencesProvider.notifier)
                      .update((p) => p.copyWith(gridColumns: v.round()));
                },
              ),
            ),
          ),
          Icon(Icons.grid_view_rounded, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Container(
            width: 24, height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('$columns',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }
}

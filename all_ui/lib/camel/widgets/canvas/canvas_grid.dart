import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/canvas_transform_provider.dart';
import '../../states/grid_setting_provider.dart';
import 'grid_painter.dart';

class CanvasGrid extends ConsumerWidget {
  const CanvasGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transform = ref.watch(canvasTransformProvider);

    return Positioned.fill(
      child: CustomPaint(
        painter: GridPainter(
          transform: transform,
          isDark: Theme.of(context).brightness == Brightness.dark,
          enabled: ref.watch(gridSettingsProvider).enabled,
          spacing: ref.watch(gridSettingsProvider).spacing,
        ),
      ),
    );
  }
}

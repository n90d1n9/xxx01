import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/canvas_transform_provider.dart';
import '../../states/provider.dart';
import '../../states/select_route_provider.dart';
import '../minimap.dart';

class CanvasMiniMap extends ConsumerWidget {
  const CanvasMiniMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(selectedRouteProvider);
    final transform = ref.watch(canvasTransformProvider);
    final showMiniMap = ref.watch(showMiniMapProvider);

    if (!showMiniMap || route == null || route.nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 16,
      bottom: 16,
      child: MiniMap(route: route, transform: transform),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/canvas_transform_provider.dart';
import '../states/select_route_provider.dart';

class ZoomHandler {
  static void zoom(WidgetRef ref, double delta) {
    ref
        .read(canvasTransformProvider.notifier)
        .zoom(delta, const Offset(400, 300));
  }

  static void fitToScreen(WidgetRef ref, BuildContext context) {
    final route = ref.read(selectedRouteProvider);
    if (route == null || route.nodes.isEmpty) return;

    ref
        .read(canvasTransformProvider.notifier)
        .fitToScreen(const Size(800, 600), route.nodes);
  }
}

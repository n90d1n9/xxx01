import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/node_route_provider.dart';
import '../states/select_route_provider.dart';

class LayoutHandler {
  static void autoLayout(WidgetRef ref, BuildContext context) {
    final routeId = ref.read(selectedRouteIdProvider);
    if (routeId == null) return;

    ref.read(routesProvider.notifier).autoLayout(routeId);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Auto layout applied')));
  }
}

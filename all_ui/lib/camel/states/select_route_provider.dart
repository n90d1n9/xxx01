// Other Providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/node_card.dart';
import '../models/node.dart';
import 'node_route_provider.dart';

final selectedRouteIdProvider = StateProvider<String?>((ref) => null);

final selectedRouteProvider = Provider<WNode?>((ref) {
  final routeId = ref.watch(selectedRouteIdProvider);
  if (routeId == null) return null;
  final routes = ref.watch(routesProvider);
  try {
    return routes.firstWhere((r) => r.id == routeId);
  } catch (e) {
    return routes.isNotEmpty ? routes.first : null;
  }
});

final selectedNodeIdProvider = StateProvider<String?>((ref) => null);

final selectedNodeProvider = Provider<NodeCard?>((ref) {
  final nodeId = ref.watch(selectedNodeIdProvider);
  final route = ref.watch(selectedRouteProvider);
  if (nodeId == null || route == null) return null;
  try {
    return route.nodes.firstWhere((n) => n.id == nodeId);
  } catch (e) {
    return null;
  }
});

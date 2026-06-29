import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';

import '../model/integration_route.dart';

final routesProvider =
    StateNotifierProvider<RoutesNotifier, List<IntegrationRoute>>((ref) {
      return RoutesNotifier();
    });

class RoutesNotifier extends StateNotifier<List<IntegrationRoute>> {
  RoutesNotifier() : super([]);

  void addRoute(IntegrationRoute route) {
    state = [...state, route];
  }

  void updateRoute(IntegrationRoute route) {
    state = [
      for (final r in state)
        if (r.id == route.id) route else r,
    ];
  }

  void deleteRoute(String id) {
    state = state.where((r) => r.id != id).toList();
  }

  void importRoutes(List<IntegrationRoute> routes) {
    state = [...state, ...routes];
  }

  String exportToJson() {
    final data = state.map((r) => r.toJson()).toList();
    return JsonEncoder.withIndent('  ').convert(data);
  }
}

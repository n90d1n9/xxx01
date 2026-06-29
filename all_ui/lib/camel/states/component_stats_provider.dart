import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/component_library.dart';
import '../models/component_stats.dart';
import 'node_route_provider.dart';

final componentStatsProvider = Provider<ComponentStats>((ref) {
  final routes = ref.watch(routesProvider);
  final allComponents = ComponentLibrary.allComponents;

  final usage = <String, int>{};

  for (final route in routes) {
    for (final node in route.nodes) {
      usage[node.type] = (usage[node.type] ?? 0) + 1;
    }
  }

  final sortedUsage =
      usage.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  final mostUsed = sortedUsage.take(5).map((e) => e.key).toList();
  final unused =
      allComponents
          .where((c) => !usage.containsKey(c.id))
          .map((c) => c.id)
          .toList();

  return ComponentStats(
    componentUsage: usage,
    averageConfigComplexity: {},
    mostUsedComponents: mostUsed,
    unusedComponents: unused,
  );
});

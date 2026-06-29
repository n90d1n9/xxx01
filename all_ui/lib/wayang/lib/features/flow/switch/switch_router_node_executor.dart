import '../cel_expression.dart';
import '../router/router_route.dart';
import '../router/router_strategy.dart';
import 'switch_editor.dart';

class SwitchRouterNodeExecutor {
  final SwitchRouterNodeDefinition definition;
  int _roundRobinIndex = 0;
  final Map<String, int> _loadCounters = {};

  SwitchRouterNodeExecutor(this.definition);

  Future<Map<String, dynamic>> execute(Map<String, dynamic> input) async {
    String? selectedRoute;

    switch (definition.strategy) {
      case RouterStrategy.roundRobin:
        selectedRoute = _selectRoundRobin();
        break;
      case RouterStrategy.random:
        selectedRoute = _selectRandom();
        break;
      case RouterStrategy.weightedRandom:
        selectedRoute = _selectWeightedRandom();
        break;
      case RouterStrategy.leastLoad:
        selectedRoute = _selectLeastLoad();
        break;
      case RouterStrategy.priority:
        selectedRoute = _selectByPriority();
        break;
      case RouterStrategy.custom:
        selectedRoute = _selectByCondition(input);
        break;
    }

    selectedRoute ??= definition.defaultRoute;

    if (selectedRoute == null) {
      return {
        'success': false,
        'error': 'No route selected and no default route configured',
        'data': input,
      };
    }

    // Update load counter
    if (definition.enableLoadBalancing) {
      _loadCounters[selectedRoute] = (_loadCounters[selectedRoute] ?? 0) + 1;
    }

    return {
      'success': true,
      'output_port': selectedRoute,
      'route': selectedRoute,
      'data': input,
      'strategy': definition.strategy.name,
    };
  }

  String _selectRoundRobin() {
    if (definition.routes.isEmpty) return '';
    final route =
        definition.routes[_roundRobinIndex % definition.routes.length];
    _roundRobinIndex++;
    return route.id;
  }

  String _selectRandom() {
    if (definition.routes.isEmpty) return '';
    final index = DateTime.now().millisecond % definition.routes.length;
    return definition.routes[index].id;
  }

  String _selectWeightedRandom() {
    if (definition.routes.isEmpty) return '';

    final totalWeight = definition.routes.fold<int>(
      0,
      (sum, r) => sum + r.weight,
    );
    var random = DateTime.now().microsecond % totalWeight;

    for (final route in definition.routes) {
      random -= route.weight;
      if (random < 0) return route.id;
    }

    return definition.routes.first.id;
  }

  String _selectLeastLoad() {
    if (definition.routes.isEmpty) return '';

    String? leastLoadedRoute;
    int minLoad = double.maxFinite.toInt();

    for (final route in definition.routes) {
      final load = _loadCounters[route.id] ?? 0;
      if (load < minLoad) {
        minLoad = load;
        leastLoadedRoute = route.id;
      }
    }

    return leastLoadedRoute ?? definition.routes.first.id;
  }

  String _selectByPriority() {
    if (definition.routes.isEmpty) return '';

    final sorted = List<RouterRoute>.from(definition.routes)
      ..sort((a, b) => b.priority.compareTo(a.priority));

    return sorted.first.id;
  }

  String? _selectByCondition(Map<String, dynamic> input) {
    for (final route in definition.routes) {
      if (route.condition != null && route.condition!.isNotEmpty) {
        try {
          final cel = CELExpression(route.condition!);
          if (cel.evaluate(input)) {
            return route.id;
          }
        } catch (e) {
          // Skip invalid conditions
          continue;
        }
      }
    }
    return null;
  }

  void resetLoadCounters() {
    _loadCounters.clear();
  }
}

import '../router/router_route.dart';
import '../router/router_strategy.dart';

class SwitchRouterNodeDefinition {
  final String id;
  final String name;
  final String description;
  final List<RouterRoute> routes;
  final RouterStrategy strategy;
  final String? defaultRoute; // Fallback route ID
  final bool enableLoadBalancing;
  final Map<String, dynamic> metadata;

  SwitchRouterNodeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.routes,
    this.strategy = RouterStrategy.roundRobin,
    this.defaultRoute,
    this.enableLoadBalancing = false,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'routes': routes.map((r) => r.toJson()).toList(),
    'strategy': strategy.name,
    'defaultRoute': defaultRoute,
    'enableLoadBalancing': enableLoadBalancing,
    'metadata': metadata,
  };

  factory SwitchRouterNodeDefinition.fromJson(Map<String, dynamic> json) =>
      SwitchRouterNodeDefinition(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        routes: (json['routes'] as List)
            .map((r) => RouterRoute.fromJson(r))
            .toList(),
        strategy: RouterStrategy.values.firstWhere(
          (e) => e.name == json['strategy'],
          orElse: () => RouterStrategy.roundRobin,
        ),
        defaultRoute: json['defaultRoute'],
        enableLoadBalancing: json['enableLoadBalancing'] ?? false,
        metadata: json['metadata'] ?? {},
      );
}

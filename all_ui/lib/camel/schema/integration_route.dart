import '../models/node_card.dart';
import '../models/node_connection.dart';
import 'endpoint.dart';
import 'error_handler.dart';
import 'monitoring_config.dart';
import 'routing_rule.dart';
import 'transformation_step.dart';

class IntegrationRoute {
  final String id;
  final String name;
  final String description;
  final List<NodeCard> nodes;
  final List<NodeConnection> connections;
  final EndpointDefinition? sourceEndpoint;
  final List<EndpointDefinition> targetEndpoints;
  final List<TransformationStep> transformations;
  final RoutingRule? routing;
  final ErrorHandler? errorHandler;
  final MonitoringConfig? monitoring;
  final Map<String, dynamic> metadata;

  const IntegrationRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.nodes,
    required this.connections,
    this.sourceEndpoint,
    this.targetEndpoints = const [],
    this.transformations = const [],
    this.routing,
    this.errorHandler,
    this.monitoring,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'nodes': nodes.map((n) => n.toJson()).toList(),
    'connections': connections.map((c) => c.toJson()).toList(),
    'sourceEndpoint': sourceEndpoint?.toJson(),
    'targetEndpoints': targetEndpoints.map((e) => e.toJson()).toList(),
    'transformations': transformations.map((t) => t.toJson()).toList(),
    'routing': routing?.toJson(),
    'errorHandler': errorHandler?.toJson(),
    'monitoring': monitoring?.toJson(),
    'metadata': metadata,
  };
}

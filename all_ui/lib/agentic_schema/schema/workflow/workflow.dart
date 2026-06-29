import '../connection/integration_connector.dart';

import '../exception/global_error_handler.dart';
import '../common/metadata.dart';
import '../variable/variable.dart';
import 'transaction_config.dart';
import 'workflow_edge.dart';
import 'workflow_node.dart';
import 'workflow_trigger.dart';

enum WorkflowType {
  sequential,
  parallel,
  eventDriven,
  saga,
  choreography,
  orchestration,
}

class Workflow {
  final String id;
  final String name;
  final String? description;
  final WorkflowType? type;
  final List<WorkflowNode> nodes;
  final List<WorkflowEdge>? edges;
  final List<Variable>? variables;
  final List<IntegrationConnector>? connectors;
  final TransactionConfig? transactionConfig;
  final List<WorkflowTrigger>? triggers;
  final GlobalErrorHandler? globalErrorHandler;
  final Metadata? metadata;

  Workflow({
    required this.id,
    required this.name,
    this.description,
    this.type,
    required this.nodes,
    this.edges,
    this.variables,
    this.connectors,
    this.transactionConfig,
    this.triggers,
    this.globalErrorHandler,
    this.metadata,
  });

  factory Workflow.fromJson(Map<String, dynamic> json) {
    return Workflow(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] != null ? _parseWorkflowType(json['type']) : null,
      nodes: (json['nodes'] as List)
          .map((e) => WorkflowNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      edges: json['edges'] != null
          ? (json['edges'] as List)
                .map((e) => WorkflowEdge.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      variables: json['variables'] != null
          ? (json['variables'] as List)
                .map((e) => Variable.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      connectors: json['connectors'] != null
          ? (json['connectors'] as List)
                .map(
                  (e) =>
                      IntegrationConnector.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      transactionConfig: json['transactionConfig'] != null
          ? TransactionConfig.fromJson(
              json['transactionConfig'] as Map<String, dynamic>,
            )
          : null,
      triggers: json['triggers'] != null
          ? (json['triggers'] as List)
                .map((e) => WorkflowTrigger.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      globalErrorHandler: json['globalErrorHandler'] != null
          ? GlobalErrorHandler.fromJson(
              json['globalErrorHandler'] as Map<String, dynamic>,
            )
          : null,
      metadata: json['metadata'] != null
          ? Metadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (type != null) 'type': type!.name,
      'nodes': nodes.map((e) => e.toJson()).toList(),
      if (edges != null) 'edges': edges!.map((e) => e.toJson()).toList(),
      if (variables != null)
        'variables': variables!.map((e) => e.toJson()).toList(),
      if (connectors != null)
        'connectors': connectors!.map((e) => e.toJson()).toList(),
      if (transactionConfig != null)
        'transactionConfig': transactionConfig!.toJson(),
      if (triggers != null)
        'triggers': triggers!.map((e) => e.toJson()).toList(),
      if (globalErrorHandler != null)
        'globalErrorHandler': globalErrorHandler!.toJson(),
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }

  static WorkflowType _parseWorkflowType(dynamic value) {
    if (value is WorkflowType) return value;
    final stringValue = value.toString();
    return WorkflowType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => WorkflowType.sequential,
    );
  }

  Workflow copyWith({
    String? id,
    String? name,
    String? description,
    WorkflowType? type,
    List<WorkflowNode>? nodes,
    List<WorkflowEdge>? edges,
    List<Variable>? variables,
    List<IntegrationConnector>? connectors,
    TransactionConfig? transactionConfig,
    List<WorkflowTrigger>? triggers,
    GlobalErrorHandler? globalErrorHandler,
    Metadata? metadata,
  }) {
    return Workflow(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      variables: variables ?? this.variables,
      connectors: connectors ?? this.connectors,
      transactionConfig: transactionConfig ?? this.transactionConfig,
      triggers: triggers ?? this.triggers,
      globalErrorHandler: globalErrorHandler ?? this.globalErrorHandler,
      metadata: metadata ?? this.metadata,
    );
  }
}

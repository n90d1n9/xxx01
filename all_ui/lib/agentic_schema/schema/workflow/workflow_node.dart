import '../config/node_config.dart';
import '../connection/integration_connector.dart';
import '../integration/integration_pattern.dart';
import '../common/metadata.dart';
import '../node/node_error_handling.dart';
import '../node/node_input.dart';
import '../node/node_output.dart';
import '../common/position.dart';
import '../node/node_type.dart';

enum NodeCategory {
  ai,
  integration,
  logic,
  transformation,
  endpoint,
  routing,
  monitoring,
}

class WorkflowNode {
  final String id;
  final NodeType type;
  final NodeCategory? category;
  final String name;
  final String? description;
  final Position position;
  final IntegrationPattern? integrationPattern;
  final IntegrationConnector? connector;
  final NodeConfig? config;
  final List<NodeInput>? inputs;
  final List<NodeOutput>? outputs;
  final NodeErrorHandling? errorHandling;
  final Metadata? metadata;

  WorkflowNode({
    required this.id,
    required this.type,
    this.category,
    required this.name,
    this.description,
    required this.position,
    this.integrationPattern,
    this.connector,
    this.config,
    this.inputs,
    this.outputs,
    this.errorHandling,
    this.metadata,
  });

  factory WorkflowNode.fromJson(Map<String, dynamic> json) {
    return WorkflowNode(
      id: json['id'] as String,
      type: _parseNodeType(json['type']),
      category: json['category'] != null
          ? _parseNodeCategory(json['category'])
          : null,
      name: json['name'] as String,
      description: json['description'] as String?,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
      integrationPattern: json['integrationPattern'] != null
          ? IntegrationPattern.fromJson(
              json['integrationPattern'] as Map<String, dynamic>,
            )
          : null,
      connector: json['connector'] != null
          ? IntegrationConnector.fromJson(
              json['connector'] as Map<String, dynamic>,
            )
          : null,
      config: json['config'] != null
          ? NodeConfig.fromJson(json['config'] as Map<String, dynamic>)
          : null,
      inputs: json['inputs'] != null
          ? (json['inputs'] as List)
                .map((e) => NodeInput.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      outputs: json['outputs'] != null
          ? (json['outputs'] as List)
                .map((e) => NodeOutput.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      errorHandling: json['errorHandling'] != null
          ? NodeErrorHandling.fromJson(
              json['errorHandling'] as Map<String, dynamic>,
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
      'type': type.name,
      if (category != null) 'category': category!.name,
      'name': name,
      if (description != null) 'description': description,
      'position': position.toJson(),
      if (integrationPattern != null)
        'integrationPattern': integrationPattern!.toJson(),
      if (connector != null) 'connector': connector!.toJson(),
      if (config != null) 'config': config!.toJson(),
      if (inputs != null) 'inputs': inputs!.map((e) => e.toJson()).toList(),
      if (outputs != null) 'outputs': outputs!.map((e) => e.toJson()).toList(),
      if (errorHandling != null) 'errorHandling': errorHandling!.toJson(),
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }

  static NodeType _parseNodeType(dynamic value) {
    if (value is NodeType) return value;
    final stringValue = value.toString();
    return NodeType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => NodeType.transform,
    );
  }

  static NodeCategory _parseNodeCategory(dynamic value) {
    if (value is NodeCategory) return value;
    final stringValue = value.toString();
    return NodeCategory.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => NodeCategory.logic,
    );
  }

  WorkflowNode copyWith({
    String? id,
    NodeType? type,
    NodeCategory? category,
    String? name,
    String? description,
    Position? position,
    IntegrationPattern? integrationPattern,
    IntegrationConnector? connector,
    NodeConfig? config,
    List<NodeInput>? inputs,
    List<NodeOutput>? outputs,
    NodeErrorHandling? errorHandling,
    Metadata? metadata,
  }) {
    return WorkflowNode(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      name: name ?? this.name,
      description: description ?? this.description,
      position: position ?? this.position,
      integrationPattern: integrationPattern ?? this.integrationPattern,
      connector: connector ?? this.connector,
      config: config ?? this.config,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      errorHandling: errorHandling ?? this.errorHandling,
      metadata: metadata ?? this.metadata,
    );
  }
}

import 'package:flutter/material.dart';

import 'workflow_node_port.dart';

enum NodeType {
  llm,
  prompt,
  data,
  api,
  processor,
  decision,
  aggregator,
  custom,
  trigger,
  action,
  condition,
  email,
  messaging,
  event,
  searchEngine,
  webhook,
  schedule,
  embedding,
  switchNode,
  transform,
  filter,
  database,
  response,
  notification,
}

enum NodeShapeType {
  start, // Start Node
  end, // End Node
  process, // Process Node
  mcp, // LLM adopt Model Context Protocol(MCP)
  group, // Grouping Node
}

class WorkflowNode {
  final String id;
  final String label;
  final Offset position;
  final Map<String, dynamic> config;
  final List<WorkflowNodePort> inputs;
  final List<WorkflowNodePort> outputs;
  final NodeStatus status;
  final String? error;
  final String templateId;
  final Size size;
  final bool isSelected;
  final NodeShapeType shapeType;
  //final NodeType type;
  final String type;
  final Map<String, dynamic> configuration;
  final bool isActive;
  final double executionProgress;
  final IconData? icon;

  WorkflowNode({
    required this.id,
    required this.type,
    required this.label,
    required this.position,
    this.config = const {},
    this.inputs = const [],
    this.outputs = const [],
    this.status = NodeStatus.idle,
    this.error,
    this.shapeType = NodeShapeType.process,
    this.templateId = '',
    this.size = const Size(120, 80),
    this.isSelected = false,
    this.isActive = false,
    this.executionProgress = 0.0,
    this.configuration = const {},
    this.icon,
  });

  WorkflowNode copyWith({
    String? id,
    //NodeType? type,
    String? type,
    NodeShapeType? shapeType,
    String? label,
    Offset? position,
    Map<String, dynamic>? config,
    List<WorkflowNodePort>? inputs,
    List<WorkflowNodePort>? outputs,
    NodeStatus? status,
    String? error,
    bool clearError = false,
    String? templateId,
    Size? size,
    bool? isSelected,
    bool? isActive,
    double? executionProgress,
    Map<String, dynamic>? configuration,
    IconData? icon,
  }) {
    return WorkflowNode(
      id: id ?? this.id,
      type: type ?? this.type,
      shapeType: shapeType ?? this.shapeType,
      label: label ?? this.label,
      position: position ?? this.position,
      config: config ?? this.config,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      templateId: templateId ?? this.templateId,
      size: size ?? this.size,
      isSelected: isSelected ?? this.isSelected,
      configuration: configuration ?? this.configuration,
      isActive: isActive ?? this.isActive,
      executionProgress: executionProgress ?? this.executionProgress,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      //'type': type.name,
      'type': type,
      'shapeType': shapeType.name,
      'label': label,
      'position': {'dx': position.dx, 'dy': position.dy},
      'config': Map<String, dynamic>.from(config),
      'inputs': inputs.map((input) => input.toMap()).toList(),
      'outputs': outputs.map((output) => output.toMap()).toList(),
      'status': status.name,
      'error': error,
      'templateId': templateId,
      'size': {'width': size.width, 'height': size.height},
      'isSelected': isSelected,
      'isActive': isActive,
      'executionProgress': executionProgress,
      'configuration': Map<String, dynamic>.from(configuration),
      'icon': _iconDataToMap(icon),
    };
  }

  factory WorkflowNode.fromMap(Map<String, dynamic> map) {
    return WorkflowNode(
      id: map['id'] as String,
      /* type: NodeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NodeType.custom,
      ), */
      type: map['type'] as String,
      shapeType: NodeShapeType.values.firstWhere(
        (e) => e.name == map['shapeType'],
        orElse: () => NodeShapeType.process,
      ),
      label: map['label'] as String,
      position: Offset(
        (map['position'] as Map)['dx'] as double,
        (map['position'] as Map)['dy'] as double,
      ),
      config: Map<String, dynamic>.from(map['config'] as Map? ?? {}),
      inputs: (map['inputs'] as List? ?? [])
          .map(
            (input) =>
                WorkflowNodePort.fromMap(Map<String, dynamic>.from(input)),
          )
          .toList(),
      outputs: (map['outputs'] as List? ?? [])
          .map(
            (output) =>
                WorkflowNodePort.fromMap(Map<String, dynamic>.from(output)),
          )
          .toList(),
      status: NodeStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => NodeStatus.idle,
      ),
      error: map['error'] as String?,
      templateId: map['templateId'] as String? ?? '',
      size: Size(
        (map['size'] as Map)['width'] as double,
        (map['size'] as Map)['height'] as double,
      ),
      isSelected: map['isSelected'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? false,
      executionProgress: (map['executionProgress'] as num?)?.toDouble() ?? 0.0,
      configuration: Map<String, dynamic>.from(
        map['configuration'] as Map? ?? {},
      ),
      icon: _iconDataFromMap(map['icon'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory WorkflowNode.fromJson(Map<String, dynamic> json) =>
      WorkflowNode.fromMap(json);

  // Helper methods for IconData serialization
  static Map<String, dynamic>? _iconDataToMap(IconData? icon) {
    if (icon == null) return null;
    return {
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
    };
  }

  static IconData? _iconDataFromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    return IconData(
      map['codePoint'] as int,
      fontFamily: map['fontFamily'] as String?,
      fontPackage: map['fontPackage'] as String?,
    );
  }

  @override
  String toString() {
    return 'WorkflowNode(id: $id, type: $type, label: $label, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkflowNode && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

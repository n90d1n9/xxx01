import 'package:flutter/material.dart';

import '../components/history/history_action.dart';
import '../model/workflow_connection.dart';
import '../model/workflow_node.dart';

class WorkflowState {
  final String id;
  final String name;
  final List<WorkflowNode> nodes;
  final List<WorkflowConnection> connections;
  final String? selectedNodeId;
  final Offset canvasOffset;
  final double zoom;
  final bool isExecuting;
  final List<String> executionLog;
  final List<HistoryAction> history;
  final int historyIndex;
  final Offset? dragConnectionEndpoint;
  final String? hoveredInputNodeId;
  final String? hoveredInputPortId;

  WorkflowState({
    required this.id,
    this.name = 'Untitled Workflow',
    this.nodes = const [],
    this.connections = const [],
    this.selectedNodeId,
    this.canvasOffset = Offset.zero,
    this.zoom = 1.0,
    this.isExecuting = false,
    this.executionLog = const [],
    this.history = const [],
    this.historyIndex = -1,
    this.dragConnectionEndpoint,
    this.hoveredInputNodeId,
    this.hoveredInputPortId,
  });

  WorkflowState copyWith({
    String? id,
    String? name,
    List<WorkflowNode>? nodes,
    List<WorkflowConnection>? connections,
    String? selectedNodeId,
    bool clearSelection = false,
    Offset? canvasOffset,
    double? zoom,
    bool? isExecuting,
    List<String>? executionLog,
    List<HistoryAction>? history,
    int? historyIndex,
    Offset? dragConnectionEndpoint,
    String? hoveredInputNodeId,
    String? hoveredInputPortId,
  }) {
    return WorkflowState(
      id: id ?? this.id,
      name: name ?? this.name,
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      selectedNodeId: clearSelection
          ? null
          : (selectedNodeId ?? this.selectedNodeId),
      canvasOffset: canvasOffset ?? this.canvasOffset,
      zoom: zoom ?? this.zoom,
      isExecuting: isExecuting ?? this.isExecuting,
      executionLog: executionLog ?? this.executionLog,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
      dragConnectionEndpoint:
          dragConnectionEndpoint ?? this.dragConnectionEndpoint,
      hoveredInputNodeId: hoveredInputNodeId ?? this.hoveredInputNodeId,
      hoveredInputPortId: hoveredInputPortId ?? this.hoveredInputPortId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nodes': nodes.map((n) => n.toJson()).toList(),
    'connections': connections.map((c) => c.toJson()).toList(),
  };

  factory WorkflowState.fromJson(Map<String, dynamic> json) => WorkflowState(
    id: json['id'],
    name: json['name'],
    nodes: (json['nodes'] as List)
        .map((n) => WorkflowNode.fromJson(n))
        .toList(),
    connections: (json['connections'] as List)
        .map((c) => WorkflowConnection.fromJson(c))
        .toList(),
  );
}

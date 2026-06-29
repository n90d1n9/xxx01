import 'package:flutter/material.dart';

import '../../schema/workflow/workflow.dart';
import '../../schema/workflow/workflow_edge.dart';
import '../../schema/workflow/workflow_node.dart';

class WorkflowState {
  final Workflow? currentWorkflow;
  final List<WorkflowNode> selectedNodes;
  final List<WorkflowEdge> selectedEdges;
  final WorkflowNode? draggedNode;
  final Offset? dragOffset;
  final String? connectingFromNode;
  final String? connectingFromHandle;
  final bool isConnecting;
  final Map<String, dynamic> clipboard;
  final List<Workflow> history;
  final int historyIndex;
  final Offset? cursorPosition; // Add this

  WorkflowState({
    this.currentWorkflow,
    this.selectedNodes = const [],
    this.selectedEdges = const [],
    this.draggedNode,
    this.dragOffset,
    this.connectingFromNode,
    this.connectingFromHandle,
    this.isConnecting = false,
    this.clipboard = const {},
    this.history = const [],
    this.historyIndex = 0,
    this.cursorPosition, // Add this
  });

  WorkflowState copyWith({
    Workflow? currentWorkflow,
    List<WorkflowNode>? selectedNodes,
    List<WorkflowEdge>? selectedEdges,
    WorkflowNode? draggedNode,
    Offset? dragOffset,
    String? connectingFromNode,
    String? connectingFromHandle,
    bool? isConnecting,
    Map<String, dynamic>? clipboard,
    List<Workflow>? history,
    int? historyIndex,
    Offset? cursorPosition, // Add this
  }) {
    return WorkflowState(
      currentWorkflow: currentWorkflow ?? this.currentWorkflow,
      selectedNodes: selectedNodes ?? this.selectedNodes,
      selectedEdges: selectedEdges ?? this.selectedEdges,
      draggedNode: draggedNode ?? this.draggedNode,
      dragOffset: dragOffset ?? this.dragOffset,
      connectingFromNode: connectingFromNode ?? this.connectingFromNode,
      connectingFromHandle: connectingFromHandle ?? this.connectingFromHandle,
      isConnecting: isConnecting ?? this.isConnecting,
      clipboard: clipboard ?? this.clipboard,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
      cursorPosition: cursorPosition ?? this.cursorPosition, // Add this
    );
  }

  bool get canUndo => historyIndex > 0;
  bool get canRedo => historyIndex < history.length - 1;
}

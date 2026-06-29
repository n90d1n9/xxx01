import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/workflow_node_port.dart';
import '../components/history/history_action.dart';
import '../model/workflow_node.dart';
import '../service/connection_service.dart';
import '../service/execution_service.dart';
import '../service/history_service.dart';
import '../service/node_service.dart';
import 'workflow_state.dart';

final draggingNodeProvider = StateProvider<bool>((ref) => false);
final executionLogProvider = StateProvider<bool>((ref) => false);

// Providers
final historyServiceProvider = Provider((ref) => HistoryService());
final nodeServiceProvider = Provider((ref) => NodeService());
final connectionServiceProvider = Provider((ref) => ConnectionService());
final executionServiceProvider = Provider((ref) => ExecutionService());

final workflowProvider = StateNotifierProvider<WorkflowNotifier, WorkflowState>(
  (ref) {
    return WorkflowNotifier(
      ref,
      historyService: ref.read(historyServiceProvider),
      nodeService: ref.read(nodeServiceProvider),
      connectionService: ref.read(connectionServiceProvider),
      executionService: ref.read(executionServiceProvider),
    );
  },
);

class WorkflowNotifier extends StateNotifier<WorkflowState> {
  final Ref _ref;
  final HistoryService _historyService;
  final NodeService _nodeService;
  final ConnectionService _connectionService;
  final ExecutionService _executionService;

  // Drag state (transient, not persisted)
  bool _isDragging = false;
  String? _draggingNodeId;
  Offset? _dragStartPosition;

  WorkflowNotifier(
    this._ref, {
    required HistoryService historyService,
    required NodeService nodeService,
    required ConnectionService connectionService,
    required ExecutionService executionService,
  }) : _historyService = historyService,
       _nodeService = nodeService,
       _connectionService = connectionService,
       _executionService = executionService,
       super(WorkflowState(id: _generateId()));

  static String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  // === Private Helpers ===
  WorkflowNode _getNodeById(String nodeId) {
    return state.nodes.firstWhere(
      (n) => n.id == nodeId,
      orElse: () => throw StateError('Node with id $nodeId not found'),
    );
  }

  bool _nodeExists(String nodeId) {
    return state.nodes.any((n) => n.id == nodeId);
  }

  // === Drag Handling ===
  void startNodeDrag(String nodeId) {
    if (!_nodeExists(nodeId)) return;

    _isDragging = true;
    _draggingNodeId = nodeId;
    _dragStartPosition = _getNodeById(nodeId).position;
  }

  void updateNodePosition(String nodeId, Offset newPosition) {
    if (!_nodeExists(nodeId)) return;
    state = _nodeService.updatePosition(state, nodeId, newPosition);
  }

  void endNodeDrag() {
    if (!_isDragging || _draggingNodeId == null || _dragStartPosition == null) {
      _resetDragState();
      return;
    }

    if (!_nodeExists(_draggingNodeId!)) {
      _resetDragState();
      return;
    }

    final node = _getNodeById(_draggingNodeId!);
    final endPosition = node.position;

    if (_dragStartPosition != endPosition) {
      final action = _nodeService.createPositionChangeAction(
        _draggingNodeId!,
        _dragStartPosition!,
        endPosition,
      );
      _historyService.record(action);
    }

    _resetDragState();
  }

  void _resetDragState() {
    _isDragging = false;
    _draggingNodeId = null;
    _dragStartPosition = null;
  }

  // === Node Operations ===
  void addNode(String type, Offset position) {
    final action = _nodeService.addNode(state, type, position);
    _historyService.record(action);
    state = action.apply(state);
  }

  void updateNodeConfig(String nodeId, String key, dynamic value) {
    if (!_nodeExists(nodeId)) return;

    final node = _getNodeById(nodeId);
    final previousValue = node.config[key];

    // Don't record history if value didn't change
    if (previousValue == value) return;

    final action = UpdateNodeConfigAction(
      nodeId: nodeId,
      key: key,
      newValue: value,
      previousValue: previousValue,
    );
    _historyService.record(action);
    state = action.apply(state);
  }

  void updateNodeLabel(String nodeId, String label) {
    if (!_nodeExists(nodeId)) return;

    final node = _getNodeById(nodeId);
    final previousLabel = node.label;

    // Don't record history if label didn't change
    if (previousLabel == label) return;

    final action = UpdateNodeLabelAction(
      nodeId: nodeId,
      newLabel: label,
      previousLabel: previousLabel,
    );
    _historyService.record(action);
    state = action.apply(state);
  }

  void selectNode(String? nodeId) {
    // Validate that the node exists if selecting a node
    if (nodeId != null && !_nodeExists(nodeId)) {
      state = state.copyWith(selectedNodeId: null);
      return;
    }
    state = state.copyWith(selectedNodeId: nodeId);
  }

  void deleteNode(String nodeId) {
    if (!_nodeExists(nodeId)) return;

    final node = _getNodeById(nodeId);

    // Remove connections associated with this node first
    final stateWithoutConnections = _connectionService.removeConnectionsForNode(
      state,
      nodeId,
    );

    // Create and record the delete action
    final action = DeleteNodeAction(nodeId, node);
    _historyService.record(action);

    // Apply the action to get final state
    state = action
        .apply(stateWithoutConnections)
        .copyWith(selectedNodeId: null);
  }

  void duplicateNode(String nodeId) {
    if (!_nodeExists(nodeId)) return;

    final action = _nodeService.duplicateNode(state, nodeId);
    if (action != null) {
      _historyService.record(action);
      state = action.apply(state);
    }
  }

  // === Connection Operations ===
  void addConnection(
    String sourceNodeId,
    String targetNodeId,
    String sourcePortId,
    String targetPortId,
  ) {
    if (!_nodeExists(sourceNodeId) || !_nodeExists(targetNodeId)) return;

    if (!_connectionService.canAddConnection(
      state,
      sourceNodeId,
      targetNodeId,
      sourcePortId,
      targetPortId,
    ))
      return;

    final action = _connectionService.addConnection(
      state,
      sourceNodeId,
      targetNodeId,
      sourcePortId,
      targetPortId,
    );

    if (action != null) {
      _historyService.record(action);
      state = action.apply(state);
    }
  }

  void deleteConnection(String connectionId) {
    final connection = state.connections.firstWhere(
      (c) => c.id == connectionId,
      orElse: () => throw StateError('Connection $connectionId not found'),
    );

    final action = DeleteConnectionAction(connectionId, connection);
    _historyService.record(action);
    state = action.apply(state);
  }

  void clearConnectionDrag() {
    state = state.copyWith(dragConnectionEndpoint: null);
  }

  void setConnectionDragEndpoint(Offset? canvasPosition) {
    state = state.copyWith(dragConnectionEndpoint: canvasPosition);
  }

  void setHoveredInputPort(String? nodeId, String? portId) {
    state = state.copyWith(
      hoveredInputNodeId: nodeId,
      hoveredInputPortId: portId,
    );
  }

  // === Canvas ===
  void updateCanvasOffset(Offset offset) =>
      state = state.copyWith(canvasOffset: offset);

  void updateZoom(double zoom) =>
      state = state.copyWith(zoom: zoom.clamp(0.25, 2.0));

  void resetView() =>
      state = state.copyWith(canvasOffset: Offset.zero, zoom: 1.0);

  // === Workflow ===
  void updateWorkflowName(String name) {
    // Don't record history if name didn't change
    if (state.name == name) return;

    final action = UpdateWorkflowNameAction(
      newName: name,
      previousName: state.name,
    );
    _historyService.record(action);
    state = state.copyWith(name: name);
  }

  void clearWorkflow() {
    final action = ClearWorkflowAction(state.toJson());
    _historyService.record(action);
    state = action.apply(state);
  }

  Future<void> executeWorkflow() async {
    if (state.isExecuting) return;

    // Reset all nodes to idle status
    final resetNodes = state.nodes
        .map((node) => node.copyWith(status: NodeStatus.idle, error: null))
        .toList();

    state = state.copyWith(
      isExecuting: true,
      executionLog: ['Starting workflow execution...\n'],
      nodes: resetNodes,
    );

    try {
      await _executionService.execute(state, (update) {
        state = state.copyWith(
          nodes: update.nodes ?? state.nodes,
          executionLog: update.log != null
              ? ['${state.executionLog}${update.log}\n']
              : state.executionLog,
          isExecuting: update.isExecuting ?? state.isExecuting,
        );
      });
    } catch (e) {
      state = state.copyWith(
        isExecuting: false,
        executionLog: ['${state.executionLog}\nExecution error: $e'],
      );
    }
  }

  void stopExecution() {
    _executionService.stop();
    state = state.copyWith(isExecuting: false);
  }

  // === History ===
  void undo() {
    final newState = _historyService.undo(state);

    // Clear selection if selected node was deleted
    final shouldClearSelection =
        state.selectedNodeId != null &&
        !newState.nodes.any((n) => n.id == state.selectedNodeId);

    state = shouldClearSelection
        ? newState.copyWith(selectedNodeId: null)
        : newState;
  }

  void redo() {
    final newState = _historyService.redo(state);

    // Clear selection if selected node was deleted in the undone state
    final shouldClearSelection =
        state.selectedNodeId != null &&
        !newState.nodes.any((n) => n.id == state.selectedNodeId);

    state = shouldClearSelection
        ? newState.copyWith(selectedNodeId: null)
        : newState;
  }

  // === Import/Export ===
  String exportWorkflow() => jsonEncode(state.toJson());

  void importWorkflow(String json) {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final newState = WorkflowState.fromJson(data);
      final action = ImportWorkflowAction(
        importedData: data,
        previousState: state.toJson(),
      );
      _historyService.record(action);
      state = newState.copyWith(selectedNodeId: null);
    } catch (e) {
      // Handle error - you might want to add error state to WorkflowState
      print('Import error: $e');
    }
  }

  // === Utility ===
  Offset globalToCanvas(Offset globalPosition, BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(globalPosition);
    return (localPos / state.zoom) - state.canvasOffset;
  }

  // === Getters for UI ===
  bool get isDragging => _isDragging;
  String? get draggingNodeId => _draggingNodeId;

  bool canUndo() => _historyService.canUndo;
  bool canRedo() => _historyService.canRedo;
}

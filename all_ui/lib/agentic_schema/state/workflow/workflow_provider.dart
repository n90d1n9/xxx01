import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../../model/collaboration_event.dart';
import '../../schema/common/position.dart';
import '../../schema/config/node_config.dart';
import '../../schema/model/model_factory.dart';
import '../../schema/node/edge_condition.dart';
import '../../schema/node/edge_interceptor.dart';
import '../../schema/node/node_input.dart';
import '../../schema/node/node_output.dart';
import '../../schema/node/node_type.dart';
import '../../schema/workflow/workflow.dart';
import '../../schema/workflow/workflow_edge.dart';
import '../../schema/workflow/workflow_node.dart';
import 'workflow_state.dart';

class WorkflowNotifier extends StateNotifier<WorkflowState> {
  final List<VoidCallback> _externalChangeListeners = [];
  bool _isApplyingExternalChange = false;
  Offset? _cursorPosition;

  WorkflowNotifier() : super(WorkflowState());

  // Add this getter for collaboration service
  Offset? get cursorPosition => _cursorPosition;

  void loadWorkflow(Workflow workflow) {
    state = state.copyWith(
      currentWorkflow: workflow,
      history: [workflow],
      historyIndex: 0,
    );
  }

  void createNewWorkflow(String name) {
    final workflow = ModelFactory.createWorkflow(name: name);
    loadWorkflow(workflow);
  }

  void _saveToHistory(Workflow workflow) {
    // Don't save to history during external changes to avoid loops
    if (_isApplyingExternalChange) return;

    final newHistory = state.history.sublist(0, state.historyIndex + 1);
    newHistory.add(workflow);

    // Keep only last 50 history items
    if (newHistory.length > 50) {
      newHistory.removeAt(0);
    }

    state = state.copyWith(
      history: newHistory,
      historyIndex: newHistory.length - 1,
    );
  }

  void undo() {
    if (state.canUndo) {
      final newIndex = state.historyIndex - 1;
      state = state.copyWith(
        currentWorkflow: state.history[newIndex],
        historyIndex: newIndex,
      );
    }
  }

  void redo() {
    if (state.canRedo) {
      final newIndex = state.historyIndex + 1;
      state = state.copyWith(
        currentWorkflow: state.history[newIndex],
        historyIndex: newIndex,
      );
    }
  }

  // ===========================================================================
  // COLLABORATION INTEGRATION METHODS
  // ===========================================================================

  /// Apply changes from external sources (collaboration) without saving to history
  void applyExternalChange(VoidCallback changeCallback) {
    _isApplyingExternalChange = true;
    try {
      changeCallback();
    } finally {
      _isApplyingExternalChange = false;
    }
  }

  /// Apply partial node changes from collaboration
  void applyNodeChanges(String nodeId, Map<String, dynamic> changes) {
    if (state.currentWorkflow == null) return;

    final nodes = state.currentWorkflow!.nodes.map((n) {
      if (n.id == nodeId) {
        return _applyPartialNodeChanges(n, changes);
      }
      return n;
    }).toList();

    final updatedWorkflow = state.currentWorkflow!.copyWith(nodes: nodes);
    state = state.copyWith(currentWorkflow: updatedWorkflow);

    _notifyExternalChangeListeners();
  }

  /// Apply partial edge changes from collaboration
  void applyEdgeChanges(String edgeId, Map<String, dynamic> changes) {
    if (state.currentWorkflow == null) return;

    final edges = state.currentWorkflow!.edges?.map((e) {
      if (e.id == edgeId) {
        return _applyPartialEdgeChanges(e, changes);
      }
      return e;
    }).toList();

    final updatedWorkflow = state.currentWorkflow!.copyWith(edges: edges);
    state = state.copyWith(currentWorkflow: updatedWorkflow);

    _notifyExternalChangeListeners();
  }

  /// Direct node addition (for collaboration)
  void addNodeDirect(WorkflowNode node) {
    if (state.currentWorkflow == null) return;

    final updatedWorkflow = state.currentWorkflow!.copyWith(
      nodes: [...state.currentWorkflow!.nodes, node],
    );

    state = state.copyWith(currentWorkflow: updatedWorkflow);
    _notifyExternalChangeListeners();
  }

  /// Direct node deletion (for collaboration)
  void deleteNodeDirect(String nodeId) {
    if (state.currentWorkflow == null) return;

    final nodes = state.currentWorkflow!.nodes
        .where((n) => n.id != nodeId)
        .toList();

    final edges = state.currentWorkflow!.edges
        ?.where((e) => e.source != nodeId && e.target != nodeId)
        .toList();

    final updatedWorkflow = state.currentWorkflow!.copyWith(
      nodes: nodes,
      edges: edges,
    );

    state = state.copyWith(currentWorkflow: updatedWorkflow);
    _notifyExternalChangeListeners();
  }

  /// Direct node movement (for collaboration)
  void moveNodeDirect(String nodeId, Position position) {
    if (state.currentWorkflow == null) return;

    final nodes = state.currentWorkflow!.nodes.map((n) {
      if (n.id == nodeId) {
        return n.copyWith(position: position);
      }
      return n;
    }).toList();

    final updatedWorkflow = state.currentWorkflow!.copyWith(nodes: nodes);
    state = state.copyWith(currentWorkflow: updatedWorkflow);
    _notifyExternalChangeListeners();
  }

  /// Direct edge addition (for collaboration)
  void addEdgeDirect(WorkflowEdge edge) {
    if (state.currentWorkflow == null) return;

    // Check if edge already exists
    final existingEdge =
        state.currentWorkflow!.edges?.any(
          (e) => e.source == edge.source && e.target == edge.target,
        ) ??
        false;

    if (existingEdge) return;

    // Create a properly typed list
    final List<WorkflowEdge> edges = [
      ...(state.currentWorkflow!.edges ?? []),
      edge,
    ];

    final updatedWorkflow = state.currentWorkflow!.copyWith(edges: edges);

    state = state.copyWith(currentWorkflow: updatedWorkflow);
    _notifyExternalChangeListeners();
  }

  /// Direct edge deletion (for collaboration)
  void deleteEdgeDirect(String edgeId) {
    if (state.currentWorkflow == null) return;

    final edges = state.currentWorkflow!.edges
        ?.where((e) => e.id != edgeId)
        .toList();

    final updatedWorkflow = state.currentWorkflow!.copyWith(edges: edges);
    state = state.copyWith(currentWorkflow: updatedWorkflow);
    _notifyExternalChangeListeners();
  }

  // ===========================================================================
  // ORIGINAL METHODS (UPDATED FOR COLLABORATION)
  // ===========================================================================

  void addNode(NodeType type, Offset position) {
    if (state.currentWorkflow == null) return;

    final node = ModelFactory.createNode(
      type: type,
      name: type.displayName,
      position: Position(x: position.dx, y: position.dy),
    );

    final updatedWorkflow = state.currentWorkflow!.copyWith(
      nodes: [...state.currentWorkflow!.nodes, node],
    );

    state = state.copyWith(currentWorkflow: updatedWorkflow);
    _saveToHistory(updatedWorkflow);

    // Notify collaboration if this was a local change
    if (!_isApplyingExternalChange) {
      _notifyCollaboration(CollaborationEventType.nodeAdded, {
        'node': node.toJson(),
      });
    }
  }

  void updateNode(WorkflowNode node) {
    if (state.currentWorkflow == null) return;

    final oldNode = state.currentWorkflow!.nodes.firstWhere(
      (n) => n.id == node.id,
      orElse: () => node,
    );

    final nodes = state.currentWorkflow!.nodes.map((n) {
      return n.id == node.id ? node : n;
    }).toList();

    final updatedWorkflow = state.currentWorkflow!.copyWith(nodes: nodes);
    state = state.copyWith(currentWorkflow: updatedWorkflow);
    _saveToHistory(updatedWorkflow);

    if (!_isApplyingExternalChange) {
      final changes = _getNodeChanges(oldNode, node);
      if (changes.isNotEmpty) {
        _notifyCollaboration(CollaborationEventType.nodeUpdated, {
          'nodeId': node.id,
          'changes': changes,
        });
      }
    }
  }

  void moveNode(String nodeId, Offset delta) {
    if (state.currentWorkflow == null) return;

    WorkflowNode? movedNode;
    final nodes = state.currentWorkflow!.nodes.map((n) {
      if (n.id == nodeId) {
        final newPosition = Position(
          x: n.position.x + delta.dx,
          y: n.position.y + delta.dy,
        );
        movedNode = n.copyWith(position: newPosition);
        return movedNode!;
      }
      return n;
    }).toList();

    final updatedWorkflow = state.currentWorkflow!.copyWith(nodes: nodes);
    state = state.copyWith(currentWorkflow: updatedWorkflow);

    if (!_isApplyingExternalChange && movedNode != null) {
      _notifyCollaboration(CollaborationEventType.nodeMoved, {
        'nodeId': nodeId,
        'position': {'x': movedNode!.position.x, 'y': movedNode!.position.y},
      });
    }
  }

  void deleteNode(String nodeId) {
    if (state.currentWorkflow == null) return;

    final nodes = state.currentWorkflow!.nodes
        .where((n) => n.id != nodeId)
        .toList();

    final edges = state.currentWorkflow!.edges
        ?.where((e) => e.source != nodeId && e.target != nodeId)
        .toList();

    final updatedWorkflow = state.currentWorkflow!.copyWith(
      nodes: nodes,
      edges: edges,
    );

    state = state.copyWith(currentWorkflow: updatedWorkflow);
    _saveToHistory(updatedWorkflow);

    if (!_isApplyingExternalChange) {
      _notifyCollaboration(CollaborationEventType.nodeDeleted, {
        'nodeId': nodeId,
      });
    }
  }

  void deleteSelectedNodes() {
    if (state.currentWorkflow == null || state.selectedNodes.isEmpty) return;

    final selectedIds = state.selectedNodes.map((n) => n.id).toSet();
    final nodes = state.currentWorkflow!.nodes
        .where((n) => !selectedIds.contains(n.id))
        .toList();

    final edges = state.currentWorkflow!.edges
        ?.where(
          (e) =>
              !selectedIds.contains(e.source) &&
              !selectedIds.contains(e.target),
        )
        .toList();

    final updatedWorkflow = state.currentWorkflow!.copyWith(
      nodes: nodes,
      edges: edges,
    );

    state = state.copyWith(currentWorkflow: updatedWorkflow, selectedNodes: []);
    _saveToHistory(updatedWorkflow);

    if (!_isApplyingExternalChange) {
      for (final nodeId in selectedIds) {
        _notifyCollaboration(CollaborationEventType.nodeDeleted, {
          'nodeId': nodeId,
        });
      }
    }
  }

  void addEdge(
    String sourceId,
    String targetId, {
    String? sourceHandle,
    String? targetHandle,
    EdgeType? type,
    ChannelType? channelType,
    String? label,
  }) {
    if (state.currentWorkflow == null) return;

    // Check if edge already exists
    final existingEdge =
        state.currentWorkflow!.edges?.any(
          (e) => e.source == sourceId && e.target == targetId,
        ) ??
        false;

    if (existingEdge) return;

    final edge =
        ModelFactory.createEdge(
          source: sourceId,
          target: targetId,
          label: label,
          type: type,
        ).copyWith(
          sourceHandle: sourceHandle,
          targetHandle: targetHandle,
          channelType: channelType,
        );

    // Create a properly typed list
    final List<WorkflowEdge> edges = [
      ...(state.currentWorkflow!.edges ?? []),
      edge,
    ];

    final updatedWorkflow = state.currentWorkflow!.copyWith(edges: edges);

    state = state.copyWith(currentWorkflow: updatedWorkflow);
    _saveToHistory(updatedWorkflow);

    if (!_isApplyingExternalChange) {
      _notifyCollaboration(CollaborationEventType.edgeAdded, {
        'edge': edge.toJson(),
      });
    }
  }

  void updateEdge(WorkflowEdge edge) {
    if (state.currentWorkflow == null) return;

    final oldEdge = state.currentWorkflow!.edges?.firstWhere(
      (e) => e.id == edge.id,
      orElse: () => edge,
    );

    final edges = state.currentWorkflow!.edges?.map((e) {
      return e.id == edge.id ? edge : e;
    }).toList();

    final updatedWorkflow = state.currentWorkflow!.copyWith(edges: edges);
    state = state.copyWith(currentWorkflow: updatedWorkflow);
    _saveToHistory(updatedWorkflow);

    if (!_isApplyingExternalChange) {
      final changes = _getEdgeChanges(oldEdge!, edge);
      if (changes.isNotEmpty) {
        _notifyCollaboration(CollaborationEventType.edgeUpdated, {
          'edgeId': edge.id,
          'changes': changes,
        });
      }
    }
  }

  void deleteEdge(String edgeId) {
    if (state.currentWorkflow == null) return;

    final edges = state.currentWorkflow!.edges
        ?.where((e) => e.id != edgeId)
        .toList();

    final updatedWorkflow = state.currentWorkflow!.copyWith(edges: edges);
    state = state.copyWith(currentWorkflow: updatedWorkflow);
    _saveToHistory(updatedWorkflow);

    if (!_isApplyingExternalChange) {
      _notifyCollaboration(CollaborationEventType.edgeDeleted, {
        'edgeId': edgeId,
      });
    }
  }

  // ===========================================================================
  // SELECTION & UI METHODS
  // ===========================================================================

  void selectNode(String nodeId, {bool addToSelection = false}) {
    if (state.currentWorkflow == null) return;

    final node = state.currentWorkflow!.nodes.firstWhere((n) => n.id == nodeId);

    final selectedNodes = addToSelection
        ? [...state.selectedNodes, node]
        : [node];

    state = state.copyWith(selectedNodes: selectedNodes);
  }

  void selectEdge(String edgeId, {bool addToSelection = false}) {
    if (state.currentWorkflow == null) return;

    final edge = state.currentWorkflow!.edges?.firstWhere(
      (e) => e.id == edgeId,
    );
    if (edge == null) return;

    final selectedEdges = addToSelection
        ? [...state.selectedEdges, edge]
        : [edge];

    state = state.copyWith(selectedEdges: selectedEdges);
  }

  void selectMultipleNodes(List<String> nodeIds) {
    if (state.currentWorkflow == null) return;

    final nodes = state.currentWorkflow!.nodes
        .where((n) => nodeIds.contains(n.id))
        .toList();

    state = state.copyWith(selectedNodes: nodes);
  }

  void clearSelection() {
    state = state.copyWith(selectedNodes: [], selectedEdges: []);
  }

  void updateCursorPosition(Offset? position) {
    _cursorPosition = position;
  }

  void startConnecting(String nodeId, {String? handleId}) {
    state = state.copyWith(
      connectingFromNode: nodeId,
      connectingFromHandle: handleId,
      isConnecting: true,
    );
  }

  void completeConnection(String targetNodeId, {String? targetHandleId}) {
    if (state.connectingFromNode != null) {
      addEdge(
        state.connectingFromNode!,
        targetNodeId,
        sourceHandle: state.connectingFromHandle,
        targetHandle: targetHandleId,
      );
    }
    cancelConnection();
  }

  void cancelConnection() {
    state = state.copyWith(
      connectingFromNode: null,
      connectingFromHandle: null,
      isConnecting: false,
    );
  }

  void copySelectedNodes() {
    if (state.selectedNodes.isEmpty) return;

    state = state.copyWith(
      clipboard: {'nodes': state.selectedNodes, 'type': 'nodes'},
    );
  }

  void pasteNodes(Offset position) {
    if (state.currentWorkflow == null || state.clipboard['type'] != 'nodes') {
      return;
    }

    final copiedNodes = state.clipboard['nodes'] as List<WorkflowNode>;
    final idMap = <String, String>{};

    // Create new nodes with new IDs
    final newNodes = copiedNodes.map((node) {
      final newId = Uuid().v4();
      idMap[node.id] = newId;

      return node.copyWith(
        id: newId,
        position: Position(x: node.position.x + 50, y: node.position.y + 50),
      );
    }).toList();

    final updatedWorkflow = state.currentWorkflow!.copyWith(
      nodes: [...state.currentWorkflow!.nodes, ...newNodes],
    );

    state = state.copyWith(currentWorkflow: updatedWorkflow);
    _saveToHistory(updatedWorkflow);

    if (!_isApplyingExternalChange) {
      for (final node in newNodes) {
        _notifyCollaboration(CollaborationEventType.nodeAdded, {
          'node': node.toJson(),
        });
      }
    }
  }

  void duplicateNode(String nodeId) {
    if (state.currentWorkflow == null) return;

    final originalNode = state.currentWorkflow!.nodes.firstWhere(
      (n) => n.id == nodeId,
    );

    final newNode = originalNode.copyWith(
      id: Uuid().v4(),
      position: Position(
        x: originalNode.position.x + 50,
        y: originalNode.position.y + 50,
      ),
    );

    final updatedWorkflow = state.currentWorkflow!.copyWith(
      nodes: [...state.currentWorkflow!.nodes, newNode],
    );

    state = state.copyWith(currentWorkflow: updatedWorkflow);
    _saveToHistory(updatedWorkflow);

    if (!_isApplyingExternalChange) {
      _notifyCollaboration(CollaborationEventType.nodeAdded, {
        'node': newNode.toJson(),
      });
    }
  }

  // ===========================================================================
  // PRIVATE HELPER METHODS
  // ===========================================================================

  WorkflowNode _applyPartialNodeChanges(
    WorkflowNode node,
    Map<String, dynamic> changes,
  ) {
    var updatedNode = node;

    for (final entry in changes.entries) {
      switch (entry.key) {
        case 'name':
          updatedNode = updatedNode.copyWith(name: entry.value as String);
          break;
        case 'description':
          updatedNode = updatedNode.copyWith(
            description: entry.value as String?,
          );
          break;
        case 'position':
          final positionData = entry.value as Map<String, dynamic>;
          updatedNode = updatedNode.copyWith(
            position: Position(
              x: (positionData['x'] as num).toDouble(),
              y: (positionData['y'] as num).toDouble(),
            ),
          );
          break;
        case 'config':
          if (entry.value != null) {
            updatedNode = updatedNode.copyWith(
              config: NodeConfig.fromJson(entry.value as Map<String, dynamic>),
            );
          }
          break;
        case 'inputs':
          if (entry.value != null) {
            updatedNode = updatedNode.copyWith(
              inputs: (entry.value as List)
                  .map((e) => NodeInput.fromJson(e as Map<String, dynamic>))
                  .toList(),
            );
          }
          break;
        case 'outputs':
          if (entry.value != null) {
            updatedNode = updatedNode.copyWith(
              outputs: (entry.value as List)
                  .map((e) => NodeOutput.fromJson(e as Map<String, dynamic>))
                  .toList(),
            );
          }
          break;
      }
    }

    return updatedNode;
  }

  WorkflowEdge _applyPartialEdgeChanges(
    WorkflowEdge edge,
    Map<String, dynamic> changes,
  ) {
    var updatedEdge = edge;

    for (final entry in changes.entries) {
      switch (entry.key) {
        case 'sourceHandle':
          updatedEdge = updatedEdge.copyWith(
            sourceHandle: entry.value as String?,
          );
          break;
        case 'targetHandle':
          updatedEdge = updatedEdge.copyWith(
            targetHandle: entry.value as String?,
          );
          break;
        case 'type':
          updatedEdge = updatedEdge.copyWith(type: _parseEdgeType(entry.value));
          break;
        case 'channelType':
          updatedEdge = updatedEdge.copyWith(
            channelType: _parseChannelType(entry.value),
          );
          break;
        case 'label':
          updatedEdge = updatedEdge.copyWith(label: entry.value as String?);
          break;
        case 'animated':
          updatedEdge = updatedEdge.copyWith(animated: entry.value as bool?);
          break;
        case 'condition':
          if (entry.value != null) {
            updatedEdge = updatedEdge.copyWith(
              condition: EdgeCondition.fromJson(
                entry.value as Map<String, dynamic>,
              ),
            );
          }
          break;
        case 'interceptors':
          if (entry.value != null) {
            updatedEdge = updatedEdge.copyWith(
              interceptors: (entry.value as List)
                  .map(
                    (e) => EdgeInterceptor.fromJson(e as Map<String, dynamic>),
                  )
                  .toList(),
            );
          }
          break;
      }
    }

    return updatedEdge;
  }

  Map<String, dynamic> _getNodeChanges(
    WorkflowNode oldNode,
    WorkflowNode newNode,
  ) {
    final changes = <String, dynamic>{};

    if (oldNode.name != newNode.name) {
      changes['name'] = newNode.name;
    }
    if (oldNode.description != newNode.description) {
      changes['description'] = newNode.description;
    }
    if (oldNode.position.x != newNode.position.x ||
        oldNode.position.y != newNode.position.y) {
      changes['position'] = {'x': newNode.position.x, 'y': newNode.position.y};
    }
    // Add more property comparisons as needed

    return changes;
  }

  Map<String, dynamic> _getEdgeChanges(
    WorkflowEdge oldEdge,
    WorkflowEdge newEdge,
  ) {
    final changes = <String, dynamic>{};

    if (oldEdge.sourceHandle != newEdge.sourceHandle) {
      changes['sourceHandle'] = newEdge.sourceHandle;
    }
    if (oldEdge.targetHandle != newEdge.targetHandle) {
      changes['targetHandle'] = newEdge.targetHandle;
    }
    if (oldEdge.type != newEdge.type) {
      changes['type'] = newEdge.type?.name;
    }
    if (oldEdge.channelType != newEdge.channelType) {
      changes['channelType'] = newEdge.channelType?.name;
    }
    if (oldEdge.label != newEdge.label) {
      changes['label'] = newEdge.label;
    }
    if (oldEdge.animated != newEdge.animated) {
      changes['animated'] = newEdge.animated;
    }

    return changes;
  }

  EdgeType _parseEdgeType(dynamic value) {
    if (value is EdgeType) return value;
    final stringValue = value.toString();
    return EdgeType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => EdgeType.defaultType,
    );
  }

  ChannelType _parseChannelType(dynamic value) {
    if (value is ChannelType) return value;
    final stringValue = value.toString();
    return ChannelType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => ChannelType.direct,
    );
  }

  final List<VoidCallback> _changeListeners = [];
  final List<CollaborationEventListener> _collaborationListeners = [];

  void _notifyCollaboration(
    CollaborationEventType eventType,
    Map<String, dynamic> data,
  ) {
    for (final listener in _collaborationListeners) {
      listener(eventType, data);
    }
    for (final listener in _changeListeners) {
      listener();
    }
  }

  void addExternalChangeListener(VoidCallback listener) {
    _changeListeners.add(listener);
  }

  void addCollaborationEventListener(CollaborationEventListener listener) {
    _collaborationListeners.add(listener);
  }

  void removeExternalChangeListener(VoidCallback listener) {
    _changeListeners.remove(listener);
  }

  void _notifyExternalChangeListeners() {
    for (final listener in _externalChangeListeners) {
      listener();
    }
  }
}

// Typedef for collaboration event listeners
typedef CollaborationEventListener =
    void Function(CollaborationEventType eventType, Map<String, dynamic> data);

final workflowProvider = StateNotifierProvider<WorkflowNotifier, WorkflowState>(
  (ref) {
    return WorkflowNotifier();
  },
);

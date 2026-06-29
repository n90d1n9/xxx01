import 'package:flutter/widgets.dart';

import '../../../dummy.dart';
import '../components/history/history_action.dart';
import '../model/workflow_node.dart';
import '../model/workflow_node_port.dart';
import '../state/workflow_state.dart';

class NodeService {
  String _generateId() => 'node_${DateTime.now().millisecondsSinceEpoch}';

  HistoryAction addNode(WorkflowState state, String type, Offset position) {
    final allNodes = nodeTypesByCategory.values.expand((list) => list).toList();
    final nodeConfig = allNodes.firstWhere((t) => t.type == type);
    final id = _generateId();

    final node = WorkflowNode(
      id: id,
      type: type,
      label: nodeConfig.label,
      position: position,
      config: Map.fromEntries(
        nodeConfig.configFields.entries.map(
          (e) => MapEntry(e.key, e.value.defaultValue),
        ),
      ),
      inputs: nodeConfig.inputs
          .map((p) => WorkflowNodePort(id: p.id, label: p.label, type: p.type))
          .toList(),
      outputs: nodeConfig.outputs
          .map((p) => WorkflowNodePort(id: p.id, label: p.label, type: p.type))
          .toList(),
    );

    return AddNodeAction(node);
  }

  WorkflowState updatePosition(
    WorkflowState state,
    String nodeId,
    Offset position,
  ) {
    final nodes = state.nodes.map((node) {
      if (node.id == nodeId) return node.copyWith(position: position);
      return node;
    }).toList();
    return state.copyWith(nodes: nodes);
  }

  HistoryAction createPositionChangeAction(
    String nodeId,
    Offset from,
    Offset to,
  ) {
    return UpdateNodePositionAction(nodeId, from, to);
  }

  WorkflowState updateConfig(
    WorkflowState state,
    String nodeId,
    String key,
    dynamic value,
  ) {
    final nodes = state.nodes.map((node) {
      if (node.id == nodeId) {
        final newConfig = Map<String, dynamic>.from(node.config);
        newConfig[key] = value;
        return node.copyWith(config: newConfig);
      }
      return node;
    }).toList();
    return state.copyWith(nodes: nodes);
  }

  WorkflowState updateLabel(WorkflowState state, String nodeId, String label) {
    final nodes = state.nodes.map((node) {
      if (node.id == nodeId) return node.copyWith(label: label);
      return node;
    }).toList();
    return state.copyWith(nodes: nodes);
  }

  WorkflowState deleteNode(WorkflowState state, String nodeId) {
    return state.copyWith(
      nodes: state.nodes.where((n) => n.id != nodeId).toList(),
      connections: state.connections
          .where((c) => c.sourceNodeId != nodeId && c.targetNodeId != nodeId)
          .toList(),
    );
  }

  // Fixed: Return HistoryAction instead of WorkflowState
  HistoryAction? duplicateNode(WorkflowState state, String nodeId) {
    try {
      final node = state.nodes.firstWhere((n) => n.id == nodeId);
      final newNode = WorkflowNode(
        id: _generateId(),
        type: node.type,
        label: '${node.label} (Copy)',
        position: node.position + const Offset(50, 50),
        config: Map.from(node.config),
        inputs: node.inputs,
        outputs: node.outputs,
      );
      return AddNodeAction(newNode);
    } catch (e) {
      return null;
    }
  }

  // Helper method to remove connections for a node
  WorkflowState removeConnectionsForNode(WorkflowState state, String nodeId) {
    return state.copyWith(
      connections: state.connections
          .where((c) => c.sourceNodeId != nodeId && c.targetNodeId != nodeId)
          .toList(),
    );
  }
}

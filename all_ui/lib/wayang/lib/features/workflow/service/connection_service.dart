import '../components/history/history_action.dart';
import '../model/workflow_connection.dart';
import '../state/workflow_state.dart';

class ConnectionService {
  String _generateId() => 'conn_${DateTime.now().millisecondsSinceEpoch}';

  bool canAddConnection(
    WorkflowState state,
    String sourceNodeId,
    String targetNodeId,
    String sourcePortId,
    String targetPortId,
  ) {
    if (sourceNodeId == targetNodeId) return false;

    // Check if connection already exists
    final connectionExists = state.connections.any(
      (c) =>
          c.sourceNodeId == sourceNodeId &&
          c.targetNodeId == targetNodeId &&
          c.sourcePortId == sourcePortId &&
          c.targetPortId == targetPortId,
    );

    if (connectionExists) return false;

    // Check if nodes exist
    final sourceNodeExists = state.nodes.any((n) => n.id == sourceNodeId);
    final targetNodeExists = state.nodes.any((n) => n.id == targetNodeId);

    return sourceNodeExists && targetNodeExists;
  }

  // Fixed: Return HistoryAction instead of WorkflowState
  HistoryAction? addConnection(
    WorkflowState state,
    String sourceNodeId,
    String targetNodeId,
    String sourcePortId,
    String targetPortId,
  ) {
    if (!canAddConnection(
      state,
      sourceNodeId,
      targetNodeId,
      sourcePortId,
      targetPortId,
    )) {
      return null;
    }

    final id = _generateId();
    final connection = WorkflowConnection(
      id: id,
      sourceNodeId: sourceNodeId,
      targetNodeId: targetNodeId,
      sourcePortId: sourcePortId,
      targetPortId: targetPortId,
    );

    return AddConnectionAction(connection);
  }

  // Fixed: Return HistoryAction instead of WorkflowState
  HistoryAction? deleteConnection(WorkflowState state, String connectionId) {
    try {
      final connection = state.connections.firstWhere(
        (c) => c.id == connectionId,
      );
      return DeleteConnectionAction(connectionId, connection);
    } catch (e) {
      return null;
    }
  }

  WorkflowState removeConnectionsForNode(WorkflowState state, String nodeId) {
    return state.copyWith(
      connections: state.connections
          .where((c) => c.sourceNodeId != nodeId && c.targetNodeId != nodeId)
          .toList(),
    );
  }

  bool hasCycle(WorkflowState state) {
    final visited = <String>{};
    final recStack = <String>{};

    bool dfs(String nodeId) {
      if (recStack.contains(nodeId)) return true;
      if (visited.contains(nodeId)) return false;

      visited.add(nodeId);
      recStack.add(nodeId);

      final outgoing = state.connections.where((c) => c.sourceNodeId == nodeId);
      for (final conn in outgoing) {
        if (dfs(conn.targetNodeId)) return true;
      }

      recStack.remove(nodeId);
      return false;
    }

    for (final node in state.nodes) {
      if (!visited.contains(node.id)) {
        if (dfs(node.id)) return true;
      }
    }
    return false;
  }

  // Helper to check if a connection would create a cycle
  bool wouldCreateCycle(
    WorkflowState state,
    String sourceNodeId,
    String targetNodeId,
  ) {
    // Create temporary state with the new connection
    final tempConnection = WorkflowConnection(
      id: 'temp',
      sourceNodeId: sourceNodeId,
      targetNodeId: targetNodeId,
      sourcePortId: 'temp',
      targetPortId: 'temp',
    );

    final tempState = state.copyWith(
      connections: [...state.connections, tempConnection],
    );

    return hasCycle(tempState);
  }
}

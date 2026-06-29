import 'dart:math' as math;
import 'dart:async';
import '../../../dummy.dart';
import '../model/workflow_node.dart';
import '../model/workflow_node_port.dart';
import '../state/workflow_state.dart';

class ExecutionUpdate {
  final List<WorkflowNode>? nodes;
  final String? log;
  final bool? isExecuting;

  ExecutionUpdate({this.nodes, this.log, this.isExecuting});
}

class ExecutionService {
  final math.Random _random = math.Random();
  bool _isStopped = false;

  void stop() {
    _isStopped = true;
  }

  Future<void> execute(
    WorkflowState state,
    void Function(ExecutionUpdate) onProgress,
  ) async {
    _isStopped = false;

    // Reset all node statuses
    final resetNodes = state.nodes
        .map((node) => node.copyWith(status: NodeStatus.idle, error: null))
        .toList();

    onProgress(ExecutionUpdate(nodes: resetNodes));

    // Validation
    if (state.nodes.isEmpty) {
      onProgress(
        ExecutionUpdate(log: 'Error: Workflow is empty', isExecuting: false),
      );
      return;
    }

    final allNodes = nodeTypesByCategory.values.expand((list) => list).toList();
    final hasTrigger = state.nodes.any((node) {
      final config = allNodes.firstWhere((n) => n.type == node.type);
      return config.category == 'Triggers';
    });

    if (!hasTrigger) {
      onProgress(
        ExecutionUpdate(
          log: 'Error: Workflow must have at least one trigger node',
          isExecuting: false,
        ),
      );
      return;
    }

    if (_hasCycle(state)) {
      onProgress(
        ExecutionUpdate(
          log: 'Error: Workflow contains cycles',
          isExecuting: false,
        ),
      );
      return;
    }

    onProgress(ExecutionUpdate(log: 'Starting execution...'));

    final executionOrder = _getExecutionOrder(state);
    var log = 'Starting execution...\n';

    for (final nodeId in executionOrder) {
      if (_isStopped) {
        onProgress(
          ExecutionUpdate(
            log: '$log\nExecution stopped by user',
            isExecuting: false,
          ),
        );
        return;
      }

      final node = state.nodes.firstWhere((n) => n.id == nodeId);

      // Update status to running
      final runningNodes = resetNodes.map((n) {
        if (n.id == nodeId) return n.copyWith(status: NodeStatus.running);
        return n;
      }).toList();

      onProgress(ExecutionUpdate(nodes: runningNodes, log: log));

      log += 'Executing: ${node.label}\n';
      onProgress(ExecutionUpdate(log: log));

      // Simulate execution time
      await Future.delayed(const Duration(milliseconds: 800));

      if (_isStopped) break;

      // Simulate random failure (10% chance)
      if (_random.nextDouble() < 0.1) {
        final errorNodes = runningNodes.map((n) {
          if (n.id == nodeId) {
            return n.copyWith(
              status: NodeStatus.error,
              error: 'Execution failed randomly',
            );
          }
          return n;
        }).toList();

        log += '❌ Error in ${node.label}: Execution failed randomly\n';
        onProgress(
          ExecutionUpdate(nodes: errorNodes, log: log, isExecuting: false),
        );
        return;
      }

      // Success
      final successNodes = runningNodes.map((n) {
        if (n.id == nodeId) return n.copyWith(status: NodeStatus.success);
        return n;
      }).toList();

      log += '✅ Completed: ${node.label}\n';
      onProgress(ExecutionUpdate(nodes: successNodes, log: log));
    }

    if (!_isStopped) {
      log += '🎉 Workflow completed successfully!\n';
      onProgress(ExecutionUpdate(log: log, isExecuting: false));
    }
  }

  bool _hasCycle(WorkflowState state) {
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

  List<String> _getExecutionOrder(WorkflowState state) {
    final inDegree = <String, int>{};
    final adjList = <String, List<String>>{};

    // Initialize
    for (final node in state.nodes) {
      inDegree[node.id] = 0;
      adjList[node.id] = [];
    }

    // Build graph
    for (final conn in state.connections) {
      adjList[conn.sourceNodeId]!.add(conn.targetNodeId);
      inDegree[conn.targetNodeId] = inDegree[conn.targetNodeId]! + 1;
    }

    // Topological sort
    final queue = <String>[];
    for (final entry in inDegree.entries) {
      if (entry.value == 0) queue.add(entry.key);
    }

    final result = <String>[];
    while (queue.isNotEmpty) {
      final node = queue.removeAt(0);
      result.add(node);

      for (final neighbor in adjList[node]!) {
        inDegree[neighbor] = inDegree[neighbor]! - 1;
        if (inDegree[neighbor] == 0) queue.add(neighbor);
      }
    }

    return result;
  }
}

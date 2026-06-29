import '../../execution/model/execution_event.dart';
import '../../execution/model/execution_result.dart';
import '../../execution/execution_config.dart';
import '../../execution/execution_context.dart';
import '../../execution/model/node_execution_result.dart';
import '../schema/workflow_data.dart';

class ParallelExecutor {
  final WorkflowData workflow;
  final ExecutionConfig config;

  ParallelExecutor({required this.workflow, required this.config});

  Future<ExecutionResult> execute(Map<String, dynamic> initialContext) async {
    final executionId = DateTime.now().millisecondsSinceEpoch.toString();
    final startTime = DateTime.now();
    final context = ExecutionContext(
      workflowId: workflow.id,
      executionId: executionId,
      variables: Map.from(initialContext),
      nodeOutputs: {},
    );

    try {
      // Group nodes by execution level
      final levels = _getExecutionLevels();
      final nodeResults = <NodeExecutionResult>[];

      // Execute each level in parallel
      for (final level in levels) {
        final futures = level
            .map((nodeId) => _executeNode(nodeId, context))
            .toList();
        final results = await Future.wait(futures);
        nodeResults.addAll(results);

        // Check for failures
        if (results.any((r) => r.status == ExecutionStatus.failed) &&
            !config.continueOnError) {
          throw Exception('Node execution failed in parallel batch');
        }
      }

      final endTime = DateTime.now();
      return ExecutionResult(
        executionId: executionId,
        workflowId: workflow.id,
        status: ExecutionStatus.success,
        startTime: startTime,
        endTime: endTime,
        input: initialContext,
        output: context.variables,
        nodeResults: nodeResults,
      );
    } catch (e) {
      final endTime = DateTime.now();
      return ExecutionResult(
        executionId: executionId,
        workflowId: workflow.id,
        status: ExecutionStatus.failed,
        startTime: startTime,
        endTime: endTime,
        input: initialContext,
        output: context.variables,
        nodeResults: [],
        error: e.toString(),
      );
    }
  }

  List<List<String>> _getExecutionLevels() {
    final levels = <List<String>>[];
    final processed = <String>{};
    final inDegree = <String, int>{};

    // Calculate in-degrees
    for (final node in workflow.nodes) {
      inDegree[node.id] = 0;
    }

    for (final conn in workflow.connections) {
      inDegree[conn.targetNodeId] = (inDegree[conn.targetNodeId] ?? 0) + 1;
    }

    while (processed.length < workflow.nodes.length) {
      final currentLevel = <String>[];

      // Find all nodes with in-degree 0
      for (final node in workflow.nodes) {
        if (!processed.contains(node.id) && inDegree[node.id] == 0) {
          currentLevel.add(node.id);
        }
      }

      if (currentLevel.isEmpty) break;

      levels.add(currentLevel);
      processed.addAll(currentLevel);

      // Update in-degrees
      for (final nodeId in currentLevel) {
        final outgoing = workflow.connections.where(
          (c) => c.sourceNodeId == nodeId,
        );
        for (final conn in outgoing) {
          inDegree[conn.targetNodeId] = (inDegree[conn.targetNodeId] ?? 1) - 1;
        }
      }
    }

    return levels;
  }

  Future<NodeExecutionResult> _executeNode(
    String nodeId,
    ExecutionContext context,
  ) async {
    // Simplified node execution for parallel processing
    final node = workflow.nodes.firstWhere((n) => n.id == nodeId);
    final startTime = DateTime.now();

    await Future.delayed(const Duration(milliseconds: 500));

    return NodeExecutionResult.success(
      nodeId: nodeId,

      outputs: {'result': 'success'},
      //outputs: {},
      duration: Duration(),
    );
  }
}

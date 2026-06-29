import 'package:flutter_riverpod/legacy.dart';

import '../../model/execution_step.dart';
import '../../model/workflow_execution_step.dart';

import '../../schema/node/node_type.dart';
import '../../schema/workflow/workflow.dart';
import '../../schema/workflow/workflow_node.dart';

class WorkflowExecutionNotifier extends StateNotifier<WorkflowExecutionState> {
  final Workflow workflow;

  WorkflowExecutionNotifier(this.workflow) : super(WorkflowExecutionState());

  Future<void> execute(Map<String, dynamic> inputData) async {
    state = state.copyWith(
      isRunning: true,
      executionData: inputData,
      executionHistory: [],
      error: null,
      progress: 0.0,
    );

    try {
      // Find start node
      final startNode = workflow.nodes.firstWhere(
        (n) => n.type == NodeType.start,
        orElse: () => workflow.nodes.first,
      );

      await _executeNode(startNode, inputData);

      state = state.copyWith(isRunning: false, progress: 1.0);
    } catch (e) {
      state = state.copyWith(isRunning: false, error: e.toString());
    }
  }

  Future<void> _executeNode(
    WorkflowNode node,
    Map<String, dynamic> data,
  ) async {
    final startTime = DateTime.now();
    state = state.copyWith(currentNodeId: node.id);

    try {
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate processing

      final output = await _processNode(node, data);

      final step = ExecutionStep(
        nodeId: node.id,
        nodeName: node.name,
        timestamp: startTime,
        input: data,
        output: output,
        duration: DateTime.now().difference(startTime),
        success: true,
      );

      state = state.copyWith(
        executionHistory: [...state.executionHistory, step],
        executionData: output,
        progress: state.executionHistory.length / workflow.nodes.length,
      );

      // Find next nodes
      final nextEdges = workflow.edges?.where((e) => e.source == node.id) ?? [];
      for (final edge in nextEdges) {
        final nextNode = workflow.nodes.firstWhere((n) => n.id == edge.target);

        // Check edge condition if exists
        if (edge.condition != null) {
          final conditionMet = _evaluateCondition(
            edge.condition!.expression,
            output,
          );
          if (!conditionMet) continue;
        }

        await _executeNode(nextNode, output);
      }
    } catch (e) {
      final step = ExecutionStep(
        nodeId: node.id,
        nodeName: node.name,
        timestamp: startTime,
        input: data,
        output: {},
        duration: DateTime.now().difference(startTime),
        success: false,
        error: e.toString(),
      );

      state = state.copyWith(
        executionHistory: [...state.executionHistory, step],
        error: e.toString(),
      );

      rethrow;
    }
  }

  Future<Map<String, dynamic>> _processNode(
    WorkflowNode node,
    Map<String, dynamic> data,
  ) async {
    switch (node.type) {
      case NodeType.start:
      case NodeType.end:
        return data;

      case NodeType.transform:
        return _processTransform(node, data);

      case NodeType.filter:
        return _processFilter(node, data);

      case NodeType.splitter:
        return _processSplitter(node, data);

      case NodeType.aggregator:
        return _processAggregator(node, data);

      case NodeType.condition:
      case NodeType.router:
        return _processRouter(node, data);

      case NodeType.llm:
        return _processLLM(node, data);

      default:
        return data;
    }
  }

  Map<String, dynamic> _processTransform(
    WorkflowNode node,
    Map<String, dynamic> data,
  ) {
    // Simple transformation simulation
    return {
      ...data,
      'transformed': true,
      'transformedAt': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _processFilter(
    WorkflowNode node,
    Map<String, dynamic> data,
  ) {
    final condition = node.config?.condition?.expression ?? 'true';
    final result = _evaluateCondition(condition, data);

    return {...data, 'filtered': result};
  }

  Map<String, dynamic> _processSplitter(
    WorkflowNode node,
    Map<String, dynamic> data,
  ) {
    // Simulate splitting data
    return {
      'items': [data],
      'splitCount': 1,
    };
  }

  Map<String, dynamic> _processAggregator(
    WorkflowNode node,
    Map<String, dynamic> data,
  ) {
    return {
      'aggregated': data,
      'aggregatedAt': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _processRouter(
    WorkflowNode node,
    Map<String, dynamic> data,
  ) {
    return {...data, 'routedThrough': node.name};
  }

  Map<String, dynamic> _processLLM(
    WorkflowNode node,
    Map<String, dynamic> data,
  ) {
    // Simulate LLM processing
    return {
      ...data,
      'llmResponse':
          'Simulated LLM response for: ${data['input'] ?? 'no input'}',
      'model': node.config?.llmConfig?.model ?? 'unknown',
    };
  }

  bool _evaluateCondition(String expression, Map<String, dynamic> data) {
    // Simple condition evaluation simulation
    // In production, use a proper expression evaluator
    return true;
  }

  void stop() {
    state = state.copyWith(isRunning: false, currentNodeId: null);
  }

  void reset() {
    state = WorkflowExecutionState();
  }
}

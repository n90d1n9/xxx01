import 'dart:async';
import 'dart:math' as math;

import '../../execution/model/node_execution_result.dart';
import '../components/node/model/schema/node_data.dart';
import '../../execution/model/execution_event.dart';
import '../../execution/model/execution_result.dart';
import '../exception/workfloe_validation.dart';
import '../../execution/execution_config.dart';
import '../../execution/execution_context.dart';
import '../../execution/model/validation_result.dart';
import '../schema/workflow_data.dart';

class WorkflowExecutor {
  final WorkflowData workflow;
  final Map<String, dynamic> initialContext;
  final ExecutionConfig config;
  final List<ExecutionListener> listeners;

  WorkflowExecutor({
    required this.workflow,
    this.initialContext = const {},
    ExecutionConfig? config,
    this.listeners = const [],
  }) : config = config ?? ExecutionConfig();

  Future<ExecutionResult> execute() async {
    final executionId = _generateId();
    final startTime = DateTime.now();
    final context = ExecutionContext(
      workflowId: workflow.id,
      executionId: executionId,
      variables: Map.from(initialContext),
      nodeOutputs: {},
    );

    try {
      _notifyListeners(ExecutionEvent.started(executionId));

      // Validate workflow
      final validation = _validateWorkflow();
      if (!validation.isValid) {
        throw WorkflowValidationException(validation.errors);
      }

      // Get execution order
      final executionOrder = _getExecutionOrder();

      // Execute nodes
      final nodeResults = <NodeExecutionResult>[];
      for (final nodeId in executionOrder) {
        final nodeResult = await _executeNode(nodeId, context);
        nodeResults.add(nodeResult);

        if (nodeResult.status == ExecutionStatus.failed) {
          if (!config.continueOnError) {
            throw NodeExecutionException(
              nodeId,
              nodeResult.error ?? 'Unknown error',
            );
          }
        }
      }

      final endTime = DateTime.now();
      final result = ExecutionResult(
        executionId: executionId,
        workflowId: workflow.id,
        status: ExecutionStatus.success,
        startTime: startTime,
        endTime: endTime,
        input: initialContext,
        output: context.variables,
        nodeResults: nodeResults,
      );

      _notifyListeners(ExecutionEvent.completed(executionId, result));
      return result;
    } catch (e) {
      final endTime = DateTime.now();
      final result = ExecutionResult(
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

      _notifyListeners(ExecutionEvent.failed(executionId, e.toString()));
      return result;
    }
  }

  Future<NodeExecutionResult> _executeNode(
    String nodeId,
    ExecutionContext context,
  ) async {
    final node = workflow.nodes.firstWhere((n) => n.id == nodeId);
    final startTime = DateTime.now();

    _notifyListeners(ExecutionEvent.nodeStarted(nodeId, node.label));

    try {
      // Check if node is disabled
      if (node.disabled) {
        return NodeExecutionResult.success(
          nodeId: nodeId,

          outputs: {},
          duration: Duration(),
        );
      }

      // Get node inputs
      final inputs = _getNodeInputs(nodeId, context);

      // Execute with retry logic
      Map<String, dynamic> output;
      int retryCount = 0;

      while (true) {
        try {
          output = await _executeNodeWithTimeout(node, inputs, context);
          break;
        } catch (e) {
          if (retryCount >= config.maxRetries) {
            rethrow;
          }
          retryCount++;
          await Future.delayed(
            Duration(
              milliseconds:
                  config.retryDelayMs * math.pow(2, retryCount - 1).toInt(),
            ),
          );
        }
      }

      // Store output in context
      context.nodeOutputs[nodeId] = output;

      final endTime = DateTime.now();
      final result = NodeExecutionResult.success(
        nodeId: nodeId,
        outputs: {},
        duration: Duration(),
      );

      _notifyListeners(ExecutionEvent.nodeCompleted(nodeId, result));
      return result;
    } catch (e) {
      final endTime = DateTime.now();
      final result = NodeExecutionResult.success(
        nodeId: nodeId,
        outputs: {},
        duration: Duration(),
      );

      _notifyListeners(ExecutionEvent.nodeFailed(nodeId, e.toString()));
      return result;
    }
  }

  Future<Map<String, dynamic>> _executeNodeWithTimeout(
    NodeData node,
    Map<String, dynamic> inputs,
    ExecutionContext context,
  ) async {
    return await Future.any([
      _executeNodeLogic(node, inputs, context),
      Future.delayed(Duration(seconds: config.nodeTimeoutSeconds)).then((_) {
        throw TimeoutException('Node execution timeout');
      }),
    ]);
  }

  Future<Map<String, dynamic>> _executeNodeLogic(
    NodeData node,
    Map<String, dynamic> inputs,
    ExecutionContext context,
  ) async {
    // Execute based on node type
    switch (node.type) {
      case 'webhook':
        return await _executeWebhook(node, inputs, context);
      case 'llm':
        return await _executeLLM(node, inputs, context);
      case 'condition':
        return await _executeCondition(node, inputs, context);
      case 'loop':
        return await _executeLoop(node, inputs, context);
      case 'api':
        return await _executeAPI(node, inputs, context);
      case 'transform':
        return await _executeTransform(node, inputs, context);
      case 'delay':
        return await _executeDelay(node, inputs, context);
      default:
        return await _executeGeneric(node, inputs, context);
    }
  }

  // ==================== NODE EXECUTORS ====================

  Future<Map<String, dynamic>> _executeWebhook(
    NodeData node,
    Map<String, dynamic> inputs,
    ExecutionContext context,
  ) async {
    // Webhook logic
    await Future.delayed(const Duration(milliseconds: 100));
    return {'triggered': true, 'data': inputs};
  }

  Future<Map<String, dynamic>> _executeLLM(
    NodeData node,
    Map<String, dynamic> inputs,
    ExecutionContext context,
  ) async {
    final prompt = inputs['prompt'] ?? '';
    final model = node.config['model'] ?? 'gpt-4';
    final temperature = node.config['temperature'] ?? 0.7;

    // Simulate LLM call
    await Future.delayed(const Duration(milliseconds: 1500));

    return {
      'response': 'AI response to: $prompt',
      'model': model,
      'tokens': 150,
    };
  }

  Future<Map<String, dynamic>> _executeCondition(
    NodeData node,
    Map<String, dynamic> inputs,
    ExecutionContext context,
  ) async {
    final condition = node.config['condition'] ?? 'true';
    final result = _evaluateExpression(condition, inputs, context);

    return {'condition': result, 'branch': result ? 'true' : 'false'};
  }

  Future<Map<String, dynamic>> _executeLoop(
    NodeData node,
    Map<String, dynamic> inputs,
    ExecutionContext context,
  ) async {
    final loopType = node.config['loopType'] ?? 'forEach';
    final maxIterations = node.config['maxIterations'] ?? 1000;
    final results = <Map<String, dynamic>>[];

    if (loopType == 'forEach') {
      final items = inputs['items'] as List? ?? [];
      for (var i = 0; i < items.length && i < maxIterations; i++) {
        final item = items[i];
        // Execute loop body with item
        results.add({'index': i, 'item': item, 'processed': true});
      }
    } else if (loopType == 'while') {
      final condition = node.config['condition'] ?? 'false';
      var iteration = 0;
      while (_evaluateExpression(condition, inputs, context) &&
          iteration < maxIterations) {
        results.add({'iteration': iteration});
        iteration++;
      }
    } else if (loopType == 'count') {
      final count = node.config['count'] ?? 1;
      for (var i = 0; i < count && i < maxIterations; i++) {
        results.add({'iteration': i});
      }
    }

    return {'iterations': results.length, 'results': results};
  }

  Future<Map<String, dynamic>> _executeAPI(
    NodeData node,
    Map<String, dynamic> inputs,
    ExecutionContext context,
  ) async {
    final url = node.config['url'] ?? '';
    final method = node.config['method'] ?? 'GET';
    final headers = node.config['headers'] as Map<String, dynamic>? ?? {};
    final body = inputs['body'];

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    return {
      'statusCode': 200,
      'data': {'success': true, 'message': 'API response'},
      'headers': headers,
    };
  }

  Future<Map<String, dynamic>> _executeTransform(
    NodeData node,
    Map<String, dynamic> inputs,
    ExecutionContext context,
  ) async {
    final script = node.config['script'] ?? 'return input';

    // Execute transformation script
    final output = _executeScript(script, inputs, context);

    return {'transformed': output};
  }

  Future<Map<String, dynamic>> _executeDelay(
    NodeData node,
    Map<String, dynamic> inputs,
    ExecutionContext context,
  ) async {
    final delayMs = node.config['delayMs'] ?? 1000;
    await Future.delayed(Duration(milliseconds: delayMs));
    return {'delayed': true, 'duration': delayMs};
  }

  Future<Map<String, dynamic>> _executeGeneric(
    NodeData node,
    Map<String, dynamic> inputs,
    ExecutionContext context,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {'output': inputs};
  }

  // ==================== HELPER METHODS ====================

  Map<String, dynamic> _getNodeInputs(String nodeId, ExecutionContext context) {
    final inputs = <String, dynamic>{};

    // Get inputs from connected nodes
    final incomingConnections = workflow.connections.where(
      (c) => c.targetNodeId == nodeId,
    );

    for (final conn in incomingConnections) {
      final sourceOutput = context.nodeOutputs[conn.sourceNodeId];
      if (sourceOutput != null) {
        inputs[conn.targetPortId] =
            sourceOutput[conn.sourcePortId] ?? sourceOutput;
      }
    }

    // Add workflow variables
    inputs.addAll(context.variables);

    return inputs;
  }

  bool _evaluateExpression(
    String expression,
    Map<String, dynamic> data,
    ExecutionContext context,
  ) {
    // Simple expression evaluator
    // In production, use a proper expression parser
    try {
      // Replace variables in expression
      var expr = expression;
      data.forEach((key, value) {
        expr = expr.replaceAll(key, value.toString());
      });

      // Simple evaluation
      if (expr.contains('>')) {
        final parts = expr.split('>');
        return double.parse(parts[0].trim()) > double.parse(parts[1].trim());
      } else if (expr.contains('<')) {
        final parts = expr.split('<');
        return double.parse(parts[0].trim()) < double.parse(parts[1].trim());
      } else if (expr.contains('==')) {
        final parts = expr.split('==');
        return parts[0].trim() == parts[1].trim();
      }

      return expr.toLowerCase() == 'true';
    } catch (e) {
      return false;
    }
  }

  dynamic _executeScript(
    String script,
    Map<String, dynamic> inputs,
    ExecutionContext context,
  ) {
    // In production, use a proper scripting engine like dart:js or a sandboxed VM
    // This is a simplified version
    return inputs;
  }

  ValidationResult _validateWorkflow() {
    final errors = <String>[];

    // Check for nodes
    if (workflow.nodes.isEmpty) {
      errors.add('Workflow has no nodes');
    }

    // Check for trigger nodes
    final hasTrigger = workflow.nodes.any(
      (n) => n.type == 'webhook' || n.type == 'schedule',
    );
    if (!hasTrigger) {
      errors.add('Workflow must have at least one trigger node');
    }

    // Check for cycles
    if (_hasCycle()) {
      errors.add('Workflow contains cycles');
    }

    // Check for orphaned nodes
    final connectedNodes = <String>{};
    for (final conn in workflow.connections) {
      connectedNodes.add(conn.sourceNodeId);
      connectedNodes.add(conn.targetNodeId);
    }

    final orphanedNodes = workflow.nodes.where(
      (n) => !connectedNodes.contains(n.id) && n.type != 'webhook',
    );
    if (orphanedNodes.isNotEmpty && workflow.nodes.length > 1) {
      errors.add('Workflow has ${orphanedNodes.length} orphaned nodes');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  bool _hasCycle() {
    final visited = <String>{};
    final recStack = <String>{};

    bool dfs(String nodeId) {
      visited.add(nodeId);
      recStack.add(nodeId);

      final outgoing = workflow.connections.where(
        (c) => c.sourceNodeId == nodeId,
      );
      for (final conn in outgoing) {
        if (!visited.contains(conn.targetNodeId)) {
          if (dfs(conn.targetNodeId)) return true;
        } else if (recStack.contains(conn.targetNodeId)) {
          return true;
        }
      }

      recStack.remove(nodeId);
      return false;
    }

    for (final node in workflow.nodes) {
      if (!visited.contains(node.id)) {
        if (dfs(node.id)) return true;
      }
    }
    return false;
  }

  List<String> _getExecutionOrder() {
    final inDegree = <String, int>{};
    final adjList = <String, List<String>>{};

    for (final node in workflow.nodes) {
      inDegree[node.id] = 0;
      adjList[node.id] = [];
    }

    for (final conn in workflow.connections) {
      adjList[conn.sourceNodeId]!.add(conn.targetNodeId);
      inDegree[conn.targetNodeId] = (inDegree[conn.targetNodeId] ?? 0) + 1;
    }

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

  void _notifyListeners(ExecutionEvent event) {
    for (final listener in listeners) {
      listener.onEvent(event);
    }
  }

  static String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();
}

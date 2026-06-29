import '../models/node_card.dart';
import '../schema/integration_route.dart';
import '../schema/route_test_suite.dart';

class RouteTestFramework {
  /// Creates a test suite for a route
  static RouteTestSuite createTestSuite(IntegrationRoute route) {
    return RouteTestSuite(routeId: route.id, routeName: route.name, tests: []);
  }

  /// Simulates route execution with test data
  static Future<RouteExecutionResult> simulateRoute(
    IntegrationRoute route,
    Map<String, dynamic> testData,
  ) async {
    final executionSteps = <ExecutionStep>[];
    final startTime = DateTime.now();

    try {
      // Simulate each node execution
      for (final node in route.nodes) {
        final stepResult = await _simulateNodeExecution(
          node,
          testData,
          executionSteps,
        );

        executionSteps.add(stepResult);

        if (!stepResult.success) {
          return RouteExecutionResult(
            success: false,
            executionTime: DateTime.now().difference(startTime),
            steps: executionSteps,
            error: stepResult.error,
          );
        }

        // Update test data with step output
        testData = stepResult.outputData ?? testData;
      }

      return RouteExecutionResult(
        success: true,
        executionTime: DateTime.now().difference(startTime),
        steps: executionSteps,
        outputData: testData,
      );
    } catch (e) {
      return RouteExecutionResult(
        success: false,
        executionTime: DateTime.now().difference(startTime),
        steps: executionSteps,
        error: e.toString(),
      );
    }
  }

  static Future<ExecutionStep> _simulateNodeExecution(
    NodeCard node,
    Map<String, dynamic> inputData,
    List<ExecutionStep> previousSteps,
  ) async {
    final startTime = DateTime.now();

    try {
      // Simulate different node types
      Map<String, dynamic>? outputData;

      switch (node.type) {
        case 'data-mapper':
          outputData = _simulateDataMapping(node, inputData);
          break;

        case 'content-based-router':
          outputData = _simulateRouting(node, inputData);
          break;

        case 'filter':
          final passes = _evaluateFilter(node, inputData);
          outputData = passes ? inputData : null;
          break;

        case 'enricher':
          outputData = _simulateEnrichment(node, inputData);
          break;

        default:
          outputData = inputData; // Pass through
      }

      return ExecutionStep(
        nodeId: node.id,
        nodeName: node.name,
        nodeType: node.type,
        success: true,
        executionTime: DateTime.now().difference(startTime),
        inputData: inputData,
        outputData: outputData,
        message: 'Node executed successfully',
      );
    } catch (e) {
      return ExecutionStep(
        nodeId: node.id,
        nodeName: node.name,
        nodeType: node.type,
        success: false,
        executionTime: DateTime.now().difference(startTime),
        inputData: inputData,
        error: e.toString(),
        message: 'Node execution failed',
      );
    }
  }

  static Map<String, dynamic> _simulateDataMapping(
    NodeCard node,
    Map<String, dynamic> input,
  ) {
    final output = <String, dynamic>{};
    final mappings = node.config['mappings'] as List? ?? [];

    for (final mapping in mappings) {
      final sourcePath = mapping['sourcePath'] as String;
      final targetPath = mapping['targetPath'] as String;

      // Simple path resolution
      final value = _getValueByPath(input, sourcePath);
      _setValueByPath(output, targetPath, value);
    }

    return output;
  }

  static Map<String, dynamic> _simulateRouting(
    NodeCard node,
    Map<String, dynamic> input,
  ) {
    final choices = node.config['choices'] as List? ?? [];

    for (final choice in choices) {
      final condition = choice['condition'] as String;
      if (_evaluateCondition(condition, input)) {
        return {...input, '_routedTo': choice['endpoint']};
      }
    }

    // Otherwise route
    if (node.config.containsKey('otherwise')) {
      return {...input, '_routedTo': node.config['otherwise']};
    }

    return input;
  }

  static bool _evaluateFilter(NodeCard node, Map<String, dynamic> input) {
    final expression = node.config['expression'] as String? ?? '';
    return _evaluateCondition(expression, input);
  }

  static Map<String, dynamic> _simulateEnrichment(
    NodeCard node,
    Map<String, dynamic> input,
  ) {
    // Simulate enrichment by adding mock data
    return {
      ...input,
      '_enriched': true,
      '_enrichmentSource': node.config['resourceUri'],
    };
  }

  static dynamic _getValueByPath(Map<String, dynamic> data, String path) {
    final parts = path.split('.');
    dynamic current = data;

    for (final part in parts) {
      if (current is Map) {
        current = current[part];
      } else {
        return null;
      }
    }

    return current;
  }

  static void _setValueByPath(
    Map<String, dynamic> data,
    String path,
    dynamic value,
  ) {
    final parts = path.split('.');
    dynamic current = data;

    for (var i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      if (!current.containsKey(part)) {
        current[part] = <String, dynamic>{};
      }
      current = current[part];
    }

    current[parts.last] = value;
  }

  static bool _evaluateCondition(String condition, Map<String, dynamic> data) {
    // Simple condition evaluation
    // In real implementation, use proper expression evaluator
    return true; // Placeholder
  }
}

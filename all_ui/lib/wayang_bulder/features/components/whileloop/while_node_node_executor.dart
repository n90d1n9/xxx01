import '../../flow/cel_expression.dart';
import 'while_loop_node_definition.dart';

class WhileLoopNodeExecutor {
  final WhileLoopNodeDefinition definition;

  WhileLoopNodeExecutor(this.definition);

  Future<Map<String, dynamic>> execute(
    Map<String, dynamic> input,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>) loopBody,
  ) async {
    final results = <Map<String, dynamic>>[];
    var currentData = Map<String, dynamic>.from(input);
    var iterations = 0;
    final startTime = DateTime.now();

    try {
      while (iterations < definition.maxIterations) {
        // Check timeout
        if (definition.timeout != null) {
          final elapsed = DateTime.now().difference(startTime);
          if (elapsed > definition.timeout!) {
            return {
              'completed': false,
              'reason': 'timeout',
              'iterations': iterations,
              'results': results,
              'final_data': currentData,
            };
          }
        }

        // Evaluate condition
        final cel = CELExpression(definition.condition);
        if (!cel.evaluate(currentData)) {
          break; // Condition is false, exit loop
        }

        // Execute loop body
        try {
          currentData = await loopBody(currentData);
          results.add(Map.from(currentData));
          iterations++;
        } catch (e) {
          if (definition.breakOnError) {
            return {
              'completed': false,
              'reason': 'error',
              'error': e.toString(),
              'iterations': iterations,
              'results': results,
              'final_data': currentData,
            };
          }
          // Continue on error
          iterations++;
        }
      }

      return {
        'completed': true,
        'iterations': iterations,
        'results': results,
        'final_data': currentData,
        'max_iterations_reached': iterations >= definition.maxIterations,
      };
    } catch (e) {
      return {
        'completed': false,
        'reason': 'error',
        'error': e.toString(),
        'iterations': iterations,
        'results': results,
        'final_data': currentData,
      };
    }
  }
}

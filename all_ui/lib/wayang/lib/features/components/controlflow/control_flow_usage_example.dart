import '../ifelse/model/ifelse_condition.dart';
import '../ifelse/model/ifelse_node_definition.dart';
import '../ifelse/utils/ifelse_node_execution.dart';
import '../whileloop/while_loop_node_definition.dart';
import '../whileloop/while_node_node_executor.dart';

class ControlFlowUsageExample {
  Future<void> demonstrateIfElse() async {
    // Create if/else node
    final ifElseNode = IfElseNodeDefinition(
      id: 'classifier',
      name: 'Route by Classification',
      description: 'Route queries based on type',
      conditions: [
        IfElseCondition(
          id: 'qa_route',
          expression: 'input.classification == "Q&A"',
          label: 'Q&A Route',
          description: 'Simple questions',
        ),
        IfElseCondition(
          id: 'research_route',
          expression: 'input.classification == "Research"',
          label: 'Research Route',
          description: 'Complex queries',
        ),
        IfElseCondition(
          id: 'urgent_route',
          expression: 'input.priority == "high" && input.confidence > 0.8',
          label: 'Urgent Route',
          description: 'High priority items',
        ),
      ],
      hasElse: true,
    );

    // Execute with sample data
    final executor = IfElseNodeExecutor(ifElseNode);

    final result1 = await executor.execute({
      'classification': 'Q&A',
      'confidence': 0.95,
      'query': 'What is the capital of France?',
    });
    print('Result 1 routes to: ${result1['output_port']}'); // qa_route

    final result2 = await executor.execute({
      'classification': 'Other',
      'confidence': 0.5,
    });
    print('Result 2 routes to: ${result2['output_port']}'); // else
  }

  Future<void> demonstrateWhileLoop() async {
    // Create while loop node
    final whileLoopNode = WhileLoopNodeDefinition(
      id: 'retry_loop',
      name: 'Retry Until Success',
      description: 'Retry operation until successful',
      condition: 'input.attempts < 3 && !input.success',
      maxIterations: 5,
      timeout: const Duration(seconds: 30),
      breakOnError: false,
    );

    // Execute with sample data
    final executor = WhileLoopNodeExecutor(whileLoopNode);

    final result = await executor.execute({'attempts': 0, 'success': false}, (
      data,
    ) async {
      // Simulate retry logic
      await Future.delayed(const Duration(milliseconds: 500));
      data['attempts'] = (data['attempts'] as int) + 1;

      // Simulate success on 3rd attempt
      if (data['attempts'] >= 3) {
        data['success'] = true;
      }

      return data;
    });

    print('Loop completed: ${result['completed']}');
    print('Total iterations: ${result['iterations']}');
    print('Final success: ${result['final_data']['success']}');
  }
}

import '../../../flow/cel_expression.dart';
import '../model/ifelse_node_definition.dart';

class IfElseNodeExecutor {
  final IfElseNodeDefinition definition;

  IfElseNodeExecutor(this.definition);

  Future<Map<String, dynamic>> execute(Map<String, dynamic> input) async {
    for (final condition in definition.conditions) {
      try {
        final cel = CELExpression(condition.expression);
        if (cel.evaluate(input)) {
          return {
            'matched': true,
            'output_port': condition.id,
            'condition': condition.label,
            'data': input,
          };
        }
      } catch (e) {
        throw Exception(
          'Condition evaluation failed for "${condition.label}": $e',
        );
      }
    }

    // No condition matched, use else
    if (definition.hasElse) {
      return {
        'matched': true,
        'output_port': 'else',
        'condition': 'else',
        'data': input,
      };
    }

    // No match and no else
    return {'matched': false, 'output_port': null, 'data': input};
  }
}

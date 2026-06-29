import 'package:flutter/material.dart';

import '../ifelse/model/ifelse_condition.dart';
import '../ifelse/model/ifelse_node_definition.dart';
import '../ifelse/utils/ifelse_node_execution.dart';
import 'while_loop_node_definition.dart';
import 'while_node_node_executor.dart';

class WhileLoopTestDialog extends StatefulWidget {
  final WhileLoopNodeDefinition definition;

  const WhileLoopTestDialog({Key? key, required this.definition})
    : super(key: key);

  @override
  State<WhileLoopTestDialog> createState() => _WhileLoopTestDialogState();
}

class _WhileLoopTestDialogState extends State<WhileLoopTestDialog> {
  final TextEditingController _testInputController = TextEditingController(
    text: '{\n  "counter": 0,\n  "max": 5,\n  "result": []\n}',
  );
  String? _testResult;
  bool _isLoading = false;

  @override
  void dispose() {
    _testInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      title: const Row(
        children: [
          Icon(Icons.loop, color: Colors.purple),
          SizedBox(width: 12),
          Text('Test While Loop', style: TextStyle(color: Colors.white)),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Input (JSON)',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _testInputController,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(16),
                  hintText: '{\n  "counter": 0\n}',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This simulates loop execution by incrementing counter each iteration',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runTest,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isLoading ? 'Running...' : 'Run Test'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            ),
            const SizedBox(height: 16),
            const Text(
              'Test Result',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _testResult == null
                    ? Center(
                        child: Text(
                          'Run test to see results',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Text(
                          _testResult!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _runTest() async {
    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      // Parse JSON input
      final input = _parseJsonInput(_testInputController.text);

      // Execute while loop with simulated body
      final executor = WhileLoopNodeExecutor(widget.definition);
      final result = await executor.execute(input, _simulatedLoopBody);

      // Format result
      final formattedResult = _formatTestResult(result);

      setState(() {
        _testResult = formattedResult;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _simulatedLoopBody(
    Map<String, dynamic> data,
  ) async {
    // Simulate some processing time
    await Future.delayed(const Duration(milliseconds: 100));

    // Increment counter (common pattern)
    if (data.containsKey('counter')) {
      data['counter'] = (data['counter'] as num) + 1;
    }

    // Add timestamp to show iterations
    if (!data.containsKey('iterations_log')) {
      data['iterations_log'] = [];
    }
    (data['iterations_log'] as List).add({
      'iteration': data['counter'],
      'timestamp': DateTime.now().toIso8601String(),
    });

    return data;
  }

  Map<String, dynamic> _parseJsonInput(String input) {
    try {
      final cleaned = input.trim().replaceAll('\n', '').replaceAll(' ', '');
      if (!cleaned.startsWith('{') || !cleaned.endsWith('}')) {
        throw Exception('Input must be a valid JSON object');
      }

      final Map<String, dynamic> result = {};
      final content = cleaned.substring(1, cleaned.length - 1);

      // Handle nested arrays
      if (content.contains('[')) {
        final arrayMatch = RegExp(r'"(\w+)":\[([^\]]*)\]').firstMatch(content);
        if (arrayMatch != null) {
          result[arrayMatch.group(1)!] = [];
          final remaining = content.replaceAll(arrayMatch.group(0)!, '');
          _parseSimpleFields(remaining, result);
        }
      } else {
        _parseSimpleFields(content, result);
      }

      return result;
    } catch (e) {
      throw Exception('Failed to parse JSON: $e');
    }
  }

  void _parseSimpleFields(String content, Map<String, dynamic> result) {
    final pairs = content.split(',').where((s) => s.isNotEmpty);

    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        var key = parts[0].replaceAll('"', '').trim();
        var value = parts[1].replaceAll('"', '').trim();

        if (key.isEmpty) continue;

        final numValue = num.tryParse(value);
        if (numValue != null) {
          result[key] = numValue;
        } else if (value == 'true') {
          result[key] = true;
        } else if (value == 'false') {
          result[key] = false;
        } else if (value.isNotEmpty) {
          result[key] = value;
        }
      }
    }
  }

  String _formatTestResult(Map<String, dynamic> result) {
    final buffer = StringBuffer();

    if (result['completed'] == true) {
      buffer.writeln('✓ Loop completed successfully\n');
    } else {
      buffer.writeln('✗ Loop terminated: ${result['reason']}\n');
      if (result['error'] != null) {
        buffer.writeln('Error: ${result['error']}\n');
      }
    }

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Execution Summary:');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Total Iterations: ${result['iterations']}');

    if (result['max_iterations_reached'] == true) {
      buffer.writeln('Status: Max iterations reached ⚠️');
    } else if (result['completed'] == true) {
      buffer.writeln('Status: Condition became false ✓');
    } else {
      buffer.writeln('Status: ${result['reason']}');
    }

    buffer.writeln('\n═══════════════════════════════════════');
    buffer.writeln('Final Data:');
    buffer.writeln('═══════════════════════════════════════');

    final finalData = result['final_data'] as Map<String, dynamic>;
    finalData.forEach((key, value) {
      if (key != 'iterations_log') {
        buffer.writeln('$key: $value');
      }
    });

    if (result['results'] != null && (result['results'] as List).isNotEmpty) {
      buffer.writeln('\n═══════════════════════════════════════');
      buffer.writeln('Iteration Details:');
      buffer.writeln('═══════════════════════════════════════');

      final results = result['results'] as List;
      for (var i = 0; i < results.length; i++) {
        buffer.writeln('\nIteration ${i + 1}:');
        final iterData = results[i] as Map<String, dynamic>;
        iterData.forEach((key, value) {
          if (key != 'iterations_log') {
            buffer.writeln('  $key: $value');
          }
        });
      }
    }

    buffer.writeln('\n═══════════════════════════════════════');
    buffer.writeln('Explanation:');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Condition: ${widget.definition.condition}');
    buffer.writeln('Max Iterations: ${widget.definition.maxIterations}');
    buffer.writeln('Timeout: ${widget.definition.timeout?.inSeconds}s');
    buffer.writeln('Break on Error: ${widget.definition.breakOnError}');

    return buffer.toString();
  }
}

// ==================== NODE INTEGRATION ====================

/// Factory to create control flow node executors
class ControlFlowNodeFactory {
  static dynamic createExecutor(
    String nodeType,
    Map<String, dynamic> definition,
  ) {
    switch (nodeType) {
      case 'if_else':
        return IfElseNodeExecutor(IfElseNodeDefinition.fromJson(definition));
      case 'while_loop':
        return WhileLoopNodeExecutor(
          WhileLoopNodeDefinition.fromJson(definition),
        );
      default:
        throw Exception('Unknown control flow node type: $nodeType');
    }
  }
}

/// Widget to display control flow node in the workflow canvas
class ControlFlowNodeWidget extends StatelessWidget {
  final String nodeType;
  final Map<String, dynamic> definition;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;

  const ControlFlowNodeWidget({
    Key? key,
    required this.nodeType,
    required this.definition,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color nodeColor = nodeType == 'if_else' ? Colors.blue : Colors.purple;
    final IconData nodeIcon = nodeType == 'if_else'
        ? Icons.alt_route
        : Icons.loop;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? nodeColor : Colors.white24,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: nodeColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: nodeColor.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(nodeIcon, color: nodeColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    definition['name'] ?? 'Unnamed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    color: Colors.white70,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onEdit,
                  ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (definition['description'] != null)
                  Text(
                    definition['description'],
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                _buildNodeDetails(),
              ],
            ),
          ),

          // Footer with outputs
          if (nodeType == 'if_else')
            _buildIfElseOutputs()
          else
            _buildWhileLoopOutputs(),
        ],
      ),
    );
  }

  Widget _buildNodeDetails() {
    if (nodeType == 'if_else') {
      final conditions = definition['conditions'] as List? ?? [];
      return Row(
        children: [
          const Icon(Icons.rule, color: Colors.blue, size: 14),
          const SizedBox(width: 6),
          Text(
            '${conditions.length} condition${conditions.length != 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.repeat, color: Colors.purple, size: 14),
              const SizedBox(width: 6),
              Text(
                'Max: ${definition['maxIterations'] ?? 100}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              definition['condition'] ?? '',
              style: const TextStyle(
                color: Colors.purple,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildIfElseOutputs() {
    final conditions = definition['conditions'] as List? ?? [];
    final hasElse = definition['hasElse'] ?? true;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        children: [
          const Text(
            'Outputs:',
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              ...conditions
                  .take(3)
                  .map((c) => _buildOutputChip(c['label'], Colors.blue)),
              if (conditions.length > 3)
                _buildOutputChip('+${conditions.length - 3} more', Colors.blue),
              if (hasElse) _buildOutputChip('else', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhileLoopOutputs() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOutputChip('loop', Colors.purple),
          _buildOutputChip('exit', Colors.green),
        ],
      ),
    );
  }

  Widget _buildOutputChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ==================== USAGE EXAMPLE ====================

/// Example showing how to use control flow nodes in a workflow
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

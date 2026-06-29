import 'package:flutter/material.dart';

import '../model/ifelse_node_definition.dart';
import '../utils/ifelse_node_execution.dart';

class IfElseTestDialog extends StatefulWidget {
  final IfElseNodeDefinition definition;

  const IfElseTestDialog({super.key, required this.definition});

  @override
  State<IfElseTestDialog> createState() => _IfElseTestDialogState();
}

class _IfElseTestDialogState extends State<IfElseTestDialog> {
  final TextEditingController _testInputController = TextEditingController(
    text:
        '{\n  "classification": "Q&A",\n  "confidence": 0.95,\n  "priority": "high"\n}',
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
          Icon(Icons.science, color: Colors.blue),
          SizedBox(width: 12),
          Text(
            'Test If/Else Conditions',
            style: TextStyle(color: Colors.white),
          ),
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
                  hintText: '{\n  "key": "value"\n}',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
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
              label: Text(_isLoading ? 'Testing...' : 'Run Test'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 16),
            const Text(
              'Test Result',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
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

      // Execute if/else
      final executor = IfElseNodeExecutor(widget.definition);
      final result = await executor.execute(input);

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

  Map<String, dynamic> _parseJsonInput(String input) {
    try {
      // Simple JSON parser for testing
      final cleaned = input.trim().replaceAll('\n', '').replaceAll(' ', '');
      if (!cleaned.startsWith('{') || !cleaned.endsWith('}')) {
        throw Exception('Input must be a valid JSON object');
      }

      // For demo purposes, use a simple parser
      // In production, use dart:convert
      final Map<String, dynamic> result = {};
      final content = cleaned.substring(1, cleaned.length - 1);
      final pairs = content.split(',');

      for (final pair in pairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          var key = parts[0].replaceAll('"', '').trim();
          var value = parts[1].replaceAll('"', '').trim();

          // Try to parse as number
          final numValue = num.tryParse(value);
          if (numValue != null) {
            result[key] = numValue;
          } else if (value == 'true') {
            result[key] = true;
          } else if (value == 'false') {
            result[key] = false;
          } else {
            result[key] = value;
          }
        }
      }

      return result;
    } catch (e) {
      throw Exception('Failed to parse JSON: $e');
    }
  }

  String _formatTestResult(Map<String, dynamic> result) {
    final buffer = StringBuffer();
    buffer.writeln('✓ Test completed successfully\n');
    buffer.writeln('Matched: ${result['matched']}');
    buffer.writeln('Output Port: ${result['output_port'] ?? 'none'}');
    buffer.writeln('Condition: ${result['condition'] ?? 'none'}');
    buffer.writeln('\nExplanation:');

    if (result['matched'] == true) {
      if (result['condition'] == 'else') {
        buffer.writeln('No conditions matched, routing to else branch');
      } else {
        buffer.writeln('Condition "${result['condition']}" matched');
        buffer.writeln('Data will be routed to port: ${result['output_port']}');
      }
    } else {
      buffer.writeln('No conditions matched and no else branch configured');
      buffer.writeln('Data will not be routed');
    }

    return buffer.toString();
  }
}

import 'package:flutter/material.dart';

import '../model/guardrail_executor.dart';
import '../model/guardrail_result.dart';
import '../model/guardrail_rule.dart';
import '../model/guardrail_type.dart';

class GuardrailTestDialog extends StatefulWidget {
  final List<GuardrailRule> rules;

  const GuardrailTestDialog({super.key, required this.rules});

  @override
  State<GuardrailTestDialog> createState() => _GuardrailTestDialogState();
}

class _GuardrailTestDialogState extends State<GuardrailTestDialog> {
  final _testInputController = TextEditingController();
  GuardrailResult? _result;
  bool _testing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2D2D2D),
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Guardrails',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _testInputController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Test Input',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'Enter text to test against guardrails...',
                hintStyle: TextStyle(color: Colors.white38),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _testing ? null : _runTest,
              icon: _testing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_testing ? 'Testing...' : 'Run Test'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 24),
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _result!.passed
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _result!.passed ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _result!.passed ? Icons.check_circle : Icons.error,
                      color: _result!.passed ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _result!.passed ? 'PASSED' : 'FAILED',
                            style: TextStyle(
                              color: _result!.passed
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!_result!.passed)
                            Text(
                              '${_result!.violations.length} violation(s) detected',
                              style: const TextStyle(color: Colors.white70),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!_result!.passed && _result!.violations.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Violations:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _result!.violations.length,
                    itemBuilder: (context, index) {
                      final violation = _result!.violations[index];
                      return Card(
                        color: const Color(0xFF1E1E1E),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            Icons.warning,
                            color: _getSeverityColor(violation.severity),
                          ),
                          title: Text(
                            violation.ruleName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            violation.message,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            '${(violation.confidence * 100).toInt()}%',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runTest() async {
    if (_testInputController.text.isEmpty) return;

    setState(() => _testing = true);

    final executor = GuardrailExecutor(widget.rules);
    final result = await executor.check(_testInputController.text);

    setState(() {
      _result = result;
      _testing = false;
    });
  }

  Color _getSeverityColor(GuardrailSeverity severity) {
    switch (severity) {
      case GuardrailSeverity.low:
        return Colors.green;
      case GuardrailSeverity.medium:
        return Colors.yellow;
      case GuardrailSeverity.high:
        return Colors.orange;
      case GuardrailSeverity.critical:
        return Colors.red;
    }
  }
}

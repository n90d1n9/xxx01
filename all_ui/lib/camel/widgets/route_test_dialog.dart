import 'dart:convert';

import 'package:flutter/material.dart';

import '../schema/integration_route.dart';
import '../schema/route_test_suite.dart';
import '../utils/route_test_framework.dart';

class RouteTestDialog extends StatefulWidget {
  final IntegrationRoute route;

  const RouteTestDialog({super.key, required this.route});

  @override
  State<RouteTestDialog> createState() => _RouteTestDialogState();
}

class _RouteTestDialogState extends State<RouteTestDialog> {
  final _testDataController = TextEditingController(
    text: '{\n  "message": "test"\n}',
  );
  RouteExecutionResult? _result;
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Test Route'),
      content: SizedBox(
        width: 800,
        height: 600,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Test Data (JSON):'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _testDataController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(flex: 1, child: _buildResults()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          onPressed: _isRunning ? null : _runTest,
          icon:
              _isRunning
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.play_arrow),
          label: const Text('Run Test'),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_result == null) {
      return const Center(child: Text('Click "Run Test" to start'));
    }

    return ListView(
      children: [
        Card(
          color: _result!.success ? Colors.green[100] : Colors.red[100],
          child: ListTile(
            leading: Icon(
              _result!.success ? Icons.check_circle : Icons.error,
              color: _result!.success ? Colors.green : Colors.red,
            ),
            title: Text(_result!.success ? 'Test Passed' : 'Test Failed'),
            subtitle: Text(
              'Execution time: ${_result!.executionTime.inMilliseconds}ms',
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Execution Steps:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ..._result!.steps.map((step) {
          return Card(
            child: ExpansionTile(
              leading: Icon(
                step.success ? Icons.check : Icons.error,
                color: step.success ? Colors.green : Colors.red,
              ),
              title: Text(step.nodeName),
              subtitle: Text('${step.executionTime.inMilliseconds}ms'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${step.nodeType}'),
                      const SizedBox(height: 8),
                      Text('Message: ${step.message}'),
                      if (step.error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${step.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _runTest() async {
    setState(() => _isRunning = true);

    try {
      final testData = jsonDecode(_testDataController.text);
      final result = await RouteTestFramework.simulateRoute(
        widget.route,
        testData,
      );

      setState(() {
        _result = result;
        _isRunning = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Test failed: $e')));
      setState(() => _isRunning = false);
    }
  }

  @override
  void dispose() {
    _testDataController.dispose();
    super.dispose();
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/execution_step.dart';
import '../model/workflow_execution_step.dart';
import '../schema/workflow/workflow.dart';
import '../state/workflow/workflow_execution_provider.dart';
import '../state/workflow/workflow_provider.dart';
import 'execution_step_card.dart';

class WorkflowTestingPanel extends ConsumerStatefulWidget {
  const WorkflowTestingPanel({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkflowTestingPanel> createState() =>
      _WorkflowTestingPanelState();
}

class _WorkflowTestingPanelState extends ConsumerState<WorkflowTestingPanel> {
  final _inputController = TextEditingController(
    text: '{"input": "test data"}',
  );
  StateNotifierProvider<WorkflowExecutionNotifier, WorkflowExecutionState>?
  _executionProvider;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workflowState = ref.watch(workflowProvider);

    if (workflowState.currentWorkflow == null) {
      return const Center(child: Text('No workflow loaded'));
    }

    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bug_report),
                const SizedBox(width: 8),
                Text(
                  'Workflow Testing',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Input section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Input Data (JSON)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _inputController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: '{"key": "value"}',
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _executeWorkflow(workflowState.currentWorkflow!),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Run Test'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _resetExecution,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          // Execution results
          Expanded(child: _buildExecutionResults()),
        ],
      ),
    );
  }

  Widget _buildExecutionResults() {
    if (_executionProvider == null) {
      return const Center(child: Text('Run a test to see results'));
    }

    final executionState = ref.watch(_executionProvider!);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (executionState.isRunning) ...[
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: executionState.progress),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Progress: ${(executionState.progress * 100).toInt()}%',
            ),
          ),
        ],

        if (executionState.error != null) ...[
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      executionState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (executionState.executionHistory.isNotEmpty) ...[
          Text(
            'Execution History',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...executionState.executionHistory.map((step) {
            return ExecutionStepCard(
              step: step,
              isActive: step.nodeId == executionState.currentNodeId,
            );
          }),
        ],

        if (!executionState.isRunning &&
            executionState.executionHistory.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Execution Complete',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Steps: ${executionState.executionHistory.length}',
                  ),
                  Text(
                    'Total Time: ${_calculateTotalDuration(executionState.executionHistory)}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _executeWorkflow(Workflow workflow) {
    try {
      final inputData = Map<String, dynamic>.from(
        json.decode(_inputController.text) as Map,
      );

      // Create execution provider
      _executionProvider =
          StateNotifierProvider<
            WorkflowExecutionNotifier,
            WorkflowExecutionState
          >((ref) => WorkflowExecutionNotifier(workflow));

      setState(() {});

      // Execute
      Future.microtask(() {
        ref.read(_executionProvider!.notifier).execute(inputData);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid JSON: $e')));
    }
  }

  void _resetExecution() {
    if (_executionProvider != null) {
      ref.read(_executionProvider!.notifier).reset();
    }
  }

  String _calculateTotalDuration(List<ExecutionStep> steps) {
    final total = steps.fold<Duration>(
      Duration.zero,
      (sum, step) => sum + step.duration,
    );
    return '${total.inMilliseconds}ms';
  }
}

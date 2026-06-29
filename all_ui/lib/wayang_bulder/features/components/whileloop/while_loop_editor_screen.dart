import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'while_loop_node_definition.dart';
import 'while_loop_test_dialog.dart';

class WhileLoopEditorScreen extends ConsumerStatefulWidget {
  final WhileLoopNodeDefinition? existingDefinition;

  const WhileLoopEditorScreen({super.key, this.existingDefinition});

  @override
  ConsumerState<WhileLoopEditorScreen> createState() =>
      _WhileLoopEditorScreenState();
}

class _WhileLoopEditorScreenState extends ConsumerState<WhileLoopEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _conditionController;
  late TextEditingController _maxIterationsController;
  late TextEditingController _timeoutController;
  bool _breakOnError = true;

  @override
  void initState() {
    super.initState();

    if (widget.existingDefinition != null) {
      _nameController = TextEditingController(
        text: widget.existingDefinition!.name,
      );
      _descriptionController = TextEditingController(
        text: widget.existingDefinition!.description,
      );
      _conditionController = TextEditingController(
        text: widget.existingDefinition!.condition,
      );
      _maxIterationsController = TextEditingController(
        text: widget.existingDefinition!.maxIterations.toString(),
      );
      _timeoutController = TextEditingController(
        text: widget.existingDefinition!.timeout != null
            ? (widget.existingDefinition!.timeout!.inSeconds).toString()
            : '60',
      );
      _breakOnError = widget.existingDefinition!.breakOnError;
    } else {
      _nameController = TextEditingController(text: 'While Loop');
      _descriptionController = TextEditingController(
        text: 'Loop while condition is true',
      );
      _conditionController = TextEditingController(text: 'input.counter < 10');
      _maxIterationsController = TextEditingController(text: '100');
      _timeoutController = TextEditingController(text: '60');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _conditionController.dispose();
    _maxIterationsController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Row(
          children: [
            Icon(Icons.loop, color: Colors.purple),
            SizedBox(width: 12),
            Text('While Loop Editor', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelp,
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _testLoop,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Test'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildBasicInfo(),
                const SizedBox(height: 24),
                _buildConditionSection(),
                const SizedBox(height: 24),
                _buildSafetySettings(),
              ],
            ),
          ),
          _buildExamplesPanel(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Node Name',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionSection() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.rule, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text(
                  'Loop Condition',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Loop continues while this condition evaluates to true',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _conditionController,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
              ),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'CEL Expression',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'input.counter < 10',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.purple, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The loop will execute the connected nodes repeatedly until this condition becomes false',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetySettings() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.security, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
                  'Safety Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Prevent infinite loops and control execution',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _maxIterationsController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Iterations',
                      labelStyle: TextStyle(color: Colors.white70),
                      hintText: '100',
                      border: OutlineInputBorder(),
                      suffixText: 'iterations',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _timeoutController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Timeout',
                      labelStyle: TextStyle(color: Colors.white70),
                      hintText: '60',
                      border: OutlineInputBorder(),
                      suffixText: 'seconds',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                'Break on Error',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Stop loop execution if an error occurs',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              value: _breakOnError,
              onChanged: (value) => setState(() => _breakOnError = value),
              activeColor: Colors.purple,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamplesPanel() {
    return Container(
      width: 400,
      color: const Color(0xFF252525),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'While Loop Examples',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          _buildExample(
            'Counter Loop',
            'input.counter < 10',
            'Loop until counter reaches 10',
            'Increment counter in loop body',
          ),
          _buildExample(
            'Confidence Check',
            'input.confidence < 0.8',
            'Retry until confidence is high',
            'Useful for iterative refinement',
          ),
          _buildExample(
            'Status Polling',
            'input.status == "processing"',
            'Wait for completion',
            'Check status repeatedly',
          ),
          _buildExample(
            'Queue Processing',
            'input.queue.length > 0',
            'Process all queue items',
            'Loop while queue has items',
          ),
          _buildExample(
            'Retry Logic',
            'input.attempts < 3 && !input.success',
            'Retry up to 3 times',
            'Stop on success or max attempts',
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          const Text(
            'Common Patterns:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildPattern(
            Icons.repeat,
            'Retry Pattern',
            'Attempt operation multiple times until success',
          ),
          _buildPattern(
            Icons.poll,
            'Polling Pattern',
            'Check status repeatedly until complete',
          ),
          _buildPattern(
            Icons.format_list_numbered,
            'Batch Processing',
            'Process items in batches',
          ),
          _buildPattern(
            Icons.refresh,
            'Iterative Refinement',
            'Improve results through iterations',
          ),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Safety First',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Always set reasonable limits:\n'
                  '• Max iterations prevents infinite loops\n'
                  '• Timeout stops runaway execution\n'
                  '• Break on error prevents cascading failures',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExample(
    String title,
    String expression,
    String description,
    String usage,
  ) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                expression,
                style: const TextStyle(
                  color: Colors.purple,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              usage,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPattern(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _testLoop() {
    showDialog(
      context: context,
      builder: (context) => WhileLoopTestDialog(
        definition: WhileLoopNodeDefinition(
          id: 'test',
          name: _nameController.text,
          description: _descriptionController.text,
          condition: _conditionController.text,
          maxIterations: int.tryParse(_maxIterationsController.text) ?? 100,
          timeout: Duration(
            seconds: int.tryParse(_timeoutController.text) ?? 60,
          ),
          breakOnError: _breakOnError,
        ),
      ),
    );
  }

  void _save() {
    if (_nameController.text.isEmpty || _conditionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and condition are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final definition = WhileLoopNodeDefinition(
      id:
          widget.existingDefinition?.id ??
          'while_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      description: _descriptionController.text,
      condition: _conditionController.text,
      maxIterations: int.tryParse(_maxIterationsController.text) ?? 100,
      timeout: Duration(seconds: int.tryParse(_timeoutController.text) ?? 60),
      breakOnError: _breakOnError,
    );

    Navigator.pop(context, definition);
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'While Loop Help',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What is While Loop?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Execute a sequence of nodes repeatedly while a condition is true. Perfect for:\n'
                '• Retry logic\n'
                '• Status polling\n'
                '• Batch processing\n'
                '• Iterative refinement',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                'How it works:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '1. Check condition before each iteration\n'
                '2. If true, execute loop body (connected nodes)\n'
                '3. Update data based on results\n'
                '4. Repeat until condition is false\n'
                '5. Exit loop and continue workflow',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                'Safety Features:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Max iterations prevents infinite loops\n'
                '• Timeout stops execution after time limit\n'
                '• Break on error halts on first failure\n'
                '• All results are collected and returned',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

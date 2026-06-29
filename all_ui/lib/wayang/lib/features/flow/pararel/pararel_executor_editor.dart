import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../trycatch/pararel_execution_exception.dart';

class ParallelExecutionEditorScreen extends ConsumerStatefulWidget {
  final ParallelExecutionNodeDefinition? existingDefinition;

  const ParallelExecutionEditorScreen({Key? key, this.existingDefinition})
    : super(key: key);

  @override
  ConsumerState<ParallelExecutionEditorScreen> createState() =>
      _ParallelExecutionEditorScreenState();
}

class _ParallelExecutionEditorScreenState
    extends ConsumerState<ParallelExecutionEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _parallelBranchesController;
  late TextEditingController _waitForNController;
  late TextEditingController _branchTimeoutController;
  ParallelWaitStrategy _waitStrategy = ParallelWaitStrategy.all;
  bool _continueOnError = false;

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
      _parallelBranchesController = TextEditingController(
        text: widget.existingDefinition!.parallelBranches.toString(),
      );
      _waitForNController = TextEditingController(
        text: widget.existingDefinition!.waitForN.toString(),
      );
      _branchTimeoutController = TextEditingController(
        text:
            widget.existingDefinition!.branchTimeout?.inSeconds.toString() ??
            '',
      );
      _waitStrategy = widget.existingDefinition!.waitStrategy;
      _continueOnError = widget.existingDefinition!.continueOnError;
    } else {
      _nameController = TextEditingController(text: 'Parallel Execution');
      _descriptionController = TextEditingController(
        text: 'Execute multiple branches concurrently',
      );
      _parallelBranchesController = TextEditingController(text: '2');
      _waitForNController = TextEditingController(text: '1');
      _branchTimeoutController = TextEditingController(text: '30');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Row(
          children: [
            Icon(Icons.call_split, color: Colors.cyan),
            SizedBox(width: 12),
            Text(
              'Parallel Execution Editor',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelp,
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
                _buildWaitStrategy(),
                const SizedBox(height: 24),
                _buildSettings(),
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
            const SizedBox(height: 16),
            TextField(
              controller: _parallelBranchesController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Parallel Branches',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                helperText: 'How many parallel paths to execute',
                helperStyle: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitStrategy() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wait Strategy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose when to continue workflow execution',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...ParallelWaitStrategy.values.map(
              (strategy) => RadioListTile<ParallelWaitStrategy>(
                title: Text(
                  _getStrategyName(strategy),
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _getStrategyDescription(strategy),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                value: strategy,
                groupValue: _waitStrategy,
                onChanged: (value) => setState(() => _waitStrategy = value!),
                activeColor: Colors.cyan,
              ),
            ),
            if (_waitStrategy == ParallelWaitStrategy.n) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _waitForNController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Wait for N branches',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  helperText: 'Continue after this many branches complete',
                  helperStyle: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _branchTimeoutController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Branch Timeout (seconds)',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                helperText: 'Leave empty for no timeout',
                helperStyle: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                'Continue on Error',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Continue even if some branches fail',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              value: _continueOnError,
              onChanged: (value) => setState(() => _continueOnError = value),
              activeColor: Colors.cyan,
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
            'Use Cases',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          _buildUseCase(
            Icons.search,
            'Multi-Source Search',
            'Query multiple databases simultaneously',
            Colors.blue,
          ),
          _buildUseCase(
            Icons.api,
            'API Aggregation',
            'Call multiple APIs in parallel',
            Colors.green,
          ),
          _buildUseCase(
            Icons.analytics,
            'Parallel Analysis',
            'Run multiple ML models concurrently',
            Colors.purple,
          ),
          _buildUseCase(
            Icons.speed,
            'Performance Boost',
            'Speed up independent operations',
            Colors.orange,
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          const Text(
            'Wait Strategies:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildStrategyExample(
            'All',
            'Wait for all branches to complete',
            'Best for: Comprehensive results',
          ),
          _buildStrategyExample(
            'Any',
            'Continue after first completion',
            'Best for: Quick response',
          ),
          _buildStrategyExample(
            'N of M',
            'Continue after N branches complete',
            'Best for: Quorum-based decisions',
          ),
          _buildStrategyExample(
            'Race',
            'First result wins, cancel others',
            'Best for: Fastest response',
          ),
        ],
      ),
    );
  }

  Widget _buildUseCase(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyExample(
    String name,
    String description,
    String bestFor,
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
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(color: Colors.cyan, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              bestFor,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStrategyName(ParallelWaitStrategy strategy) {
    switch (strategy) {
      case ParallelWaitStrategy.all:
        return 'Wait for All';
      case ParallelWaitStrategy.any:
        return 'Wait for Any';
      case ParallelWaitStrategy.n:
        return 'Wait for N';
      case ParallelWaitStrategy.race:
        return 'Race (First Wins)';
    }
  }

  String _getStrategyDescription(ParallelWaitStrategy strategy) {
    switch (strategy) {
      case ParallelWaitStrategy.all:
        return 'Wait for all branches to complete';
      case ParallelWaitStrategy.any:
        return 'Continue after any branch completes';
      case ParallelWaitStrategy.n:
        return 'Continue after N branches complete';
      case ParallelWaitStrategy.race:
        return 'First to complete wins, others cancelled';
    }
  }

  void _save() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final definition = ParallelExecutionNodeDefinition(
      id:
          widget.existingDefinition?.id ??
          'parallel_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      description: _descriptionController.text,
      parallelBranches: int.tryParse(_parallelBranchesController.text) ?? 2,
      waitStrategy: _waitStrategy,
      waitForN: int.tryParse(_waitForNController.text) ?? 1,
      branchTimeout: _branchTimeoutController.text.isNotEmpty
          ? Duration(seconds: int.parse(_branchTimeoutController.text))
          : null,
      continueOnError: _continueOnError,
    );

    Navigator.pop(context, definition);
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Parallel Execution Help',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What is Parallel Execution?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Execute multiple branches simultaneously for better performance. Perfect for:\n'
                '• Querying multiple data sources\n'
                '• Calling multiple APIs\n'
                '• Running parallel analyses\n'
                '• Independent operations',
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
                '1. Split input to N branches\n'
                '2. Execute all branches concurrently\n'
                '3. Wait based on strategy\n'
                '4. Aggregate results\n'
                '5. Continue workflow',
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _parallelBranchesController.dispose();
    _waitForNController.dispose();
    _branchTimeoutController.dispose();
    super.dispose();
  }
}

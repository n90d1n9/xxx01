import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'retry_strategy.dart';
import 'trycatch_finally_defintion.dart';

class TryCatchFinallyEditorScreen extends ConsumerStatefulWidget {
  final TryCatchFinallyNodeDefinition? existingDefinition;

  const TryCatchFinallyEditorScreen({super.key, this.existingDefinition});

  @override
  ConsumerState<TryCatchFinallyEditorScreen> createState() =>
      _TryCatchFinallyEditorScreenState();
}

class _TryCatchFinallyEditorScreenState
    extends ConsumerState<TryCatchFinallyEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxRetriesController;
  late TextEditingController _retryDelayController;
  late TextEditingController _backoffMultiplierController;
  RetryStrategy _retryStrategy = RetryStrategy.exponentialBackoff;
  bool _executeFinallyOnError = true;

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
      _maxRetriesController = TextEditingController(
        text: widget.existingDefinition!.maxRetries.toString(),
      );
      _retryDelayController = TextEditingController(
        text: widget.existingDefinition!.retryDelay.inSeconds.toString(),
      );
      _backoffMultiplierController = TextEditingController(
        text: widget.existingDefinition!.backoffMultiplier.toString(),
      );
      _retryStrategy = widget.existingDefinition!.retryStrategy;
      _executeFinallyOnError = widget.existingDefinition!.executeFinallyOnError;
    } else {
      _nameController = TextEditingController(text: 'Try-Catch-Finally');
      _descriptionController = TextEditingController(
        text: 'Handle errors with retry logic',
      );
      _maxRetriesController = TextEditingController(text: '3');
      _retryDelayController = TextEditingController(text: '1');
      _backoffMultiplierController = TextEditingController(text: '2.0');
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
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 12),
            Text(
              'Try-Catch-Finally Editor',
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
                _buildRetrySettings(),
                const SizedBox(height: 24),
                _buildFinallySettings(),
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

  Widget _buildRetrySettings() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Retry Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _maxRetriesController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Retries',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                helperText: 'Number of retry attempts before giving up',
                helperStyle: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Retry Strategy',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...RetryStrategy.values.map(
              (strategy) => RadioListTile<RetryStrategy>(
                title: Text(
                  _getStrategyName(strategy),
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _getStrategyDescription(strategy),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                value: strategy,
                groupValue: _retryStrategy,
                onChanged: (value) => setState(() => _retryStrategy = value!),
                activeColor: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _retryDelayController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Base Delay (seconds)',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _backoffMultiplierController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    enabled: _retryStrategy == RetryStrategy.exponentialBackoff,
                    decoration: const InputDecoration(
                      labelText: 'Backoff Multiplier',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinallySettings() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Finally Block',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                'Execute Finally on Error',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Run finally block even if catch block fails',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              value: _executeFinallyOnError,
              onChanged: (value) =>
                  setState(() => _executeFinallyOnError = value),
              activeColor: Colors.red,
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
            Icons.cloud_upload,
            'API Calls',
            'Retry failed API requests with backoff',
            Colors.blue,
          ),
          _buildUseCase(
            Icons.storage,
            'Database Operations',
            'Handle transient database errors',
            Colors.green,
          ),
          _buildUseCase(
            Icons.network_check,
            'Network Operations',
            'Retry on network failures',
            Colors.orange,
          ),
          _buildUseCase(
            Icons.memory,
            'Resource Allocation',
            'Ensure cleanup in finally block',
            Colors.purple,
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          const Text(
            'Retry Strategies:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildStrategyExample(
            'Fixed Delay',
            '1s → 1s → 1s',
            'Same delay between retries',
          ),
          _buildStrategyExample(
            'Exponential Backoff',
            '1s → 2s → 4s → 8s',
            'Exponentially increasing delays',
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
    String timeline,
    String description,
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
              timeline,
              style: const TextStyle(
                color: Colors.red,
                fontFamily: 'monospace',
                fontSize: 12,
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
    );
  }

  String _getStrategyName(RetryStrategy strategy) {
    switch (strategy) {
      case RetryStrategy.none:
        return 'No Retry';
      case RetryStrategy.fixedDelay:
        return 'Fixed Delay';
      case RetryStrategy.exponentialBackoff:
        return 'Exponential Backoff';
      case RetryStrategy.custom:
        return 'Custom';
    }
  }

  String _getStrategyDescription(RetryStrategy strategy) {
    switch (strategy) {
      case RetryStrategy.none:
        return 'No retries, fail immediately';
      case RetryStrategy.fixedDelay:
        return 'Same delay between each retry';
      case RetryStrategy.exponentialBackoff:
        return 'Increasing delays (1s, 2s, 4s, 8s...)';
      case RetryStrategy.custom:
        return 'Custom retry logic';
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

    final definition = TryCatchFinallyNodeDefinition(
      id:
          widget.existingDefinition?.id ??
          'trycatch_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      description: _descriptionController.text,
      maxRetries: int.tryParse(_maxRetriesController.text) ?? 3,
      retryStrategy: _retryStrategy,
      retryDelay: Duration(
        seconds: int.tryParse(_retryDelayController.text) ?? 1,
      ),
      backoffMultiplier:
          double.tryParse(_backoffMultiplierController.text) ?? 2.0,
      executeFinallyOnError: _executeFinallyOnError,
    );

    Navigator.pop(context, definition);
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Try-Catch-Finally Help',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What is Try-Catch-Finally?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Robust error handling with automatic retry logic. Perfect for:\n'
                '• API calls that might fail\n'
                '• Network operations\n'
                '• Database transactions\n'
                '• Resource management',
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
                '1. Try: Execute main logic\n'
                '2. Retry: If fails, retry with strategy\n'
                '3. Catch: Handle final error\n'
                '4. Finally: Cleanup (always runs)',
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
    _maxRetriesController.dispose();
    _retryDelayController.dispose();
    _backoffMultiplierController.dispose();
    super.dispose();
  }
}

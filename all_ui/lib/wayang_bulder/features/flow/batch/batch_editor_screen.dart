import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'batch_processor_node_definition.dart';
import 'batch_trigger.dart';

class BatchProcessorEditorScreen extends ConsumerStatefulWidget {
  final BatchProcessorNodeDefinition? existingDefinition;

  const BatchProcessorEditorScreen({super.key, this.existingDefinition});

  @override
  ConsumerState<BatchProcessorEditorScreen> createState() =>
      _BatchProcessorEditorScreenState();
}

class _BatchProcessorEditorScreenState
    extends ConsumerState<BatchProcessorEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _batchSizeController;
  late TextEditingController _batchTimeoutController;
  late TextEditingController _maxQueueSizeController;
  BatchTrigger _trigger = BatchTrigger.both;
  bool _processPartialBatch = true;

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
      _batchSizeController = TextEditingController(
        text: widget.existingDefinition!.batchSize.toString(),
      );
      _batchTimeoutController = TextEditingController(
        text: widget.existingDefinition!.batchTimeout.inSeconds.toString(),
      );
      _maxQueueSizeController = TextEditingController(
        text: widget.existingDefinition!.maxQueueSize.toString(),
      );
      _trigger = widget.existingDefinition!.trigger;
      _processPartialBatch = widget.existingDefinition!.processPartialBatch;
    } else {
      _nameController = TextEditingController(text: 'Batch Processor');
      _descriptionController = TextEditingController(
        text: 'Process items in batches',
      );
      _batchSizeController = TextEditingController(text: '10');
      _batchTimeoutController = TextEditingController(text: '30');
      _maxQueueSizeController = TextEditingController(text: '1000');
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
            Icon(Icons.layers, color: Colors.amber),
            SizedBox(width: 12),
            Text(
              'Batch Processor Editor',
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
                _buildBatchSettings(),
                const SizedBox(height: 24),
                _buildAdvancedSettings(),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: const TextStyle(),
              decoration: const InputDecoration(
                labelText: 'Node Name',
                labelStyle: TextStyle(),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(),
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchSettings() {
    return Card(
      color: const Color(0xFF2D2D2D),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Batch Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _batchSizeController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Batch Size',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      helperText: 'Items per batch',
                      helperStyle: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _batchTimeoutController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Timeout (seconds)',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      helperText: 'Max wait time',
                      helperStyle: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Trigger Strategy',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...BatchTrigger.values.map(
              (trigger) => RadioListTile<BatchTrigger>(
                title: Text(
                  _getTriggerName(trigger),
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _getTriggerDescription(trigger),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                value: trigger,
                groupValue: _trigger,
                onChanged: (value) => setState(() => _trigger = value!),
                activeColor: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettings() {
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
              controller: _maxQueueSizeController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Queue Size',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                helperText: 'Maximum items in queue',
                helperStyle: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                'Process Partial Batch',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Process batch even if not full when timeout occurs',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              value: _processPartialBatch,
              onChanged: (value) =>
                  setState(() => _processPartialBatch = value),
              activeColor: Colors.amber,
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
            Icons.storage,
            'Database Inserts',
            'Batch multiple records for efficiency',
            Colors.blue,
          ),
          _buildUseCase(
            Icons.email,
            'Email Campaigns',
            'Send emails in batches',
            Colors.green,
          ),
          _buildUseCase(
            Icons.cloud_upload,
            'File Uploads',
            'Upload multiple files together',
            Colors.purple,
          ),
          _buildUseCase(
            Icons.analytics,
            'Log Processing',
            'Process logs in batches',
            Colors.orange,
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          const Text(
            'Performance Benefits:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildBenefit('Reduced API calls', 'Fewer requests = lower costs'),
          _buildBenefit('Better throughput', 'Process more data faster'),
          _buildBenefit('Resource efficiency', 'Optimize resource usage'),
          _buildBenefit('Network efficiency', 'Reduce network overhead'),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.speed, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Performance Tip',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Batch size of 10-100 items typically provides best balance between latency and throughput.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
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

  Widget _buildBenefit(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
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

  String _getTriggerName(BatchTrigger trigger) {
    switch (trigger) {
      case BatchTrigger.size:
        return 'Size-based';
      case BatchTrigger.time:
        return 'Time-based';
      case BatchTrigger.both:
        return 'Size OR Time';
    }
  }

  String _getTriggerDescription(BatchTrigger trigger) {
    switch (trigger) {
      case BatchTrigger.size:
        return 'Process when batch reaches specified size';
      case BatchTrigger.time:
        return 'Process after timeout, regardless of size';
      case BatchTrigger.both:
        return 'Process on size OR timeout (whichever first)';
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

    final definition = BatchProcessorNodeDefinition(
      id:
          widget.existingDefinition?.id ??
          'batch_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      description: _descriptionController.text,
      batchSize: int.tryParse(_batchSizeController.text) ?? 10,
      batchTimeout: Duration(
        seconds: int.tryParse(_batchTimeoutController.text) ?? 30,
      ),
      trigger: _trigger,
      processPartialBatch: _processPartialBatch,
      maxQueueSize: int.tryParse(_maxQueueSizeController.text) ?? 1000,
    );

    Navigator.pop(context, definition);
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Batch Processor Help',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What is Batch Processor?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Collect and process items in batches for efficiency. Perfect for:\n'
                '• Database bulk operations\n'
                '• API rate limiting\n'
                '• Email campaigns\n'
                '• Log processing',
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
                '1. Items arrive one at a time\n'
                '2. Queued until batch ready\n'
                '3. Batch processed together\n'
                '4. Results returned\n'
                '5. Queue cleared for next batch',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                'Triggers:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Size: Process when full\n'
                '• Time: Process after timeout\n'
                '• Both: First condition wins',
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
    _batchSizeController.dispose();
    _batchTimeoutController.dispose();
    _maxQueueSizeController.dispose();
    super.dispose();
  }
}

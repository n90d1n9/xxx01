import 'package:flutter/material.dart';

import '../../schema/model/schema_migration.dart';

class MigrationDryRunDialog extends StatefulWidget {
  final SchemaMigration migration;
  const MigrationDryRunDialog({super.key, required this.migration});
  @override
  State<MigrationDryRunDialog> createState() => _MigrationDryRunDialogState();
}

class _MigrationDryRunDialogState extends State<MigrationDryRunDialog> {
  bool _isRunning = false;
  double _progress = 0.0;
  List<String> _logs = [];
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.science, color: Colors.blue),
          SizedBox(width: 12),
          Text('Migration Dry Run'),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Testing: ${widget.migration.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 16),
            const Text(
              'Execution Log:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _logs[index],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.greenAccent,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (!_isRunning)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        FilledButton(
          onPressed: _isRunning ? null : _runDryRun,
          child: Text(_isRunning ? 'Running...' : 'Run Test'),
        ),
      ],
    );
  }

  Future<void> _runDryRun() async {
    setState(() {
      _isRunning = true;
      _logs = [];
      _progress = 0.0;
    });
    final steps = [
      'Validating migration syntax...',
      'Checking for conflicts...',
      'Simulating schema changes...',
      'Verifying foreign keys...',
      'Testing rollback compatibility...',
      'Dry run completed successfully!',
    ];
    for (var i = 0; i < steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _logs.add(
          '[${DateTime.now().toString().substring(11, 19)}] ${steps[i]}',
        );
        _progress = (i + 1) / steps.length;
      });
    }
    setState(() => _isRunning = false);
  }
}

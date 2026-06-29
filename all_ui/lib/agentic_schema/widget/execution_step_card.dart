import 'dart:convert';

import 'package:flutter/material.dart';

import '../model/execution_step.dart';

class ExecutionStepCard extends StatelessWidget {
  final ExecutionStep step;
  final bool isActive;

  const ExecutionStepCard({
    super.key,
    required this.step,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isActive
          ? Colors.blue.shade50
          : step.success
          ? Colors.white
          : Colors.red.shade50,
      child: ExpansionTile(
        leading: Icon(
          step.success ? Icons.check_circle : Icons.error,
          color: step.success ? Colors.green : Colors.red,
        ),
        title: Text(
          step.nodeName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${step.duration.inMilliseconds}ms',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Input:', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    json.encode(step.input),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Output:', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    json.encode(step.output),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                if (step.error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Error:',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 4),
                  Text(step.error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../model/workflow_version.dart';

class VersionHistoryCard extends StatelessWidget {
  final WorkflowVersion version;
  final bool isCurrent;
  final VoidCallback onCheckout;

  const VersionHistoryCard({
    super.key,
    required this.version,
    required this.isCurrent,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrent ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: const Icon(Icons.commit),
        title: Text(
          version.message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('by ${version.author}'),
            Text(
              _formatTimestamp(version.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (version.changes.isNotEmpty)
              Text(
                _formatChanges(version.changes),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.green),
              ),
          ],
        ),
        trailing: isCurrent
            ? const Chip(
                label: Text('CURRENT'),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white),
              )
            : IconButton(
                icon: const Icon(Icons.restore),
                tooltip: 'Checkout',
                onPressed: onCheckout,
              ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  String _formatChanges(Map<String, dynamic> changes) {
    if (changes['type'] == 'initial') {
      return 'Initial commit';
    }

    final parts = <String>[];
    if (changes['nodes'] != null) {
      final nodes = changes['nodes'] as Map;
      if (nodes['added'] > 0) parts.add('+${nodes['added']} nodes');
      if (nodes['removed'] > 0) parts.add('-${nodes['removed']} nodes');
      if (nodes['modified'] > 0) parts.add('~${nodes['modified']} nodes');
    }

    return parts.isEmpty ? 'No changes' : parts.join(', ');
  }
}

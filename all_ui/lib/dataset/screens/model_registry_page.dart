import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job_status.dart';
import '../states/provider.dart';
import '../widgets/status_badge.dart';

class ModelRegistryPage extends ConsumerWidget {
  const ModelRegistryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Registry'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage all your trained models',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _RegistryStatCard(
                    icon: Icons.inventory_2,
                    label: 'Total Models',
                    value: '12',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RegistryStatCard(
                    icon: Icons.rocket_launch,
                    label: 'Deployed',
                    value: '5',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RegistryStatCard(
                    icon: Icons.storage,
                    label: 'Total Size',
                    value: '42 GB',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RegistryStatCard(
                    icon: Icons.trending_up,
                    label: 'This Month',
                    value: '+3',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Models List
            Expanded(
              child: Card(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ModelRegistryItem(
                      name: 'Medical QA',
                      version: 'v2.0',
                      status: 'Deployed',
                      accuracy: 0.94,
                      size: '3.2 GB',
                      deployedAt: '2 hours ago',
                      endpoint: 'https://api.example.com/v1/medical-qa',
                    ),
                    const Divider(),
                    _ModelRegistryItem(
                      name: 'Legal Assistant',
                      version: 'v1.5',
                      status: 'Training',
                      accuracy: null,
                      size: '2.8 GB',
                      deployedAt: null,
                      endpoint: null,
                    ),
                    const Divider(),
                    _ModelRegistryItem(
                      name: 'Code Generator',
                      version: 'v3.0',
                      status: 'Deployed',
                      accuracy: 0.89,
                      size: '4.1 GB',
                      deployedAt: '1 day ago',
                      endpoint: 'https://api.example.com/v1/code-gen',
                    ),
                    const Divider(),
                    _ModelRegistryItem(
                      name: 'Finance Assistant',
                      version: 'v1.0',
                      status: 'Ready',
                      accuracy: 0.91,
                      size: '3.5 GB',
                      deployedAt: null,
                      endpoint: null,
                    ),
                    const Divider(),
                    _ModelRegistryItem(
                      name: 'Customer Support',
                      version: 'v2.5',
                      status: 'Deployed',
                      accuracy: 0.88,
                      size: '3.0 GB',
                      deployedAt: '3 days ago',
                      endpoint: 'https://api.example.com/v1/support',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref.read(selectedTabProvider.notifier).state = 1,
        icon: const Icon(Icons.upload),
        label: const Text('Upload Model'),
      ),
    );
  }
}

class _RegistryStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RegistryStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelRegistryItem extends StatelessWidget {
  final String name;
  final String version;
  final String status;
  final double? accuracy;
  final String size;
  final String? deployedAt;
  final String? endpoint;

  const _ModelRegistryItem({
    required this.name,
    required this.version,
    required this.status,
    required this.accuracy,
    required this.size,
    required this.deployedAt,
    required this.endpoint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Model Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        version,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(size, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),

          // Metrics
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (accuracy != null) ...[
                  Text(
                    'Accuracy',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${(accuracy! * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ] else
                  const Text(
                    'Training in progress...',
                    style: TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(status: _stringToStatus(status)),
                if (deployedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    deployedAt!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (endpoint != null)
                IconButton(
                  icon: const Icon(Icons.link, size: 20),
                  tooltip: 'View Endpoint',
                  onPressed: () => _showEndpointDialog(context, endpoint!),
                ),
              IconButton(
                icon: const Icon(Icons.download, size: 20),
                tooltip: 'Download',
                onPressed: () {},
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 20),
                itemBuilder:
                    (context) => <PopupMenuItem>[
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 18),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'deploy',
                        child: Row(
                          children: [
                            Icon(Icons.rocket_launch, size: 18),
                            SizedBox(width: 8),
                            Text('Deploy'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'compare',
                        child: Row(
                          children: [
                            Icon(Icons.compare, size: 18),
                            SizedBox(width: 8),
                            Text('Compare Versions'),
                          ],
                        ),
                      ),
                      //const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  JobStatus _stringToStatus(String status) {
    switch (status.toLowerCase()) {
      case 'deployed':
        return JobStatus.deployed;
      case 'training':
        return JobStatus.training;
      case 'ready':
        return JobStatus.completed;
      case 'failed':
        return JobStatus.failed;
      default:
        return JobStatus.draft;
    }
  }

  void _showEndpointDialog(BuildContext context, String endpoint) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('API Endpoint'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Endpoint URL:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    endpoint,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Example Request:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    'curl -X POST "$endpoint" \\\n'
                    '  -H "Authorization: Bearer YOUR_KEY" \\\n'
                    '  -H "Content-Type: application/json" \\\n'
                    '  -d \'{"prompt": "Your question here"}\'',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
              ),
            ],
          ),
    );
  }
}

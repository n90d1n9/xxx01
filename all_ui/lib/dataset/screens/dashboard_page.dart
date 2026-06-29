import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Active Pipelines',
                    value: '3',
                    icon: Icons.account_tree,
                    color: Colors.blue,
                    trend: '+2',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Training Jobs',
                    value: '1',
                    icon: Icons.model_training,
                    color: Colors.orange,
                    trend: 'Running',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Models Deployed',
                    value: '5',
                    icon: Icons.rocket_launch,
                    color: Colors.green,
                    trend: '+1',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Total Models',
                    value: '12',
                    icon: Icons.inventory_2,
                    color: Colors.purple,
                    trend: '+3',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ActivityItem(
                    icon: Icons.check_circle,
                    color: Colors.green,
                    title: 'Medical QA Model v2.0 deployed',
                    timestamp: '2 hours ago',
                  ),
                  _ActivityItem(
                    icon: Icons.pending,
                    color: Colors.orange,
                    title: 'Training job "Legal Assistant" started',
                    timestamp: '4 hours ago',
                  ),
                  _ActivityItem(
                    icon: Icons.upload_file,
                    color: Colors.blue,
                    title: 'Dataset "customer_support_v3" prepared',
                    timestamp: '6 hours ago',
                  ),
                  _ActivityItem(
                    icon: Icons.assessment,
                    color: Colors.purple,
                    title: 'Evaluation completed for Finance Model',
                    timestamp: '8 hours ago',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Training Progress',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          _TrainingProgressItem(
                            name: 'Legal Assistant',
                            progress: 0.65,
                            epoch: '2/3',
                          ),
                          const SizedBox(height: 16),
                          _TrainingProgressItem(
                            name: 'Code Generator',
                            progress: 0.32,
                            epoch: '1/3',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.add_circle),
                            title: const Text('New Pipeline'),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.upload_file),
                            title: const Text('Upload Dataset'),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.model_training),
                            title: const Text('Start Training'),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.rocket_launch),
                            title: const Text('Deploy Model'),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(selectedTabProvider.notifier).state = 1;
        },
        icon: const Icon(Icons.add),
        label: const Text('New Pipeline'),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String timestamp;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      trailing: Text(
        timestamp,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
      ),
    );
  }
}

class _TrainingProgressItem extends StatelessWidget {
  final String name;
  final double progress;
  final String epoch;

  const _TrainingProgressItem({
    required this.name,
    required this.progress,
    required this.epoch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: Theme.of(context).textTheme.bodyLarge),
            Text(epoch, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress, minHeight: 8),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}% complete',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
